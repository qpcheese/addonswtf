----------------------------------------- Shadow skin for 6.2.2 ------------------------------------------

local MSQ = LibStub("Masque", true)
if not MSQ then return end
----------------------------------------------------------------------------------------------------------
-------------------------------------------- Masque: OyanaUI --------------------------------------------
----------------------------------------------------------------------------------------------------------
MSQ:AddSkin("Masque: OyanaUI", 
{
	Author = "Oyana",
	Version = "6.2.2",
	Shape = "Circle",
	Masque_Version = 60200,
	Backdrop = {
		Width = 48,
		Height = 48,
		Color = {0.3, 0.3, 0.3, 1},
		Texture = [[Interface\Addons\Masque_OyanaUI\Textures\OyanaHex\Backdrop]],
	},
	Icon = {
		Width = 44,
		Height = 44,
		TexCoords = {0.08, 0.92, 0.08, 0.92},
		Mask = [[Interface\Addons\Masque_OyanaUI\Textures\OyanaHex\Mask]],
		MaskWidth = 48,
		MaskHeight = 48,
	},
	Flash = {
		Width = 52,
		Height = 52,
		BlendMode = "ADD",
		Color = {0.5, 0, 1, 0.6},
		Texture = [[Interface\Addons\Masque_OyanaUI\Textures\OyanaHex\Overlay]],
		Mask = [[Interface\Addons\Masque_OyanaUI\Textures\OyanaHex\Mask]],
		MaskWidth = 48,
		MaskHeight = 48,
	},
	Cooldown = {
		Width = 43,
		Height = 43,
		Mask = [[Interface\Addons\Masque_OyanaUI\Textures\OyanaHex\Mask]],
		MaskWidth = 41,
		MaskHeight = 41,
	},
	AutoCast = {
		Width = 42,
		Height = 42,
	},
	Normal = {
		Width = 52,
		Height = 52,
		Color = {0, 0, 0, 1},
		Texture = [[Interface\Addons\Masque_OyanaUI\Textures\OyanaHex\Normal]],
	},
	Pushed = {
		Width = 52,
		Height = 52,
		BlendMode = "ADD",
		Color = {0, 0, 0, 1},
		Texture = [[Interface\Addons\Masque_OyanaUI\Textures\OyanaHex\Highlight]],
	},
	Border = {
		Width = 52,
		Height = 52,
		BlendMode = "BLEND",
		Texture = [[Interface\Addons\Masque_OyanaUI\Textures\OyanaHex\Border]],
	},
	Disabled = {
		Width = 52,
		Height = 52,
		BlendMode = "BLEND",
		Color = {0.77, 0.12, 0.23, 1},
		Texture = [[Interface\Addons\Masque_OyanaUI\Textures\OyanaHex\Border]],
	},
	Checked = {
		Width = 52,
		Height = 52,
		BlendMode = "BLEND",
		Color = {0, 0.12, 1, 1},
		Texture = [[Interface\Addons\Masque_OyanaUI\Textures\OyanaHex\Border]],
	},
	AutoCastable = {
		Width = 48,
		Height = 48,
		Texture = [[Interface\Addons\Masque_OyanaUI\Textures\OyanaHex\Autocast]],
	},
	Highlight = {
		Width = 52,
		Height = 52,
		BlendMode = "ADD",
		Color = {0.5, 0, 1, 1},
		Texture = [[Interface\Addons\Masque_OyanaUI\Textures\OyanaHex\Highlight]],
	},
	Gloss = {
		Width = 52,
		Height = 52,
		BlendMode = "ADD",
		Color = {1, 1, 1, 1},
		Texture = [[Interface\Addons\Masque_OyanaUI\Textures\OyanaHex\Gloss]],
	},
	HotKey = {
		Width = 42,
		Height = 14,
		JustifyH = "RIGHT",
		JustifyV = "TOP",
		OffsetX = -3,
		OffsetY = -4,
	},
	Count = {
		Width = 42,
		Height = 14,
		JustifyH = "RIGHT",
		JustifyV = "BOTTOM",
		OffsetY = 1,
	},
	Name = {
		Width = 42,
		Height = 0,
		JustifyH = "CENTER",
		JustifyV = "BOTTOM",
		OffsetY = 2,
	},
}, true)
