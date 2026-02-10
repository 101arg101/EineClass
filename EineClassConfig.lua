-- Saved variables
EineClassDB = EineClassDB or {
  minimapPos = 220,
  debug = true,
  autoTargetNearest = true,
  petRotations = true,
  curse = "Curse of Agony",
  OOCStealth = true,
  smallBleed = true,
  manaPot = true,
  healthPot = true,
  healthstone = true,
}

-- Curse spell data for Warlock
local curseData = {
  {name = "Curse of Agony", texture = "Interface\\Icons\\Spell_Shadow_CurseOfSargeras"},
  {name = "Curse of Recklessness", texture = "Interface\\Icons\\Spell_Shadow_UnholyStrength"},
  {name = "Curse of Shadow", texture = "Interface\\Icons\\Spell_Shadow_CurseOfAchimonde"},
  {name = "Curse of the Elements", texture = "Interface\\Icons\\Spell_Shadow_ChillTouch"},
  {name = "Curse of Weakness", texture = "Interface\\Icons\\Spell_Shadow_CurseOfMannoroth"},
  {name = "Curse of Tongues", texture = "Interface\\Icons\\Spell_Shadow_CurseOfTounges"}
}

local classSpecificPanels = {}
local panelsLayout = {
  GLOBAL = {
    {fieldType = "checkbox", name = "debug", label = "Enable debug messages", height = 25},
    {fieldType = "checkbox", name = "autoTargetNearest", label = "Auto-target nearest enemy", height = 25},
    {fieldType = "checkbox", name = "petRotations", label = "Enable pet rotations", height = 25},
    {fieldType = "checkbox", name = "manaPot", label = "Mana potion at 10%", height = 25},
    {fieldType = "checkbox", name = "healthPot", label = "Health potion at 25%", height = 25},
    {fieldType = "checkbox", name = "healthstone", label = "Healthstone at 25%", height = 25},
  },
  WARLOCK = {
    {fieldType = "iconrow", name = "curse", label = "Select curse:", height = 65, data = curseData},
  },
  DRUID = {
    {fieldType = "checkbox", name = "OOCStealth", label = "Stealth when out of combat", height = 25},
    {fieldType = "checkbox", name = "smallBleed", label = "Rip at 1 combo point instead of 5", height = 25},
  }
}

local function CreateIconRow(iconTable, DBName, vert, panel)
  local iconButtons = {}
  local iconsPerRow = math.mod(Eine_Length(iconTable), 7)
  local iconSize = 32
  local iconSpacing = 6
  
  for i, iconData in ipairs(iconTable) do
    local button = CreateFrame("Button", "EineClassIconButton"..DBName..i, panel)
    button:SetWidth(iconSize)
    button:SetHeight(iconSize)
    
    -- Calculate position
    local row = math.floor((i - 1) / iconsPerRow)
    local col = math.mod((i - 1), iconsPerRow)
    local xOffset = (col - iconsPerRow/2 + 0.5) * (iconSize + iconSpacing)
    local yOffset = -50 - (row * (iconSize + iconSpacing)) + vert
    
    button:SetPoint("TOP", xOffset, yOffset)
    
    -- Icon texture
    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetAllPoints()
    icon:SetTexture(iconData.texture)
    button.icon = icon
    
    -- Normal border texture (always visible, subtle)
    local normalBorder = button:CreateTexture(nil, "ARTWORK")
    normalBorder:SetWidth(iconSize * 1.6)
    normalBorder:SetHeight(iconSize * 1.6)
    normalBorder:SetPoint("CENTER",0,0)
    normalBorder:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    normalBorder:SetBlendMode("ADD")
    normalBorder:SetVertexColor(0.4, 0.4, 0.4, 0.8)
    
    -- Hover highlight (white)
    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetWidth(iconSize * 1.6)
    highlight:SetHeight(iconSize * 1.6)
    highlight:SetPoint("CENTER",0,0)
    highlight:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    highlight:SetBlendMode("ADD")
    highlight:SetVertexColor(1, 1, 1, 0.5)
    
    -- Selected border (gold, on top)
    local selected = button:CreateTexture(nil, "OVERLAY")
    selected:SetWidth(iconSize * 1.6)
    selected:SetHeight(iconSize * 1.6)
    selected:SetPoint("CENTER",0,0)
    selected:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    selected:SetBlendMode("ADD")
    selected:SetVertexColor(1, 0.8, 0, 1)
    selected:Hide()
    button.selectedBorder = selected
    
    -- Store icon name
    button.name = iconData.name
    
    -- Click handler
    button:SetScript("OnClick", function()
      EineClassDB[DBName] = this.name
      -- Update all button highlights
      for _, btn in ipairs(iconButtons) do
        btn.selectedBorder:Hide()
      end
      this.selectedBorder:Show()
    end)
    
    -- Tooltip
    button:SetScript("OnEnter", function()
      GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
      GameTooltip:SetText(this.name, 1, 1, 1)
      GameTooltip:Show()
    end)
    
    button:SetScript("OnLeave", function()
      GameTooltip:Hide()
    end)
    
    table.insert(iconButtons, button)
  end
  
  return iconButtons, function()
    for _, btn in ipairs(iconButtons) do
      if btn.name == EineClassDB[DBName] then
        btn.selectedBorder:Show()
      else
        btn.selectedBorder:Hide()
      end
    end
  end
