--[[
    DreamHouse - Localization
    Multi-language support for the addon
    
    Default: German (deDE)
    Supported: English (enUS/enGB), Spanish (esES/esMX), French (frFR)
]]

local addonName, DreamHouse = ...

-- Localization table
local L = {}
DreamHouse.L = L

-- Get client locale
local locale = GetLocale()

-- ============================================
-- GERMAN (Default)
-- ============================================
local deDE = {
    -- General
    ["Favorites"] = "Favoriten",
    ["Hotbar"] = "Schnellleiste",
    ["Settings"] = "Einstellungen",
    ["Unknown"] = "Unbekannt",
    ["Yes"] = "Ja",
    ["No"] = "Nein",
    ["Close"] = "Schließen",
    ["Save"] = "Speichern",
    ["Load"] = "Laden",
    ["Delete"] = "Löschen",
    ["Export"] = "Exportieren",
    ["Import"] = "Importieren",
    ["Refresh"] = "Aktualisieren",
    ["Clear"] = "Leeren",
    ["Cancel"] = "Abbrechen",
    
    -- Favorites
    ["Add to Favorites"] = "Zu Favoriten hinzufügen",
    ["Remove from Favorites"] = "Von Favoriten entfernen",
    ["X items marked"] = "%d Items markiert",
    ["Favorites from this category only"] = "Nur Favoriten aus dieser Kategorie",
    ["No favorites marked yet"] = "Du hast noch keine Favoriten markiert!",
    ["Click star or use context menu"] = "Klicke auf den Stern bei einem Item oder nutze das Rechtsklick-Menü.",
    ["No favorites available"] = "Keine Favoriten vorhanden!",
    ["No favorites in this category"] = "Keine Favoriten in dieser Kategorie!",
    ["Favorite set"] = "Favorit gesetzt",
    ["Favorite removed"] = "Favorit entfernt",
    ["You have X favorites"] = "Du hast %d Favoriten",
    
    -- Hotbar
    ["Empty Slot X"] = "Leerer Slot %d",
    ["Empty Slot"] = "Leerer Slot",
    ["In possession"] = "Im Besitz",
    ["Not available"] = "Nicht verfügbar",
    ["Quick place"] = "Schnell platzieren",
    ["Left-click: Place"] = "Linksklick: Platzieren",
    ["Right-click: Menu"] = "Rechtsklick: Menü",
    ["Drag: Rearrange"] = "Ziehen: Umsortieren",
    ["Right-click catalog item"] = "Rechtsklick auf Katalog-Item",
    ["-> 'Add to hotbar'"] = "-> 'Zur Schnellleiste'",
    ["Hotbar empty slot hint"] = "Im Katalog Rechtsklick auf ein Item und 'Zur Schnellleiste hinzufügen' wählen.",
    ["Remove from Hotbar"] = "Aus Schnellleiste entfernen",
    ["Add to Hotbar"] = "Zur Schnellleiste hinzufügen",
    ["Clear all slots"] = "Alle Slots leeren",
    ["Clear all items from hotbar?"] = "Alle Items aus der Schnellleiste entfernen?",
    ["Hotbar X/10 used"] = "Hotbar: %d / 10 belegt",
    ["Hotbar not available yet"] = "Hotbar noch nicht verfügbar",
    ["Item already in hotbar"] = "Item bereits in Schnellleiste",
    ["Hotbar full"] = "Schnellleiste voll!",
    
    -- Stats Panel
    ["Housing Statistics"] = "Housing Statistiken",
    ["Placed Decorations"] = "Platzierte Dekorationen",
    ["Storage Capacity"] = "Storage-Kapazität",
    ["Quick Info"] = "Schnellinfo",
    ["Editor"] = "Editor",
    ["Status"] = "Status",
    ["In Housing Area"] = "Im Housing-Bereich",
    ["Outside"] = "Außerhalb",
    ["Placed"] = "Platziert",
    ["Inactive"] = "Inaktiv",
    ["Stats Panel not available yet"] = "Stats-Panel noch nicht verfügbar",
    
    -- Tooltip Enhancer
    ["--- DreamHouse Info ---"] = "--- DreamHouse Info ---",
    ["Placement"] = "Platzierung",
    ["Indoor"] = "Innen",
    ["Outdoor"] = "Außen",
    ["Size"] = "Größe",
    ["Size_Tiny"] = "Winzig",
    ["Size_Small"] = "Klein",
    ["Size_Medium"] = "Mittel",
    ["Size_Large"] = "Groß",
    ["Size_Huge"] = "Riesig",
    ["Source"] = "Herkunft",
    ["Category"] = "Kategorie",
    ["Favorite"] = "Favorit",
    ["Type"] = "Typ",
    ["Type_Decoration"] = "Dekoration",
    ["Type_Room"] = "Raum",
    ["--- Placed ---"] = "--- Platziert ---",
    ["Locked"] = "Gesperrt",
    ["Cannot be removed"] = "Nicht entfernbar",
    
    -- Preset Manager
    ["Preset Manager"] = "Preset Manager",
    ["Save new preset"] = "Neues Preset speichern:",
    ["Saved Presets"] = "Gespeicherte Presets:",
    ["Presets"] = "Presets",
    ["Delete preset X?"] = "Preset '%s' wirklich löschen?",
    ["No items to save"] = "Keine Items zum Speichern gefunden!",
    ["Preset X saved"] = "Preset '%s' gespeichert! (%d Items)",
    ["No presets to export"] = "Keine Presets zum Exportieren",
    ["Import not implemented"] = "Import-Funktion noch nicht implementiert",
    ["Preset load not implemented"] = "Preset-Laden noch nicht vollständig implementiert (API-Abhängig)",
    
    -- Quality Filter
    ["Rarity"] = "Seltenheit",
    ["Select All"] = "Alle auswählen",
    ["Select None"] = "Keine auswählen",
    
    -- Vendor Database
    ["Vendor Database"] = "Vendor-Datenbank",
    ["No vendor open"] = "Kein Händler geöffnet",
    ["Unknown Vendor"] = "Unbekannter Händler",
    ["X new housing items from Y saved"] = "%d neue Housing-Items von %s gespeichert!",
    ["X housing items already known"] = "%s: %d Housing-Items bereits bekannt",
    ["No housing items at this vendor"] = "Keine Housing-Items bei diesem Händler",
    ["TomTom Waypoint"] = "TomTom Wegpunkt",
    ["Waypoint for X set"] = "Wegpunkt für %s gesetzt!",
    ["Vendor: X in Y"] = "Händler: %s in %s",
    ["No waypoint possible"] = "(Kein Wegpunkt möglich)",
    ["Statistics"] = "Statistiken",
    ["Items"] = "Items",
    ["Vendors"] = "Händler",
    ["Vendor database cleared"] = "Vendor-Datenbank geleert!",
    ["VendorDB Commands"] = "Befehle:",
    ["VendorDB not available"] = "Vendor-Datenbank nicht verfügbar",
    
    -- Source on Map
    ["Show source on map"] = "Quelle auf Karte zeigen",
    ["No map position available"] = "Keine Kartenposition verfügbar",
    ["Item not in database"] = "Dieses Item ist nicht in der Datenbank.",
    ["Visit vendor tip"] = "Tipp: Besuche den Händler, der dieses Item",
    ["Visit vendor tip2"] = "verkauft, um es automatisch zu erfassen!",
    ["No map position for item"] = "Für dieses Item konnte keine Kartenposition gefunden werden.",
    ["Source cannot be shown on map"] = "Die Quelle kann nicht auf der Karte angezeigt werden.",
    ["Source for X"] = "Quelle für %s",
    ["Visit vendor to save position"] = "(Besuche den Händler um die Position zu speichern!)",
    ["Content tracking not available"] = "Content-Tracking ist nicht verfügbar.",
    ["X has no known source"] = "%s hat keine bekannte Quelle.",
    ["Visit vendors to collect items"] = "(Besuche Händler um Items automatisch zu erfassen)",
    ["X is being tracked"] = "%s wird getrackt. Schau auf der Weltkarte nach dem Marker.",
    ["[DH] Mark as Favorite"] = "Als Favorit markieren",
    ["[DH] Remove Favorite"] = "Favorit entfernen",
    ["[DH] Add to Hotbar"] = "Zur Schnellleiste hinzufügen",
    ["[DH] Remove from Hotbar"] = "Aus Schnellleiste entfernen",
    ["[DH] Show source on map"] = "Quelle auf Karte zeigen",
    
    -- Debug Console
    ["Debug"] = "Debug",
    ["Entries"] = "Einträge",
    ["Output X entries to chat"] = "Alle %d Einträge in den Chat ausgeben",
    ["Ctrl+A = All, Ctrl+C = Copy"] = "Ctrl+A = Alles, Ctrl+C = Kopieren",
    ["Log cleared"] = "Log geleert",
    ["DreamHouse Debug Log"] = "DreamHouse Debug Log",
    ["End (X entries)"] = "Ende (%d Einträge)",
    ["Debug Log Export"] = "Debug Log Export - Ctrl+A, Ctrl+C zum Kopieren",
    ["Exported"] = "Exportiert",
    ["Console initialized"] = "Konsole initialisiert (Ctrl+A, Ctrl+C zum Kopieren)",
    ["-> Chat"] = "-> Chat",
    
    -- Core / Slash Commands
    ["Commands"] = "Befehle:",
    ["/dh debug"] = "/dh debug - Debug-Konsole ein/aus",
    ["/dh export"] = "/dh export - Debug-Log Export Popup",
    ["/dh stats"] = "/dh stats - Statistiken anzeigen",
    ["/dh favorites"] = "/dh favorites - Favoriten anzeigen",
    ["/dh hotbar"] = "/dh hotbar - Hotbar ein/aus",
    ["/dh vendordb"] = "/dh vendordb - Vendor-Datenbank Befehle",
    ["/dh reset"] = "/dh reset - Einstellungen zurücksetzen",
    ["/dh test"] = "/dh test - Test-Nachricht ins Log",
    ["Reset all settings?"] = "Alle DreamHouse-Einstellungen zurücksetzen?",
    ["Settings reset"] = "Einstellungen zurückgesetzt!",
    ["Unknown command"] = "Unbekannter Befehl. Nutze /dh help",
    ["X test messages written"] = "%d Test-Nachrichten ins Log geschrieben!",
    
    -- Editor Modes
    ["Mode_None"] = "Keiner",
    ["Mode_BasicDecor"] = "Basis-Deko",
    ["Mode_ExpertDecor"] = "Experten-Deko",
    ["Mode_Layout"] = "Layout",
    ["Mode_Customize"] = "Anpassen",
    ["Mode_Cleanup"] = "Aufräumen",
    ["Mode_ExteriorCustomization"] = "Außenbereich",
    
    -- Collections Tab
    ["Collections"] = "Kollektionen",
    ["Collection"] = "Kollektion",
    ["Collections Tab"] = "Kollektionen",
    ["Back to list"] = "Zurück zur Liste",
    ["No items in collection"] = "Keine Items in Kollektion",
    ["[DH] Add to Collection"] = "Zu Kollektion hinzufügen",
    ["Create new collection"] = "Neue Kollektion erstellen",
    ["Remove from collection"] = "Aus Kollektion entfernen",
    ["Confirm"] = "Bestätigen",
    ["Change icon"] = "Icon ändern",
    ["Rename collection"] = "Kollektion umbenennen",
    ["Rename"] = "Umbenennen",
    ["Enter new name"] = "Neuen Namen eingeben:",
    ["Collection Hotbar Mode"] = "Kollektions-Hotbar-Modus",
    ["Active"] = "Aktiv",
    ["Click to activate"] = "Klicken zum Aktivieren",
    ["Click to deactivate"] = "Klicken zum Deaktivieren",
    ["Shift+Scroll to cycle collections"] = "Shift+Mausrad zum Wechseln der Kollektionen",
    ["Set as active collection"] = "Als aktive Kollektion setzen",
    ["Remove active status"] = "Aktiv-Status entfernen",
    ["No collections available"] = "Keine Kollektionen verfügbar!",
    ["Collections not implemented"] = "Kollektionen werden in einer zukünftigen Version verfügbar sein.",
    ["Collection Sets"] = "Kollektions-Sets",
    ["Seasonal Items"] = "Saisonale Items",
    ["Limited Items"] = "Limitierte Items",
    ["Complete Sets"] = "Vollständige Sets",
    ["Incomplete Sets"] = "Unvollständige Sets",
    ["Click to create your first collection"] = "Klicke um deine erste Kollektion zu erstellen",
    ["No collections yet"] = "Noch keine Kollektionen",
    ["Create a collection to organize your decor"] = "Erstelle eine Kollektion um deine Dekorationen zu organisieren",
    ["Enter collection name"] = "Kollektions-Name eingeben:",
    ["Create"] = "Erstellen",
    ["Delete collection X?"] = "Kollektion '%s' wirklich löschen?",
    ["Select icon"] = "Icon wählen",
    ["More icons"] = "Mehr Icons...",
    ["Search atlas"] = "Atlas durchsuchen...",
    ["CHM active - disable first"] = "Deaktiviere bitte erst den KHM",
    ["CHM active"] = "KHM aktiv",
    ["Search collections"] = "Kollektionen durchsuchen...",
    ["Search items"] = "Items durchsuchen...",
    ["No search results"] = "Keine Treffer",
    
    -- 3D Preview
    ["3D Preview"] = "3D Vorschau",
    ["Click to show 3D model"] = "Klicken für 3D-Modell",
    
    -- Hotbar Slot Selection
    ["Select Slot"] = "Slot wählen",
    ["Slot"] = "Slot",
    ["Empty"] = "Leer",
}

