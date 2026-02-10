-- Minimap Button for EineClass
EineClassMinimap = {}
EineClassMinimap.isMoving = false

local function EineClassMinimap_OnLoad()
  this:RegisterForDrag("LeftButton")
  this:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  this:SetFrameStrata("MEDIUM")
  this:SetFrameLevel(9)
end

local function EineClassMinimap_OnClick()
  if arg1 == "RightButton" then
    -- Right-click: toggle debug
    EineClassDB.debug = not EineClassDB.debug
    if EineClassDB.debug then
      DEFAULT_CHAT_FRAME:AddMessage(_Color.g.."EineClass: Debug enabled|r")
    else
      DEFAULT_CHAT_FRAME:AddMessage(_Color.y.."EineClass: Debug disabled|r")
    end
  else
    -- Left-click: open config
    if EineClassConfigFrame:IsVisible() then
      EineClassConfigFrame:Hide()
    else
      EineClassConfigFrame:Show()
    end
  end
end

local function EineClassMinimap_OnDragStart()
  EineClassMinimap.isMoving = true
  this:LockHighlight()
end

local function EineClassMinimap_OnDragStop()
  EineClassMinimap.isMoving = false
  this:UnlockHighlight()
end

local function EineClassMinimap_OnUpdate()
  if EineClassMinimap.isMoving then
    local mx, my = Minimap:GetCenter()
    local px, py = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    px, py = px / scale, py / scale
    
    -- Calculate angle
    local angle = math.deg(math.atan2(py - my, px - mx))
    EineClassDB.minimapPos = angle
  end
  
  -- Update position
  local angle = math.rad(EineClassDB.minimapPos or 220)
  local x = 80 * math.cos(angle)
  local y = 80 * math.sin(angle)
  this:SetPoint("CENTER", "Minimap", "CENTER", x, y)
end

local function EineClassMinimap_OnEnter()
  GameTooltip:SetOwner(this, "ANCHOR_LEFT")
  GameTooltip:SetText("|cfffa33faEineClass|r", 1, 1, 1)
  GameTooltip:AddLine("Left-click: Open settings", 0.8, 0.8, 0.8)
  GameTooltip:AddLine("Right-click: Toggle debug", 0.8, 0.8, 0.8)
  GameTooltip:AddLine("Drag: Move button", 0.8, 0.8, 0.8)
  GameTooltip:Show()
end

local function EineClassMinimap_OnLeave()
  GameTooltip:Hide()
end

-- Create the minimap button
local function CreateMinimapButton()
  -- Create the button
  local button = CreateFrame("Button", "EineClassMinimapButton", Minimap)
  button:SetWidth(32)
  button:SetHeight(32)
  button:SetFrameStrata("MEDIUM")
  button:SetFrameLevel(9)
  button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
  
  -- Icon
  local icon = button:CreateTexture("EineClassMinimapButtonIcon", "BACKGROUND")
  icon:SetWidth(20)
  icon:SetHeight(20)
  icon:SetPoint("CENTER", 0, 1)
  icon:SetTexture("Interface\\AddOns\\EineClass\\Icons\\Energy")
  
  -- Border
  local overlay = button:CreateTexture("EineClassMinimapButtonBorder", "OVERLAY")
  overlay:SetWidth(52)
  overlay:SetHeight(52)
  overlay:SetPoint("TOPLEFT", 0, 0)
  overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
  
  -- Scripts
  button:SetScript("OnLoad", EineClassMinimap_OnLoad)
  button:SetScript("OnClick", EineClassMinimap_OnClick)
  button:SetScript("OnDragStart", EineClassMinimap_OnDragStart)
  button:SetScript("OnDragStop", EineClassMinimap_OnDragStop)
  button:SetScript("OnUpdate", EineClassMinimap_OnUpdate)
  button:SetScript("OnEnter", EineClassMinimap_OnEnter)
  button:SetScript("OnLeave", EineClassMinimap_OnLeave)
  
  button:RegisterForDrag("LeftButton")
  button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  
  -- Initial position
  EineClassMinimap_OnUpdate()
end

-- Initialize after variables are loaded
local minimapLoader = CreateFrame("Frame")
minimapLoader:RegisterEvent("VARIABLES_LOADED")
minimapLoader:SetScript("OnEvent", function()
  CreateMinimapButton()
end)
