local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:NewLocale("MythicPlusKeyAnnouncer", "esES")
if not L then return end

L["Mythic Plus Key Announcer"] = "Anunciador de Llaves Míticas"
L["Show popup on join"] = "Mostrar ventana al unirse"
L["Message Color"] = "Color del mensaje"
L["Announcement Channel"] = "Canal de anuncio"
L["Whisper (requires target)"] = "Susurro (requiere objetivo)"
L["Channel (requires channel number)"] = "Canal (requiere número de canal)"
L["Target"] = "Objetivo"
L["Test Announcement"] = "Anuncio de prueba"
L["Configure how group announcements are sent and displayed."] =
"Configura cómo se envían y muestran los anuncios de grupo."
L["Say"] = "Decir"
L["Party"] = "Grupo"
L["Raid"] = "Banda"
L["Guild"] = "Hermandad"
L["Instance"] = "Instancia"
L["Yell"] = "Grito"
L["Test the configured announcement and popup."] =
"Envía un anuncio de prueba usando la configuración actual y muestra la ventana emergente."
L["Show a popup window when you join a Mythic+ group."] =
"Muestra una ventana emergente cuando te unes a un grupo Mítica+."
L["Set the color for the group filled chat message."] = "Establece el color del mensaje de chat de grupo completado."
L["Send chat announcements"] = "Enviar anuncios al chat"
L["Toggle sending announcements to chat; when disabled only the popup will appear (if enabled)."] =
"Alterna enviar anuncios al chat; cuando está desactivado solo aparecerá la ventana emergente (si está activada)."
L["Announcements are disabled; popup only."] = "Los anuncios están desactivados; solo la ventana emergente."
L["Joined Mythic+ Group"] = "Unido a grupo Mítica+"
L["No whisper target set; sending to SAY."] = "No se estableció un objetivo para susurrar; enviando a DECIR."
L["Invalid channel number; sending to SAY."] = "Número de canal inválido; enviando a DECIR."
L["Mythic Plus Key Group:"] = "Grupo de Llave Mítica:"
L["No recent group found."] = "No se encontró un grupo reciente."
L["Re-sent last announcement."] = "Reenviado el último anuncio."
L["No plain announcement available to resend."] = "No hay anuncio simple disponible para reenviar."
L["Announcement channel set to %s"] = "Canal de anuncio establecido a %s"

return L