-- ============================================
-- ENGLISH
-- ============================================
local enUS = {
    -- General
    ["Favorites"] = "Favorites",
    ["Hotbar"] = "Hotbar",
    ["Settings"] = "Settings",
    ["Unknown"] = "Unknown",
    ["Yes"] = "Yes",
    ["No"] = "No",
    ["Close"] = "Close",
    ["Save"] = "Save",
    ["Load"] = "Load",
    ["Delete"] = "Delete",
    ["Export"] = "Export",
    ["Import"] = "Import",
    ["Refresh"] = "Refresh",
    ["Clear"] = "Clear",
    ["Cancel"] = "Cancel",
    
    -- Favorites
    ["Add to Favorites"] = "Add to Favorites",
    ["Remove from Favorites"] = "Remove from Favorites",
    ["X items marked"] = "%d items marked",
    ["Favorites from this category only"] = "Favorites from this category only",
    ["No favorites marked yet"] = "You haven't marked any favorites yet!",
    ["Click star or use context menu"] = "Click on the star on an item or use the right-click menu.",
    ["No favorites available"] = "No favorites available!",
    ["No favorites in this category"] = "No favorites in this category!",
    ["Favorite set"] = "Favorite set",
    ["Favorite removed"] = "Favorite removed",
    ["You have X favorites"] = "You have %d favorites",
    
    -- Hotbar
    ["Empty Slot X"] = "Empty Slot %d",
    ["Empty Slot"] = "Empty Slot",
    ["In possession"] = "Owned",
    ["Not available"] = "Not available",
    ["Quick place"] = "Quick place",
    ["Left-click: Place"] = "Left-click: Place",
    ["Right-click: Menu"] = "Right-click: Menu",
    ["Drag: Rearrange"] = "Drag: Rearrange",
    ["Right-click catalog item"] = "Right-click on catalog item",
    ["-> 'Add to hotbar'"] = "-> 'Add to Hotbar'",
    ["Hotbar empty slot hint"] = "Right-click an item in the catalog and select 'Add to Hotbar'.",
    ["Remove from Hotbar"] = "Remove from Hotbar",
    ["Add to Hotbar"] = "Add to Hotbar",
    ["Clear all slots"] = "Clear all slots",
    ["Clear all items from hotbar?"] = "Remove all items from the hotbar?",
    ["Hotbar X/10 used"] = "Hotbar: %d / 10 used",
    ["Hotbar not available yet"] = "Hotbar not available yet",
    ["Item already in hotbar"] = "Item already in hotbar",
    ["Hotbar full"] = "Hotbar full!",
    
    -- Stats Panel
    ["Housing Statistics"] = "Housing Statistics",
    ["Placed Decorations"] = "Placed Decorations",
    ["Storage Capacity"] = "Storage Capacity",
    ["Quick Info"] = "Quick Info",
    ["Editor"] = "Editor",
    ["Status"] = "Status",
    ["In Housing Area"] = "In Housing Area",
    ["Outside"] = "Outside",
    ["Placed"] = "Placed",
    ["Inactive"] = "Inactive",
    ["Stats Panel not available yet"] = "Stats Panel not available yet",
    
    -- Tooltip Enhancer
    ["--- DreamHouse Info ---"] = "--- DreamHouse Info ---",
    ["Placement"] = "Placement",
    ["Indoor"] = "Indoor",
    ["Outdoor"] = "Outdoor",
    ["Size"] = "Size",
    ["Size_Tiny"] = "Tiny",
    ["Size_Small"] = "Small",
    ["Size_Medium"] = "Medium",
    ["Size_Large"] = "Large",
    ["Size_Huge"] = "Huge",
    ["Source"] = "Source",
    ["Category"] = "Category",
    ["Favorite"] = "Favorite",
    ["Type"] = "Type",
    ["Type_Decoration"] = "Decoration",
    ["Type_Room"] = "Room",
    ["--- Placed ---"] = "--- Placed ---",
    ["Locked"] = "Locked",
    ["Cannot be removed"] = "Cannot be removed",
    
    -- Preset Manager
    ["Preset Manager"] = "Preset Manager",
    ["Save new preset"] = "Save new preset:",
    ["Saved Presets"] = "Saved Presets:",
    ["Presets"] = "Presets",
    ["Delete preset X?"] = "Delete preset '%s'?",
    ["No items to save"] = "No items found to save!",
    ["Preset X saved"] = "Preset '%s' saved! (%d items)",
    ["No presets to export"] = "No presets to export",
    ["Import not implemented"] = "Import function not yet implemented",
    ["Preset load not implemented"] = "Preset loading not fully implemented (API dependent)",
    
    -- Quality Filter
    ["Rarity"] = "Rarity",
    ["Select All"] = "Select All",
    ["Select None"] = "Select None",
    
    -- Vendor Database
    ["Vendor Database"] = "Vendor Database",
    ["No vendor open"] = "No vendor open",
    ["Unknown Vendor"] = "Unknown Vendor",
    ["X new housing items from Y saved"] = "%d new housing items from %s saved!",
    ["X housing items already known"] = "%s: %d housing items already known",
    ["No housing items at this vendor"] = "No housing items at this vendor",
    ["TomTom Waypoint"] = "TomTom Waypoint",
    ["Waypoint for X set"] = "Waypoint for %s set!",
    ["Vendor: X in Y"] = "Vendor: %s in %s",
    ["No waypoint possible"] = "(No waypoint possible)",
    ["Statistics"] = "Statistics",
    ["Items"] = "Items",
    ["Vendors"] = "Vendors",
    ["Vendor database cleared"] = "Vendor database cleared!",
    ["VendorDB Commands"] = "Commands:",
    ["VendorDB not available"] = "Vendor database not available",
    
    -- Source on Map
    ["Show source on map"] = "Show source on map",
    ["No map position available"] = "No map position available",
    ["Item not in database"] = "This item is not in the database.",
    ["Visit vendor tip"] = "Tip: Visit the vendor that sells this item",
    ["Visit vendor tip2"] = "to automatically save its location!",
    ["No map position for item"] = "No map position could be found for this item.",
    ["Source cannot be shown on map"] = "The source cannot be shown on the map.",
    ["Source for X"] = "Source for %s",
    ["Visit vendor to save position"] = "(Visit the vendor to save the position!)",
    ["Content tracking not available"] = "Content tracking is not available.",
    ["X has no known source"] = "%s has no known source.",
    ["Visit vendors to collect items"] = "(Visit vendors to automatically collect items)",
    ["X is being tracked"] = "%s is being tracked. Look for the marker on the world map.",
    ["[DH] Mark as Favorite"] = "Mark as Favorite",
    ["[DH] Remove Favorite"] = "Remove Favorite",
    ["[DH] Add to Hotbar"] = "Add to Hotbar",
    ["[DH] Remove from Hotbar"] = "Remove from Hotbar",
    ["[DH] Show source on map"] = "Show source on map",
    
    -- Debug Console
    ["Debug"] = "Debug",
    ["Entries"] = "Entries",
    ["Output X entries to chat"] = "Output all %d entries to chat",
    ["Ctrl+A = All, Ctrl+C = Copy"] = "Ctrl+A = All, Ctrl+C = Copy",
    ["Log cleared"] = "Log cleared",
    ["DreamHouse Debug Log"] = "DreamHouse Debug Log",
    ["End (X entries)"] = "End (%d entries)",
    ["Debug Log Export"] = "Debug Log Export - Ctrl+A, Ctrl+C to copy",
    ["Exported"] = "Exported",
    ["Console initialized"] = "Console initialized (Ctrl+A, Ctrl+C to copy)",
    ["-> Chat"] = "-> Chat",
    
    -- Core / Slash Commands
    ["Commands"] = "Commands:",
    ["/dh debug"] = "/dh debug - Toggle debug console",
    ["/dh export"] = "/dh export - Debug log export popup",
    ["/dh stats"] = "/dh stats - Show statistics",
    ["/dh favorites"] = "/dh favorites - Show favorites",
    ["/dh hotbar"] = "/dh hotbar - Toggle hotbar",
    ["/dh vendordb"] = "/dh vendordb - Vendor database commands",
    ["/dh reset"] = "/dh reset - Reset settings",
    ["/dh test"] = "/dh test - Write test message to log",
    ["Reset all settings?"] = "Reset all DreamHouse settings?",
    ["Settings reset"] = "Settings reset!",
    ["Unknown command"] = "Unknown command. Use /dh help",
    ["X test messages written"] = "%d test messages written to log!",
    
    -- Editor Modes
    ["Mode_None"] = "None",
    ["Mode_BasicDecor"] = "Basic Decor",
    ["Mode_ExpertDecor"] = "Expert Decor",
    ["Mode_Layout"] = "Layout",
    ["Mode_Customize"] = "Customize",
    ["Mode_Cleanup"] = "Cleanup",
    ["Mode_ExteriorCustomization"] = "Exterior",
    
    -- Collections Tab
    ["Collections"] = "Collections",
    ["Collection"] = "Collection",
    ["Collections Tab"] = "Collections",
    ["Back to list"] = "Back to list",
    ["No items in collection"] = "No items in collection",
    ["[DH] Add to Collection"] = "Add to Collection",
    ["Create new collection"] = "Create new collection",
    ["Remove from collection"] = "Remove from collection",
    ["Confirm"] = "Confirm",
    ["Change icon"] = "Change icon",
    ["Rename collection"] = "Rename collection",
    ["Rename"] = "Rename",
    ["Enter new name"] = "Enter new name:",
    ["Collection Hotbar Mode"] = "Collection Hotbar Mode",
    ["Active"] = "Active",
    ["Click to activate"] = "Click to activate",
    ["Click to deactivate"] = "Click to deactivate",
    ["Shift+Scroll to cycle collections"] = "Shift+Scroll to cycle collections",
    ["Set as active collection"] = "Set as active collection",
    ["Remove active status"] = "Remove active status",
    ["No collections available"] = "No collections available!",
    ["Collections not implemented"] = "Collections will be available in a future update.",
    ["Collection Sets"] = "Collection Sets",
    ["Seasonal Items"] = "Seasonal Items",
    ["Limited Items"] = "Limited Items",
    ["Complete Sets"] = "Complete Sets",
    ["Incomplete Sets"] = "Incomplete Sets",
    ["Click to create your first collection"] = "Click to create your first collection",
    ["No collections yet"] = "No collections yet",
    ["Create a collection to organize your decor"] = "Create a collection to organize your decor",
    ["Enter collection name"] = "Enter collection name:",
    ["Create"] = "Create",
    ["Delete collection X?"] = "Delete collection '%s'?",
    ["Select icon"] = "Select Icon",
    ["More icons"] = "More icons...",
    ["Search atlas"] = "Search atlas...",
    ["CHM active - disable first"] = "Please disable the CHM first",
    ["CHM active"] = "CHM active",
    ["Search collections"] = "Search collections...",
    ["Search items"] = "Search items...",
    ["No search results"] = "No results",
    
    -- 3D Preview
    ["3D Preview"] = "3D Preview",
    ["Click to show 3D model"] = "Click to show 3D model",
    
    -- Hotbar Slot Selection
    ["Select Slot"] = "Select Slot",
    ["Slot"] = "Slot",
    ["Empty"] = "Empty",
}

