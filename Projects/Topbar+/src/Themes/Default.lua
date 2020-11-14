-- IMPORTANT
-- Do not remove or modify this file (module) at all!
-- The default theme is needed when constructing an icon and when comparing default values
-- against other values.
-- Unlike other themes, the Default theme module may be overwritten during a plugin update
-- if you make any changes yourself.

return {
    
    -- Settings which describe how an item behaves or transitions between states
    action =  {
        toggleTransitionInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        captionFadeInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        tipFadeInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        dropdownSlideInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    },

    -- Settings which describe how an item appears when 'deselected' and 'selected'
    toggleable = {
        -- How items appear normally (i.e. when they're 'deselected')
        deselected = {
            iconBackgroundColor = Color3.fromRGB(0, 0, 0),
            iconBackgroundTransparency = 0.5,
            iconCornerRadius = UDim.new(0.25, 0),
            iconGradientColor = ColorSequence.new(Color3.fromRGB(255, 255, 255)),
            iconGradientRotation = 0,
            iconImage = "",
            iconImageColor =Color3.fromRGB(255, 255, 255),
            iconImageTransparency = 0,
            iconImageYScale = 0.63,
            iconImageRatio = 1,
            iconLabelYScale = 0.45,
            iconScale = UDim2.new(1, 0, 1, 0),
            iconSize = UDim2.new(0, 32, 0, 32),
            iconOffset = UDim2.new(0, 0, 0, 0),
            iconText = "",
            iconTextColor = Color3.fromRGB(255, 255, 255),
            iconFont = Enum.Font.GothamSemibold,
            noticeCircleColor = Color3.fromRGB(255, 255, 255),
            noticeCircleImage = "http://www.roblox.com/asset/?id=4871790969",
            noticeTextColor = Color3.fromRGB(31, 33, 35),
            baseZIndex = 1,
            order = 1,
            alignment = "left",
        },
        -- How items appear after the icon has been clicked (i.e. when they're 'selected')
        -- If a selected value is not specified, it will default to the deselected value
        selected = {
            iconBackgroundColor = Color3.fromRGB(245, 245, 245),
            iconBackgroundTransparency = 0.1,
            iconImageColor = Color3.fromRGB(57, 60, 65),
            iconTextColor = Color3.fromRGB(57, 60, 65),
        }
    },

    -- Settings where toggleState doesn't matter (they have a singular state)
    other = {
        -- Caption settings
        captionBackgroundColor = Color3.fromRGB(0, 0, 0),
        captionBackgroundTransparency = 0.5,
        captionTextColor = Color3.fromRGB(255, 255, 255),
        captionTextTransparency = 0,
        captionFont = Enum.Font.GothamSemibold,
        captionOverlineColor = Color3.fromRGB(0, 170, 255),
        captionOverlineTransparency = 0,
        captionCornerRadius = UDim.new(0.25, 0),
        -- Tip settings
        tipBackgroundColor = Color3.fromRGB(255, 255, 255),
        tipBackgroundTransparency = 0.1,
        tipTextColor = Color3.fromRGB(27, 42, 53),
        tipTextTransparency = 0,
        tipFont = Enum.Font.GothamSemibold,
        tipCornerRadius = UDim.new(0.175, 0),
        -- Dropdown settings
        dropdownAlignment = "auto", -- 'left', 'mid', 'right' or 'auto' (auto is where the dropdown alignment matches the icons alignment)
        dropdownMaxIconsBeforeScroll = 4,
        dropdownMinWidth = 32,
        dropdownSquareCorners = true,
        dropdownBindToggleToIcon = true,
        dropdownToggleOnLongPress = false,
        dropdownToggleOnRightClick = false,
        dropdownCloseOnTapAway = false,
        dropdownListPadding = UDim.new(0, 2),
        dropdownScrollBarColor = Color3.fromRGB(25, 25, 25),
        dropdownScrollBarTransparency = 0.2,
        dropdownScrollBarThickness = 4,
    },
    
}