function EineClass_OnLoad()
  this:RegisterEvent("PLAYER_ENTERING_WORLD")
  this:RegisterEvent("ADDON_LOADED")
  SLASH_EINE1 = "/eine"
  _Eine = {}
  _Eine.init = {}
  _Eine.subcmds = {}
  _Eine.firstLoad = true
  _Eine.petRotations = {}
  _Color = {}
  _Color.r = "|cfffa3333" -- error
  _Color.g = "|cff33fa33" -- success
  _Color.b = "|cff3333fa" -- variable
  _Color.c = "|cff33fafa" -- info
  _Color.y = "|cfffafa33" -- pending
  _Color.m = "|cfffa33fa" -- 
  _Color.k = "|cff676767" -- disabled
  _Color.w = "|cffe4e4e4" -- default (offwhite to differentiate between priest class color)
  _Color.DRUID = "|cffff7c0a"
  _Color.HUNTER = "|cffaad372"
  _Color.MAGE = "|cff3fc7eb"
  _Color.PALADIN = "|cfff48cba"
  _Color.PRIEST = "|cffffffff"
  _Color.ROGUE = "|cfffff468"
  _Color.SHAMAN = "|cff0070dd"
  _Color.WARLOCK = "|cff8788ee"
  _Color.WARRIOR = "|cffc69b6d"
  
  _Eine.classLocal, _Eine.class, _Eine.classI = UnitClass("player")
  _Color.class = _Color[_Eine.class]
  _Eine.classText = _Color[_Eine.class].._Eine.classLocal.."|r"
  
  DEFAULT_CHAT_FRAME:AddMessage(_Color.y.."•••••|r ".._Color.w.."Setting up EineClass (made by Fryn on Nordanaar)|r ".._Color.y.."•••••|r")
  
  _Eine.petAttackExceptions = {}
  _Eine.petAttackExceptions["Emperor Vek'nilash"] = true
  _Eine.petAttackExceptions["Emperor Vek'lor"] = true
  
  _Eine.summonSpellIds = {}
  _Eine.summonSpellIds[688] = "Imp"
  _Eine.summonSpellIds[697] = "Voidwalker"
  _Eine.summonSpellIds[712] = "Succubus"
  _Eine.summonSpellIds[691] = "Felhunter"
  _Eine.summonSpellIds[1122] = "Infernal"
  _Eine.summonSpellIds[45908] = "Felguard"
  _Eine.summonSpellIds[18540] = "Doomguard"
  
  SlashCmdList["EINE"] = EINE_SLASH
  
  local loadBuffer = CreateFrame("Frame", "loadBuffer")
  loadBuffer:RegisterEvent("PLAYER_ENTERING_WORLD")
  loadBuffer:RegisterEvent("ZONE_CHANGED_NEW_AREA") -- this fixes the problem of talents not being loaded when the addon is first loaded in
  loadBuffer:RegisterEvent("CHARACTER_POINTS_CHANGED")
  loadBuffer:SetScript("OnEvent", EineClass_Loader)
end

function EineClass_Loader(opts)
  if _Eine.init[_Eine.class] then
    _Eine.init[_Eine.class](opts)
  end
  _Eine.firstLoad = false
end

