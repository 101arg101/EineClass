local DemoFire, DemoShadow, Affliction, ShadowboltEst, ShadowburnEst

_Eine.init.WARLOCK = function(opts)
  _Eine.subcmds["demo shadow"] = {
    description = "sends pet to attack, casts empower demon, casts corruption, casts immolate, casts shadowbolt, casts shadowburn",
    fn = DemoShadow
  }
  
  _Eine.subcmds["demo fire"] = {
    description = "sends pet to attack, casts empower demon, casts corruption, casts immolate, casts searing pain",
    fn = DemoFire
  }
  
  _Eine.subcmds["affliction"] = {
    description = "sends pet to attack, casts empower demon, casts corruption, casts immolate, casts searing pain",
    fn = Affliction
  }
  
  _Eine.lastSB = GetTime()
  -- /run local a = GetUnitData("pet");print(a.createdBySpell)
  if _Eine.firstLoad then
    DEFAULT_CHAT_FRAME:AddMessage(_Color.g.."•••••|r ".._Color.w.."Loaded EineClass (|r".._Eine.classText.._Color.w..")|r ".._Color.g.."•••••|r")
  end
end

_Eine.petRotations["Imp"] = function(opts)
  local pDistance = UnitXP("distanceBetween", "pet", "target")
  local pLos = UnitXP("inSight", "pet", "target")
  
  if pDistance <= 31 and pLos and GetSpellCooldown("power overwhelming") == 0 then
    CastSpellByName("power overwhelming")
  end
end

_Eine.petRotations["Succubus"] = function(opts)
  local pDistance = UnitXP("distanceBetween", "pet", "target")
  
  if pDistance <= 6 and GetSpellCooldown("power overwhelming") == 0 then
    CastSpellByName("power overwhelming")
  end
end

_Eine.petRotations["Voidwalker"] = function(opts)
  local pDistance = UnitXP("distanceBetween", "pet", "target")
  
  if pDistance <= 6 and GetSpellCooldown("power overwhelming") == 0 then
    CastSpellByName("power overwhelming")
  end
end

_Eine.petRotations["Felhunter"] = function(opts)
  local pDistance = UnitXP("distanceBetween", "pet", "target")
  local pLos = UnitXP("inSight", "pet", "target")
  
  if pDistance <= 6 and GetSpellCooldown("power overwhelming") == 0 then
    CastSpellByName("power overwhelming")
  end
end

_Eine.petRotations["Infernal"] = function(opts)
  local pDistance = UnitXP("distanceBetween", "pet", "target")
  if pDistance <= 6 and GetSpellCooldown("power overwhelming") == 0 then
    dbg("casting power overwhelming")
    CastSpellByName("power overwhelming")
  end
end

_Eine.petRotations["Felguard"] = function(opts)
  local pDistance = UnitXP("distanceBetween", "pet", "target")
  local pLos = UnitXP("inSight", "pet", "target")
  local pursuitI
  
  for i=1, 10 do
    --local name, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i
    local name,_,_,_,_,_,autoEnabled = GetPetActionInfo(i)
    if (name == "Legion Strike" and not autoEnabled) then
      TogglePetAutocast(i)
    elseif (name == "Pursuit") then
      pursuitI = i
    end
  end
  
  if pDistance <= 26 and pLos and GetSpellCooldown("power overwhelming") == 0 then
    dbg("casting power overwhelming")
    CastSpellByName("power overwhelming")
  end
  
  if 8 <= pDistance and pDistance <= 25 and pLos and GetPetActionCooldown(pursuitI) == 0 then
    dbg("casting pursuit")
    CastPetAction(pursuitI)
  end
end

_Eine.petRotations["Doomguard"] = function(opts)
  local pDistance = UnitXP("distanceBetween", "pet", "target")
  local pLos = UnitXP("inSight", "pet", "target")
  local pursuitI
  
  for i=1, 10 do
    --local name, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i
    local name,_,_,_,_,_,autoEnabled = GetPetActionInfo(i)
    if (name == "Infernal Blade" and not autoEnabled) then
      TogglePetAutocast(i)
    end
  end
  
  if pDistance <= 6 and GetSpellCooldown("power overwhelming") == 0 then
    dbg("casting power overwhelming")
    CastSpellByName("power overwhelming")
  end
end

function ShadowboltEst(opts)
  --      base                           spellpower               coefficient buffs/debuffs
  local physical, holy, fire, nature, frost, shadow, arcane = GetSpellPower()
  return ((510 + shadow * 6/7) * Eine_ShadowMult())
end

