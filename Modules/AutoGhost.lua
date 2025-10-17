-- Automatically releases spirit in PvP zones to reduce downtime

local RELEASE_DELAY = 0.1

local function releaseSpiritInPvp()
  
  -- Skip when self-resurrection is available
  if C_DeathInfo and C_DeathInfo.GetSelfResurrectOptions then
    local selfResOptions = C_DeathInfo.GetSelfResurrectOptions()
    if selfResOptions and #selfResOptions > 0 then
      return
    end
  end

  -- Only release in PvP zones or combat zones
  local _, instanceType = IsInInstance()
  local zonePvp = GetZonePVPInfo()
  if instanceType ~= "pvp" and zonePvp ~= "combat" then
    return
  end

  -- Delay to allow death UI to initialize
  C_Timer.After(RELEASE_DELAY, function()
    if not UnitIsDead("player") or UnitIsGhost("player") then
      return
    end

    if RepopMe then
      RepopMe()
      return
    end

    if StaticPopup_FindVisible then
      local deathDialog = StaticPopup_FindVisible("DEATH")
      if deathDialog and deathDialog.button1 and deathDialog.button1:IsEnabled() then
        deathDialog.button1:Click()
      end
    end
  end)
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_DEAD")
eventFrame:SetScript("OnEvent", releaseSpiritInPvp)
