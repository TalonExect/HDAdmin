-- LOCAL
local starterGui = game:GetService("StarterGui")
local guiService = game:GetService("GuiService")
local hapticService = game:GetService("HapticService")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local IconController = {}
local Icon = require(script.Parent.Icon)
local replicatedStorage = game:GetService("ReplicatedStorage")
local HDAdmin = replicatedStorage:WaitForChild("HDAdmin")
local Signal = require(HDAdmin:WaitForChild("Signal"))
local topbarIcons = {}
local fakeChatName = "_FakeChat"
local forceTopbarDisabled = false
local menuOpen
local topbarUpdating = false
local robloxStupidOffset = 32



-- LOCAL METHODS
local function getTopbarPlusGui()
	local player = game:GetService("Players").LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	local topbarPlusGui = playerGui:WaitForChild("Topbar+")
	return topbarPlusGui
end
local function checkTopbarEnabled()
	local success, bool = xpcall(function()
		return starterGui:GetCore("TopbarEnabled")
	end,function(err)
		--has not been registered yet, but default is that is enabled
		return true	
	end)
	return (success and bool)
end

local function isConsoleMode()
	return guiService:IsTenFootInterface()
end

local function getScaleMultiplier()
	if isConsoleMode() then
		return 3
	else
		return 1.3
	end
end

local function updateIconSize(icon, controllerEnabled)
	local currentSize, previousSize = icon:get("iconSize", nil, "previous")
	if not controllerEnabled then
		return
	end
	local scaleMultiplier = getScaleMultiplier()
	local finalSize = UDim2.new(0, currentSize.X.Offset*scaleMultiplier, 0, currentSize.Y.Offset*scaleMultiplier)
	icon:set("iconSize", finalSize)
end



-- PROPERTIES
IconController.topbarEnabled = true
IconController.forceController = false
IconController.previousTopbarEnabled = checkTopbarEnabled()



-- EVENTS
IconController.iconAdded = Signal.new()
IconController.iconRemoved = Signal.new()



-- CONNECTIONS
local iconCreationCount = 0
IconController.iconAdded:Connect(function(icon)
	topbarIcons[icon] = true
	if IconController.gameTheme then
		icon:setTheme(IconController.gameTheme)
	end
	icon.updated:Connect(function()
		IconController.updateTopbar()
	end)
	-- When this icon is selected, deselect other icons if necessary
	icon.selected:Connect(function()
		local allIcons = IconController.getIcons()
		for _, otherIcon in pairs(allIcons) do
			if icon.deselectWhenOtherIconSelected and otherIcon ~= icon and otherIcon.deselectWhenOtherIconSelected and otherIcon:getToggleState() == "selected" then
				otherIcon:deselect()
			end
		end
	end)
	-- Order by creation if no order specified
	iconCreationCount = iconCreationCount + 1
	if not icon._orderWasSet then
		icon:setOrder(iconCreationCount)
	end
	-- Apply controller view if enabled
	if IconController._isControllerMode() then
		updateIconSize(icon, true)
		icon:setMid()
	end
end)

IconController.iconRemoved:Connect(function(icon)
	topbarIcons[icon] = nil
	icon:setEnabled(false)
	icon:deselect()
	icon.updated:Fire()
end)



-- METHODS
function IconController.setGameTheme(theme)
	IconController.gameTheme = theme
	local icons = IconController.getIcons()
	for _, icon in pairs(icons) do
		icon:setTheme(theme)
	end
end

function IconController.setDisplayOrder(value)
	local topbarPlusGui = getTopbarPlusGui()
	value = tonumber(value) or topbarPlusGui.DisplayOrder
	topbarPlusGui.DisplayOrder = value
end

function IconController.getIcon(name)
	for otherIcon, _ in pairs(topbarIcons) do
		if otherIcon.name == name then
			return otherIcon
		end
	end
	return false
end

function IconController.getIcons()
	local allIcons = {}
	for otherIcon, _ in pairs(topbarIcons) do
		table.insert(allIcons, otherIcon)
	end
	return allIcons
end

