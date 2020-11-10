-- LOCAL
local tweenService = game:GetService("TweenService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local debris = game:GetService("Debris")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local textService = game:GetService("TextService")
local guiService = game:GetService("GuiService")
local player = game:GetService("Players").LocalPlayer
local playerGui = player.PlayerGui
local topbarPlusGui = playerGui:WaitForChild("Topbar+")
local topbarContainer = topbarPlusGui.TopbarContainer
local iconTemplate = topbarContainer["IconContainer"]
local HDAdmin = replicatedStorage:WaitForChild("HDAdmin")
local Signal = require(HDAdmin:WaitForChild("Signal"))
local Maid = require(HDAdmin:WaitForChild("Maid"))
local DEFAULT_THEME = require(script.Parent.Themes.Default)
local THUMB_OFFSET = 65
local Icon = {}
Icon.__index = Icon



-- CONSTRUCTOR
function Icon.new(name, order, imageId, labelText)
	local self = {}
	setmetatable(self, Icon)

	-- Maids (for autocleanup)
	local maid = Maid.new()
	self._maid = maid
	self._fakeChatMaid = maid:give(Maid.new())
	self._hoveringMaid = maid:give(Maid.new())

	-- These are the GuiObjects that make up the icon
	local instances = {}
	self.instances = instances
	local iconContainer = maid:give(iconTemplate:Clone())
	iconContainer.Name = name
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
	instances["tipFrame"] = iconContainer.TipFrame
	instances["tipLabel"] = instances.tipFrame.TipLabel
	instances["tipCorner"] = instances.tipFrame.TipCorner

	-- These determine and describe how instances behave and appear
	self._settings = {
		action = {
			["toggleTweenInfo"] = {},
			["captionTweenInfo"] = {},
			["tipTweenInfo"] = {},
		},
		toggleable = {
			["iconBackgroundColor"] = {instanceNames = {"iconButton"}, propertyName = "BackgroundColor3"},
			["iconBackgroundTransparency"] = {instanceNames = {"iconButton"}, propertyName = "BackgroundTransparency"},
			["iconCornerRadius"] = {instanceNames = {"iconCorner", "iconOverlayCorner"}, propertyName = "CornerRadius"},
			["iconGradientColor"] = {instanceNames = {"iconGradient"}, propertyName = "Color"},
			["iconGradientRotation"] = {instanceNames = {"iconGradient"}, propertyName = "Rotation"},
			["iconImage"] = {callMethod = self._updateIconSize, instanceNames = {"iconImage"}, propertyName = "Image"},
			["iconImageColor"] = {instanceNames = {"iconImage"}, propertyName = "ImageColor3"},
			["iconImageTransparency"] = {instanceNames = {"iconImage"}, propertyName = "ImageTransparency"},
			["iconScale"] = {instanceNames = {"iconButton"}, propertyName = "Size"},
			["iconSize"] = {callMethod = self._updateIconSize, instanceNames = {"iconContainer"}, propertyName = "Size"},
			["iconOffset"] = {instanceNames = {"iconButton"}, propertyName = "Position"},
			["iconText"] = {callMethod = self._updateIconSize, instanceNames = {"iconLabel"}, propertyName = "Text"},
			["iconTextColor"] = {instanceNames = {"iconLabel"}, propertyName = "TextColor3"},
			["iconFont"] = {instanceNames = {"iconLabel"}, propertyName = "Font"},
			["iconImageYScale"] = {callMethod = self._updateIconSize},
			["iconImageRatio"] = {callMethod = self._updateIconSize},
			["iconLabelYScale"] = {callMethod = self._updateIconSize},
			["noticeCircleColor"] = {instanceNames = {"noticeFrame"}, propertyName = "ImageColor3"},
			["noticeCircleImage"] = {instanceNames = {"noticeFrame"}, propertyName = "Image"},
			["noticeTextColor"] = {instanceNames = {"noticeLabel"}, propertyName = "TextColor3"},
			["baseZIndex"] = {callMethod = self._updateBaseZIndex},
			["order"] = {callSignal = self.updated},
			["alignment"] = {callSignal = self.updated},
		},
		other = {
			["captionBackgroundColor"] = {instanceNames = {"captionFrame"}, propertyName = "BackgroundColor3"},
			["captionBackgroundTransparency"] = {instanceNames = {"captionFrame"}, propertyName = "BackgroundTransparency", unique = "caption"},
			["captionOverlineColor"] = {instanceNames = {"captionOverline"}, propertyName = "BackgroundColor3"},
			["captionOverlineTransparency"] = {instanceNames = {"captionOverline"}, propertyName = "BackgroundTransparency", unique = "caption"},
			["captionTextColor"] = {instanceNames = {"captionLabel"}, propertyName = "TextColor3"},
			["captionTextTransparency"] = {instanceNames = {"captionLabel"}, propertyName = "TextTransparency", unique = "caption"},
			["captionFont"] = {instanceNames = {"captionLabel"}, propertyName = "Font"},
			["captionCornerRadius"] = {instanceNames = {"captionCorner", "captionOverlineCorner"}, propertyName = "CornerRadius"},
			["tipBackgroundColor"] = {instanceNames = {"tipFrame"}, propertyName = "BackgroundColor3"},
			["tipBackgroundTransparency"] = {instanceNames = {"tipFrame"}, propertyName = "BackgroundTransparency", unique = "tip"},
			["tipTextColor"] = {instanceNames = {"tipLabel"}, propertyName = "TextColor3"},
			["tipTextTransparency"] = {instanceNames = {"tipLabel"}, propertyName = "TextTransparency", unique = "tip"},
			["tipFont"] = {instanceNames = {"tipLabel"}, propertyName = "Font"},
			["tipCornerRadius"] = {instanceNames = {"tipCorner", "captionOverlineCorner"}, propertyName = "CornerRadius"},
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
		["caption"] = function(instance, propertyName, value)
			local tweenInfo = self._settings.action.captionTweenInfo.value
			local newValue = value
			if not self.hovering then
				newValue = 1
			end
			tweenService:Create(instance, tweenInfo, {[propertyName] = newValue}):Play()
		end,
		["tip"] = function(instance, propertyName, value)
			local tweenInfo = self._settings.action.tipTweenInfo.value
			local newValue = value
			if not self.hovering then
				newValue = 1
			end
			tweenService:Create(instance, tweenInfo, {[propertyName] = newValue}):Play()
		end
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
	self.name = name
	self.isSelected = false
	self.enabled = true
	self.hovering = false
	self.tipText = nil
	self.caption = nil
	self.notices = 0
	self.deselectWhenOtherIconSelected = true
	
	-- Private Properties
	self._draggingFinger = false
	self._subIcons = {}
	self._totalSubIcons = 0
	self._parentIcons = {}
	self._updatingIconSize = true
	
	-- Apply start values
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

	-- Shows/hides the dark overlay when the icon is presssed/released
	instances.iconButton.MouseButton1Down:Connect(function()
		self:_updateStateOverlay(0.7, Color3.new(0, 0, 0))
	end)
	instances.iconButton.MouseButton1Up:Connect(function()
		self:_updateStateOverlay(0.9, Color3.new(1, 1, 1))
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
	self:_updateIconSize()
	
	return self
end



-- CORE UTILITY METHODS
function Icon:set(settingName, value, toggleState, setAdditional)
	local settingDetail = self._settingsDictionary[settingName]
	assert(settingDetail ~= nil, ("setting '%s' does not exist"):format(settingName))
	-- Check previous and new are not the same
	local previousValue = self:get(settingName, toggleState)
	if previousValue == value then
		return "Value was already set"
	end
	-- Update the settings value
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
			settingDetail.additionalValues["previous_"..v] = value
			if type(setAdditional) == "string" then
				settingDetail.additionalValues[setAdditional.."_"..v] = value
			end
		end
	else
		settingDetail.value = value
		if type(setAdditional) == "string" then
			settingDetail.additionalValues["previous"] = value
			settingDetail.additionalValues[setAdditional] = value
		end
	end
	-- Update appearances of associated instances
	local currentToggleState = self:getToggleState()
	if settingDetail.instanceNames and (currentToggleState == toggleState or toggleState == nil) then
		self:_update(settingName, currentToggleState, true)
	end
	-- Call any methods present
	if settingDetail.callMethod then
		settingDetail.callMethod(self, value)
	end
	
	-- Call any signals present
	if settingDetail.callSignal then
		settingDetail.callSignal:Fire()
	end
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
	local value = settingDetail.value or settingDetail.values[toggleState]
	local tweenInfo = (applyInstantly and TweenInfo.new(0)) or self._settings.action.toggleTweenInfo.value
	local propertyName = settingDetail.propertyName
	local invalidPropertiesTypes = {
		["string"] = true,
		["NumberSequence"] = true,
		["Text"] = true,
		["EnumItem"] = true,
		["ColorSequence"] = true,
		--["Color3"] = true,
		--["BrickColor"] = true,
	}
	local uniqueSetting = self._uniqueSettingsDictionary[settingName]
	for _, instanceName in pairs(settingDetail.instanceNames) do
		local instance = self.instances[instanceName]
		local propertyType = typeof(instance[propertyName])
		local cannotTweenProperty = invalidPropertiesTypes[propertyType]
		if uniqueSetting then
			uniqueSetting(instance, propertyName, value)
		elseif cannotTweenProperty then
			instance[propertyName] = value
		else
			tweenService:Create(instance, tweenInfo, {[propertyName] = value}):Play()
		end
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
end

function Icon:setEnabled(bool)
	self.enabled = bool
	self.instances.iconContainer.Visible = bool
	self.updated:Fire()
end

function Icon:select()
	self.isSelected = true
	self:_setToggleItemVisible(true)
	if self._totalSubIcons > 0 then
		self.instances.noticeFrame.Visible = false
	end
	for subIcon, _ in pairs(self._subIcons) do
		subIcon:setEnabled(true)
	end
	self:_updateAll()
	self.selected:Fire()
end

function Icon:deselect()
	self.isSelected = false
	self:_setToggleItemVisible(false)
	if self._totalSubIcons > 0 and self.notices > 0 then
		self.instances.noticeFrame.Visible = true
	end
	for subIcon, _ in pairs(self._subIcons) do
		subIcon:setEnabled(false)
	end
	self:_updateAll()
	self.deselected:Fire()
end

function Icon:notify(clearNoticeEvent)
	coroutine.wrap(function()
		if not clearNoticeEvent then
			clearNoticeEvent = self.deselected
		end
		for parentIcon, _ in pairs(self._parentIcons) do
			parentIcon:notify(clearNoticeEvent)
		end
		self.notices = self.notices + 1
		self.instances.noticeLabel.Text = (self.notices < 100 and self.notices) or "99+"
		self.instances.noticeFrame.Visible = true
		
		local notifComplete = Signal.new()
		local endEvent = self._endNotices:Connect(function()
			notifComplete:Fire()
		end)
		local customEvent = clearNoticeEvent:Connect(function()
			notifComplete:Fire()
		end)
		
		notifComplete:Wait()
		
		endEvent:Disconnect()
		customEvent:Disconnect()
		notifComplete:Disconnect()
		
		self.notices = self.notices - 1
		self.instances.noticeLabel.Text = self.notices
		if self.notices < 1 then
			self.instances.noticeFrame.Visible = false
		end
	end)()
end

function Icon:clearNotices()
	self._endNotices:Fire()
end

function Icon:disableStateOverlay(bool)
	if bool == nil then
		bool = true
	end
	local stateOverlay = self.instances.iconOverlay
	stateOverlay.Visible = not bool
end



-- TOGGLEABLE METHODS
function Icon:setLabel(text, toggleState)
	text = text or ""
	self:set("iconText", text, toggleState)
end

function Icon:setCornerRadius(scale, offset, toggleState)
	local oldCornerRadius = self.instances.iconCorner.CornerRadius
	local newCornerRadius = UDim.new(scale or oldCornerRadius.Scale, offset or oldCornerRadius.Offset)
	self:set("iconCornerRadius", newCornerRadius, toggleState)
end

function Icon:setImage(imageId, toggleState)
	local textureId = (tonumber(imageId) and "http://www.roblox.com/asset/?id="..imageId) or imageId or ""
	self:set("iconImage", textureId, toggleState)
end

function Icon:setOrder(order, toggleState)
	local newOrder = tonumber(order) or 1
	self:set("order", newOrder, toggleState)
end

function Icon:setLeft(toggleState)
	self:set("alignment", "left", toggleState)
end

function Icon:setMid(toggleState)
	self:set("alignment", "mid", toggleState)
end

function Icon:setRight(toggleState)
	self:set("alignment", "right", toggleState)
end

function Icon:setImageYScale(YScale, toggleState)
	local newYScale = tonumber(YScale) or 0.63
	self:set("iconImageYScale", newYScale, toggleState)
end

function Icon:setImageRatio(ratio, toggleState)
	local newRatio = tonumber(ratio) or 1
	self:set("iconImageRatio", newRatio, toggleState)
end

function Icon:setLabelYScale(YScale, toggleState)
	local newYScale = tonumber(YScale) or 0.45
	self:set("iconLabelYScale", newYScale, toggleState)
end
	
function Icon:setBaseZIndex(ZIndex, toggleState)
	local newBaseZIndex = tonumber(ZIndex) or 1
	self:set("baseZIndex", newBaseZIndex, toggleState)
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
	self:set("iconSize", UDim2.new(0, newXOffset, 0, newYOffset), toggleState)
end

function Icon:_updateIconSize()
	-- This is responsible for handling the appearance and size of the icons label and image, in additon to its own size
	if self._updatingIconSize then return false end
	self._updatingIconSize = true

	local X_MARGIN = 8
	local X_GAP = 8

	local values = {
		iconImage = self:get("iconImage") or "",
		iconText = self:get("iconText") or "",
		iconSize = self:get("iconSize") or "_NIL",
		iconImageYScale = self:get("iconImageYScale") or "_NIL",
		iconImageRatio = self:get("iconImageRatio") or "_NIL",
		iconLabelYScale = self:get("iconLabelYScale") or "_NIL",
	}
	for k, v in pairs(values) do
		if v == "_NIL" then
			return false
		end
	end 

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
		iconImage.Visible = true
		iconImage.AnchorPoint = Vector2.new(0.5, 0.5)
		iconImage.Position = UDim2.new(0.5, 0, 0.5, 0)
		iconImage.Size = UDim2.new(values.iconImageYScale*values.iconImageRatio, 0, values.iconImageYScale, 0)
		iconLabel.Visible = false
		notifPosYScale = 0.45

	elseif not usingImage and usingText then
		desiredCellWidth = labelWidth+(X_MARGIN*2)
		iconLabel.Visible = true
		iconLabel.AnchorPoint = Vector2.new(0, 0.5)
		iconLabel.Position = UDim2.new(0, X_MARGIN, 0.5, 0)
		iconLabel.Size = UDim2.new(1, -X_MARGIN*2, values.iconLabelYScale, 0)
		iconImage.Visible = false

	elseif usingImage and usingText then
		local labelGap = X_MARGIN + imageWidth + X_GAP
		desiredCellWidth = labelGap + labelWidth + X_MARGIN
		iconImage.Visible = true
		iconLabel.Visible = true
		iconImage.AnchorPoint = Vector2.new(0, 0.5)
		iconLabel.AnchorPoint = Vector2.new(0, 0.5)
		iconImage.Position = UDim2.new(0, X_MARGIN, 0.5, 0)
		iconImage.Size = UDim2.new(0, imageWidth, values.iconImageYScale, 0)
		iconLabel.Position = UDim2.new(0, labelGap, 0.5, 0)
		iconLabel.Size = UDim2.new(1, -labelGap-X_MARGIN, values.iconLabelYScale, 0)

	end
	if desiredCellWidth then
		local widthScale = (cellSizeXScale > 0 and cellSizeXScale) or 0
		local widthOffset = (cellSizeXScale > 0 and 0) or math.clamp(desiredCellWidth, minCellWidth, maxCellWidth)
		self:set("iconSize", UDim2.new(widthScale, widthOffset, values.iconSize.Y.Scale, values.iconSize.Y.Offset))
	end

	self._updatingIconSize = false
	self.updated:Fire()
end



-- FEATURE METHODS
-- Toggle Item
function Icon:setToggleItem(guiObject)
	if not guiObject:IsA("GuiObject") and not guiObject:IsA("LayerCollector") then
		guiObject = nil
	end
	self.toggleItem = guiObject
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
	self.tipText = text
	if self.hovering then
		self:_displayTip(true)
	end
end

function Icon:_displayTip(visibility)
	local newVisibility = visibility
	if self.tipText == nil then
		return
	elseif userInputService.TouchEnabled and not self._draggingFinger then
		return
	end
	if newVisibility == true then
		-- When the user moves their cursor/finger, update tip to match the position
		local tipFrame = self.instances.tipFrame
		local function updateTipPositon(x, y)
			local newX, newY
			local camera = workspace.CurrentCamera
			if camera then
				local viewportSize = camera.ViewportSize
				newX = math.clamp(x, 5, viewportSize.X - tipFrame.Size.X.Offset-53)
				newY = math.clamp(y, tipFrame.Size.Y.Offset+3, viewportSize.Y)
			end
			if userInputService.TouchEnabled then
				newX = newX - tipFrame.Size.X.Offset/2
				newY = newY + THUMB_OFFSET + 40
			end
			local difX = tipFrame.AbsolutePosition.X - tipFrame.Position.X.Offset
			local difY = tipFrame.AbsolutePosition.Y - tipFrame.Position.Y.Offset
			local globalX = newX - difX
			local globalY = newY - difY
			tipFrame.Position = UDim2.new(0, globalX, 0, globalY-55)
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
	local sizeMultiplier = math.clamp(((self:get("iconSize").X.Offset or 32)/32),1,2)
	local labelTextSize = 12*sizeMultiplier
	local newTextSize = textService:GetTextSize(text, labelTextSize, Enum.Font.GothamSemibold, Vector2.new(1000,20-6))
	self.instances.captionLabel.TextSize = newTextSize
	self.instances.captionContainer.Size = UDim2.new(0, newTextSize.X+20*sizeMultiplier, 0, 25*sizeMultiplier)
	if self.hovering then
		self:_displayCaption(true)
	end
end

function Icon:_displayCaption(visibility)
	local newVisibility = visibility
	if self.captionText == nil then
		newVisibility = false
	end
	local yOffset = 4
	if self._draggingFinger then
		yOffset = yOffset + THUMB_OFFSET
	end
	local oldPos = self.instances.captionContainer.Position
	local newPos = UDim2.new(oldPos.X.Scale, oldPos.X.Offset, oldPos.Y.Scale, yOffset)
	self.instances.captionContainer.Position = newPos
	-- Change transparency of relavent caption instances
	for _, settingName in pairs(self._uniqueSettings.caption) do
		self:_update(settingName)
	end
end

-- Dropdowns
function Icon:createDropdown(options)
	if self.dropdown then
		self:removeDropdown()
	end
	local DropdownModule = require(script.Parent:WaitForChild("Dropdown"))
	self.dropdown = self._maid:give(DropdownModule.new(self,options))
	return self.dropdown
end

function Icon:removeDropdown()
	if self.dropdown then
		self.dropdown:destroy()
		self.dropdown = nil
	end
end



-- DESTROY/CLEANUP METHOD
function Icon:destroy()
	self:clearNotices()
	self._maid:clean()
	self._fakeChatConnections:clean()
end



return Icon