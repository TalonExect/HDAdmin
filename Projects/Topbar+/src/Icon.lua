-- LOCAL
local tweenService = game:GetService("TweenService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local debris = game:GetService("Debris")
local userInputService = game:GetService("UserInputService")
local httpService = game:GetService("HttpService") -- This is to generate GUIDs
local runService = game:GetService("RunService")
local textService = game:GetService("TextService")
local guiService = game:GetService("GuiService")
local starterGui = game:GetService("StarterGui")
local players = game:GetService("Players")
local player = players.LocalPlayer
local playerGui = player.PlayerGui
local topbarPlusGui = playerGui:WaitForChild("Topbar+")
local activeItems = topbarPlusGui.ActiveItems
local topbarContainer = topbarPlusGui.TopbarContainer
local iconTemplate = topbarContainer["IconContainer"]
local HDAdmin = replicatedStorage:WaitForChild("HDAdmin")
local IconController = require(script.Parent.IconController)
local Signal = require(HDAdmin:WaitForChild("Signal"))
local Maid = require(HDAdmin:WaitForChild("Maid"))
local DEFAULT_THEME = require(script.Parent.Themes.Default)
local THUMB_OFFSET = 55
local Icon = {}
Icon.__index = Icon



-- CONSTRUCTORS
function Icon.new(order, imageId, labelText)
	local self = {}
	setmetatable(self, Icon)

	-- Maids (for autocleanup)
	local maid = Maid.new()
	self._maid = maid
	self._hoveringMaid = maid:give(Maid.new())

	-- These are the GuiObjects that make up the icon
	local instances = {}
	self.instances = instances
	local iconContainer = maid:give(iconTemplate:Clone())
	iconContainer.Visible = true
	iconContainer.Parent = topbarContainer
	instances["iconContainer"] = iconContainer
	instances["iconButton"] = iconContainer.IconButton
	instances["iconImage"] = instances.iconButton.IconImage
	instances["iconLabel"] = instances.iconButton.IconLabel
	instances["iconGradient"] = instances.iconButton.IconGradient
	instances["iconCorner"] = instances.iconButton.IconCorner
	instances["iconOverlay"] = iconContainer.IconOverlay
	instances["iconOverlayCorner"] = instances.iconOverlay.IconOverlayCorner
	instances["noticeFrame"] = instances.iconButton.NoticeFrame
	instances["noticeLabel"] = instances.noticeFrame.NoticeLabel
	instances["captionContainer"] = iconContainer.CaptionContainer
	instances["captionFrame"] = instances.captionContainer.CaptionFrame
	instances["captionLabel"] = instances.captionContainer.CaptionLabel
	instances["captionCorner"] = instances.captionFrame.CaptionCorner
	instances["captionOverlineContainer"] = instances.captionContainer.CaptionOverlineContainer
	instances["captionOverline"] = instances.captionOverlineContainer.CaptionOverline
	instances["captionOverlineCorner"] = instances.captionOverline.CaptionOverlineCorner
	instances["captionVisibilityBlocker"] = instances.captionFrame.CaptionVisibilityBlocker
	instances["captionVisibilityCorner"] = instances.captionVisibilityBlocker.CaptionVisibilityCorner
	instances["tipFrame"] = iconContainer.TipFrame
	instances["tipLabel"] = instances.tipFrame.TipLabel
	instances["tipCorner"] = instances.tipFrame.TipCorner
	instances["dropdownContainer"] = iconContainer.DropdownContainer
	instances["dropdownFrame"] = instances.dropdownContainer.DropdownFrame
	instances["dropdownList"] = instances.dropdownFrame.DropdownList

	-- These determine and describe how instances behave and appear
	self._settings = {
		action = {
			["toggleTransitionInfo"] = {},
			["captionFadeInfo"] = {},
			["tipFadeInfo"] = {},
			["dropdownSlideInfo"] = {},
		},
		toggleable = {
			["iconBackgroundColor"] = {instanceNames = {"iconButton"}, propertyName = "BackgroundColor3"},
			["iconBackgroundTransparency"] = {instanceNames = {"iconButton"}, propertyName = "BackgroundTransparency"},
			["iconCornerRadius"] = {instanceNames = {"iconCorner", "iconOverlayCorner"}, propertyName = "CornerRadius"},
			["iconGradientColor"] = {instanceNames = {"iconGradient"}, propertyName = "Color"},
			["iconGradientRotation"] = {instanceNames = {"iconGradient"}, propertyName = "Rotation"},
			["iconImage"] = {callMethods = {self._updateIconSize}, instanceNames = {"iconImage"}, propertyName = "Image"},
			["iconImageColor"] = {instanceNames = {"iconImage"}, propertyName = "ImageColor3"},
			["iconImageTransparency"] = {instanceNames = {"iconImage"}, propertyName = "ImageTransparency"},
			["iconScale"] = {instanceNames = {"iconButton"}, propertyName = "Size"},
			["iconSize"] = {callMethods = {self._updateIconSize}, instanceNames = {"iconContainer"}, propertyName = "Size"},
			["iconOffset"] = {instanceNames = {"iconButton"}, propertyName = "Position"},
			["iconText"] = {callMethods = {self._updateIconSize}, instanceNames = {"iconLabel"}, propertyName = "Text"},
			["iconTextColor"] = {instanceNames = {"iconLabel"}, propertyName = "TextColor3"},
			["iconFont"] = {instanceNames = {"iconLabel"}, propertyName = "Font"},
			["iconImageYScale"] = {callMethods = {self._updateIconSize}},
			["iconImageRatio"] = {callMethods = {self._updateIconSize}},
			["iconLabelYScale"] = {callMethods = {self._updateIconSize}},
			["noticeCircleColor"] = {instanceNames = {"noticeFrame"}, propertyName = "ImageColor3"},
			["noticeCircleImage"] = {instanceNames = {"noticeFrame"}, propertyName = "Image"},
			["noticeTextColor"] = {instanceNames = {"noticeLabel"}, propertyName = "TextColor3"},
			["noticeImageTransparency"] = {instanceNames = {"noticeFrame"}, propertyName = "ImageTransparency"},
			["noticeTextTransparency"] = {instanceNames = {"noticeLabel"}, propertyName = "TextTransparency"},
			["baseZIndex"] = {callMethods = {self._updateBaseZIndex}},
			["order"] = {callSignals = {self.updated}, instanceNames = {"iconContainer"}, propertyName = "LayoutOrder"},
			["alignment"] = {callSignals = {self.updated}, callMethods = {self._updateDropdown}},
			["iconImageVisible"] = {instanceNames = {"iconImage"}, propertyName = "Visible"},
			["iconImageAnchorPoint"] = {instanceNames = {"iconImage"}, propertyName = "AnchorPoint"},
			["iconImagePosition"] = {instanceNames = {"iconImage"}, propertyName = "Position"},
			["iconImageSize"] = {instanceNames = {"iconImage"}, propertyName = "Size"},
			["iconImageTextXAlignment"] = {instanceNames = {"iconImage"}, propertyName = "TextXAlignment"},
			["iconLabelVisible"] = {instanceNames = {"iconLabel"}, propertyName = "Visible"},
			["iconLabelAnchorPoint"] = {instanceNames = {"iconLabel"}, propertyName = "AnchorPoint"},
			["iconLabelPosition"] = {instanceNames = {"iconLabel"}, propertyName = "Position"},
			["iconLabelSize"] = {instanceNames = {"iconLabel"}, propertyName = "Size"},
			["iconLabelTextXAlignment"] = {instanceNames = {"iconLabel"}, propertyName = "TextXAlignment"},
			["iconLabelTextSize"] = {instanceNames = {"iconLabel"}, propertyName = "TextSize"},
			["noticeFramePosition"] = {instanceNames = {"noticeFrame"}, propertyName = "Position"},
		},
		other = {
			["captionBackgroundColor"] = {instanceNames = {"captionFrame"}, propertyName = "BackgroundColor3"},
			["captionBackgroundTransparency"] = {instanceNames = {"captionFrame"}, propertyName = "BackgroundTransparency", unique = "caption"},
			["captionBlockerTransparency"] = {instanceNames = {"captionVisibilityBlocker"}, propertyName = "BackgroundTransparency", unique = "caption"},
			["captionOverlineColor"] = {instanceNames = {"captionOverline"}, propertyName = "BackgroundColor3"},
			["captionOverlineTransparency"] = {instanceNames = {"captionOverline"}, propertyName = "BackgroundTransparency", unique = "caption"},
			["captionTextColor"] = {instanceNames = {"captionLabel"}, propertyName = "TextColor3"},
			["captionTextTransparency"] = {instanceNames = {"captionLabel"}, propertyName = "TextTransparency", unique = "caption"},
			["captionFont"] = {instanceNames = {"captionLabel"}, propertyName = "Font"},
			["captionCornerRadius"] = {instanceNames = {"captionCorner", "captionOverlineCorner", "captionVisibilityCorner"}, propertyName = "CornerRadius"},
			["tipBackgroundColor"] = {instanceNames = {"tipFrame"}, propertyName = "BackgroundColor3"},
			["tipBackgroundTransparency"] = {instanceNames = {"tipFrame"}, propertyName = "BackgroundTransparency", unique = "tip"},
			["tipTextColor"] = {instanceNames = {"tipLabel"}, propertyName = "TextColor3"},
			["tipTextTransparency"] = {instanceNames = {"tipLabel"}, propertyName = "TextTransparency", unique = "tip"},
			["tipFont"] = {instanceNames = {"tipLabel"}, propertyName = "Font"},
			["tipCornerRadius"] = {instanceNames = {"tipCorner"}, propertyName = "CornerRadius"},
			["dropdownSize"] = {instanceNames = {"dropdownContainer"}, propertyName = "Size", unique = "dropdown"},
			["dropdownCanvasSize"] = {instanceNames = {"dropdownFrame"}, propertyName = "CanvasSize"},
			["dropdownMaxIconsBeforeScroll"] = {callMethods = {self._updateDropdown}},
			["dropdownMinWidth"] = {callMethods = {self._updateDropdown}},
			["dropdownSquareCorners"] = {callMethods = {self._updateDropdown}},
			["dropdownBindToggleToIcon"] = {},
			["dropdownToggleOnLongPress"] = {},
			["dropdownToggleOnRightClick"] = {},
			["dropdownCloseOnTapAway"] = {},
			["dropdownHidePlayerlistOnOverlap"] = {},
			["dropdownListPadding"] = {callMethods = {self._updateDropdown}, instanceNames = {"dropdownList"}, propertyName = "Padding"},
			["dropdownAlignment"] = {callMethods = {self._updateDropdown}},
			["dropdownScrollBarColor"] = {instanceNames = {"dropdownFrame"}, propertyName = "ScrollBarImageColor3"},
			["dropdownScrollBarTransparency"] = {instanceNames = {"dropdownFrame"}, propertyName = "ScrollBarImageTransparency"},
			["dropdownScrollBarThickness"] = {instanceNames = {"dropdownFrame"}, propertyName = "ScrollBarThickness"},
		}
	}
	-- The setting values themselves will be set within _settings
	-- Setup a dictionary to make it quick and easy to reference setting by name
	self._settingsDictionary = {}
	-- Some instances require unique behaviours. These are defined with the 'unique' key
	-- for instance, we only want caption transparency effects to be applied on hovering
	self._uniqueSettings = {}
	self._uniqueSettingsDictionary = {}
	local uniqueBehaviours = {
		["caption"] = function(settingName, instance, propertyName, value)
			local tweenInfo = self:get("captionFadeInfo")
			local newValue = value
			if not self.hovering or self.captionText == nil then
				newValue = 1
			end
			tweenService:Create(instance, tweenInfo, {[propertyName] = newValue}):Play()
		end,
		["tip"] = function(settingName, instance, propertyName, value)
			local tweenInfo = self:get("tipFadeInfo")
			local newValue = value
			if not self.hovering or self.tipText == nil then
				newValue = 1
			end
			tweenService:Create(instance, tweenInfo, {[propertyName] = newValue}):Play()
		end,
		["dropdown"] = function(settingName, instance, propertyName, value)
			local tweenInfo = self:get("dropdownSlideInfo")
			local canvasSize = self:get("dropdownCanvasSize")
			local bindToggleToIcon = self:get("dropdownBindToggleToIcon")
			local hidePlayerlist = self:get("dropdownHidePlayerlistOnOverlap") == true and self:get("alignment") == "right"
			local newValue = value
			local isOpen = true
			local isDeselected = not self.isSelected
			if bindToggleToIcon == false then
				isDeselected = not self.dropdownOpen
			end
			local isSpecialPressing = self._longPressing or self._rightClicking
			if self._tappingAway or (isDeselected and not isSpecialPressing) or (isSpecialPressing and self.dropdownOpen) then 
				local dropdownSize = self:get("dropdownSize")
				local XOffset = (dropdownSize and dropdownSize.X.Offset/1) or 0
				newValue = UDim2.new(0, XOffset, 0, 0)
				canvasSize = UDim2.new(0, 0, 0, 0)
				isOpen = false
			end
			self.dropdownOpen = isOpen
			if #self.dropdownIcons > 0 and isOpen and hidePlayerlist then
				if starterGui:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList) then
					starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
				end
				IconController._bringBackPlayerlist = (IconController._bringBackPlayerlist and IconController._bringBackPlayerlist + 1) or 1
				self._bringBackPlayerlist = true
			elseif self._bringBackPlayerlist and not isOpen and IconController._bringBackPlayerlist then
				IconController._bringBackPlayerlist -= 1
				if IconController._bringBackPlayerlist <= 0 then
					IconController._bringBackPlayerlist = nil
					starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
				end
				self._bringBackPlayerlist = nil
			end
			tweenService:Create(instance, tweenInfo, {[propertyName] = newValue}):Play()
			tweenService:Create(self.instances.dropdownFrame, tweenInfo, {CanvasSize = canvasSize}):Play()
		end,
	}
	for settingsType, settingsDetails in pairs(self._settings) do
		for settingName, settingDetail in pairs(settingsDetails) do
			if settingsType == "toggleable" then
				settingDetail.values = settingDetail.values or {
					deselected = nil,
					selected = nil,
				}
			else
				settingDetail.value = nil
			end
			settingDetail.additionalValues = {}
			settingDetail.type = settingsType
			self._settingsDictionary[settingName] = settingDetail
			--
			local uniqueCat = settingDetail.unique
			if uniqueCat then
				local uniqueCatArray = self._uniqueSettings[uniqueCat] or {}
				table.insert(uniqueCatArray, settingName)
				self._uniqueSettings[uniqueCat] = uniqueCatArray
				self._uniqueSettingsDictionary[settingName] = uniqueBehaviours[uniqueCat]
			end
			--
		end
	end
	
	-- Signals (events)
	self.updated = maid:give(Signal.new())
	self.selected = maid:give(Signal.new())
	self.deselected = maid:give(Signal.new())
	self.hoverStarted = maid:give(Signal.new())
	self.hoverEnded = maid:give(Signal.new())
	self._endNotices = maid:give(Signal.new())

	-- Properties
	self.deselectWhenOtherIconSelected = true
	self.name = ""
	self.isSelected = false
	self.presentOnTopbar = true
	self.enabled = true
	self.hovering = false
	self.tipText = nil
	self.caption = nil
	self.totalNotices = 0
	self.notices = {}
	self.dropdownIcons = {}
	self.menuIcons = {}
	
	-- Private Properties
	self._draggingFinger = false
	self._subIcons = {}
	self._totalSubIcons = 0
	self._updatingIconSize = true
	
	-- Apply start values
	self:setName("UnnamedIcon")
	self:setTheme(DEFAULT_THEME)
	self:setOrder(order)
	self:setImage(imageId)
	self:setLabel(labelText)

	-- Input handlers
	-- Calls deselect/select when the icon is clicked
	instances.iconButton.MouseButton1Click:Connect(function()
		if self._draggingFinger then
			return false
		elseif self.isSelected then
			self:deselect()
			return true
		end
		self:select()
	end)
	instances.iconButton.MouseButton2Click:Connect(function()
		self._rightClicking = true
		if self:get("dropdownToggleOnRightClick") == true then
			self:_update("dropdownSize")
		end
		self._rightClicking = false
	end)

	-- Shows/hides the dark overlay when the icon is presssed/released
	instances.iconButton.MouseButton1Down:Connect(function()
		self:_updateStateOverlay(0.7, Color3.new(0, 0, 0))
	end)
	instances.iconButton.MouseButton1Up:Connect(function()
		self:_updateStateOverlay(0.9, Color3.new(1, 1, 1))
	end)

	-- Tap away
	userInputService.InputBegan:Connect(function(input, touchingAnObject)
		local validTapAwayInputs = {
			[Enum.UserInputType.MouseButton1] = true,
			[Enum.UserInputType.MouseButton2] = true,
			[Enum.UserInputType.MouseButton3] = true,
			[Enum.UserInputType.Touch] = true,
		}
		if self.dropdownOpen and not touchingAnObject and validTapAwayInputs[input.UserInputType] then
			self._tappingAway = true
			if self:get("dropdownCloseOnTapAway") == true then
				self:_update("dropdownSize")
			end
			self._tappingAway = false
		end
	end)
	
	-- hoverStarted and hoverEnded triggers and actions
	-- these are triggered when a mouse enters/leaves the icon with a mouse, is highlighted with
	-- a controller selection box, or dragged over with a touchpad
	self.hoverStarted:Connect(function(x, y)
		self.hovering = true
		self:_updateStateOverlay(0.9, Color3.fromRGB(255, 255, 255))
		if not self.isSelected then
			self:_displayTip(true)
			self:_displayCaption(true)
		end
	end)
	self.hoverEnded:Connect(function()
		self.hovering = false
		self:_updateStateOverlay(1)
		self:_displayTip(false)
		self:_displayCaption(false)
		self._hoveringMaid:clean()
	end)
	instances.iconButton.MouseEnter:Connect(function(x, y) -- Mouse (started)
		self.hoverStarted:Fire(x, y)
	end)
	instances.iconButton.MouseLeave:Connect(function() -- Mouse (ended)
		self.hoverEnded:Fire()
	end)
	instances.iconButton.SelectionGained:Connect(function() -- Controller (started)
		self.hoverStarted:Fire()
	end)
	instances.iconButton.SelectionLost:Connect(function() -- Controller (ended)
		self.hoverEnded:Fire()
	end)
	instances.iconButton.MouseButton1Down:Connect(function() -- TouchPad (started)
		if self._draggingFinger then
			self.hoverStarted:Fire()
		end
		-- Long press check
		local heartbeatConnection
		local releaseConnection
		local longPressTime = 0.7
		local endTick = tick() + longPressTime
		heartbeatConnection = runService.Heartbeat:Connect(function()
			if tick() >= endTick then
				releaseConnection:Disconnect()
				heartbeatConnection:Disconnect()
				self._longPressing = true
				if self:get("dropdownToggleOnLongPress") == true then
					self:_update("dropdownSize")
				end
				self._longPressing = false
			end
		end)
		releaseConnection = instances.iconButton.MouseButton1Up:Connect(function()
			releaseConnection:Disconnect()
			heartbeatConnection:Disconnect()
		end)
	end)
	instances.iconButton.MouseButton1Up:Connect(function() -- TouchPad (ended)
		if self.hovering then
			self.hoverEnded:Fire()
		end
	end)
	if userInputService.TouchEnabled then
		-- This is used to highlight when a mobile/touch device is dragging their finger accross the screen
		-- this is important for determining the hoverStarted and hoverEnded events on mobile
		local dragCount = 0
		userInputService.TouchMoved:Connect(function(touch, touchingAnObject)
			if touchingAnObject then
				return
			end
			self._draggingFinger = true
		end)
		userInputService.TouchEnded:Connect(function()
			self._draggingFinger = false
		end)
	end

	-- Finish
	self._updatingIconSize = false
	self._orderWasSet = (order and true) or nil
	self:_updateIconSize()
	IconController.iconAdded:Fire(self)
	
	return self