-- This is responsible for positioning the topbar icons
function IconController.updateTopbar()
	local gap = 12
	local function getIncrement(otherIcon)
		--local container = otherIcon.instances.iconContainer
		--local sizeX = container.Size.X.Offset
		local iconSize = otherIcon:get("iconSize") or UDim2.new(0, 32, 0, 32)
		local sizeX = iconSize.X.Offset
		local increment = (sizeX + gap)
		return increment
	end
	local function updateIcon()
		if topbarUpdating then -- This prevents the topbar updating and shifting icons more than it needs to
			return false
		end
		topbarUpdating = true
		runService.Heartbeat:Wait()
		topbarUpdating = false
		
		local defaultIncrement = 44
		local alignmentDetails = {
			left = {
				startScale = 0,
				getStartOffset = function() 
					local offset = 104
					if not starterGui:GetCoreGuiEnabled("Chat") then
						offset = offset - defaultIncrement
					end
					return offset
				end,
				records = {}
			},
			mid = {
				startScale = 0.5,
				getStartOffset = function(totalIconX) 
					return -totalIconX/2 + (gap/2)
				end,
				records = {}
			},
			right = {
				startScale = 1,
				getStartOffset = function(totalIconX) 
					local offset = -totalIconX
					if starterGui:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList) or starterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack) or starterGui:GetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu) then
						offset = offset - defaultIncrement
					end
					return offset
				end,
				records = {}
				--reverseSort = true
			},
		}
		for otherIcon, _ in pairs(topbarIcons) do
			if otherIcon.enabled == true then
				table.insert(alignmentDetails[otherIcon:get("alignment")].records, otherIcon)
			end
		end
		for alignment, alignmentInfo in pairs(alignmentDetails) do
			local records = alignmentInfo.records
			if #records > 1 then
				if alignmentInfo.reverseSort then
					table.sort(records, function(a,b) return a:get("order") > b:get("order") end)
				else
					table.sort(records, function(a,b) return a:get("order") < b:get("order") end)
				end
			end
			local totalIconX = 0
			for i, otherIcon in pairs(records) do
				local increment = getIncrement(otherIcon)
				totalIconX = totalIconX + increment
			end
			local offsetX = alignmentInfo.getStartOffset(totalIconX)
			for i, otherIcon in pairs(records) do
				local container = otherIcon.instances.iconContainer
				local increment = getIncrement(otherIcon)
				container.Position = UDim2.new(alignmentInfo.startScale, offsetX, 0, 4)
				offsetX = offsetX + increment
			end
		end
		return true
	end
	coroutine.wrap(function() updateIcon() end)()
end

