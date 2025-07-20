-- HideFrame - Улучшенная версия с интерфейсом Ace3
-- Скрывает текстуры драконов и значки фракций с фреймов цели, фокуса и игрока
local HideFrame = LibStub("AceAddon-3.0"):NewAddon("HideFrame", "AceConsole-3.0")

-- Получить таблицу локализации
local function getL()
    return HideFrame_Locale or {}
end

-- Константа пути к текстуре
local TEXTURE_PATH = "Interface\\AddOns\\HideFrame\\Textures\\UI-TargetingFrame"

-- Простая функция хука как в оригинале
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

-- Простое скрытие PVP иконки
local function hidePVPIcon(iconFrame)
    if iconFrame then
        iconFrame:Hide()
        hooksecurefunc(iconFrame, "Show", function(self)
            self:Hide()
        end)
    end
end

-- Настройки по умолчанию
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
    -- Инициализация базы данных
    self.db = LibStub("AceDB-3.0"):New("HideFrameDB", defaults, true)

    -- Настройка конфигурации
    self:SetupConfig()

    -- Создание основного фрейма событий как в оригинале
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_LOGIN")
    frame:SetScript("OnEvent", function()
        HideFrame:ApplyFrameHiding()
    end)
end

function HideFrame:OnEnable()
    -- Применение настроек при включении аддона
    self:ApplyFrameHiding()
end

function HideFrame:ApplyFrameHiding()
    -- Применение скрытия фрейма цели
    if self.db.profile.hideTargetDragon then
        hookTexture(TargetFrameTextureFrameTexture)
    end

    -- Применение скрытия фрейма фокуса
    if self.db.profile.hideFocusDragon then
        hookTexture(FocusFrameTextureFrameTexture)
    end

    -- Применение скрытия фреймов боссов
    if self.db.profile.hideBossDragon then
        for i = 1, 5 do
            local bossFrame = _G["Boss"..i.."TargetFrameTextureFrameTexture"]
            if bossFrame then
                hookTexture(bossFrame)
            end
        end
    end

    -- Применение скрытия PVP иконок
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



-- Настройка интерфейса конфигурации
function HideFrame:SetupConfig()
    local L = getL()

    -- Вспомогательная функция для создания переключателей
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

    -- Регистрация опций
    LibStub("AceConfig-3.0"):RegisterOptionsTable("HideFrame", options)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("HideFrame", "HideFrame")

    -- Добавление команд чата
    local function openConfig()
        InterfaceOptionsFrame_OpenToCategory("HideFrame")
    end

    self:RegisterChatCommand("hideframe", openConfig)
    self:RegisterChatCommand("hf", openConfig)
end