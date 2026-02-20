Merfin.RP = {
  cooldowns = {},
}

Merfin.GetCDTime = function(ID)
  if Merfin.RP.cooldowns[ID] and Merfin.RP.cooldowns[ID].expirationTime then
    return Merfin.RP.cooldowns[ID].expirationTime - GetTime()
  end
  return 0
end

Merfin.SaveCD = function(cooldown)
  if cooldown and cooldown.ID then
    local ID = cooldown.ID
    Merfin.RP.cooldowns[ID] = Merfin.RP.cooldowns[ID] or {}
    Merfin.RP.cooldowns[ID].expirationTime = cooldown.expirationTime
  end
end

Merfin.IsBossModOn = function()
  if C_AddOns.IsAddOnLoaded("BigWigs") then
    return true
  end
end
