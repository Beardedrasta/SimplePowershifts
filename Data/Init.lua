SPS = SPS or {}
SPS.DruidLib = AceLibrary("DruidManaLib-1.0")
_, SPS.PlayerClass = UnitClass("player")
SPS.EventFrame = CreateFrame("Frame")

local defaults = {
    locked = false,
    width = 40,
    height = 40,
    fontSize = 26,
    point = "CENTER",
    relativePoint = "CENTER",
    x = -150,
    y = 0,
}

local function UpdateSettings()
    if not SPS_DB then
        SPS_DB = {}
    end
    for options, value in defaults do
        if SPS_DB[options] == nil then
            SPS_DB[options] = value
        end
    end
end

SPS.EventFrame:RegisterEvent("VARIABLES_LOADED")
SPS.EventFrame:RegisterEvent("PLAYER_LOGIN")
SPS.EventFrame:RegisterEvent("PLAYER_LOGOUT")
SPS.EventFrame:SetScript("OnEvent", function(event)
    UpdateSettings()
end)

function SPS_print(text)
    DEFAULT_CHAT_FRAME:AddMessage(text)
end

SPS_CustomFont = CreateFont("SimplePowershifts_Font")
SPS_CustomFont:SetFont("Interface\\AddOns\\SimplePowershifts\\Media\\Expressway.ttf", 26, "")
SPS_CustomFont:SetTextColor(1, 0.82, 0)
SPS_CustomFont:SetShadowColor(0, 0, 0, 1)
SPS_CustomFont:SetShadowOffset(1, -1)

SPS_CustomFont_AltFont = CreateFont("SimplePowershifts_AltFont")
SPS_CustomFont_AltFont:SetFont("Interface\\AddOns\\SimplePowershifts\\Media\\Expressway.ttf", 16, "")
SPS_CustomFont_AltFont:SetTextColor(1, 0.82, 0)
SPS_CustomFont_AltFont:SetShadowColor(0, 0, 0, 1)
SPS_CustomFont_AltFont:SetShadowOffset(1, -1)