function ShadowburnEst(opts)
  local physical, holy, fire, nature, frost, shadow, arcane = GetSpellPower()
  return ((487 + shadow * 3/7) * Eine_ShadowMult())
end

function SearingEst(opts)
  local physical, holy, fire, nature, frost, shadow, arcane = GetSpellPower()
  return ((487 + fire * 3/7) * Eine_FireMult())
end

-- TODO: track the spell you're casting if it has travel time and predict its damage
-- TODO: read the tracked spell to help predict DeathETA
-- TODO: read current dot being cast, and do not attempt to nampower buffer it
function DemoShadow(opts)
  if opts.isTarget then
    local shadowburnETA = Eine_DeathETA(ShadowburnEst(), 4.8)
    local corruptionETA = Eine_DeathETA(ShadowboltEst(), 2.4)
    local curseETA = Eine_DeathETA(700, 6)
    if HasPetUI() and EineClassDB.petRotations and not _Eine.petAttackExceptions[opts.targetName] then
      local petData = GetUnitData("pet")
      if _Eine.summonSpellIds[petData.createdBySpell] then
        dbg("pet recognized: "..petData.createdBySpell)
        _Eine.petRotations[_Eine.summonSpellIds[petData.createdBySpell]](opts)
      else
        dbg("pet recognized: "..UnitName("pet"))
        _Eine.petRotations[UnitName("pet")](opts)
      end
    end
    
    dbg("")
    dbg(Eine_DeathETA())
    dbg("shadowburn "..tostring(shadowburnETA <= 0 and GetSpellCooldown("shadowburn") == 0).." ("..shadowburnETA.." "..GetSpellCooldown("shadowburn")..")")
    dbg("curse "..tostring(not Cursive.curses:HasCurse(string.lower(EineClassDB.curse), opts.targetGUID, 0) and (curseETA > 0)).." ("..tostring(not Cursive.curses:HasCurse(string.lower(EineClassDB.curse), opts.targetGUID, 0)).." "..curseETA..")")
    dbg("corruption "..tostring(not Cursive.curses:HasCurse("corruption", opts.targetGUID, 1.5) and corruptionETA > 0).." (".. tostring(not Cursive.curses:HasCurse("corruption", opts.targetGUID, 1.5)) .." "..corruptionETA..")")
    if shadowburnETA <= 0 and GetSpellCooldown("shadowburn") == 0 then
      dbg("cast shadowburn")
      CastSpellByName("shadowburn")
    else
      if not Cursive.curses:HasCurse(string.lower(EineClassDB.curse), opts.targetGUID, 0) and curseETA > 0 then
        dbg("cast curse")
        CastSpellByName(EineClassDB.curse)
      elseif not Cursive.curses:HasCurse("corruption", opts.targetGUID, 1.5) and corruptionETA > 0 then
        dbg("cast corruption")
        CastSpellByName("Corruption")
      else
        dbg("cast shadow bolt")
        CastSpellByName("Shadow Bolt")
      end
    end
  end
end

function DemoFire(opts)
  if opts.isTarget then
    local shortETA = Eine_DeathETA(700, 3)
    local immolateETA = Eine_DeathETA(700, 10)
    if HasPetUI() and EineClassDB.petRotations and not _Eine.petAttackExceptions[opts.targetName] then
      local petData = GetUnitData("pet")
      if _Eine.summonSpellIds[petData.createdBySpell] then
        _Eine.petRotations[_Eine.summonSpellIds[petData.createdBySpell]](opts)
      else
        _Eine.petRotations[UnitName("pet")](opts)
      end
    end
    
    if not Cursive.curses:HasCurse(string.lower(EineClassDB.curse), opts.targetGUID, 0) and not shortETA <= 0 then
      CastSpellByName(EineClassDB.curse)
    elseif Cursive.curses:HasCurse("immolate", opts.targetGUID, 1.5) and immolateETA >= 0 then
      CastSpellByName("Immolate")
    else
      CastSpellByName("Searing Pain")
    end
  end
end