end

-- This is the same as Icon.new(), except it adds additional behaviour for certain specified names designed to mimic core icons, such as 'Chat'
function Icon.mimic(coreIconToMimic)
	local iconName = coreIconToMimic.."Mimic"
	local icon = IconController.getIcon(iconName)
	if icon then
		return icon
	end
	icon = Icon.new()
	icon:setName(iconName)

	if coreIconToMimic == "Chat" then
		-- Setup maid and cleanup actioon
		local maid = icon._maid
		icon._fakeChatMaid = maid:give(Maid.new())
		maid.chatMimicCleanup = function()
			starterGui:SetCoreGuiEnabled("Chat", icon.enabled)
		end
		-- Tap into chat module
		local chatMainModule = players.LocalPlayer.PlayerScripts:WaitForChild("ChatScript").ChatMain
		local ChatMain = require(chatMainModule)
		local function displayChatBar(visibility)
			icon.ignoreVisibilityStateChange = true
			ChatMain.CoreGuiEnabled:fire(visibility)
			ChatMain.IsCoreGuiEnabled = false
			ChatMain:SetVisible(visibility)
			icon.ignoreVisibilityStateChange = nil
		end
		local function setIconEnabled(visibility)
			icon.ignoreVisibilityStateChange = true
			ChatMain.CoreGuiEnabled:fire(visibility)
			icon:setEnabled(visibility)
			starterGui:SetCoreGuiEnabled("Chat", false)
			icon:deselect()
			icon.updated:Fire()
			icon.ignoreVisibilityStateChange = nil
		end
		-- Open chat via Slash key
		icon._fakeChatMaid:give(userInputService.InputEnded:connect(function(inputObject, gameProcessedEvent)
			if gameProcessedEvent then
				return "Another menu has priority"
			elseif not(inputObject.KeyCode == Enum.KeyCode.Slash or inputObject.KeyCode == Enum.SpecialKey.ChatHotkey) then
				return "No relavent key pressed"
			elseif ChatMain.IsFocused() then
				return "Chat bar already open"
			elseif not icon.enabled then
				return "Icon disabled"
			end
			ChatMain:FocusChatBar(true)
			icon:select()
		end))
		-- ChatActive
		icon._fakeChatMaid:give(ChatMain.VisibilityStateChanged:connect(function(visibility)
			if not icon.ignoreVisibilityStateChange then
				if visibility == true then
					icon:select()
				else
					icon:deselect()
				end
			end
		end))
		-- Keep when other icons selected
		icon.deselectWhenOtherIconSelected = false
		-- Mimic chat notifications
		icon._fakeChatMaid:give(ChatMain.MessagesChanged:connect(function()
			if ChatMain:GetVisibility() == true then
				return "ChatWindow was open"
			end
			icon:notify(icon.selected)
		end))
		-- Mimic visibility when StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, state) is called
		coroutine.wrap(function()
			runService.Heartbeat:Wait()
			icon._fakeChatMaid:give(ChatMain.CoreGuiEnabled:connect(function(newState)
				if icon.ignoreVisibilityStateChange then
					return "ignoreVisibilityStateChange enabled"
				end
				local topbarEnabled = starterGui:GetCore("TopbarEnabled")
				if topbarEnabled ~= IconController.previousTopbarEnabled then
					return "SetCore was called instead of SetCoreGuiEnabled"
				end
				if not icon.enabled and userInputService:IsKeyDown(Enum.KeyCode.LeftShift) and userInputService:IsKeyDown(Enum.KeyCode.P) then
					icon:setEnabled(true)
				else
					setIconEnabled(newState)
				end
			end))
		end)()
		icon:setOrder(-1)
		icon:setImage("rbxasset://textures/ui/TopBar/chatOff.png", "deselected")
		icon:setImage("rbxasset://textures/ui/TopBar/chatOn.png", "selected")
		icon:setImageYScale(0.625)
		icon.deselected:Connect(function()
			displayChatBar(false)
		end)
		icon.selected:Connect(function()
			displayChatBar(true)
		end)
		setIconEnabled(starterGui:GetCoreGuiEnabled("Chat"))

	end
	return icon