function IconController.setTopbarEnabled(bool, forceBool)
	if forceBool == nil then
		forceBool = true
	end
	local topbar = getTopbarPlusGui()
	if not topbar then return end
	local indicator = topbar.Indicator
	if forceBool and not bool then
		forceTopbarDisabled = true
	elseif forceBool and bool then
		forceTopbarDisabled = false
	end
	if IconController._isControllerMode() then
		if bool then
			if topbar.TopbarContainer.Visible or forceTopbarDisabled or menuOpen or not checkTopbarEnabled() then return end
			if forceBool then
				indicator.Visible = checkTopbarEnabled()
			else
				if hapticService:IsVibrationSupported(Enum.UserInputType.Gamepad1) and hapticService:IsMotorSupported(Enum.UserInputType.Gamepad1,Enum.VibrationMotor.Small) then
					hapticService:SetMotor(Enum.UserInputType.Gamepad1,Enum.VibrationMotor.Small,1)
					delay(0.2,function()
						pcall(function()
							hapticService:SetMotor(Enum.UserInputType.Gamepad1,Enum.VibrationMotor.Small,0)
						end)
					end)
				end
				topbar.TopbarContainer.Visible = true
				topbar.TopbarContainer:TweenPosition(
					UDim2.new(0,0,0,5 + robloxStupidOffset),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Quad,
					0.1,
					true
				)
				guiService:AddSelectionParent("TopbarPlus",topbar.TopbarContainer)
				guiService.CoreGuiNavigationEnabled = false
				guiService.GuiNavigationEnabled = true
				
				local selectIcon
				local targetOffset = 0
				runService.Heartbeat:Wait()
				local indicatorSizeTrip = 50 --indicator.AbsoluteSize.Y * 2
				for otherIcon, _ in pairs(topbarIcons) do
					local container = otherIcon.instances.iconContainer
					if container.Visible then
						if not selectIcon or otherIcon:get("order") > selectIcon:get("order") then
							selectIcon = otherIcon
						end
					end
					local newTargetOffset = -27 + container.AbsoluteSize.Y + indicatorSizeTrip
					if newTargetOffset > targetOffset then
						targetOffset = newTargetOffset
					end
				end
				if guiService:GetEmotesMenuOpen() then
					guiService:SetEmotesMenuOpen(false)
				end
				if guiService:GetInspectMenuEnabled() then
					guiService:CloseInspectMenu()
				end
				delay(0.15,function()
					guiService.SelectedObject = selectIcon.instances.iconContainer
				end)
				indicator.Image = "rbxassetid://5278151071"
				indicator:TweenPosition(
					UDim2.new(0.5,0,0,targetOffset + robloxStupidOffset),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Quad,
					0.1,
					true
				)
			end
		else
			if forceBool then
				indicator.Visible = false
			else
				indicator.Visible = checkTopbarEnabled()
			end
			if not topbar.TopbarContainer.Visible then return end
			guiService.AutoSelectGuiEnabled = true
			guiService:RemoveSelectionGroup("TopbarPlus")
			topbar.TopbarContainer:TweenPosition(
				UDim2.new(0,0,0,-topbar.TopbarContainer.Size.Y.Offset + robloxStupidOffset),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				0.1,
				true,
				function()
					topbar.TopbarContainer.Visible = false
				end
			)
			indicator.Image = "rbxassetid://5278151556"
			indicator:TweenPosition(
				UDim2.new(0.5,0,0,5),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				0.1,
				true
			)
		end
	else
		local topbarContainer = topbar.TopbarContainer
		if checkTopbarEnabled() then
			topbarContainer.Visible = bool
		else
			topbarContainer.Visible = false
		end
	end
end



-- PRIVATE METHODS
function IconController._isControllerMode()
	return userInputService.GamepadEnabled and (not userInputService.MouseEnabled or IconController.forceController)
end

function IconController._enableControllerMode(bool)
	local topbar = getTopbarPlusGui()
	if not topbar then return end
	local indicator = topbar.Indicator
	local controllerOptionIcon = IconController.getIcon("_TopbarControllerOption")
	if bool then
		topbar.TopbarContainer.Position = UDim2.new(0,0,0,5)
		topbar.TopbarContainer.Visible = false
		local scaleMultiplier = getScaleMultiplier()
		indicator.Position = UDim2.new(0.5,0,0,5)
		indicator.Size = UDim2.new(0, 18*scaleMultiplier, 0, 18*scaleMultiplier)
		indicator.Image = "rbxassetid://5278151556"
		indicator.Visible = checkTopbarEnabled()
		local isConsole = isConsoleMode()
		indicator.Position = UDim2.new(0.5,0,0,5)
		for otherIcon, _ in pairs(topbarIcons) do
			updateIconSize(otherIcon, true)
			otherIcon:setMid()
		end
		if controllerOptionIcon then
			if not userInputService.MouseEnabled then
				controllerOptionIcon:setEnabled(false)
			else
				controllerOptionIcon:setEnabled(true)
			end
		end
	else
		if userInputService.GamepadEnabled and controllerOptionIcon then
			--mouse user but might want to use controller
			controllerOptionIcon:setEnabled(true)
		elseif controllerOptionIcon then
			controllerOptionIcon:setEnabled(false)
		end
		local isConsole = isConsoleMode()
		for otherIcon, _ in pairs(topbarIcons) do
			local currentAlignment, previousAlignment = otherIcon:get("alignment", nil, "previous")
			if previousAlignment then
				otherIcon:set("alignment", previousAlignment)
			end
			local currentSize, previousSize = otherIcon:get("iconSize", nil, "previous")
			if previousSize then
				otherIcon:set("iconSize", previousSize)
			end
		end
		topbar.TopbarContainer.Position = UDim2.new(0,0,0,0)
		topbar.TopbarContainer.Visible = checkTopbarEnabled()
		indicator.Visible = false
	end
