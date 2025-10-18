-- Adds "Player Names" button to PVP scoreboard for copying all player names.
-- Extracts names by scrolling through content and searching frame hierarchy.

local namesDialog = nil

-- Show or toggle player names dialog
local function showPlayerNamesDialog(playerNames)
  if namesDialog and namesDialog:IsShown() then
    namesDialog:Hide()
    return
  end

  if namesDialog then
    local namesText = table.concat(playerNames, "\n")
    namesDialog.input:SetText(namesText)
    namesDialog.input:SetCursorPosition(0)
    namesDialog:Show()
    return
  end

  local dialog = CreateFrame("Frame", nil, UIParent, "BasicFrameTemplateWithInset")
  dialog:SetSize(500, 400)
  dialog:SetPoint("CENTER")
  dialog:SetMovable(true)
  dialog:EnableMouse(true)
  dialog:RegisterForDrag("LeftButton")
  dialog:SetScript("OnDragStart", dialog.StartMoving)
  dialog:SetScript("OnDragStop", dialog.StopMovingOrSizing)
  dialog:SetFrameStrata("DIALOG")
  dialog:SetFrameLevel(100)

  dialog.title = dialog:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  dialog.title:SetPoint("TOP", dialog.TitleBg, "TOP", 0, -5)
  dialog.title:SetText("Player Names")

  local scrollFrame = CreateFrame("ScrollFrame", nil, dialog, "UIPanelScrollFrameTemplate")
  scrollFrame:SetPoint("TOPLEFT", dialog, "TOPLEFT", 12, -30)
  scrollFrame:SetPoint("BOTTOMRIGHT", dialog, "BOTTOMRIGHT", -30, 50)

  local input = CreateFrame("EditBox", nil, scrollFrame)
  input:SetMultiLine(true)
  input:SetMaxLetters(0)
  input:SetFontObject(GameFontHighlight)
  input:SetWidth(scrollFrame:GetWidth() - 20)
  input:SetHeight(5000)
  input:SetAutoFocus(false)
  input:SetScript("OnEscapePressed", function() dialog:Hide() end)

  scrollFrame:SetScrollChild(input)
  
  local namesText = table.concat(playerNames, "\n")
  input:SetText(namesText)
  input:SetCursorPosition(0)

  local helpText = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  helpText:SetPoint("BOTTOM", dialog, "BOTTOM", 0, 20)
  helpText:SetText("Press Ctrl+C (Cmd+C on macOS) to copy the names.")

  dialog.input = input
  namesDialog = dialog
  dialog:Show()
end

-- Extract player names from scoreboard content
local function extractPlayerNames(contentFrame, callback)
  if not contentFrame then
    callback({})
    return
  end

  local playerNames = {}
  local foundNames = {}

  local function searchFrameHierarchy(frame)
    if not frame then
      return
    end

    if frame.text and type(frame.text) == "table" and frame.text.GetText then
      local text = frame.text:GetText()
      
      if text and not text:match("%d") and text ~= "Name" and text ~= "Deaths" then
        local isPlayerName = text:match("^[%a]+%-?[%a]*$")
        
        if isPlayerName and text ~= "" and not foundNames[text] then
          foundNames[text] = true
          table.insert(playerNames, text)
        end
      end
    end

    local children = {frame:GetChildren()}
    for _, child in ipairs(children) do
      searchFrameHierarchy(child)
    end
  end

  -- Scroll through content to render all entries
  if contentFrame.scrollBox then
    local scrollBox = contentFrame.scrollBox
    
    pcall(function()
      if scrollBox.ScrollToBegin then
        scrollBox:ScrollToBegin()
      end
    end)
    
    C_Timer.After(0.1, function()
      pcall(function()
        if scrollBox.ScrollToEnd then
          scrollBox:ScrollToEnd()
        end
      end)
      
      C_Timer.After(0.1, function()
        pcall(function()
          if scrollBox.ScrollToBegin then
            scrollBox:ScrollToBegin()
          end
        end)
        
        C_Timer.After(0.1, function()
          searchFrameHierarchy(contentFrame)
          callback(playerNames)
        end)
      end)
    end)
  else
    searchFrameHierarchy(contentFrame)
    callback(playerNames)
  end
end

-- Create player names button
local function createPlayerNamesButton(parentFrame)
  if not parentFrame or parentFrame.bentoNamesButton then
    return
  end

  local button = CreateFrame("Button", nil, parentFrame, "UIPanelButtonTemplate")
  button:SetSize(120, 25)
  button:SetText("Player Names")
  
  if parentFrame.leaveButton then
    button:SetPoint("LEFT", parentFrame.leaveButton, "RIGHT", 5, 0)
  else
    button:SetPoint("BOTTOMLEFT", parentFrame, "BOTTOMLEFT", 10, 10)
  end
  
  button:SetScript("OnClick", function()
    if InCombatLockdown() then
      return
    end

    local contentFrame = parentFrame.Content or parentFrame.content
    if contentFrame then
      extractPlayerNames(contentFrame, function(playerNames)
        if #playerNames > 0 then
          showPlayerNamesDialog(playerNames)
        end
      end)
    end
  end)

  parentFrame.bentoNamesButton = button
end

-- Setup buttons on scoreboard frames
local function setupButtons()
  if PVPMatchScoreboard then
    createPlayerNamesButton(PVPMatchScoreboard)
  end
  
  if PVPMatchResults then
    createPlayerNamesButton(PVPMatchResults)
  end
end

-- Initialize on PVPUI load
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(_, _, addonName)
  if addonName == "Blizzard_PVPUI" then
    setupButtons()
    
    if PVPMatchScoreboard then
      PVPMatchScoreboard:HookScript("OnShow", function()
        if not PVPMatchScoreboard.bentoNamesButton then
          createPlayerNamesButton(PVPMatchScoreboard)
        end
      end)
    end
    
    if PVPMatchResults then
      PVPMatchResults:HookScript("OnShow", function()
        if not PVPMatchResults.bentoNamesButton then
          createPlayerNamesButton(PVPMatchResults)
        end
      end)
    end
    
    eventFrame:UnregisterEvent("ADDON_LOADED")
  end
end)

setupButtons()