end



-- CORE UTILITY METHODS
function Icon:set(settingName, value, toggleState, setAdditional)
	local settingDetail = self._settingsDictionary[settingName]
	assert(settingDetail ~= nil, ("setting '%s' does not exist"):format(settingName))
	-- Update the settings value
	if type(toggleState) == "string" then
		toggleState = toggleState:lower()
	end
	local previousValue = self:get(settingName, toggleState)
	local settingType = settingDetail.type
	if settingType == "toggleable" then
		local valuesToSet = {}
		if toggleState == "deselected" or toggleState == "selected" then
			table.insert(valuesToSet, toggleState)
		else
			table.insert(valuesToSet, "deselected")
			table.insert(valuesToSet, "selected")
			toggleState = nil
		end
		for i, v in pairs(valuesToSet) do
			settingDetail.values[v] = value
			if setAdditional ~= "_ignorePrevious" then
				settingDetail.additionalValues["previous_"..v] = previousValue
			end
			if type(setAdditional) == "string" then
				settingDetail.additionalValues[setAdditional.."_"..v] = previousValue
			end
		end
	else
		settingDetail.value = value
		if type(setAdditional) == "string" then
			if setAdditional ~= "_ignorePrevious" then
				settingDetail.additionalValues["previous"] = previousValue
			end
			settingDetail.additionalValues[setAdditional] = previousValue
		end
	end
	-- Check previous and new are not the same
	if previousValue == value then
		return self, "Value was already set"
	end
	-- Update appearances of associated instances
	local currentToggleState = self:getToggleState()
	if settingDetail.instanceNames and (currentToggleState == toggleState or toggleState == nil) then
		self:_update(settingName, currentToggleState, true)
	end
	-- Call any methods present
	if settingDetail.callMethods then
		for _, callMethod in pairs(settingDetail.callMethods) do
			callMethod(self, value, toggleState)
		end
	end
	
	-- Call any signals present
	if settingDetail.callSignals then
		for _, callSignal in pairs(settingDetail.callSignals) do
			callSignal:Fire()
		end
	end
	return self
