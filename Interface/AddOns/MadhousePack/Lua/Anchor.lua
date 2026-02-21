local alertAnchor = AceGUI:Create("Anchor", { name = "MHAlarmAnchor" })
alertAnchor:SetWidth(300)
alertAnchor:SetHeight(100)
alertAnchor:SetTitle(isGerman and "Alarm Anker" or "Alert Anchor")
alertAnchor:Show()

local messageAnchor = AceGUI:Create("Anchor", { name = "MHMessageAnchor" })
messageAnchor:SetWidth(300)
messageAnchor:SetHeight(100)
messageAnchor:SetTitle(isGerman and "Nachrichten Anker" or "Message Anchor")
messageAnchor:Show()



Madhouse.anchor = {
    alertAnchor,
    messageAnchor
}
