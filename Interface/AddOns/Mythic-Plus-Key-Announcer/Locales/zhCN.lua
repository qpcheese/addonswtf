local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:NewLocale("MythicPlusKeyAnnouncer", "zhCN")
if not L then return end

L["Mythic Plus Key Announcer"] = "史诗钥石组通知器"
L["Show popup on join"] = "加入时显示弹窗"
L["Message Color"] = "消息颜色"
L["Announcement Channel"] = "公告频道"
L["Whisper (requires target)"] = "密语（需要目标）"
L["Channel (requires channel number)"] = "频道（需要频道编号）"
L["Target"] = "目标"
L["Test Announcement"] = "测试公告"
L["Configure how group announcements are sent and displayed."] = "配置组公告的发送和显示方式。"
L["Say"] = "说"
L["Party"] = "队伍"
L["Raid"] = "团队"
L["Guild"] = "公会"
L["Instance"] = "副本"
L["Yell"] = "大喊"
L["Test the configured announcement and popup."] = "使用当前设置发送测试公告并显示弹窗。"
L["Show a popup window when you join a Mythic+ group."] = "当你加入神话+ 队伍时显示弹窗。"
L["Set the color for the group filled chat message."] = "设置完成的队伍聊天消息颜色。"
L["Send chat announcements"] = "发送聊天公告"
L["Toggle sending announcements to chat; when disabled only the popup will appear (if enabled)."] =
"切换是否将公告发送到聊天；禁用时仅显示弹窗（如果启用）。"
L["Announcements are disabled; popup only."] = "公告已禁用；仅显示弹窗。"
L["Joined Mythic+ Group"] = "已加入史诗+ 小队"
L["No whisper target set; sending to SAY."] = "未设置密语目标；已改为在说话频道发送。"
L["Invalid channel number; sending to SAY."] = "频道号码无效；已改为在说话频道发送。"
L["Mythic Plus Key Group:"] = "史诗钥石队伍："
L["No recent group found."] = "未找到最近的队伍。"
L["Re-sent last announcement."] = "已重新发送最后一条公告。"
L["No plain announcement available to resend."] = "没有可重新发送的简单公告。"
L["Announcement channel set to %s"] = "公告频道已设置为 %s"

return L
