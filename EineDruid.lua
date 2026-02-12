local FeralBear, FeralBleed, FeralNoBleed

_Eine.init.DRUID = function(opts)
  _Eine.subcmds["feral bear"] = {
    description = "Maul or Reshift if not enough energy",
    fn = FeralBear
  }
  
  _Eine.subcmds["feral bleed"] = {
    description = "Prowl if out of combat, Tiger's Fury, Pounce, Rake if high HP, Rip if 1 point and high HP, Claw or Shred if behind, Ferocious Bite if target low HP or at 5 points",
    fn = FeralBleed
  }
  
  _Eine.subcmds["feral nobleed"] = {
    description = "Prowl if out of combat, Tiger's Fury, Ravage, Claw or Shred if behind, Ferocious Bite if target low HP or at 5 points",
    fn = FeralNoBleed
  }
  
  _Eine.genesisSet = 0
  _Eine.cenarionSet = 0
  if (helm ~= nil) then
    if (string.find(helm, "Genesis Helmet")) then
      _Eine.genesisSet = _Eine.genesisSet + 1
    elseif (string.find(helm, "Cenarion Helmet")) then
      _Eine.cenarionSet = _Eine.cenarionSet + 1
    end
  end
  if (shoulder ~= nil) then
    if (string.find(shoulder, "Genesis Shoulderpads")) then
      _Eine.genesisSet = _Eine.genesisSet + 1
    elseif (string.find(shoulder, "Cenarion Shoulderpads")) then
      _Eine.cenarionSet = _Eine.cenarionSet + 1
    end
  end
  if (chest ~= nil) then
    if (string.find(chest, "Genesis Raiments")) then
      _Eine.genesisSet = _Eine.genesisSet + 1
    elseif (string.find(chest, "Cenarion Raiments")) then
      _Eine.cenarionSet = _Eine.cenarionSet + 1
    end
  end
  if (belt ~= nil) then
    if (string.find(belt, "Genesis Girdle")) then
      _Eine.genesisSet = _Eine.genesisSet + 1
    elseif (string.find(belt, "Cenarion Girdle")) then
      _Eine.cenarionSet = _Eine.cenarionSet + 1
    end
  end
  if (pants ~= nil) then
    if (string.find(pants, "Genesis Pants")) then
      _Eine.genesisSet = _Eine.genesisSet + 1
    elseif (string.find(pants, "Cenarion Pants")) then
      _Eine.cenarionSet = _Eine.cenarionSet + 1
    end
  end
  if (boots ~= nil) then
    if (string.find(boots, "Genesis Treads")) then
      _Eine.genesisSet = _Eine.genesisSet + 1
    elseif (string.find(boots, "Cenarion Treads")) then
      _Eine.cenarionSet = _Eine.cenarionSet + 1
    end
  end
  if (bracers ~= nil) then
    if (string.find(bracers, "Genesis Wristguards")) then
      _Eine.genesisSet = _Eine.genesisSet + 1
    elseif (string.find(bracers, "Cenarion Wristguards")) then
      _Eine.cenarionSet = _Eine.cenarionSet + 1
    end
  end
  if (gloves ~= nil) then
    if (string.find(gloves, "Genesis Handguards")) then
      _Eine.genesisSet = _Eine.genesisSet + 1
    elseif (string.find(gloves, "Cenarion Handguards")) then
      _Eine.cenarionSet = _Eine.cenarionSet + 1
    end
  end
  
  -- 757.8 potent venom 2.6%
  -- 756.2 hoj ?%
  -- 732 whip
  local _, _, _, _, natShifterCurrRank, _ = GetTalentInfo(1, 8)
  local _, _, _, _, ferocityCurrRank, _ = GetTalentInfo(2, 1)
  local _, intelligence = UnitStat("player", 4)
  local maxMana = UnitManaMax("player")
  local extraMana = 0
  if (Eine_IsBuff("Flask_of_Wisdom")) then
    extraMana = 2000
  end
  local baseMana = maxMana - min(20, intelligence) - 15 * (intelligence - min(20, intelligence)) - extraMana
  _Eine.shiftCost = math.floor((baseMana * .35) * (1 - (natShifterCurrRank * .10)))
  _Eine.maulCost = 15 - ferocityCurrRank
  _Eine.swipeCost = 20 - ferocityCurrRank
  
  if (idol ~= nil and string.find(idol, "Idol of Brutality")) then
    _Eine.maulCost = _Eine.maulCost - 3
    _Eine.swipeCost = _Eine.swipeCost - 3
  end
  
  if _Eine.firstLoad then
    DEFAULT_CHAT_FRAME:AddMessage(_Color.g.."•••••|r ".._Color.w.."Loaded EineClass (|r".._Eine.classText.._Color.w..")|r ".._Color.g.."•••••|r")
  end
