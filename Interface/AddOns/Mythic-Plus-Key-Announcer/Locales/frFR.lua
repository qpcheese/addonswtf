local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:NewLocale("MythicPlusKeyAnnouncer", "frFR")
if not L then return end

L["Mythic Plus Key Announcer"] = "Annonceur de clés Mythiques"
L["Show popup on join"] = "Afficher la fenêtre à la jonction"
L["Message Color"] = "Couleur du message"
L["Announcement Channel"] = "Canal d'annonce"
L["Whisper (requires target)"] = "Chuchoter (nécessite une cible)"
L["Channel (requires channel number)"] = "Canal (nécessite un numéro de canal)"
L["Target"] = "Cible"
L["Test Announcement"] = "Annonce de test"
L["Configure how group announcements are sent and displayed."] =
"Configurer comment les annonces de groupe sont envoyées et affichées."
L["Say"] = "Dire"
L["Party"] = "Groupe"
L["Raid"] = "Raid"
L["Guild"] = "Guilde"
L["Instance"] = "Instance"
L["Yell"] = "Crier"
L["Test the configured announcement and popup."] = "Testez l'annonce configurée et la fenêtre contextuelle."
L["Show a popup window when you join a Mythic+ group."] =
"Afficher une fenêtre contextuelle lorsque vous rejoignez un groupe Mythic+."
L["Set the color for the group filled chat message."] = "Définir la couleur du message de chat de groupe rempli."
L["Send chat announcements"] = "Envoyer les annonces au chat"
L["Toggle sending announcements to chat; when disabled only the popup will appear (if enabled)."] =
"Basculer l'envoi des annonces au chat ; lorsqu'il est désactivé, seule la fenêtre contextuelle apparaîtra (si activée)."
L["Announcements are disabled; popup only."] = "Les annonces sont désactivées ; seule la fenêtre contextuelle."
L["Joined Mythic+ Group"] = "Groupe Mythic+ rejoint"
L["No whisper target set; sending to SAY."] = "Aucune cible de chuchotement définie ; envoi en DIT."
L["Invalid channel number; sending to SAY."] = "Numéro de canal invalide ; envoi en DIT."
L["Mythic Plus Key Group:"] = "Groupe de Clef Mythique :"
L["No recent group found."] = "Aucun groupe récent trouvé."
L["Re-sent last announcement."] = "Dernière annonce renvoyée."
L["No plain announcement available to resend."] = "Aucune annonce simple disponible pour renvoyer."
L["Announcement channel set to %s"] = "Canal d'annonce défini sur %s"

return L
