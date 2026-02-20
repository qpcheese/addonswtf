local myname, ns = ...

ns.defaults = {
    profile = {
        icon_scale = 1.5,
        icon_alpha = 1.0,
        entrances = true,
        debug = false,
    },
}

ns.options = {
    type = "group",
    name = myname:gsub("HandyNotes_", ""),
    get = function(info) return ns.db[info[#info]] end,
    set = function(info, v)
        ns.db[info[#info]] = v
        ns.HL:SendMessage("HandyNotes_NotifyUpdate", myname:gsub("HandyNotes_", ""))
    end,
    args = {
        icon = {
            type = "group",
            name = "Icon settings",
            inline = true,
            args = {
                desc = {
                    name = "These settings control the look and feel of the icon.",
                    type = "description",
                    order = 0,
                },
                icon_scale = {
                    type = "range",
                    name = "Icon Scale",
                    desc = "The scale of the icons",
                    min = 0.25, max = 2, step = 0.01,
                    order = 20,
                },
                icon_alpha = {
                    type = "range",
                    name = "Icon Alpha",
                    desc = "The alpha transparency of the icons",
                    min = 0, max = 1, step = 0.01,
                    order = 30,
                },
                reset_icons = {
                    type = "execute",
                    name = "Reset to Defaults",
                    desc = "Reset icon scale and alpha to default values",
                    func = function()
                        ns.db.icon_scale = ns.defaults.profile.icon_scale
                        ns.db.icon_alpha = ns.defaults.profile.icon_alpha
                        ns.HL:SendMessage("HandyNotes_NotifyUpdate", myname:gsub("HandyNotes_", ""))
                        print("[LegionMagePortals] Icon settings reset to defaults")
                    end,
                    order = 35,
                },
            },
        },
        debug = {
            type = "toggle",
            name = "Debug Mode",
            desc = "Enable debug output to chat",
            order = 40,
        },
    },
}