end

function FeralBear(opts)
  if (opts.energy < _Eine.maulCost and _Eine.maulCost <= 10 and not isBuff("Ability_Druid_Enrage") and not isBuff("Spell_Shadow_UnholyFrenzy")) then
    CastSpellByName("Reshift")
  else
    CastSpellByName("Maul")
  end
end

function FeralBleed(opts)
  opts.energy, opts.mana = UnitMana("player")
  opts.isReshiftable = _Eine.shiftCost <= opts.mana
  local isStealth = Eine_IsBuff("Ability_Ambush")
  local isFury = isBuff("Ability_Mount_JungleTiger")
  local furyBonus = 0
  if isFury then
    furyBonus = 50
  end
  if (not UnitAffectingCombat("player") and not isStealth and EineClassDB.OOCStealth and GetSpellCooldown("prowl") == 0) then
    dbg("casting prowl")
    CastSpellByName("prowl")
  end
  
  if not isFury then
    if (opts.energy < 30 and opts.isReshiftable) then
      dbg("casting reshift", GetSpellCooldown("reshift") == 0)
      CastSpellByName("reshift")
    else
      dbg("casting tigers fury")
      CastSpellByName("tiger's fury")
      _Eine.lastFury = opts.time
    end
  elseif not _Eine.lastFury or opts.time - _Eine.lastFury > 9 then
    if (opts.energy < 30 and opts.isReshiftable) then
      dbg("casting early reshift", GetSpellCooldown("reshift") == 0)
      CastSpellByName("reshift")
    end
  end
  
  if opts.isTarget then
    opts.pts = GetComboPoints()
    opts.isClearcast = isBuff("Spell_Shadow_ManaBurn")
    local baseAP, posBuffAP, negBuffAP = UnitAttackPower("player")
    local ap = baseAP + posBuffAP + negBuffAP
    if (opts.isClearcast) then
      opts.fbAdditionalEnergy = opts.energy
    else
      opts.fbAdditionalEnergy = opts.energy - 35
    end
    local _, _, _, _, aggressionCurrRank, _ = GetTalentInfo(2, 2)
    local isSunder, sunderCount = isDebuff("Ability_Warrior_Sunder")
    local isFF = isDebuff("Spell_Nature_FaerieFire")
    local isReckless = isDebuff("Spell_Shadow_UnholyStrength")
    local expectedArmor = 50*UnitLevel("target")
    if expectedArmor < 0 then
      expectedArmor = 3731
    end
    expectedArmor = expectedArmor - sunderCount*450
    if (isFF) then
      expectedArmor = expectedArmor - 505
    end
    
    if (isReckless) then
      expectedArmor = expectedArmor - 640
    end
    
    -- rank 6 ferocious bite has a 2.7 damage per energy ratio, 52 flat damage, and 147 damage per combo point
    opts.fbDMG = math.floor(
      (1 - expectedArmor/ (expectedArmor + 400 + 85 * UnitLevel("player"))) * (ap * 0.1526 + opts.fbAdditionalEnergy * 2.7 + opts.pts * 147 + 52 + furyBonus) * (1 + aggressionCurrRank * .03)
    )
    
    if (_Eine.genesisSet == 5) then
      opts.fbDMG = opts.fbDMG*1.15
    end
    
    local fbETA = Eine_DeathETA(opts.fbDMG)
    local dETA = Eine_DeathETA()
    local hasRip = Cursive.curses:HasCurse("rip", opts.targetGUID, 0)
    
    if isStealth then
      dbg("casting pounce")
      CastSpellByName("pounce")
    end
    
    if (opts.pts > 0 and fbETA <= 1) or (opts.pts >= 5 and hasRip) then
      dbg("casting ferocious bite", GetSpellCooldown("ferocious bite") == 0 and (opts.energy >= 35 or opts.isClearcast))
      CastSpellByName("ferocious bite")
    elseif ((EineClassDB.smallBleed and opts.pts > 0 and not hasRip) or (opts.pts >= 5 and not hasRip)) and dETA >= 15 then
      dbg("casting rip", GetSpellCooldown("rip") == 0 and (opts.energy >= 30 or opts.isClearcast))
      CastSpellByName("rip")
    elseif not Cursive.curses:HasCurse("rake", opts.targetGUID, 0) and dETA >= 6 then
      dbg("casting rake", GetSpellCooldown("rake") == 0 and (opts.energy >= 32 or opts.isClearcast))
      CastSpellByName("rake")
    elseif opts.isBehind then
      dbg("casting shred", GetSpellCooldown("shred") == 0 and (opts.energy >= 45 or opts.isClearcast))
      CastSpellByName("shred")
    else
      dbg("casting claw", GetSpellCooldown("claw") == 0 and (opts.energy >= 37 or opts.isClearcast))
      CastSpellByName("claw")
    end
  end