function EINE_SLASH(subcmd)
  local opts = {}
  if (subcmd == "reload") then
    _Eine.firstLoad = true
    EineClass_Loader(opts)
  elseif (subcmd == "list") then
    DEFAULT_CHAT_FRAME:AddMessage(_Color.c.."•••••|r")
    DEFAULT_CHAT_FRAME:AddMessage(_Color.w.."Supported rotations:|r")
    for subKey, subVal in pairs(_Eine.subcmds) do
      DEFAULT_CHAT_FRAME:AddMessage(_Color.class.."  • "..subKey.."|r")
      DEFAULT_CHAT_FRAME:AddMessage("      ".._Color.w..subVal.description.."|r")
    end
    DEFAULT_CHAT_FRAME:AddMessage(_Color.c.."•••••|r")
  elseif (subcmd == "config") then
    if EineClassConfigFrame:IsVisible() then
      EineClassConfigFrame:Hide()
    else
      EineClassConfigFrame:Show()
    end
  elseif (_Eine.subcmds[subcmd]) then
    opts.time = GetTime()
    opts.isTarget, opts.targetGUID = UnitExists("target")
    opts.curseOptions = {}
    opts.isBehind = UnitXP("behind","player","target")
    opts.distance = UnitXP("distanceBetween", "player", "target")
    opts.los = UnitXP("inSight", "player", "target")

    if (not opts.isTarget and EineClassDB.autoTargetNearest) then
      TargetNearestEnemy()
      opts.isTarget, opts.targetGUID = UnitExists("target")
    end
    
    opts.targetName = UnitName("target")
    
    if HasPetUI() and EineClassDB.petRotations and opts.isTarget then
      dbg("sending pet to attack")
      PetAttack()
    end
    
    opts.hpMax = UnitHealthMax("player")
    opts.hp = UnitHealth("player")
    opts.manaMax = UnitManaMax("player")
    opts.energy, opts.mana = UnitMana("player")
    opts.rage = opts.energy
    if not opts.mana then opts.mana = opts.energy end
    
    if EineClassDB.healthstone and opts.hp/opts.hpMax < .25 then
      dbg("attempt healthstone")
      for b = 0, 4 do
        for s = 1, GetContainerNumSlots(b) do
          if GetContainerItemLink(b,s) and (string.find(GetContainerItemLink(b,s),"Healthstone", 1, true)) then
            dbg("using healthstone")
            UseContainerItem(b,s)
            s = GetContainerNumSlots(b)
            b = 4
          end
        end
      end
    end
    
    if EineClassDB.healthPot and opts.hp/opts.hpMax < .25 then
      dbg("attempt health pot")
      for b = 0, 4 do
        for s = 1, GetContainerNumSlots(b) do
          if GetContainerItemLink(b,s) and (string.find(GetContainerItemLink(b,s),"Healing Potion", 1, true)) then
            dbg("using health pot")
            UseContainerItem(b,s)
            s = GetContainerNumSlots(b)
            b = 4
          end
        end
      end
    end
    
    if EineClassDB.manaPot and opts.mana/opts.manaMax < .1 then
      dbg("attempt mana pot")
      for b = 0, 4 do
        for s = 1, GetContainerNumSlots(b) do
          if GetContainerItemLink(b,s) and (string.find(GetContainerItemLink(b,s),"Mana Potion", 1, true)) then
            dbg("using mana pot")
            UseContainerItem(b,s)
            s = GetContainerNumSlots(b)
            b = 4
          end
        end
      end
    end

    _Eine.subcmds[subcmd].fn(opts)
  else -- displays help
    DEFAULT_CHAT_FRAME:AddMessage(_Color.c.."•••••|r")
    DEFAULT_CHAT_FRAME:AddMessage(_Color.w.."To use a rotation, add a macro to your hotbar with the following code:")
    DEFAULT_CHAT_FRAME:AddMessage(_Color.w.."  /eine |r".._Color.b.."<name of rotation>|r")
    DEFAULT_CHAT_FRAME:AddMessage(" ")
    DEFAULT_CHAT_FRAME:AddMessage(_Color.w.."Example:|r")
    DEFAULT_CHAT_FRAME:AddMessage(_Color.w.."  /eine feral bleed|r")
    DEFAULT_CHAT_FRAME:AddMessage(" ")
    DEFAULT_CHAT_FRAME:AddMessage(_Color.w.."Commands:|r")
    DEFAULT_CHAT_FRAME:AddMessage(_Color.w.."  /eine reload|r ".._Color.c.."Reloads variables. Useful when you change equipment")
    DEFAULT_CHAT_FRAME:AddMessage(_Color.w.."  /eine config|r ".._Color.c.."Displays settings menu")
    DEFAULT_CHAT_FRAME:AddMessage(_Color.w.."  /eine list|r ".._Color.c.."List available rotations to make macros with")
    DEFAULT_CHAT_FRAME:AddMessage(_Color.w.."  /eine help|r ".._Color.c.."Display this text")
    DEFAULT_CHAT_FRAME:AddMessage(_Color.c.."•••••|r")
  end
end