function Affliction(opts)
  if opts.isTarget then
    local dETA = Eine_DeathETA()
    local dhcd = GetSpellCooldown("dark harvest") == 0
    local hasCurse = Cursive.curses:HasCurse(string.lower(EineClassDB.curse), opts.targetGUID, 1.5)
    local hasAgony = Cursive.curses:HasCurse("curse of agony", opts.targetGUID, 0)
    local hasCorrupt = Cursive.curses:HasCurse("corruption", opts.targetGUID, 1)
    local plentyAgony = Cursive.curses:HasCurse("curse of agony", opts.targetGUID, 9)
    local plentyCorrupt = Cursive.curses:HasCurse("corruption", opts.targetGUID, 7)
    if HasPetUI() and EineClassDB.petRotations and not _Eine.petAttackExceptions[opts.targetName] then
      local petData = GetUnitData("pet")
      if _Eine.summonSpellIds[petData.createdBySpell] then
        _Eine.petRotations[_Eine.summonSpellIds[petData.createdBySpell]](opts)
      else
        _Eine.petRotations[UnitName("pet")](opts)
      end
    end
    
    if Eine_IsBuff("Spell_Shadow_Twilight") and GetTime() - _Eine.lastSB > 1.5 then
      dbg(dETA.." casting shadow bolt")
      -- until nampower's IsCurrentCast glitch gets fixed, this is the only way to prevent you from interrupting your own dark harvest for shadow bolts. this means other warlocks can prevent you from utilizing nightfall
      if not Eine_IsDebuff("Spell_Shadow_SoulLeech") then
        SpellStopCasting()
      end
      CastSpellByName("shadow bolt")
      _Eine.lastSB = GetTime()
    end
    
    if ((dETA <= 6.5 and (plentyAgony or plentyCorrupt)) or (dETA >= 35 and plentyAgony and plentyCorrupt)) then
      dbg(dETA.." casting dark harvest")
      CastSpellByName("dark harvest") -- casts dark harvest as a top priority for vanilla code without nampower
      CastSpellByName("drain soul") -- casts drain soul if dark harvest is on cooldown
      CastSpellByName("dark harvest") -- if user us running nampower, the last spell here will be queued and cast instead of any spells before it
    elseif dETA <= 5 then
      dbg(dETA.." casting drain soul")
      CastSpellByName("drain soul")
    elseif not hasCurse or not hasAgony then
      dbg(dETA.." casting curse")
      CastSpellByName(EineClassDB.curse)
    elseif not hasCorrupt then
      dbg(dETA.." casting corruption")
      CastSpellByName("corruption")
    else
      dbg(dETA.." casting drain soul 2")
      CastSpellByName("drain soul")
    end
  end
end

local function eineLock(curseName)
  local _TT, _TG = UnitExists("target")
  local _TA = Cursive.curses:HasCurse("curse of agony", _TG, 0)
  local _TS = Cursive.curses:HasCurse("curse of shadow", _TG, 0)
  local _TC = Cursive.curses:HasCurse("corruption", _TG, 0)
  local _TV = Cursive.curses:HasCurse("shadow vulnerability", _TG, 0)
  local _TE = Eine_DeathETA()
  print(_TE)
  if(_TT) then
    if(Eine_IsBuff("Spell_Shadow_Twilight")) then
      CastSpellByName("Shadow Bolt")
    else
      if(_TA and _TC) then
        if(_TE <= 8) then
          CastSpellByName("Dark Harvest")
        else
          CastSpellByName("Drain Soul")
        end
      else
        if(_TE <= 5) then
          CastSpellByName("Drain Soul")
        elseif(_TE <= 10 and (_TA or _TC)) then
          Cursive:Curse(curseName, _TG, {refreshtime=4})
          Cursive:Curse("curse of agony", _TG, {refreshtime=4})
          Cursive:Curse("Corruption", _TG, {refreshtime=4})
          CastSpellByName("Dark Harvest")
        end
        Cursive:Curse(curseName, _TG, {})
        Cursive:Curse("curse of agony", _TG, {})
        Cursive:Curse("Corruption", _TG, {})
      end
    end
  end
end

local function zweiLock(curseName)
  local _TT, _TG = UnitExists("target")
  local _TC = Cursive.curses:HasCurse(curseName, _TG, 0)
  local _TI = Cursive.curses:HasCurse("immolate", _TG, 0)
  local _TE = Eine_DeathETA()
  local _TD = UnitXP("distanceBetween", "player", "target")
  local _TS = UnitXP("inSight", "player", "target")
  print(_TE)
  
  if(_TT and _TE <= 4 and F_.lastShadowburn + 15 <= GetTime() and _TD < 24 and _TS) then
    CastSpellByName("Shadowburn")
    F_.lastShadowburn = GetTime()
  elseif((not Eine_IsBuff("Spell_Fire_Fireball02") and not UnitAffectingCombat("player")) or (not Eine_IsBuff("Spell_Fire_Fireball02") and _TE >= 5)) then
    CastSpellByName("Soul Fire")
  elseif(_TE >= 15 and not _TC) then
    Cursive:Curse(curseName, _TG, {refreshtime=1})
  else
    Cursive:Curse("immolate", _TG, {refreshtime=1})
    CastSpellByName("Conflagrate")
    CastSpellByName("Searing Pain")
  end
end