end

function Icon:get(settingName, toggleState, getAdditional)
	local settingDetail = self._settingsDictionary[settingName]
	assert(settingDetail ~= nil, ("setting '%s' does not exist"):format(settingName))
	local settingType = settingDetail.type
	if settingType == "toggleable" then
		toggleState = toggleState or self:getToggleState()
		local additionalValue = type(getAdditional) == "string" and settingDetail.additionalValues[getAdditional.."_"..toggleState]
		return settingDetail.values[toggleState], additionalValue
	end
	local additionalValue = type(getAdditional) == "string" and settingDetail.additionalValues[getAdditional]
	return settingDetail.value, additionalValue
end

function Icon:getToggleState(isSelected)
	isSelected = isSelected or self.isSelected
	return (isSelected and "selected") or "deselected"
end

function Icon:_update(settingName, toggleState, applyInstantly)
	local settingDetail = self._settingsDictionary[settingName]
	assert(settingDetail ~= nil, ("setting '%s' does not exist"):format(settingName))
	toggleState = toggleState or self:getToggleState()
	local value = settingDetail.value or (settingDetail.values and settingDetail.values[toggleState])
	if value == nil then return end
	local tweenInfo = (applyInstantly and TweenInfo.new(0)) or self._settings.action.toggleTransitionInfo.value
	local propertyName = settingDetail.propertyName
	local invalidPropertiesTypes = {
		["string"] = true,
		["NumberSequence"] = true,
		["Text"] = true,
		["EnumItem"] = true,
		["ColorSequence"] = true,
	}
	local uniqueSetting = self._uniqueSettingsDictionary[settingName]
	for _, instanceName in pairs(settingDetail.instanceNames) do
		local instance = self.instances[instanceName]
		local propertyType = typeof(instance[propertyName])
		local cannotTweenProperty = invalidPropertiesTypes[propertyType]
		if uniqueSetting then
			uniqueSetting(settingName, instance, propertyName, value)
		elseif cannotTweenProperty then
			instance[propertyName] = value
		else
			tweenService:Create(instance, tweenInfo, {[propertyName] = value}):Play()
		end
		--
		if settingName == "iconSize" and instance[propertyName] ~= value then
			self.updated:Fire()
		end
		--
	end
