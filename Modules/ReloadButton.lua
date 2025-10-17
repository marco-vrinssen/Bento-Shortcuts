-- Right-click main menu button to reload UI

local function reloadOnRightClick(_, button)
  if button == "RightButton" then 
    ReloadUI() 
  end
end

if MainMenuMicroButton then
  MainMenuMicroButton:HookScript("OnClick", reloadOnRightClick)
end