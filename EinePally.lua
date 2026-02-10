function einePally(sealName)
  local _TT, _TG = UnitExists("target")
  
  if (not _TT) then
    TargetNearestEnemy()
    _TT, _TG = UnitExists("target")
  end
  
  local buffName = string.lower("seal of "..sealName)
  local curseName = string.lower("judgement of "..sealName)
  
  if(string.lower(sealName) == "crusader") then
    buffName = string.lower("seal of the "..sealName)
    curseName = string.lower("judgement of the "..sealName)
  end
  
  local sealTexturesAssoc = {
    ["seal of wisdom"] = "Spell_Holy_RighteousnessAura",
    ["seal of righteousness"] = "Ability_Thunderbolt",
    ["seal of the crusader"] = "Spell_Holy_HolySmite",
    ["seal of justice"] = "Spell_Holy_SealOfWrath"
  }
  
  local _TC = isDebuff(sealTexturesAssoc[buffName])
  local _TE = deathETA()
  
  print(" ")
  print("targeting: ".._TG)
  print("has buff?")
  print(isBuff(sealTexturesAssoc[buffName]))
  print("has curse?")
  print(_TC)
  
  
  if(pallyLastConsecrate + 8 < GetTime()) then
    pallyLastConsecrate = GetTime()
    CastSpellByName("Consecrate")
  end
  
  if(not isBuff("Spell_Holy_BlessingOfProtection")) then
    print("  shield")
    CastSpellByName("Holy Shield")
  end
  
  if(_TT) then
    if (not isBuff(sealTexturesAssoc[buffName])) then
      print("  seal")
      CastSpellByName(buffName)
    elseif (_TC) then
      print("  strike")
      CastSpellByName("Holy Strike")
    else
      print("  judge")
      CastSpellByName("Judgement")
    end
  end
end