end

function FeralNoBleed(opts)
  opts.energy, opts.mana = UnitMana("player")
  opts.isReshiftable = _Eine.shiftCost <= opts.mana
  local isStealth = Eine_IsBuff("Ability_Ambush")
  local isFury = isBuff("Ability_Mount_JungleTiger")
  local isFrenzy = isBuff("Ability_GhoulFrenzy")
  local furyBonus = 0
  if isFury then
    furyBonus = 50
  end
  if (not UnitAffectingCombat("player") and not isStealth and EineClassDB.OOCStealth and GetSpellCooldown("prowl") == 0) then
    dbg("casting prowl")
    CastSpellByName("prowl")
  end
  
  -- 560
  if not isFury then
    if (opts.energy < 30 and opts.isReshiftable) then
      dbg("casting reshift", GetSpellCooldown("reshift") == 0)
      CastSpellByName("reshift")
    else
      dbg("casting tigers fury")
      CastSpellByName("tiger's fury")
      _Eine.lastFury = opts.time
    end
  elseif not _Eine.lastFury or opts.time - _Eine.lastFury > 6 then
    if (opts.energy < 30 and opts.isReshiftable) then
      dbg("casting early reshift", GetSpellCooldown("reshift") == 0)
      CastSpellByName("reshift")
    end
  end
  
  if opts.isTarget then
    opts.pts = GetComboPoints()
    opts.isClearcast = isBuff("Spell_Shadow_ManaBurn")
    local baseAP, posBuffAP, negBuffAP = UnitAttackPower("player")
    local ap = baseAP + posBuffAP + negBuffAP
    if (opts.isClearcast) then
      opts.fbAdditionalEnergy = opts.energy
    else
      opts.fbAdditionalEnergy = opts.energy - 35 -- 35 is cost of ferocious bite
    end
    local _, _, _, _, aggressionCurrRank, _ = GetTalentInfo(2, 2)
    local isSunder, sunderCount = isDebuff("Ability_Warrior_Sunder")
    local isFF = isDebuff("Spell_Nature_FaerieFire")
    local isReckless = isDebuff("Spell_Shadow_UnholyStrength")
    local expectedArmor = 50*UnitLevel("target")
    if expectedArmor < 0 then
      expectedArmor = 3731
    end
    expectedArmor = expectedArmor - sunderCount*450
    if (isFF) then
      expectedArmor = expectedArmor - 505
    end
    
    if (isReckless) then
      expectedArmor = expectedArmor - 640
    end
    
    -- rank 6 ferocious bite has a 2.7 damage per energy ratio, 52 flat damage, and 147 damage per combo point
    opts.fbDMG = math.floor(
      (1 - expectedArmor/ (expectedArmor + 400 + 85 * UnitLevel("player"))) * (ap * 0.1526 + opts.fbAdditionalEnergy * 2.7 + opts.pts * 147 + 52 + furyBonus) * (1 + aggressionCurrRank * .03)
    )
    
    if (_Eine.genesisSet == 5) then
      opts.fbDMG = opts.fbDMG*1.15
    end
    
    local fbETA = Eine_DeathETA(opts.fbDMG)
    local dETA = Eine_DeathETA()
    local hasRip = Cursive.curses:HasCurse("rip", opts.targetGUID, 0)
    
    if isStealth then
      dbg("casting ravage")
      CastSpellByName("ravage")
    end
    
    if (opts.pts > 0 and fbETA <= 1) or opts.pts >= 5 then
      dbg("casting ferocious bite", GetSpellCooldown("ferocious bite") == 0 and (opts.energy >= 35 or opts.isClearcast))
      CastSpellByName("ferocious bite")
    elseif opts.isBehind then
      dbg("casting shred", GetSpellCooldown("shred") == 0 and (opts.energy >= 45 or opts.isClearcast))
      CastSpellByName("shred")
    else
      dbg("casting claw", GetSpellCooldown("claw") == 0 and (opts.energy >= 37 or opts.isClearcast))
      CastSpellByName("claw")
    end
  end
end