end

local function CreateClassPanel(class, parent)
  local panel = CreateFrame("Frame", nil, parent)
  panel:SetPoint("TOPLEFT", 200, -85)
  panel:SetPoint("BOTTOMRIGHT", -10, 15)
  
  local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  title:SetPoint("TOP", 0, 0)
  title:SetText(_Eine.classText.." Settings|r")
  
  local totalYOffset = 0
  local updates = {}
  for i,field in ipairs(panelsLayout[_Eine.class]) do
    if field.fieldType == "iconrow" then
      -- Curse selection label
      local fieldLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
      fieldLabel:SetPoint("TOP", 0, -25 - totalYOffset)
      fieldLabel:SetText(field.label)
      
      -- Create curse icon buttons
      local fieldButtons, fieldButtonsUpdate = CreateIconRow(field.data, field.name, totalYOffset, panel)
      
      table.insert(updates, fieldButtonsUpdate)
    elseif field.fieldType == "checkbox" then
      local fieldCheck = CreateFrame("CheckButton", "EineClass"..field.name.."Check", panel, "UICheckButtonTemplate")
      fieldCheck:SetPoint("TOPLEFT", 20, -25 - totalYOffset)
      fieldCheck:SetWidth(24)
      fieldCheck:SetHeight(24)
      fieldCheck.name = field.name
      getglobal(fieldCheck:GetName().."Text"):SetText(field.label)
      fieldCheck:SetScript("OnClick", function()
        EineClassDB[this.name] = this:GetChecked() == 1
      end)
      
      table.insert(updates, function() fieldCheck:SetChecked(EineClassDB[fieldCheck.name]) end)
    end
    
    totalYOffset = totalYOffset + field.height
  end
  
  
  -- Function to update selected class options
  panel.UpdateSelection = function()
    for _, fn in ipairs(updates) do
      fn()
    end
  end
  
  return panel
end