-- ============================================
-- SPANISH (Español)
-- ============================================
local esES = {
    -- General
    ["Favorites"] = "Favoritos",
    ["Hotbar"] = "Barra rápida",
    ["Settings"] = "Configuración",
    ["Unknown"] = "Desconocido",
    ["Yes"] = "Sí",
    ["No"] = "No",
    ["Close"] = "Cerrar",
    ["Save"] = "Guardar",
    ["Load"] = "Cargar",
    ["Delete"] = "Eliminar",
    ["Export"] = "Exportar",
    ["Import"] = "Importar",
    ["Refresh"] = "Actualizar",
    ["Clear"] = "Limpiar",
    ["Cancel"] = "Cancelar",
    
    -- Favorites
    ["Add to Favorites"] = "Añadir a favoritos",
    ["Remove from Favorites"] = "Quitar de favoritos",
    ["X items marked"] = "%d objetos marcados",
    ["Favorites from this category only"] = "Solo favoritos de esta categoría",
    ["No favorites marked yet"] = "¡Aún no has marcado favoritos!",
    ["Click star or use context menu"] = "Haz clic en la estrella o usa el menú contextual.",
    ["No favorites available"] = "¡No hay favoritos disponibles!",
    ["No favorites in this category"] = "¡No hay favoritos en esta categoría!",
    ["Favorite set"] = "Favorito añadido",
    ["Favorite removed"] = "Favorito eliminado",
    ["You have X favorites"] = "Tienes %d favoritos",
    
    -- Hotbar
    ["Empty Slot X"] = "Ranura vacía %d",
    ["Empty Slot"] = "Ranura vacía",
    ["In possession"] = "En posesión",
    ["Not available"] = "No disponible",
    ["Quick place"] = "Colocación rápida",
    ["Left-click: Place"] = "Clic izquierdo: Colocar",
    ["Right-click: Menu"] = "Clic derecho: Menú",
    ["Drag: Rearrange"] = "Arrastrar: Reordenar",
    ["Right-click catalog item"] = "Clic derecho en objeto del catálogo",
    ["-> 'Add to hotbar'"] = "-> 'Añadir a barra rápida'",
    ["Hotbar empty slot hint"] = "Haz clic derecho en un objeto del catálogo y selecciona 'Añadir a barra rápida'.",
    ["Remove from Hotbar"] = "Quitar de barra rápida",
    ["Add to Hotbar"] = "Añadir a barra rápida",
    ["Clear all slots"] = "Limpiar todas las ranuras",
    ["Clear all items from hotbar?"] = "¿Eliminar todos los objetos de la barra rápida?",
    ["Hotbar X/10 used"] = "Barra rápida: %d / 10 usados",
    ["Hotbar not available yet"] = "Barra rápida aún no disponible",
    ["Item already in hotbar"] = "Objeto ya está en la barra rápida",
    ["Hotbar full"] = "¡Barra rápida llena!",
    
    -- Stats Panel
    ["Housing Statistics"] = "Estadísticas de vivienda",
    ["Placed Decorations"] = "Decoraciones colocadas",
    ["Storage Capacity"] = "Capacidad de almacenamiento",
    ["Quick Info"] = "Info rápida",
    ["Editor"] = "Editor",
    ["Status"] = "Estado",
    ["In Housing Area"] = "En zona de vivienda",
    ["Outside"] = "Fuera",
    ["Placed"] = "Colocado",
    ["Inactive"] = "Inactivo",
    ["Stats Panel not available yet"] = "Panel de estadísticas aún no disponible",
    
    -- Tooltip Enhancer
    ["--- DreamHouse Info ---"] = "--- Info DreamHouse ---",
    ["Placement"] = "Ubicación",
    ["Indoor"] = "Interior",
    ["Outdoor"] = "Exterior",
    ["Size"] = "Tamaño",
    ["Size_Tiny"] = "Diminuto",
    ["Size_Small"] = "Pequeño",
    ["Size_Medium"] = "Mediano",
    ["Size_Large"] = "Grande",
    ["Size_Huge"] = "Enorme",
    ["Source"] = "Origen",
    ["Category"] = "Categoría",
    ["Favorite"] = "Favorito",
    ["Type"] = "Tipo",
    ["Type_Decoration"] = "Decoración",
    ["Type_Room"] = "Habitación",
    ["--- Placed ---"] = "--- Colocado ---",
    ["Locked"] = "Bloqueado",
    ["Cannot be removed"] = "No se puede quitar",
    
    -- Preset Manager
    ["Preset Manager"] = "Gestor de preajustes",
    ["Save new preset"] = "Guardar nuevo preajuste:",
    ["Saved Presets"] = "Preajustes guardados:",
    ["Presets"] = "Preajustes",
    ["Delete preset X?"] = "¿Eliminar preajuste '%s'?",
    ["No items to save"] = "¡No hay objetos para guardar!",
    ["Preset X saved"] = "¡Preajuste '%s' guardado! (%d objetos)",
    ["No presets to export"] = "No hay preajustes para exportar",
    ["Import not implemented"] = "Función de importación aún no implementada",
    ["Preset load not implemented"] = "Carga de preajustes no completamente implementada (depende de API)",
    
    -- Quality Filter
    ["Rarity"] = "Rareza",
    ["Select All"] = "Seleccionar todo",
    ["Select None"] = "Seleccionar ninguno",
    
    -- Vendor Database
    ["Vendor Database"] = "Base de datos de vendedores",
    ["No vendor open"] = "Ningún vendedor abierto",
    ["Unknown Vendor"] = "Vendedor desconocido",
    ["X new housing items from Y saved"] = "¡%d nuevos objetos de vivienda de %s guardados!",
    ["X housing items already known"] = "%s: %d objetos de vivienda ya conocidos",
    ["No housing items at this vendor"] = "No hay objetos de vivienda en este vendedor",
    ["TomTom Waypoint"] = "Punto de ruta TomTom",
    ["Waypoint for X set"] = "¡Punto de ruta para %s establecido!",
    ["Vendor: X in Y"] = "Vendedor: %s en %s",
    ["No waypoint possible"] = "(No es posible crear punto de ruta)",
    ["Statistics"] = "Estadísticas",
    ["Items"] = "Objetos",
    ["Vendors"] = "Vendedores",
    ["Vendor database cleared"] = "¡Base de datos de vendedores limpiada!",
    ["VendorDB Commands"] = "Comandos:",
    ["VendorDB not available"] = "Base de datos de vendedores no disponible",
    
    -- Source on Map
    ["Show source on map"] = "Mostrar origen en el mapa",
    ["No map position available"] = "No hay posición en el mapa disponible",
    ["Item not in database"] = "Este objeto no está en la base de datos.",
    ["Visit vendor tip"] = "Consejo: Visita al vendedor que vende este objeto",
    ["Visit vendor tip2"] = "para guardar automáticamente su ubicación.",
    ["No map position for item"] = "No se encontró posición en el mapa para este objeto.",
    ["Source cannot be shown on map"] = "El origen no se puede mostrar en el mapa.",
    ["Source for X"] = "Origen de %s",
    ["Visit vendor to save position"] = "(¡Visita al vendedor para guardar la posición!)",
    ["Content tracking not available"] = "Seguimiento de contenido no disponible.",
    ["X has no known source"] = "%s no tiene origen conocido.",
    ["Visit vendors to collect items"] = "(Visita vendedores para recolectar objetos automáticamente)",
    ["X is being tracked"] = "%s está siendo rastreado. Busca el marcador en el mapa del mundo.",
    ["[DH] Mark as Favorite"] = "Marcar como favorito",
    ["[DH] Remove Favorite"] = "Quitar favorito",
    ["[DH] Add to Hotbar"] = "Añadir a barra rápida",
    ["[DH] Remove from Hotbar"] = "Quitar de barra rápida",
    ["[DH] Show source on map"] = "Mostrar origen en el mapa",
    
    -- Debug Console
    ["Debug"] = "Depuración",
    ["Entries"] = "Entradas",
    ["Output X entries to chat"] = "Mostrar %d entradas en el chat",
    ["Ctrl+A = All, Ctrl+C = Copy"] = "Ctrl+A = Todo, Ctrl+C = Copiar",
    ["Log cleared"] = "Registro limpiado",
    ["DreamHouse Debug Log"] = "Registro de depuración DreamHouse",
    ["End (X entries)"] = "Fin (%d entradas)",
    ["Debug Log Export"] = "Exportar registro - Ctrl+A, Ctrl+C para copiar",
    ["Exported"] = "Exportado",
    ["Console initialized"] = "Consola inicializada (Ctrl+A, Ctrl+C para copiar)",
    ["-> Chat"] = "-> Chat",
    
    -- Core / Slash Commands
    ["Commands"] = "Comandos:",
    ["/dh debug"] = "/dh debug - Alternar consola de depuración",
    ["/dh export"] = "/dh export - Popup de exportación de registro",
    ["/dh stats"] = "/dh stats - Mostrar estadísticas",
    ["/dh favorites"] = "/dh favorites - Mostrar favoritos",
    ["/dh hotbar"] = "/dh hotbar - Alternar barra rápida",
    ["/dh vendordb"] = "/dh vendordb - Comandos de base de datos",
    ["/dh reset"] = "/dh reset - Restablecer configuración",
    ["/dh test"] = "/dh test - Escribir mensaje de prueba",
    ["Reset all settings?"] = "¿Restablecer toda la configuración de DreamHouse?",
    ["Settings reset"] = "¡Configuración restablecida!",
    ["Unknown command"] = "Comando desconocido. Usa /dh help",
    ["X test messages written"] = "¡%d mensajes de prueba escritos!",
    
    -- Editor Modes
    ["Mode_None"] = "Ninguno",
    ["Mode_BasicDecor"] = "Decoración básica",
    ["Mode_ExpertDecor"] = "Decoración experta",
    ["Mode_Layout"] = "Diseño",
    ["Mode_Customize"] = "Personalizar",
    ["Mode_Cleanup"] = "Limpiar",
    ["Mode_ExteriorCustomization"] = "Exterior",
    
    -- Collections Tab
    ["Collections"] = "Colecciones",
    ["Collection"] = "Colección",
    ["Collections Tab"] = "Colecciones",
    ["Back to list"] = "Volver a la lista",
    ["No items in collection"] = "No hay objetos en la colección",
    ["[DH] Add to Collection"] = "Añadir a colección",
    ["Create new collection"] = "Crear nueva colección",
    ["Remove from collection"] = "Quitar de colección",
    ["Confirm"] = "Confirmar",
    ["Change icon"] = "Cambiar icono",
    ["Rename collection"] = "Renombrar colección",
    ["Rename"] = "Renombrar",
    ["Enter new name"] = "Introduce nuevo nombre:",
    ["Collection Hotbar Mode"] = "Modo barra rápida de colección",
    ["Active"] = "Activo",
    ["Click to activate"] = "Clic para activar",
    ["Click to deactivate"] = "Clic para desactivar",
    ["Shift+Scroll to cycle collections"] = "Shift+Rueda para cambiar colecciones",
    ["Set as active collection"] = "Establecer como colección activa",
    ["Remove active status"] = "Quitar estado activo",
    ["No collections available"] = "¡No hay colecciones disponibles!",
    ["Collections not implemented"] = "Las colecciones estarán disponibles en una actualización futura.",
    ["Collection Sets"] = "Sets de colección",
    ["Seasonal Items"] = "Objetos de temporada",
    ["Limited Items"] = "Objetos limitados",
    ["Complete Sets"] = "Sets completos",
    ["Incomplete Sets"] = "Sets incompletos",
    ["Click to create your first collection"] = "Clic para crear tu primera colección",
    ["No collections yet"] = "Aún no hay colecciones",
    ["Create a collection to organize your decor"] = "Crea una colección para organizar tu decoración",
    ["Enter collection name"] = "Introduce nombre de colección:",
    ["Create"] = "Crear",
    ["Delete collection X?"] = "¿Eliminar colección '%s'?",
    ["Select icon"] = "Seleccionar icono",
    ["More icons"] = "Más iconos...",
    ["Search atlas"] = "Buscar atlas...",
    ["CHM active - disable first"] = "Por favor desactiva primero el MBC",
    ["CHM active"] = "MBC activo",
    ["Search collections"] = "Buscar colecciones...",
    ["Search items"] = "Buscar objetos...",
    ["No search results"] = "Sin resultados",
    
    -- 3D Preview
    ["3D Preview"] = "Vista previa 3D",
    ["Click to show 3D model"] = "Clic para mostrar modelo 3D",
    
    -- Hotbar Slot Selection
    ["Select Slot"] = "Seleccionar ranura",
    ["Slot"] = "Ranura",
    ["Empty"] = "Vacío",
}

