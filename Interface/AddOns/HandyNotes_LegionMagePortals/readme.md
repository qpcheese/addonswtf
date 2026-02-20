# HandyNotes: Legion Mage Portals

A World of Warcraft addon that displays Mage Teleportation Nexus portal locations on your map for the Legion expansion zones.

## Features

- 🗺️ **Map Integration**: Shows portal locations directly on your zone maps
- 🔮 **Quest Awareness**: Icons change color based on whether you've unlocked the Teleportation Nexus
- ⚙️ **Customizable**: Adjust icon size, transparency, and visibility options
- 🎯 **TomTom Support**: Right-click icons to create waypoints (requires TomTom addon)

## Requirements

- **HandyNotes** addon (required dependency)
- **Legion expansion** content access
- **Mage character** with Teleportation Nexus quest completed (Quest ID: 42696)

## Installation

1. Download the addon files
2. Extract to your `World of Warcraft\_retail_\Interface\AddOns\` folder
3. Ensure the folder is named `HandyNotes_LegionMagePortals`
4. Restart World of Warcraft or type `/reload`
5. Enable the addon in your AddOn list

## Portal Locations

The addon shows portal locations in these Legion zones:
- **Azsuna** - Teleportation Nexus portal
- **Highmountain** - Teleportation Nexus portal  
- **Val'sharah** - Teleportation Nexus portal
- **Stormheim** - Teleportation Nexus portal
- **Suramar** - Teleportation Nexus portal

## Configuration

Access settings through: **Interface → AddOns → HandyNotes → Plugins → LegionMagePortals**

### Available Options:
- **Icon Scale**: Adjust the size of portal icons (0.25x to 2.0x)
- **Icon Alpha**: Control icon transparency (0% to 100%)
- **Debug Mode**: Enable debug output for troubleshooting
- **Reset to Defaults**: Quickly restore default icon settings

## Usage

1. Complete the Mage class hall questline to unlock the Teleportation Nexus
2. Visit any Legion zone
3. Portal locations will appear as icons on your map
4. **Green icons**: Portals you can use (quest completed)
5. **Red icons**: Portals not yet available (quest incomplete)

### Interactions:
- **Hover**: View portal information in tooltip
- **Right-click**: Create TomTom waypoint (if TomTom is installed)

## Troubleshooting

### Icons not showing?
1. Ensure HandyNotes is installed and enabled
2. Check that the plugin is enabled in HandyNotes settings
3. Verify you're in a Legion zone (Broken Isles)
4. Enable debug mode to see diagnostic information

### Quest not detected?
- Make sure you've completed the Mage class hall questline
- The addon checks for Quest ID 42696 completion
- Try `/reload` to refresh quest status

## Technical Information

- **Interface Version**: 11.0.7 (The War Within compatible)
- **Saved Variables**: `HandyNotes_LegionMagePortalsDB`
- **Dependencies**: HandyNotes
- **Optional**: TomTom (for waypoint creation)

## Credits

- **Original Author**: Tsaavik Gnoballs@Greymane
- **Based on work by**: Kemayo
- **Updated for current WoW**: Community contributions

## License

All Rights Reserved

## Support

For issues, suggestions, or contributions:
- **GitHub**: [tsaavik/HandyNotes-Mage-Hall-Portals](https://github.com/tsaavik/HandyNotes-Mage-Hall-Portals)
- **Issues**: Use GitHub Issues for bug reports and feature requests

---

*This addon enhances the Legion mage experience by providing easy access to portal location information directly on your map interface.*