end

function Icon:_updateAll(toggleState, applyInstantly)
	for settingName, settingDetail in pairs(self._settingsDictionary) do
		if settingDetail.instanceNames then
			self:_update(settingName, toggleState, applyInstantly)
		end
	end
end

function Icon:_updateStateOverlay(transparency, color)
	local stateOverlay = self.instances.iconOverlay
	stateOverlay.BackgroundTransparency = transparency or 1
	stateOverlay.BackgroundColor3 = color or Color3.new(1, 1, 1)
end

function Icon:setTheme(theme)
	for settingsType, settingsDetails in pairs(theme) do
		if settingsType == "toggleable" then
			for settingName, settingValue in pairs(settingsDetails.deselected) do
				self:set(settingName, settingValue, "both")
			end
			for settingName, settingValue in pairs(settingsDetails.selected) do
				self:set(settingName, settingValue, "selected")
			end
		else
			for settingName, settingValue in pairs(settingsDetails) do
				self:set(settingName, settingValue)
			end
		end
	end
	return self
end

function Icon:setEnabled(bool)
	self.enabled = bool
	self.instances.iconContainer.Visible = bool
	self.updated:Fire()
	return self
end

function Icon:setName(string)
	self.name = string
	self.instances.iconContainer.Name = string
	return self
end

function Icon:select()
	self.isSelected = true
	self:_setToggleItemVisible(true)
	if #self.dropdownIcons > 0 or #self.menuIcons > 0 then
		self:_displayNotice(false)
	end
	self:_updateAll()
	self.selected:Fire()
	return self
end