-- ============================================
-- FRENCH (Français)
-- ============================================
local frFR = {
    -- General
    ["Favorites"] = "Favoris",
    ["Hotbar"] = "Barre rapide",
    ["Settings"] = "Paramètres",
    ["Unknown"] = "Inconnu",
    ["Yes"] = "Oui",
    ["No"] = "Non",
    ["Close"] = "Fermer",
    ["Save"] = "Sauvegarder",
    ["Load"] = "Charger",
    ["Delete"] = "Supprimer",
    ["Export"] = "Exporter",
    ["Import"] = "Importer",
    ["Refresh"] = "Actualiser",
    ["Clear"] = "Effacer",
    ["Cancel"] = "Annuler",
    
    -- Favorites
    ["Add to Favorites"] = "Ajouter aux favoris",
    ["Remove from Favorites"] = "Retirer des favoris",
    ["X items marked"] = "%d objets marqués",
    ["Favorites from this category only"] = "Favoris de cette catégorie uniquement",
    ["No favorites marked yet"] = "Vous n'avez pas encore de favoris !",
    ["Click star or use context menu"] = "Cliquez sur l'étoile ou utilisez le menu contextuel.",
    ["No favorites available"] = "Aucun favori disponible !",
    ["No favorites in this category"] = "Aucun favori dans cette catégorie !",
    ["Favorite set"] = "Favori ajouté",
    ["Favorite removed"] = "Favori supprimé",
    ["You have X favorites"] = "Vous avez %d favoris",
    
    -- Hotbar
    ["Empty Slot X"] = "Emplacement vide %d",
    ["Empty Slot"] = "Emplacement vide",
    ["In possession"] = "En possession",
    ["Not available"] = "Non disponible",
    ["Quick place"] = "Placement rapide",
    ["Left-click: Place"] = "Clic gauche : Placer",
    ["Right-click: Menu"] = "Clic droit : Menu",
    ["Drag: Rearrange"] = "Glisser : Réorganiser",
    ["Right-click catalog item"] = "Clic droit sur un objet du catalogue",
    ["-> 'Add to hotbar'"] = "-> 'Ajouter à la barre rapide'",
    ["Hotbar empty slot hint"] = "Clic droit sur un objet du catalogue et sélectionnez 'Ajouter à la barre rapide'.",
    ["Remove from Hotbar"] = "Retirer de la barre rapide",
    ["Add to Hotbar"] = "Ajouter à la barre rapide",
    ["Clear all slots"] = "Vider tous les emplacements",
    ["Clear all items from hotbar?"] = "Retirer tous les objets de la barre rapide ?",
    ["Hotbar X/10 used"] = "Barre rapide : %d / 10 utilisés",
    ["Hotbar not available yet"] = "Barre rapide pas encore disponible",
    ["Item already in hotbar"] = "Objet déjà dans la barre rapide",
    ["Hotbar full"] = "Barre rapide pleine !",
    
    -- Stats Panel
    ["Housing Statistics"] = "Statistiques de logement",
    ["Placed Decorations"] = "Décorations placées",
    ["Storage Capacity"] = "Capacité de stockage",
    ["Quick Info"] = "Info rapide",
    ["Editor"] = "Éditeur",
    ["Status"] = "Statut",
    ["In Housing Area"] = "Dans la zone de logement",
    ["Outside"] = "À l'extérieur",
    ["Placed"] = "Placé",
    ["Inactive"] = "Inactif",
    ["Stats Panel not available yet"] = "Panneau de stats pas encore disponible",
    
    -- Tooltip Enhancer
    ["--- DreamHouse Info ---"] = "--- Info DreamHouse ---",
    ["Placement"] = "Emplacement",
    ["Indoor"] = "Intérieur",
    ["Outdoor"] = "Extérieur",
    ["Size"] = "Taille",
    ["Size_Tiny"] = "Minuscule",
    ["Size_Small"] = "Petit",
    ["Size_Medium"] = "Moyen",
    ["Size_Large"] = "Grand",
    ["Size_Huge"] = "Énorme",
    ["Source"] = "Source",
    ["Category"] = "Catégorie",
    ["Favorite"] = "Favori",
    ["Type"] = "Type",
    ["Type_Decoration"] = "Décoration",
    ["Type_Room"] = "Pièce",
    ["--- Placed ---"] = "--- Placé ---",
    ["Locked"] = "Verrouillé",
    ["Cannot be removed"] = "Ne peut pas être retiré",
    
    -- Preset Manager
    ["Preset Manager"] = "Gestionnaire de préréglages",
    ["Save new preset"] = "Sauvegarder nouveau préréglage :",
    ["Saved Presets"] = "Préréglages sauvegardés :",
    ["Presets"] = "Préréglages",
    ["Delete preset X?"] = "Supprimer le préréglage '%s' ?",
    ["No items to save"] = "Aucun objet à sauvegarder !",
    ["Preset X saved"] = "Préréglage '%s' sauvegardé ! (%d objets)",
    ["No presets to export"] = "Aucun préréglage à exporter",
    ["Import not implemented"] = "Fonction d'import pas encore implémentée",
    ["Preset load not implemented"] = "Chargement de préréglage pas entièrement implémenté (dépend de l'API)",
    
    -- Quality Filter
    ["Rarity"] = "Rareté",
    ["Select All"] = "Tout sélectionner",
    ["Select None"] = "Ne rien sélectionner",
    
    -- Vendor Database
    ["Vendor Database"] = "Base de données des vendeurs",
    ["No vendor open"] = "Aucun vendeur ouvert",
    ["Unknown Vendor"] = "Vendeur inconnu",
    ["X new housing items from Y saved"] = "%d nouveaux objets de logement de %s sauvegardés !",
    ["X housing items already known"] = "%s : %d objets de logement déjà connus",
    ["No housing items at this vendor"] = "Aucun objet de logement chez ce vendeur",
    ["TomTom Waypoint"] = "Point de repère TomTom",
    ["Waypoint for X set"] = "Point de repère pour %s défini !",
    ["Vendor: X in Y"] = "Vendeur : %s à %s",
    ["No waypoint possible"] = "(Impossible de créer un point de repère)",
    ["Statistics"] = "Statistiques",
    ["Items"] = "Objets",
    ["Vendors"] = "Vendeurs",
    ["Vendor database cleared"] = "Base de données des vendeurs effacée !",
    ["VendorDB Commands"] = "Commandes :",
    ["VendorDB not available"] = "Base de données des vendeurs non disponible",
    
    -- Source on Map
    ["Show source on map"] = "Afficher la source sur la carte",
    ["No map position available"] = "Aucune position sur la carte disponible",
    ["Item not in database"] = "Cet objet n'est pas dans la base de données.",
    ["Visit vendor tip"] = "Conseil : Visitez le vendeur qui vend cet objet",
    ["Visit vendor tip2"] = "pour sauvegarder automatiquement sa position !",
    ["No map position for item"] = "Aucune position trouvée pour cet objet.",
    ["Source cannot be shown on map"] = "La source ne peut pas être affichée sur la carte.",
    ["Source for X"] = "Source de %s",
    ["Visit vendor to save position"] = "(Visitez le vendeur pour sauvegarder la position !)",
    ["Content tracking not available"] = "Suivi de contenu non disponible.",
    ["X has no known source"] = "%s n'a pas de source connue.",
    ["Visit vendors to collect items"] = "(Visitez les vendeurs pour collecter automatiquement)",
    ["X is being tracked"] = "%s est suivi. Cherchez le marqueur sur la carte du monde.",
    ["[DH] Mark as Favorite"] = "Marquer comme favori",
    ["[DH] Remove Favorite"] = "Retirer des favoris",
    ["[DH] Add to Hotbar"] = "Ajouter à la barre rapide",
    ["[DH] Remove from Hotbar"] = "Retirer de la barre rapide",
    ["[DH] Show source on map"] = "Afficher la source sur la carte",
    
    -- Debug Console
    ["Debug"] = "Débogage",
    ["Entries"] = "Entrées",
    ["Output X entries to chat"] = "Afficher %d entrées dans le chat",
    ["Ctrl+A = All, Ctrl+C = Copy"] = "Ctrl+A = Tout, Ctrl+C = Copier",
    ["Log cleared"] = "Journal effacé",
    ["DreamHouse Debug Log"] = "Journal de débogage DreamHouse",
    ["End (X entries)"] = "Fin (%d entrées)",
    ["Debug Log Export"] = "Export du journal - Ctrl+A, Ctrl+C pour copier",
    ["Exported"] = "Exporté",
    ["Console initialized"] = "Console initialisée (Ctrl+A, Ctrl+C pour copier)",
    ["-> Chat"] = "-> Chat",
    
    -- Core / Slash Commands
    ["Commands"] = "Commandes :",
    ["/dh debug"] = "/dh debug - Basculer la console de débogage",
    ["/dh export"] = "/dh export - Popup d'export du journal",
    ["/dh stats"] = "/dh stats - Afficher les statistiques",
    ["/dh favorites"] = "/dh favorites - Afficher les favoris",
    ["/dh hotbar"] = "/dh hotbar - Basculer la barre rapide",
    ["/dh vendordb"] = "/dh vendordb - Commandes de base de données",
    ["/dh reset"] = "/dh reset - Réinitialiser les paramètres",
    ["/dh test"] = "/dh test - Écrire un message de test",
    ["Reset all settings?"] = "Réinitialiser tous les paramètres DreamHouse ?",
    ["Settings reset"] = "Paramètres réinitialisés !",
    ["Unknown command"] = "Commande inconnue. Utilisez /dh help",
    ["X test messages written"] = "%d messages de test écrits !",
    
    -- Editor Modes
    ["Mode_None"] = "Aucun",
    ["Mode_BasicDecor"] = "Décor basique",
    ["Mode_ExpertDecor"] = "Décor expert",
    ["Mode_Layout"] = "Agencement",
    ["Mode_Customize"] = "Personnaliser",
    ["Mode_Cleanup"] = "Nettoyage",
    ["Mode_ExteriorCustomization"] = "Extérieur",
    
    -- Collections Tab
    ["Collections"] = "Collections",
    ["Collection"] = "Collection",
    ["Collections Tab"] = "Collections",
    ["Back to list"] = "Retour à la liste",
    ["No items in collection"] = "Aucun objet dans la collection",
    ["[DH] Add to Collection"] = "Ajouter à la collection",
    ["Create new collection"] = "Créer une nouvelle collection",
    ["Remove from collection"] = "Retirer de la collection",
    ["Confirm"] = "Confirmer",
    ["Change icon"] = "Changer l'icône",
    ["Rename collection"] = "Renommer la collection",
    ["Rename"] = "Renommer",
    ["Enter new name"] = "Entrez le nouveau nom :",
    ["Collection Hotbar Mode"] = "Mode barre rapide de collection",
    ["Active"] = "Actif",
    ["Click to activate"] = "Cliquer pour activer",
    ["Click to deactivate"] = "Cliquer pour désactiver",
    ["Shift+Scroll to cycle collections"] = "Shift+Molette pour changer de collection",
    ["Set as active collection"] = "Définir comme collection active",
    ["Remove active status"] = "Retirer le statut actif",
    ["No collections available"] = "Aucune collection disponible !",
    ["Collections not implemented"] = "Les collections seront disponibles dans une future mise à jour.",
    ["Collection Sets"] = "Sets de collection",
    ["Seasonal Items"] = "Objets saisonniers",
    ["Limited Items"] = "Objets limités",
    ["Complete Sets"] = "Sets complets",
    ["Incomplete Sets"] = "Sets incomplets",
    ["Click to create your first collection"] = "Cliquez pour créer votre première collection",
    ["No collections yet"] = "Pas encore de collections",
    ["Create a collection to organize your decor"] = "Créez une collection pour organiser votre décor",
    ["Enter collection name"] = "Entrez le nom de la collection :",
    ["Create"] = "Créer",
    ["Delete collection X?"] = "Supprimer la collection '%s' ?",
    ["Select icon"] = "Sélectionner une icône",
    ["More icons"] = "Plus d'icônes...",
    ["Search atlas"] = "Rechercher dans l'atlas...",
    ["CHM active - disable first"] = "Veuillez d'abord désactiver le MBC",
    ["CHM active"] = "MBC actif",
    ["Search collections"] = "Rechercher des collections...",
    ["Search items"] = "Rechercher des objets...",
    ["No search results"] = "Aucun résultat",
    
    -- 3D Preview
    ["3D Preview"] = "Aperçu 3D",
    ["Click to show 3D model"] = "Cliquer pour afficher le modèle 3D",
    
    -- Hotbar Slot Selection
    ["Select Slot"] = "Sélectionner l'emplacement",
    ["Slot"] = "Emplacement",
    ["Empty"] = "Vide",
}

