-- Automatically sends whisper messages to players invited to WoW communities

local eventFrame = CreateFrame("Frame")

local waitingForPopup = false
local waitingForConfirm = false
local checkStartTime = 0

local INVITE_PATTERN = "You have invited (.+) to join"

local function whisperPlayer(playerName)
    if BentoShortcutsDB.autoWhisperEnabled and playerName and BentoShortcutsDB.whisperMessage ~= "" then
        SendChatMessage(BentoShortcutsDB.whisperMessage, "WHISPER", nil, playerName)
        print("Bento Shortcuts: Whispered " .. playerName)
    end
end

local function parsePlayerName(message)
    return string.match(message, INVITE_PATTERN)
end

local function createSettingsPopup()
    local popup = CreateFrame("Frame", "BentoShortcutsInvitePopup", UIParent, "BasicFrameTemplateWithInset")
    popup:SetSize(400, 200)
    popup:SetFrameStrata("DIALOG")
    popup:SetFrameLevel(1000)
    popup:Hide()
    
    popup.title = popup:CreateFontString(nil, "OVERLAY")
    popup.title:SetFontObject("GameFontHighlight")
    popup.title:SetPoint("CENTER", popup.TitleBg, "CENTER", 0, 0)
    popup.title:SetText("Bento Invite Whisper Settings")
    
    local label = popup:CreateFontString(nil, "OVERLAY")
    label:SetFontObject("GameFontNormal")
    label:SetPoint("TOPLEFT", popup, "TOPLEFT", 20, -35)
    label:SetText("Welcome message:")
    
    local input = CreateFrame("EditBox", nil, popup)
    input:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -8)
    input:SetSize(352, 80)
    input:SetMultiLine(true)
    input:SetMaxLetters(255)
    input:SetAutoFocus(false)
    input:SetFontObject("ChatFontNormal")
    
    local checkbox = CreateFrame("CheckButton", nil, popup, "UICheckButtonTemplate")
    checkbox:SetSize(20, 20)
    checkbox:SetPoint("BOTTOMLEFT", popup, "BOTTOMLEFT", 20, 50)
    
    local checkboxLabel = popup:CreateFontString(nil, "OVERLAY")
    checkboxLabel:SetFontObject("GameFontNormal")
    checkboxLabel:SetPoint("LEFT", checkbox, "RIGHT", 4, 0)
    checkboxLabel:SetText("Auto-whisper after inviting players")
    
    local cancelButton = CreateFrame("Button", nil, popup, "GameMenuButtonTemplate")
    cancelButton:SetSize(80, 25)
    cancelButton:SetPoint("BOTTOMLEFT", popup, "BOTTOMLEFT", 20, 20)
    cancelButton:SetText("Cancel")
    
    local saveButton = CreateFrame("Button", nil, popup, "GameMenuButtonTemplate")
    saveButton:SetSize(80, 25)
    saveButton:SetPoint("BOTTOMRIGHT", popup, "BOTTOMRIGHT", -20, 20)
    saveButton:SetText("Save")
    
    local originalMessage, originalEnabled
    
    local function initControls()
        originalMessage = BentoShortcutsDB.whisperMessage
        originalEnabled = BentoShortcutsDB.autoWhisperEnabled
        input:SetText(originalMessage)
        checkbox:SetChecked(originalEnabled)
    end
    
    cancelButton:SetScript("OnClick", function()
        input:SetText(originalMessage)
        checkbox:SetChecked(originalEnabled)
        popup:Hide()
    end)
    
    saveButton:SetScript("OnClick", function()
        BentoShortcutsDB.whisperMessage = input:GetText()
        BentoShortcutsDB.autoWhisperEnabled = checkbox:GetChecked()
        originalMessage = BentoShortcutsDB.whisperMessage
        originalEnabled = BentoShortcutsDB.autoWhisperEnabled
        print("Bento Shortcuts: Settings saved")
        popup:Hide()
    end)
    
    popup.initControls = initControls
    return popup
end

local settingsPopup = createSettingsPopup()

local function showSettings()
    if not CommunitiesFrame or not CommunitiesFrame:IsShown() then
        return
    end
    
    settingsPopup.initControls()
    settingsPopup:ClearAllPoints()
    settingsPopup:SetPoint("BOTTOMLEFT", CommunitiesFrame, "BOTTOMRIGHT", 10, 0)
    settingsPopup:Show()
end