function Eine_Length(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function Eine_ShadowMult(opts)
  local multipliers = {}
  local multiplier = 1
  
  if Eine_IsDebuff("Spell_Shadow_ShadowBolt") then
    table.insert(multipliers, 1.2)
  end
  
  if Eine_IsDebuff("Spell_Shadow_CurseOfAchimonde") then
    table.insert(multipliers, 1.1)
  end
  
  if _Eine.class == "WARLOCK" then
    local petData = GetUnitData("pet")
    if HasPetUI() and Eine_IsBuff("Spell_Shadow_GatherShadows") and petData and petData.createdBySpell and _Eine.summonSpellIds[petData.createdBySpell] == "Succubus" then
      table.insert(multipliers, 1.1)
    end
    
    if HasPetUI() and Eine_IsBuff("Spell_Shadow_ShadowPact") then
      table.insert(multipliers, 1.05)
    end
    
    local _,_,_,_,shadowMasteryRank=GetTalentInfo(1, 18)
    table.insert(multipliers, (1 + .02*shadowMasteryRank))
  end
  
  for i,v in ipairs(multipliers) do
    multiplier = multiplier*v
  end
  return multiplier
end

function Eine_FireMult(opts)
  local multipliers = {}
  local multiplier = 1
  
  
  if Eine_IsDebuff("Spell_Shadow_ChillTouch") then
    table.insert(multipliers,1.1)
  end
  
  if _Eine.class == "WARLOCK" then
    local petData = GetUnitData("pet")
    if HasPetUI() and Eine_IsBuff("Spell_Shadow_GatherShadows") and petData and petData.createdBySpell and _Eine.summonSpellIds[petData.createdBySpell] == "Succubus" then
      table.insert(multipliers,1.1)
    end
    
    if HasPetUI() and Eine_IsBuff("Spell_Shadow_ShadowPact") then
      table.insert(multipliers,1.05)
    end
  end
  
  for i,v in ipairs(multipliers) do
    multiplier = multiplier*v
  end
  return multiplier
end

function Eine_IsBuff(texture)
  local i = 0
  local g = GetPlayerBuff

  while not (g(i) == -1) do
    if (GetPlayerBuffTexture(g(i)) == "Interface\\Icons\\"..texture) then
      return 1
    end
    i = i + 1
  end
  return false
end

function dbg(out, condition)
  if EineClassDB.debug and condition ~= false then
    print(_Color.c..string.sub(tostring(GetTime()*1000), 3, 5)..": |r"..tostring(out))
  end
end

function Eine_IsDebuff(debuff)
  local retval = false
  local retcount = 0
  for i = 1, 32 do
    local d, c = UnitDebuff("target", i)
    if (d and "Interface\\Icons\\"..debuff == d) then
      retval = true
      if (c) then
        retcount = c
      end
    end
  end
  return retval, retcount
end

function Eine_DeathETA(untilHP, untilTime)
  -- if casting a 2 second cast time spell that's expected to do 1000 damage, untilHP should be 1000 and untilTime should be 2, and this function will return true
  local targetExist, targetGUID = UnitExists("target")
  -- for k,v in pairs(ShaguDPS.data.damage[0]) do print(k) end
  local shaguName = nil
  local shaguValue = nil
  local memberExist = nil
  local memberName = nil
  local memberI = nil
  local memberTarget = nil
  local mtGUID = nil
  local totalDPS = 1 -- start at 1 to prevent division by 0
  local group = false
  if GetNumPartyMembers() > 0 then group = "party" end
  if GetNumRaidMembers() > 0 then group = "raid" end
  if (not untilHP) then
    untilHP = 0
  end
  if (not untilTime) then
    untilTime = 0
  end
  
  if ShaguDPS ~= nil then
    if group == "party" then
      memberTarget, mtGUID = UnitExists("target")
      memberName = UnitName("player")
      shaguValue = ShaguDPS.data.damage[0][memberName]
      if (memberTarget and shaguValue and shaguValue._ctime >= 30) then
        -- print(memberName.." is targeting "..UnitName(mtGUID))
        -- print("  dps: "..(tostring(shaguValue._sum/shaguValue._ctime)))    
        totalDPS = totalDPS + shaguValue._sum/shaguValue._ctime
      end
      
      for i = 1, 4, 1 do
        memberI = "party"..i
        memberExist = UnitExists(memberI)
        memberTarget, mtGUID = UnitExists(memberI.."target")
        memberName = UnitName(memberI)
        shaguValue = ShaguDPS.data.damage[0][memberName]
        if (memberExist and memberTarget and shaguValue and shaguValue._ctime >= 30) then
          -- print(memberName.." is targeting "..UnitName(mtGUID))
          -- print("  dps: "..(tostring(shaguValue._sum/shaguValue._ctime)))    
          totalDPS = totalDPS + shaguValue._sum/shaguValue._ctime
        end
      end
    elseif group == "raid" then
      for i = 1, 40, 1 do
        memberI = "raid"..i
        memberExist = UnitExists(memberI)
        memberTarget, mtGUID = UnitExists(memberI.."target")
        memberName = UnitName(memberI)
        shaguValue = ShaguDPS.data.damage[0][memberName]
        if (memberExist and memberTarget and shaguValue and shaguValue._ctime >= 30) then
          totalDPS = totalDPS + shaguValue._sum/shaguValue._ctime
        end
      end
    else
      memberTarget, mtGUID = UnitExists("target")
      memberName = UnitName("player")
      shaguValue = ShaguDPS.data.damage[0][memberName]
      if (memberTarget and shaguValue and shaguValue._ctime >= 30) then
        totalDPS = totalDPS + shaguValue._sum/shaguValue._ctime
      end
    end
    
    return (UnitHealth("target") - untilHP - untilTime*totalDPS)/(totalDPS)
  else
    return 30
  end
end