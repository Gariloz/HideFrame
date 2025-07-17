-- HideFrame - Enhanced version with Ace3 interface
-- Removes dragon textures and faction icons from target, focus, and player frames
local HideFrame = LibStub("AceAddon-3.0"):NewAddon("HideFrame", "AceConsole-3.0")

-- Get localization table
local function getL()
    return HideFrame_Locale or {}
end

-- Texture path constant
local TEXTURE_PATH = "Interface\\AddOns\\HideFrame\\Textures\\UI-TargetingFrame"

-- Simple hook function like in original
local function hookTexture(texture)
    if texture then
        hooksecurefunc(texture, "SetTexture", function(self, tex)
            if tex ~= TEXTURE_PATH then
                self:SetTexture(TEXTURE_PATH)
            end
        end)
        texture:SetTexture(TEXTURE_PATH)
    end
end

-- Simple PVP icon hiding
local function hidePVPIcon(iconFrame)
    if iconFrame then
        iconFrame:Hide()
        hooksecurefunc(iconFrame, "Show", function(self)
            self:Hide()
        end)
    end
end

-- Default settings
local defaults = {
    profile = {
        hideTargetDragon = true,
        hideFocusDragon = true,
        hideBossDragon = true,
        hideTargetPVPIcon = true,
        hideFocusPVPIcon = true,
        hidePlayerPVPIcon = true,
    }
}

function HideFrame:OnInitialize()
    -- Initialize database
    self.db = LibStub("AceDB-3.0"):New("HideFrameDB", defaults, true)

    -- Setup config
    self:SetupConfig()

    -- Create main event frame like in original
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_LOGIN")
    frame:SetScript("OnEvent", function()
        HideFrame:ApplyFrameHiding()
    end)
end

function HideFrame:OnEnable()
    -- Apply settings when addon is enabled
    self:ApplyFrameHiding()
end

function HideFrame:ApplyFrameHiding()
    -- Apply target frame hiding
    if self.db.profile.hideTargetDragon then
        hookTexture(TargetFrameTextureFrameTexture)
    end

    -- Apply focus frame hiding
    if self.db.profile.hideFocusDragon then
        hookTexture(FocusFrameTextureFrameTexture)
    end

    -- Apply boss frame hiding
    if self.db.profile.hideBossDragon then
        for i = 1, 5 do
            local bossFrame = _G["Boss"..i.."TargetFrameTextureFrameTexture"]
            if bossFrame then
                hookTexture(bossFrame)
            end
        end
    end

    -- Apply PVP icon hiding
    if self.db.profile.hideTargetPVPIcon then
        hidePVPIcon(TargetFrameTextureFramePVPIcon)
    end
    if self.db.profile.hideFocusPVPIcon then
        hidePVPIcon(FocusFrameTextureFramePVPIcon)
    end
    if self.db.profile.hidePlayerPVPIcon then
        hidePVPIcon(PlayerPVPIcon)
    end
end



-- Setup configuration interface
function HideFrame:SetupConfig()
    local L = getL()

    -- Helper function to create toggle options
    local function createToggle(key, nameKey, descKey, order)
        return {
            type = "toggle",
            name = L[nameKey] or nameKey,
            desc = L[descKey] or descKey,
            get = function() return self.db.profile[key] end,
            set = function(_, value)
                self.db.profile[key] = value
                self:ApplyFrameHiding()
            end,
            order = order,
        }
    end

    local options = {
        type = "group",
        name = "HideFrame",
        args = {
            targetDragon = createToggle("hideTargetDragon", L["Hide Target Dragon"], L["Hides the dragon texture around the target frame"], 1),
            focusDragon = createToggle("hideFocusDragon", L["Hide Focus Dragon"], L["Hides the dragon texture around the focus frame"], 2),
            bossDragon = createToggle("hideBossDragon", L["Hide Boss Dragon"], L["Hides the dragon texture around boss frames"], 3),
            targetPVP = createToggle("hideTargetPVPIcon", L["Hide Target PVP Icon"], L["Hides the faction/PVP icon on the target frame"], 4),
            focusPVP = createToggle("hideFocusPVPIcon", L["Hide Focus PVP Icon"], L["Hides the faction/PVP icon on the focus frame"], 5),
            playerPVP = createToggle("hidePlayerPVPIcon", L["Hide Player PVP Icon"], L["Hides the faction/PVP icon on the player frame"], 6),
        }
    }

    -- Register options
    LibStub("AceConfig-3.0"):RegisterOptionsTable("HideFrame", options)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("HideFrame", "HideFrame")

    -- Add slash commands
    local function openConfig()
        InterfaceOptionsFrame_OpenToCategory("HideFrame")
    end

    self:RegisterChatCommand("hideframe", openConfig)
    self:RegisterChatCommand("hf", openConfig)
end