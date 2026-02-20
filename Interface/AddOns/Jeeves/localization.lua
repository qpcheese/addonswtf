local me,ns=...
local lang=GetLocale()
local l=LibStub("AceLocale-3.0")
local L=l:NewLocale(me,"enUS",true,true)
L["Appearance of popup button"] = true
L["Ignore items under this level of quality"] = true
L["Show an example"] = true

L=l:NewLocale(me,"ptBR")
if (L) then
L["Appearance of popup button"] = "Aparecimento de bot\195\163o pop-up"
L["Ignore items under this level of quality"] = "Ignorar itens sob este n\195\173vel de qualidade"
L["Show an example"] = "Mostrar um exemplo"

return
end
L=l:NewLocale(me,"frFR")
if (L) then
L["Appearance of popup button"] = "Apparition de bouton de menu d\195\169roulant"
L["Ignore items under this level of quality"] = "Ignorer articles sous ce niveau de qualit\195\169"
L["Show an example"] = "Voir un exemple"

return
end
L=l:NewLocale(me,"deDE")
if (L) then
L["Appearance of popup button"] = "Aussehen der Pop-up-Schaltfl\195\164che"
L["Ignore items under this level of quality"] = "Gegenst\195\164nde unter dieser Qualit\195\164t ignorieren"
L["Show an example"] = "Ein Beispiel zeigen"

return
end
L=l:NewLocale(me,"itIT")
if (L) then
L["Appearance of popup button"] = "Aspetto del popup"
L["Ignore items under this level of quality"] = "Ignora gli oggetti sotto questo livello di qualit\195\160"
L["Show an example"] = "Mostra un esempio"

return
end
L=l:NewLocale(me,"koKR")
if (L) then
L["Appearance of popup button"] = "\237\140\157\236\151\133 \235\178\132\237\138\188\236\157\152 \235\170\168\236\150\145"
L["Ignore items under this level of quality"] = "\237\146\136\236\167\136\236\157\180 \236\136\152\236\164\128 \236\149\132\235\158\152\236\157\152 \237\149\173\235\170\169\236\157\132 \235\172\180\236\139\156"
L["Show an example"] = "\236\152\136\235\165\188 \235\179\180\236\157\180\234\184\176"

return
end
L=l:NewLocale(me,"esMX")
if (L) then
L["Appearance of popup button"] = "Aspecto del bot\195\179n emergente"
L["Ignore items under this level of quality"] = "No haga caso de art\195\173culos bajo este nivel de calidad"
L["Show an example"] = "Mostrar un ejemplo"

return
end
L=l:NewLocale(me,"ruRU")
if (L) then
L["Appearance of popup button"] = "\208\159\208\190\209\143\208\178\208\187\208\181\208\189\208\184\208\181 \208\178\209\129\208\191\208\187\209\139\208\178\208\176\209\142\209\137\208\181\208\179\208\190 \208\186\208\189\208\190\208\191\208\186\208\184"
L["Ignore items under this level of quality"] = "\208\152\208\179\208\189\208\190\209\128\208\184\209\128\208\190\208\178\208\176\209\130\209\140 \208\191\209\128\208\181\208\180\208\188\208\181\209\130\209\139 \208\191\208\190\208\180 \209\141\209\130\208\184\208\188 \209\131\209\128\208\190\208\178\208\189\208\181\208\188 \208\186\208\176\209\135\208\181\209\129\209\130\208\178\208\176"
L["Show an example"] = "\208\159\208\190\208\186\208\176\208\183\208\176\209\130\209\140 \208\191\209\128\208\184\208\188\208\181\209\128"

return
end
L=l:NewLocale(me,"zhCN")
if (L) then
L["Appearance of popup button"] = "\229\188\185\229\135\186\230\140\137\233\146\174\231\154\132\229\164\150\232\167\130"
L["Ignore items under this level of quality"] = "\229\156\168\229\191\189\231\149\165\232\191\153\228\184\170\232\180\168\233\135\143\230\176\180\229\185\179\231\154\132\233\161\185\231\155\174"
L["Show an example"] = "\230\152\190\231\164\186\231\154\132\228\190\139\229\173\144"

return
end
L=l:NewLocale(me,"esES")
if (L) then
L["Appearance of popup button"] = "Aspecto del bot\195\179n emergente"
L["Ignore items under this level of quality"] = "No haga caso de art\195\173culos bajo este nivel de calidad"
L["Show an example"] = "Mostrar un ejemplo"

return
end
L=l:NewLocale(me,"zhTW")
if (L) then
L["Appearance of popup button"] = "\229\189\136\229\135\186\230\140\137\233\136\149\231\154\132\229\164\150\232\167\128"
L["Ignore items under this level of quality"] = "\229\156\168\229\191\189\231\149\165\233\128\153\229\128\139\232\179\170\233\135\143\230\176\180\229\185\179\231\154\132\233\160\133\231\155\174"
L["Show an example"] = "\233\161\175\231\164\186\231\154\132\228\190\139\229\173\144"

return
end