local function CreateConfigFrame()
  local frame = CreateFrame("Frame", "EineClassConfigFrame", UIParent)
  frame:SetWidth(550)
  frame:SetHeight(350)
  frame:SetPoint("CENTER", 0, 0)
  frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
  })
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:SetFrameStrata("DIALOG")
  frame:Hide()
  
  -- Title (colored by class)
  local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOP", 0, -20)
  title:SetText(_Color[_Eine.class].."EineClass Settings|r")
  
  -- Close button
  local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
  closeButton:SetPoint("TOPRIGHT", -5, -5)
  closeButton:SetScript("OnClick", function() frame:Hide() end)
  
  -- Make frame draggable
  local titleRegion = CreateFrame("Button", nil, frame)
  titleRegion:SetPoint("TOPLEFT", 10, -10)
  titleRegion:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -10, -40)
  titleRegion:EnableMouse(true)
  titleRegion:RegisterForDrag("LeftButton")
  titleRegion:SetScript("OnDragStart", function() frame:StartMoving() end)
  titleRegion:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)
  
  -- Command Buttons at top
  local buttonWidth = 120
  local buttonSpacing = (frame:GetWidth() - buttonWidth*4)/5
  local totalButtonsWidth = (buttonWidth * 4) + (buttonSpacing * 3)
  local startX = (frame:GetWidth() - buttonWidth)/2 - buttonSpacing
  
  local helpButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
  helpButton:SetPoint("TOP", -startX, -45)
  helpButton:SetWidth(buttonWidth)
  helpButton:SetHeight(22)
  helpButton:SetText("Help")
  helpButton:SetScript("OnClick", function()
    EINE_SLASH("help")
  end)
  
  local listButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
  listButton:SetPoint("LEFT", helpButton, "RIGHT", buttonSpacing, 0)
  listButton:SetWidth(buttonWidth)
  listButton:SetHeight(22)
  listButton:SetText("List")
  listButton:SetScript("OnClick", function()
    EINE_SLASH("list")
  end)
  
  local reloadButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
  reloadButton:SetPoint("LEFT", listButton, "RIGHT", buttonSpacing, 0)
  reloadButton:SetWidth(buttonWidth)
  reloadButton:SetHeight(22)
  reloadButton:SetText("Reload")
  reloadButton:SetScript("OnClick", function()
    EINE_SLASH("reload")
  end)
  
  local resetMapButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
  resetMapButton:SetPoint("LEFT", reloadButton, "RIGHT", buttonSpacing, 0)
  resetMapButton:SetWidth(buttonWidth)
  resetMapButton:SetHeight(22)
  resetMapButton:SetText("Reset Map Button")
  resetMapButton:SetScript("OnClick", function()
    EineClassDB.minimapPos = 220
  end)
  
  -- Left column: Global Settings
  local globalSettingsLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  globalSettingsLabel:SetPoint("TOPLEFT", 20, -85)
  globalSettingsLabel:SetText(_Color.y.."Global Settings|r")
  
  
  
  local totalYOffset = 85
  local updates = {}
  for i,field in ipairs(panelsLayout.GLOBAL) do
    if field.fieldType == "iconrow" then
      -- Curse selection label
      local fieldLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
      fieldLabel:SetPoint("TOP", 0, -25 - totalYOffset)
      fieldLabel:SetText(field.label)
      
      -- Create curse icon buttons
      local fieldButtons, fieldButtonsUpdate = CreateIconRow(field.data, field.name, totalYOffset, frame)
      
      table.insert(updates, fieldButtonsUpdate)
    elseif field.fieldType == "checkbox" then
      local fieldCheck = CreateFrame("CheckButton", "EineClass"..field.name.."Check", frame, "UICheckButtonTemplate")
      fieldCheck:SetPoint("TOPLEFT", 20, -25 - totalYOffset)
      fieldCheck:SetWidth(24)
      fieldCheck:SetHeight(24)
      fieldCheck.name = field.name
      getglobal(fieldCheck:GetName().."Text"):SetText(field.label)
      fieldCheck:SetScript("OnClick", function()
        EineClassDB[this.name] = this:GetChecked() == 1
      end)
      
      table.insert(updates, function() fieldCheck:SetChecked(EineClassDB[fieldCheck.name]) end)
    end
    
    totalYOffset = totalYOffset + field.height
  end
  
  
  -- Function to update selected class options
  frame.UpdateSelection = function()
    for _, fn in ipairs(updates) do
      fn()
    end
  end
  
  -- Separator line (vertical)
  local separator = frame:CreateTexture(nil, "ARTWORK")
  separator:SetPoint("TOPLEFT", 195, -80)
  separator:SetPoint("BOTTOMLEFT", 195, 10)
  separator:SetWidth(1)
  separator:SetTexture(0.5, 0.5, 0.5, 0.5)
  
  _Eine.classSpecificPanel = CreateClassPanel(_Eine.class, frame)
  
  -- OnShow handler to update checkboxes and show correct panel
  frame:SetScript("OnShow", function()
    _Eine.classSpecificPanel.UpdateSelection()
    this.UpdateSelection()
  end)
  
  return frame
end

-- Create the config frame when addon loads
local configLoader = CreateFrame("Frame")
configLoader:RegisterEvent("ADDON_LOADED")
configLoader:SetScript("OnEvent", function()
  if arg1 == "EineClass" then
    CreateConfigFrame()
  end
end)