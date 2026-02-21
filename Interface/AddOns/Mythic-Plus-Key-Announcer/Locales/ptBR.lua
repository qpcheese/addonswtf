local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:NewLocale("MythicPlusKeyAnnouncer", "ptBR")
if not L then return end

L["Mythic Plus Key Announcer"] = "Anunciador de Chaves Míticas+"
L["Show popup on join"] = "Mostrar janela pop-up ao entrar"
L["Message Color"] = "Cor da mensagem"
L["Announcement Channel"] = "Canal de anúncio"
L["Whisper (requires target)"] = "Sussurro (requer alvo)"
L["Channel (requires channel number)"] = "Canal (requer número do canal)"
L["Target"] = "Alvo"
L["Configure how group announcements are sent and displayed."] = "Configure como os anúncios de grupo são enviados e exibidos."
L["Say"] = "Dizer"
L["Party"] = "Grupo"
L["Raid"] = "Raide"
L["Guild"] = "Guilda"
L["Instance"] = "Instância"
L["Yell"] = "Gritar"
L["Test the configured announcement and popup."] = "Testar a mensagem de anúncio e janela pop-up configurados."
L["Show a popup window when you join a Mythic+ group."] = "Mostra uma janela pop-up quando você entra em um Grupo de Mítica+."
L["Set the color for the group filled chat message."] = "Defina a cor para mensagem de grupo preenchido no chat."
L["Send chat announcements"] = "Enviar anúncios no chat"
L["Toggle sending announcements to chat; when disabled only the popup will appear (if enabled)."] =
"Ativa/desativa enviar anúncios no chat; quando desativado, apenas a janela pop-up irá aparecer (caso ativada)."
L["Announcements are disabled; popup only."] = "Os anúncios estão desativados; apenas janela pop-up."
L["Test Announcement"] = "Testar anúncio"
L["Joined Mythic+ Group"] = "Entrou em um Grupo de Mítica+"
L["No whisper target set; sending to SAY."] = "Nenhum alvo definido para sussurro; enviando para DIZER."
L["Invalid channel number; sending to SAY."] = "Número de canal inválido; enviando para DIZER."
L["Mythic Plus Key Group:"] = "Grupo de Chave Mítica+:"
L["No recent group found."] = "Nenhum grupo recente encontrado."
L["Re-sent last announcement."] = "Enviar novamente o último anúncio."
L["No plain announcement available to resend."] = "Nenhum anúncio simples disponível para enviar novamente."
L["Announcement channel set to %s"] = "Canal de anúncio definido como %s"

return L

