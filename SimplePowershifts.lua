SPS = SPS or {}
local _G = getfenv(0)
local DruidLib = AceLibrary("DruidManaLib-1.0")

local SimplePowershiftsTooltip = CreateFrame("GameTooltip", "SimplePowershiftsTooltip", nil, "GameTooltipTemplate")
SimplePowershiftsTooltip:SetOwner(UIParent, "ANCHOR_NONE")

if not SPS.PlayerClass == "DRUID" then
    return;
end

local subtractMana = 0
local holder = _G["SimplePowershiftsFrame"]
local bg = _G["SimplePowershiftsBear"]
local border = _G["SimplePowershiftsBorder"]
local castText = _G["SimplePowershifts_Casts"]
local neededText = _G["SimplePowershifts_ManaNeeded"]
local costText = _G["SimplePowershifts_FormCost"]
castText:SetFontObject(SPS_CustomFont)
neededText:SetFontObject(SPS_CustomFont_AltFont)
neededText:SetTextColor(0, 0.8, 0.8)
costText:SetFontObject(SPS_CustomFont_AltFont)
bg:SetDesaturated(false)


local function GetShapeshiftCost()
    local _, _, numSpells = GetSpellTabInfo(4)
    for i = 1, numSpells do
        local spellTexture = GetSpellTexture(i, BOOKTYPE_SPELL)
        if spellTexture and spellTexture == "Interface\\Icons\\Ability_Racial_BearForm" then
            SimplePowershiftsTooltip:SetSpell(i, BOOKTYPE_SPELL)
            local costText = SimplePowershiftsTooltipTextLeft2:GetText()
            if costText then
                local _, _, cost = string.find(costText, "(%d+) Mana")
                if cost then
                    subtractMana = tonumber(cost)
                    return subtractMana
                end
            end
        end
    end
    return 0
end

local function UpdateFormDisplay()
    local currentMana, maxMana = DruidLib:GetMana()
    local formCost = GetShapeshiftCost()
    if currentMana >= formCost then
        local maxCasts = math.floor(currentMana / formCost)
        castText:SetText(maxCasts)
        costText:SetText("")
        neededText:SetText("")
        bg:SetDesaturated(false)
    else
        castText:SetText("")
        costText:SetText(formCost)
        neededText:SetText(formCost - currentMana)
        bg:SetDesaturated(true)
    end
end

function SPS_OnEvent()
    if event == "PLAYER_ENTERING_WORLD" then
        UpdateFormDisplay()
    elseif (event == "UNIT_MANA" or event == "UNIT_DISPLAYPOWER") and arg1 == "player" then
        UpdateFormDisplay()
    elseif event == "PLAYER_AURAS_CHANGED" or event == "UPDATE_SHAPESHIFT_FORMS" then
        if UnitPowerType("player") == 1 then
            GetShapeshiftCost()
            UpdateFormDisplay()
        elseif UnitPowerType("player") == 0 then
            UpdateFormDisplay()
        end
    end
end

function SPS_MouseEnter()
    if SPS_DB.lock == false then
        border:SetBackdropBorderColor(0, 0.8, 0.8, 1)
    end
end

function SPS_MouseLeave()
    border:SetBackdropBorderColor(1, 1, 1, 1)
end

local updateInterval = 0.1
local timeSinceLastUpdate = 0

holder:SetScript("OnUpdate", function()
    timeSinceLastUpdate = timeSinceLastUpdate + arg1
    if timeSinceLastUpdate >= updateInterval then
        UpdateFormDisplay()
        timeSinceLastUpdate = 0
    end
end)

local function ToggleLock()
    SPS_DB.lock = not SPS_DB.lock
    if SPS_DB.lock == true then
        holder:EnableMouse(false)
    else
        holder:EnableMouse(true)
    end
end



local function UpdateVisibility()
    holder:SetHeight(SPS_DB.height)
    bg:SetHeight(SPS_DB.height)
    holder:SetWidth(SPS_DB.width)
    bg:SetWidth(SPS_DB.width)

    if (SPS_DB.height >= 60 and SPS_DB.height <= 79) or SPS_DB.width >= 60 and SPS_DB.width <= 79 then
        border:SetBackdrop({
            edgeFile = "Interface\\AddOns\\SimplePowershifts\\Media\\Caith.tga",
            edgeSize = 18,
        })
        border:SetHeight(SPS_DB.height + 3)
        border:SetWidth(SPS_DB.width + 3)
    elseif (SPS_DB.height >= 80 and SPS_DB.height <= 100) or SPS_DB.width >= 80 and SPS_DB.width <= 100 then
        border:SetBackdrop({
            edgeFile = "Interface\\AddOns\\SimplePowershifts\\Media\\Caith.tga",
            edgeSize = 24,
        })
        border:SetHeight(SPS_DB.height + 4)
        border:SetWidth(SPS_DB.width + 4)
    else
        border:SetBackdrop({
            edgeFile = "Interface\\AddOns\\SimplePowershifts\\Media\\Caith.tga",
            edgeSize = 14,
        })
        border:SetHeight(SPS_DB.height + 3)
        border:SetWidth(SPS_DB.width + 3)
    end

    if SPS_DB.lock == true then
        holder:EnableMouse(false)
    else
        holder:EnableMouse(true)
    end
end


local e = CreateFrame("Frame")
e:RegisterEvent("VARIABLES_LOADED")
e:RegisterEvent("PLAYER_ENTERING_WORLD")
e:SetScript("OnEvent", function(event)
    UpdateVisibility()
    SLASH_SIMPLEPOWERSHIFT1 = "/sps"
    SlashCmdList["SIMPLEPOWERSHIFT"] = function(msg)
        msg = string.lower(msg)
        if msg == "" or msg == nil then
            SPS_print("SimplePowershifts Commands:")
            SPS_print("/sps lock")
            SPS_print("/sps size <value>")
        elseif msg == "lock" then
            ToggleLock()
            if SPS_DB.lock == true then
                SPS_print("SimplePowrshifts: Locked")
            else
                SPS_print("SimplePowrshifts: Unlocked")
            end
        elseif string.find(msg, " ") then
            local firstSpace = string.find(msg, " ")
            local command = string.sub(msg, 1, firstSpace - 1)
            local value = tonumber(string.sub(msg, firstSpace + 1))

            if command == "size" and value then
                SPS_DB.width = value
                SPS_DB.height = value
                UpdateVisibility()
                SPS_print("SimplePowershifts: Size = " .. value)
            else
                SPS_print("Invalid command or value. Use '/sps size <value>'.")
            end
        elseif msg == "reset" then
            SPS_DB = nil
            ReloadUI()
        else
            SPS_print("Invalid command. Use '/sps' for help.")
        end
    end
end)