end

function IconController._updateDevice()
	if IconController._isControllerMode() then
		for otherIcon, _ in pairs(topbarIcons) do
			otherIcon._isControllerMode = true
		end
		IconController._enableControllerMode(true)
		return
	end
	for otherIcon, _ in pairs(topbarIcons) do
		otherIcon._isControllerMode = false
	end
	IconController._enableControllerMode()
end



-- BEHAVIOUR
-- This is mostly console and fake chat support
coroutine.wrap(function() -- This is required to prevent cicular infinite references
	runService.Heartbeat:Wait()

	--Controller
	IconController._updateDevice()
	userInputService.GamepadConnected:Connect(IconController._updateDevice)
	userInputService.GamepadDisconnected:Connect(IconController._updateDevice)
	userInputService:GetPropertyChangedSignal("MouseEnabled"):Connect(IconController._updateDevice)
	userInputService.InputBegan:Connect(function(input,gpe)
		local topbar = getTopbarPlusGui()
		if not topbar then return end
		if not IconController._isControllerMode() then return end
		if input.KeyCode == Enum.KeyCode.DPadDown then
			if not guiService.SelectedObject and checkTopbarEnabled() then
				IconController.setTopbarEnabled(true,false)
			end
		elseif input.KeyCode == Enum.KeyCode.ButtonB then
			IconController.setTopbarEnabled(false,false)
		end
		input:Destroy()
	end)
	local controllerOptionIcon = Icon.new()
		:setName("_TopbarControllerOption")
		:setOrder(100)
		:setImage("rbxassetid://5278150942")
		:setRight()
		:setEnabled(false)
		:setTip("Controller mode")
	controllerOptionIcon.deselectWhenOtherIconSelected = false
	if not IconController._isControllerMode() and userInputService.GamepadEnabled then
		controllerOptionIcon:setEnabled(true)
	end
	controllerOptionIcon.selected:Connect(function()
		controllerOptionIcon:setTip("Normal mode")
		IconController.forceController = true
		IconController._updateDevice()
	end)
	controllerOptionIcon.deselected:Connect(function()
		controllerOptionIcon:setTip("Controller mode")
		IconController.forceController = false
		IconController._updateDevice()
	end)
	local topbar = getTopbarPlusGui()
	topbar.Indicator.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			IconController.setTopbarEnabled(true,false)
		end
		input:Destroy()
	end)

	-- Mimic the enabling of the topbar when StarterGui:SetCore("TopbarEnabled", state) is called
	local ChatMain = require(players.LocalPlayer.PlayerScripts:WaitForChild("ChatScript").ChatMain)
	ChatMain.CoreGuiEnabled:connect(function()
		local topbarEnabled = checkTopbarEnabled()
		if topbarEnabled == IconController.previousTopbarEnabled then
			IconController.updateTopbar()
			return "SetCoreGuiEnabled was called instead of SetCore"
		end
		IconController.previousTopbarEnabled = topbarEnabled
		if IconController._isControllerMode() then
			IconController.setTopbarEnabled(false,false)
		else
			IconController.setTopbarEnabled(topbarEnabled,false)
		end
		IconController.updateTopbar()
	end)
	IconController.setTopbarEnabled(checkTopbarEnabled(),false)
	
end)()

-- Mimic roblox menu
guiService.MenuClosed:Connect(function()
	menuOpen = false
	if not IconController._isControllerMode() then
		IconController.setTopbarEnabled(IconController.topbarEnabled,false)
	end
end)
guiService.MenuOpened:Connect(function()
	menuOpen = true
	IconController.setTopbarEnabled(false,false)
end)


return IconController