local function createSettingsButton()
    if not CommunitiesFrame or not CommunitiesFrame.CommunitiesControlFrame then
        return
    end
    
    if CommunitiesFrame.BentoShortcutsButton then
        return
    end
    
    local button = CreateFrame("Button", nil, CommunitiesFrame.CommunitiesControlFrame, "GameMenuButtonTemplate")
    button:SetSize(100, 20)
    button:SetText("Whisper Settings")
    button:GetFontString():SetTextColor(1, 0.82, 0)
    button:SetPoint("BOTTOMLEFT", CommunitiesFrame, "BOTTOMLEFT", 8, 4)
    
    button:SetScript("OnClick", function()
        if settingsPopup:IsShown() then
            settingsPopup:Hide()
        else
            showSettings()
        end
    end)
    
    CommunitiesFrame.BentoShortcutsButton = button
end

local function updateCommunityFrame()
    if CommunitiesFrame then
        if CommunitiesFrame:IsShown() then
            createSettingsButton()
        else
            settingsPopup:Hide()
        end
    end
end

local function checkPopup()
    if StaticPopup1 and StaticPopup1:IsShown() then
        waitingForPopup = false
        if StaticPopup1Button1 then
            StaticPopup1Button1:HookScript("OnClick", function()
                waitingForConfirm = true
                checkStartTime = GetTime()
            end)
        end
    elseif GetTime() - checkStartTime > 5 then
        waitingForPopup = false
    end
end

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("CHAT_MSG_SYSTEM")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addon = ...
        if addon == "Bento-Shortcuts" then
            BentoShortcutsDB = BentoShortcutsDB or {}
            BentoShortcutsDB.whisperMessage = BentoShortcutsDB.whisperMessage or "Welcome to our community! Feel free to ask questions."
            BentoShortcutsDB.autoWhisperEnabled = BentoShortcutsDB.autoWhisperEnabled ~= false
            print("Bento Shortcuts: Type /bs for commands")
        end
    elseif event == "CHAT_MSG_SYSTEM" then
        local message = ...
        if waitingForConfirm and message then
            local playerName = parsePlayerName(message)
            if playerName then
                waitingForConfirm = false
                C_Timer.After(1, function()
                    whisperPlayer(playerName)
                end)
            elseif GetTime() - checkStartTime > 10 then
                waitingForConfirm = false
            end
        end
    end
end)

local function hookInviteButton()
    if CommunitiesFrame and CommunitiesFrame:IsShown() and CommunitiesFrame.InviteButton then
        if not CommunitiesFrame.InviteButton.hookedBentoWhisper then
            CommunitiesFrame.InviteButton:HookScript("OnClick", function()
                waitingForPopup = true
                checkStartTime = GetTime()
            end)
            CommunitiesFrame.InviteButton.hookedBentoWhisper = true
        end
    end
end

eventFrame:SetScript("OnUpdate", function()
    hookInviteButton()
    updateCommunityFrame()
    
    if waitingForPopup then
        checkPopup()
    end
end)

SLASH_BENTOSHORTCUTS1 = "/bs"
SLASH_BENTOSHORTCUTS2 = "/bentoshortcuts"
SlashCmdList["BENTOSHORTCUTS"] = function(msg)
    local command = msg:lower():trim()
    
    if command == "" or command == "help" then
        print("Bento Shortcuts commands:")
        print("/bs toggle - Enable/disable auto-whisper")
        print("/bs message <text> - Set whisper message")
        print("/bs show - Show current settings")
        print("/bs config - Open settings window")
    elseif command == "toggle" then
        BentoShortcutsDB.autoWhisperEnabled = not BentoShortcutsDB.autoWhisperEnabled
        local status = BentoShortcutsDB.autoWhisperEnabled and "enabled" or "disabled"
        print("Bento Shortcuts: Auto-whisper " .. status)
    elseif command:match("^message ") then
        local message = msg:match("^message (.+)")
        if message then
            BentoShortcutsDB.whisperMessage = message
            print("Bento Shortcuts: Message updated")
        else
            print("Bento Shortcuts: Usage /bs message <text>")
        end
    elseif command == "show" then
        print("Bento Shortcuts settings:")
        print("Auto-whisper: " .. (BentoShortcutsDB.autoWhisperEnabled and "enabled" or "disabled"))
        print("Message: " .. (BentoShortcutsDB.whisperMessage or "none"))
    elseif command == "config" then
        if CommunitiesFrame and CommunitiesFrame:IsShown() then
            showSettings()
        else
            print("Bento Shortcuts: Open Communities frame first")
        end
    else
        print("Bento Shortcuts: Unknown command, type /bs help for commands")
    end
end