function Icon:deselect()
	self.isSelected = false
	self:_setToggleItemVisible(false)
	if (#self.dropdownIcons > 0 or #self.menuIcons > 0) and self.totalNotices > 0 then
		self:_displayNotice(true)
	end
	self:_updateAll()
	self.deselected:Fire()
	return self
end

function Icon:notify(clearNoticeEvent, noticeId)
	coroutine.wrap(function()
		if not clearNoticeEvent then
			clearNoticeEvent = self.deselected
		end
		if self._parentIcon then
			self._parentIcon:notify(clearNoticeEvent)
		end
		self:_displayNotice(true)
		
		local notifComplete = Signal.new()
		local endEvent = self._endNotices:Connect(function()
			notifComplete:Fire()
		end)
		local customEvent = clearNoticeEvent:Connect(function()
			notifComplete:Fire()
		end)
		
		noticeId = noticeId or httpService:GenerateGUID(true)
		self.notices[noticeId] = {
			completeSignal = notifComplete,
			clearNoticeEvent = clearNoticeEvent,
		}
		self.totalNotices = self.totalNotices + 1
		self.instances.noticeLabel.Text = (self.totalNotices < 100 and self.totalNotices) or "99+"

		notifComplete:Wait()
		
		endEvent:Disconnect()
		customEvent:Disconnect()
		notifComplete:Disconnect()
		
		self.totalNotices = self.totalNotices - 1
		self.instances.noticeLabel.Text = self.totalNotices
		self.notices[noticeId] = nil
		if self.totalNotices < 1 then
			self:_displayNotice(false)
		end
	end)()
	return self
end

function Icon:_displayNotice(bool)
	local value = (bool and 0) or 1
	self:set("noticeImageTransparency", value)
	self:set("noticeTextTransparency", value)
end

function Icon:clearNotices()
	self._endNotices:Fire()
	return self
end

function Icon:disableStateOverlay(bool)
	if bool == nil then
		bool = true
	end
	local stateOverlay = self.instances.iconOverlay
	stateOverlay.Visible = not bool
	return self
end



-- TOGGLEABLE METHODS
function Icon:setLabel(text, toggleState)
	text = text or ""
	self:set("iconText", text, toggleState)
	return self
end

function Icon:setCornerRadius(scale, offset, toggleState)
	local oldCornerRadius = self.instances.iconCorner.CornerRadius
	local newCornerRadius = UDim.new(scale or oldCornerRadius.Scale, offset or oldCornerRadius.Offset)
	self:set("iconCornerRadius", newCornerRadius, toggleState)
	return self
end

function Icon:setImage(imageId, toggleState)
	local textureId = (tonumber(imageId) and "http://www.roblox.com/asset/?id="..imageId) or imageId or ""
	return self:set("iconImage", textureId, toggleState)
end

function Icon:setOrder(order, toggleState)
	local newOrder = tonumber(order) or 1
	return self:set("order", newOrder, toggleState)
end

function Icon:setLeft(toggleState)
	return self:set("alignment", "left", toggleState)
end

function Icon:setMid(toggleState)
	return self:set("alignment", "mid", toggleState)
end

function Icon:setRight(toggleState)
	return self:set("alignment", "right", toggleState)
end

function Icon:setImageYScale(YScale, toggleState)
	local newYScale = tonumber(YScale) or 0.63
	return self:set("iconImageYScale", newYScale, toggleState)
end

function Icon:setImageRatio(ratio, toggleState)
	local newRatio = tonumber(ratio) or 1
	return self:set("iconImageRatio", newRatio, toggleState)
end

function Icon:setLabelYScale(YScale, toggleState)
	local newYScale = tonumber(YScale) or 0.45
	return self:set("iconLabelYScale", newYScale, toggleState)
end
	
function Icon:setBaseZIndex(ZIndex, toggleState)
	local newBaseZIndex = tonumber(ZIndex) or 1
	return self:set("baseZIndex", newBaseZIndex, toggleState)
end

function Icon:_updateBaseZIndex(baseValue)
	local container = self.instances.iconContainer
	local newBaseValue = tonumber(baseValue) or container.ZIndex
	local difference = newBaseValue - container.ZIndex
	if difference == 0 then return "The baseValue is the same" end
	for _, object in pairs(self.instances) do
		object.ZIndex = object.ZIndex + difference
	end
	return true
end

function Icon:setSize(XOffset, YOffset, toggleState)
	local newXOffset = tonumber(XOffset) or 32
	local newYOffset = tonumber(YOffset) or newXOffset
	return self:set("iconSize", UDim2.new(0, newXOffset, 0, newYOffset), toggleState)
end

function Icon:_updateIconSize(_, toggleState)
	-- This is responsible for handling the appearance and size of the icons label and image, in additon to its own size
	if self._updatingIconSize then return false end
	self._updatingIconSize = true
	
	local X_MARGIN = 12
	local X_GAP = 8

	local values = {
		iconImage = self:get("iconImage", toggleState),
		iconText = self:get("iconText", toggleState),
		iconSize = self:get("iconSize", toggleState),
		iconImageYScale = self:get("iconImageYScale", toggleState),
		iconImageRatio = self:get("iconImageRatio", toggleState),
		iconLabelYScale = self:get("iconLabelYScale", toggleState),
	}

	local iconContainer = self.instances.iconContainer
	local iconLabel = self.instances.iconLabel
	local iconImage = self.instances.iconImage
	local noticeFrame = self.instances.noticeFrame

	-- We calculate the cells dimensions as apposed to reading because there's a possibility the cells dimensions were changed at the exact time and have not yet updated
	-- this essentially saves us from waiting a heartbeat which causes additonal complications
	local cellSizeXOffset = values.iconSize.X.Offset
	local cellSizeXScale = values.iconSize.X.Scale
	local cellWidth = cellSizeXOffset + (cellSizeXScale * iconContainer.Parent.AbsoluteSize.X)
	local minCellWidth = cellWidth
	local maxCellWidth = (cellSizeXScale > 0 and cellWidth) or (cellWidth * 5)
	local cellSizeYOffset = values.iconSize.Y.Offset
	local cellSizeYScale = values.iconSize.Y.Scale
	local cellHeight = cellSizeYOffset + (cellSizeYScale * iconContainer.Parent.AbsoluteSize.Y)
	local labelHeight = cellHeight * values.iconLabelYScale
	local labelWidth = textService:GetTextSize(values.iconText, labelHeight, iconLabel.Font, Vector2.new(10000, labelHeight)).X
	local imageWidth = cellHeight * values.iconImageYScale * values.iconImageRatio
	
	local usingImage = values.iconImage ~= ""
	local usingText = values.iconText ~= ""
	local notifPosYScale = 0.5
	local desiredCellWidth
	
	if usingImage and not usingText then
		notifPosYScale = 0.45
		self:set("iconImageVisible", true, toggleState)
		self:set("iconImageAnchorPoint", Vector2.new(0.5, 0.5), toggleState)
		self:set("iconImagePosition", UDim2.new(0.5, 0, 0.5, 0), toggleState)
		self:set("iconImageSize", UDim2.new(values.iconImageYScale*values.iconImageRatio, 0, values.iconImageYScale, 0), toggleState)
		self:set("iconLabelVisible", false, toggleState)

	elseif not usingImage and usingText then
		desiredCellWidth = labelWidth+(X_MARGIN*2)
		self:set("iconLabelVisible", true, toggleState)
		self:set("iconLabelAnchorPoint", Vector2.new(0, 0.5), toggleState)
		self:set("iconLabelPosition", UDim2.new(0, X_MARGIN, 0.5, 0), toggleState)
		self:set("iconLabelSize", UDim2.new(1, -X_MARGIN*2, values.iconLabelYScale, 0), toggleState)
		self:set("iconLabelTextXAlignment", Enum.TextXAlignment.Center, toggleState)
		self:set("iconImageVisible", false, toggleState)

	elseif usingImage and usingText then
		local labelGap = X_MARGIN + imageWidth + X_GAP
		desiredCellWidth = labelGap + labelWidth + X_MARGIN
		self:set("iconImageVisible", true, toggleState)
		self:set("iconImageAnchorPoint", Vector2.new(0, 0.5), toggleState)
		self:set("iconImagePosition", UDim2.new(0, X_MARGIN, 0.5, 0), toggleState)
		self:set("iconImageSize", UDim2.new(0, imageWidth, values.iconImageYScale, 0), toggleState)
		----
		self:set("iconLabelVisible", true, toggleState)
		self:set("iconLabelAnchorPoint", Vector2.new(0, 0.5), toggleState)
		self:set("iconLabelPosition", UDim2.new(0, labelGap, 0.5, 0), toggleState)
		self:set("iconLabelSize", UDim2.new(1, -labelGap-X_MARGIN, values.iconLabelYScale, 0), toggleState)
		self:set("iconLabelTextXAlignment", Enum.TextXAlignment.Left, toggleState)
	end
	if desiredCellWidth then
		local widthScale = (cellSizeXScale > 0 and cellSizeXScale) or 0
		local widthOffset = (cellSizeXScale > 0 and 0) or math.clamp(desiredCellWidth, minCellWidth, maxCellWidth)
		self:set("iconSize", UDim2.new(widthScale, widthOffset, values.iconSize.Y.Scale, values.iconSize.Y.Offset), toggleState, "_ignorePrevious")
	end
	self:set("iconLabelTextSize", labelHeight, toggleState)
	self:set("noticeFramePosition", UDim2.new(notifPosYScale, 0, 0, -2), toggleState)

	-- Caption
	if self.captionText then
		local CAPTION_X_MARGIN = 6
		local CAPTION_CONTAINER_Y_SIZE_SCALE = 0.8
		local CAPTION_LABEL_Y_SCALE = 0.58
		local captionContainer = self.instances.captionContainer
		local captionLabel = self.instances.captionLabel
		local captionContainerHeight = cellHeight * CAPTION_CONTAINER_Y_SIZE_SCALE
		local captionLabelHeight = captionContainerHeight * CAPTION_LABEL_Y_SCALE
		local labelFont = self:get("captionFont")
		local textWidth = textService:GetTextSize(self.captionText, captionLabelHeight, labelFont, Vector2.new(10000, captionLabelHeight)).X
		captionLabel.TextSize = captionLabelHeight
		captionLabel.Size = UDim2.new(0, textWidth, CAPTION_LABEL_Y_SCALE, 0)
		captionContainer.Size = UDim2.new(0, textWidth + CAPTION_X_MARGIN*2, 0, cellHeight*CAPTION_CONTAINER_Y_SIZE_SCALE)
	end

	self._updatingIconSize = false
end



-- FEATURE METHODS
-- Toggle Item
function Icon:setToggleItem(guiObject)
	if not guiObject:IsA("GuiObject") and not guiObject:IsA("LayerCollector") then
		guiObject = nil
	end
	self.toggleItem = guiObject
	return self
end

function Icon:_setToggleItemVisible(bool)
	local toggleItem = self.toggleItem
	local property = "Visible"
	if not toggleItem then return end
	if toggleItem:IsA("LayerCollector") then
		property = "Enbaled"
	end
	toggleItem[property] = bool
end

-- Tips
function Icon:setTip(text)
	assert(typeof(text) == "string" or text == nil, "Expected string, got "..typeof(text))
	local textSize = textService:GetTextSize(text, 12, Enum.Font.GothamSemibold, Vector2.new(1000, 20-6))
	self.instances.tipLabel.Text = text
	self.instances.tipFrame.Size = UDim2.new(0, textSize.X+6, 0, 20)
	self.instances.tipFrame.Parent = (text and activeItems) or self.instances.iconContainer
	self.tipText = text
	if self.hovering then
		self:_displayTip(true)
	end
	return self
end

function Icon:_displayTip(visibility)
	local newVisibility = visibility
	local tipFrame = self.instances.tipFrame
	if self.tipText == nil then
		return
	elseif userInputService.TouchEnabled and not self._draggingFinger then
		return
	end
	if newVisibility == true then
		-- When the user moves their cursor/finger, update tip to match the position
		local function updateTipPositon(x, y)
			local newX = x
			local newY = y
			local camera = workspace.CurrentCamera
			local viewportSize = camera and camera.ViewportSize
			if userInputService.TouchEnabled then
				--tipFrame.AnchorPoint = Vector2.new(0.5, 0.5)
				local desiredX = newX - tipFrame.Size.X.Offset/2
				local minX = 0
				local maxX = viewportSize.X - tipFrame.Size.X.Offset
				local desiredY = newY + THUMB_OFFSET + 60
				local minY = tipFrame.AbsoluteSize.Y + THUMB_OFFSET + 64 + 3
				local maxY = viewportSize.Y - tipFrame.Size.Y.Offset
				newX = math.clamp(desiredX, minX, maxX)
				newY = math.clamp(desiredY, minY, maxY)
			elseif IconController.controllerModeEnabled then
				local indicator = topbarPlusGui.Indicator
				local newPos = indicator.AbsolutePosition
				newX = newPos.X - tipFrame.Size.X.Offset/2 + indicator.AbsoluteSize.X/2
				newY = newPos.Y + 90
			else
				local desiredX = newX
				local minX = 0
				local maxX = viewportSize.X - tipFrame.Size.X.Offset - 48
				local desiredY = newY
				local minY = tipFrame.Size.Y.Offset+3
				local maxY = viewportSize.Y
				newX = math.clamp(desiredX, minX, maxX)
				newY = math.clamp(desiredY, minY, maxY)
			end
			--local difX = tipFrame.AbsolutePosition.X - tipFrame.Position.X.Offset
			--local difY = tipFrame.AbsolutePosition.Y - tipFrame.Position.Y.Offset
			--local globalX = newX - difX
			--local globalY = newY - difY
			--tipFrame.Position = UDim2.new(0, globalX, 0, globalY-55)
			tipFrame.Position = UDim2.new(0, newX, 0, newY-20)
		end
		local cursorLocation = userInputService:GetMouseLocation()
		if cursorLocation then
			updateTipPositon(cursorLocation.X, cursorLocation.Y)
		end
		self._hoveringMaid:give(self.instances.iconButton.MouseMoved:Connect(updateTipPositon))
	end
	-- Change transparency of relavent tip instances
	for _, settingName in pairs(self._uniqueSettings.tip) do
		self:_update(settingName)
	end
end

-- Captions
function Icon:setCaption(text)
	assert(typeof(text) == "string" or text == nil, "Expected string, got "..typeof(text))
	self.captionText = text
	self.instances.captionLabel.Text = text
	self.instances.captionContainer.Parent = (text and activeItems) or self.instances.iconContainer
	self:_updateIconSize()
	if self.hovering then
		self:_displayCaption(true)
	end
	return self
end

function Icon:_displayCaption(visibility)
	local newVisibility = visibility
	if self.captionText == nil then
		return
	elseif userInputService.TouchEnabled and not self._draggingFinger then
		return
	end
	local yOffset = 8
	if self._draggingFinger then
		yOffset = yOffset + THUMB_OFFSET
	end
	local iconContainer = self.instances.iconContainer
	local captionContainer = self.instances.captionContainer
	local newPos = UDim2.new(0, iconContainer.AbsolutePosition.X+iconContainer.AbsoluteSize.X/2-captionContainer.AbsoluteSize.X/2, 0, iconContainer.AbsolutePosition.Y+(iconContainer.AbsoluteSize.Y*2)+yOffset)
	captionContainer.Position = newPos
	-- Change transparency of relavent caption instances
	for _, settingName in pairs(self._uniqueSettings.caption) do
		self:_update(settingName)
	end
end

-- Join or leave a special feature such as a Dropdown or Menu
function Icon:join(parentIcon, featureName, dontUpdate)
	local newFeatureName = (featureName and featureName:lower()) or "dropdown"
	local beforeName = "before"..featureName:sub(1,1):upper()..featureName:sub(2)
	local parentFrame = parentIcon.instances[featureName.."Frame"]
	self.presentOnTopbar = false
	self._parentIcon = parentIcon
	self.instances.iconContainer.Parent = parentFrame
	for noticeId, noticeDetail in pairs(self.notices) do
		parentIcon:notify(noticeDetail.clearNoticeEvent, noticeId)
	end
	
	if featureName == "dropdown" then
		local squareCorners = self:get("dropdownSquareCorners")
		self:set("iconSize", UDim2.new(1, 0, 0, self:get("iconSize", "deselected").Y.Offset), "deselected", beforeName)
		self:set("iconSize", UDim2.new(1, 0, 0, self:get("iconSize", "selected").Y.Offset), "selected", beforeName)
		if squareCorners then
			self:set("iconCornerRadius", UDim.new(0, 0), "deselected", beforeName)
			self:set("iconCornerRadius", UDim.new(0, 0), "selected", beforeName)
		end
		self:set("captionBlockerTransparency", 0.4, nil, beforeName)
	end
	
	local array = parentIcon[newFeatureName.."Icons"]
	table.insert(array, self)
	if dontUpdate == false then
		parentIcon:_updateDropdown()
	end
end

function Icon:leave()
	local settingsToReset = {"iconSize", "captionBlockerTransparency", "iconCornerRadius"}
	local parentIcon = self._parentIcon
	self.instances.iconContainer.Parent = topbarContainer
	self.presentOnTopbar = true
	local function scanFeature(t, prevReference, updateMethod)
		for i, otherIcon in pairs(t) do
			if otherIcon == self then
				for _, settingName in pairs(settingsToReset) do
					local states = {"deselected", "selected"}
					for _, toggleState in pairs(states) do
						local currentSetting, previousSetting = self:get(settingName, toggleState, prevReference)
						if previousSetting then
							self:set(settingName, previousSetting, toggleState)
						end
					end
				end
				table.remove(t, i)
				updateMethod(parentIcon)
				if #t == 0 then
					self._parentIcon.deselectWhenOtherIconSelected = true
				end
				break
			end
		end
	end
	scanFeature(parentIcon.dropdownIcons, "beforeDropdown", parentIcon._updateDropdown)
	scanFeature(parentIcon.menuIcons, "beforeMenu", parentIcon._updateMenu)
	--
	for noticeId, noticeDetail in pairs(self.notices) do
		local parentIconNoticeDetail = parentIcon.notices[noticeId]
		if parentIconNoticeDetail then
			parentIconNoticeDetail.completeSignal:Fire()
		end
	end
	--
	self._parentIcon = nil
end

-- Dropdowns
function Icon:setDropdown(arrayOfIcons)
	local dropdownFrame = self.instances.dropdownFrame
	self.deselectWhenOtherIconSelected = false
	
	-- Reset any previous icons
	for i, otherIcon in pairs(self.dropdownIcons) do
		otherIcon:leave()
	end

	-- Apply new icons
	for i, otherIcon in pairs(arrayOfIcons) do
		otherIcon:join(self, "dropdown", true)
	end

	-- Update dropdown
	self:_updateDropdown()
end

function Icon:_updateDropdown()
	--print("_updateDropdown! 1", self.name)
	local values = {
		maxIconsBeforeScroll = self:get("dropdownMaxIconsBeforeScroll") or "_NIL",
		minWidth = self:get("dropdownMinWidth") or "_NIL",
		padding = self:get("dropdownListPadding") or "_NIL",
		dropdownAlignment = self:get("dropdownAlignment") or "_NIL",
		iconAlignment = self:get("alignment") or "_NIL",
		scrollBarThickness = self:get("dropdownScrollBarThickness") or "_NIL",
	}
	for k, v in pairs(values) do if v == "_NIL" then return end end
	--print("_updateDropdown! 2", self.name)
	
	local YPadding = values.padding.Offset
	local dropdownContainer = self.instances.dropdownContainer
	local dropdownFrame = self.instances.dropdownFrame
	local dropdownList = self.instances.dropdownList
	local totalIcons = #self.dropdownIcons

	local lastVisibleIconIndex = (totalIcons > values.maxIconsBeforeScroll and values.maxIconsBeforeScroll) or totalIcons
	local newCanvasSizeY = -YPadding
	local newFrameSizeY = 0
	local newMinWidth = values.minWidth
	for i = 1, totalIcons do
		local otherIcon = self.dropdownIcons[i]
		local _, otherIconSize = otherIcon:get("iconSize", nil, "beforeDropdown")
		local increment = otherIconSize.Y.Offset + YPadding
		if i <= lastVisibleIconIndex then
			newFrameSizeY = newFrameSizeY + increment
		end
		if i == totalIcons then
			newFrameSizeY = newFrameSizeY + increment/4
		end
		newCanvasSizeY = newCanvasSizeY + increment
		local otherIconWidth = otherIconSize.X.Offset + 4 + 100 -- the +100 is to allow for notices
		if otherIconWidth > newMinWidth then
			newMinWidth = otherIconWidth
		end
	end

	print("_updateDropdown! STATS", self.name)
	self:set("dropdownCanvasSize", UDim2.new(0, 0, 0, newCanvasSizeY))
	self:set("dropdownSize", UDim2.new(0, newMinWidth, 0, newFrameSizeY))

	-- Set alignment while considering screen bounds
	local dropdownAlignment = values.dropdownAlignment:lower()
	local alignmentDetails = {
		left = {
			AnchorPoint = Vector2.new(0, 0),
			PositionXScale = 0
		},
		mid = {
			AnchorPoint = Vector2.new(0.5, 0),
			PositionXScale = 0.5
		},
		right = {
			AnchorPoint = Vector2.new(0.5, 0),
			PositionXScale = 1,
			FrameAnchorPoint = Vector2.new(0, 0),
			FramePositionXScale = 0,
		}
	}
	local alignmentDetail = alignmentDetails[dropdownAlignment]
	if not alignmentDetail then
		alignmentDetail = alignmentDetails[values.iconAlignment:lower()]
	end
	dropdownContainer.AnchorPoint = alignmentDetail.AnchorPoint
	dropdownContainer.Position = UDim2.new(alignmentDetail.PositionXScale, 0, 1, YPadding+0)
	local thicknessHalf = values.scrollBarThickness/2
	local additionalOffset = (dropdownFrame.VerticalScrollBarPosition == Enum.VerticalScrollBarPosition.Right and thicknessHalf) or -thicknessHalf
	dropdownFrame.AnchorPoint = alignmentDetail.FrameAnchorPoint or alignmentDetail.AnchorPoint
	dropdownFrame.Position = UDim2.new(alignmentDetail.FramePositionXScale or alignmentDetail.PositionXScale, additionalOffset, 0, 0)
end


-- Menus
function Icon:setMenu()
	
end

function Icon:_updateMenu()
	
end



-- DESTROY/CLEANUP METHOD
function Icon:destroy()
	IconController.iconRemoved:Fire(self)
	self:clearNotices()
	self._maid:clean()
end



return Icon