-- ============================================
-- SET ACTIVE LOCALE
-- ============================================

-- Default to German
local activeLocale = deDE

-- Switch based on client language
if locale == "enUS" or locale == "enGB" then
    activeLocale = enUS
elseif locale == "esES" or locale == "esMX" then
    activeLocale = esES
elseif locale == "frFR" then
    activeLocale = frFR
end

-- Metatable for easy access with fallback
setmetatable(L, {
    __index = function(t, key)
        local value = activeLocale[key]
        if value then
            return value
        end
        -- Fallback to German if not found
        value = deDE[key]
        if value then
            return value
        end
        -- Return key if nothing found
        return key
    end,
    __newindex = function(t, key, value)
        rawset(activeLocale, key, value)
    end,
})

-- Helper function for formatted strings
function DreamHouse.L.Format(key, ...)
    local str = L[key]
    if select("#", ...) > 0 then
        return string.format(str, ...)
    end
    return str
end

-- Get current locale
function DreamHouse.L.GetLocale()
    return locale
end

-- Check if using English
function DreamHouse.L.IsEnglish()
    return locale == "enUS" or locale == "enGB"
end

-- Check if using Spanish
function DreamHouse.L.IsSpanish()
    return locale == "esES" or locale == "esMX"
end

-- Check if using French
function DreamHouse.L.IsFrench()
    return locale == "frFR"
end
