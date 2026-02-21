local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:NewLocale("MythicPlusKeyAnnouncer", "enUS", true)
if not L then return end

L["Mythic Plus Key Announcer"] = "Mythic Plus Key Announcer"
L["Show popup on join"] = "Show popup on join"
L["Message Color"] = "Message Color"
L["Announcement Channel"] = "Announcement Channel"
L["Whisper (requires target)"] = "Whisper (requires target)"
L["Channel (requires channel number)"] = "Channel (requires channel number)"
L["Target"] = "Target"
L["Configure how group announcements are sent and displayed."] = "Configure how group announcements are sent and displayed."
L["Say"] = "Say"
L["Party"] = "Party"
L["Raid"] = "Raid"
L["Guild"] = "Guild"
L["Instance"] = "Instance"
L["Yell"] = "Yell"
L["Test the configured announcement and popup."] = "Test the configured announcement and popup."
L["Show a popup window when you join a Mythic+ group."] = "Show a popup window when you join a Mythic+ group."
L["Set the color for the group filled chat message."] = "Set the color for the group filled chat message."
L["Send chat announcements"] = "Send chat announcements"
L["Toggle sending announcements to chat; when disabled only the popup will appear (if enabled)."] =
"Toggle sending announcements to chat; when disabled only the popup will appear (if enabled)."
L["Announcements are disabled; popup only."] = "Announcements are disabled; popup only."
L["Test Announcement"] = "Test Announcement"
L["Joined Mythic+ Group"] = "Joined Mythic+ Group"
L["No whisper target set; sending to SAY."] = "No whisper target set; sending to SAY."
L["Invalid channel number; sending to SAY."] = "Invalid channel number; sending to SAY."
L["Mythic Plus Key Group:"] = "Mythic Plus Key Group:"
L["No recent group found."] = "No recent group found."
L["Re-sent last announcement."] = "Re-sent last announcement."
L["No plain announcement available to resend."] = "No plain announcement available to resend."
L["Announcement channel set to %s"] = "Announcement channel set to %s"

return L
