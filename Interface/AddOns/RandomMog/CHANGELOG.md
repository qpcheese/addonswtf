# RandomMog Changelog

## Version 1.4.2 (2025-01-30)

### ?? Maintenance

- **Quiet Console** - Disabled the lingering debug output so live builds stay silent

## Version 1.4.1 (2025-01-24)

### 🐛 Bug Fixes

**Fixed Shoulder Checkbox Management**
- Fixed shoulder checkboxes not properly recreating when switching between split/single modes
- Improved shoulder state detection and checkbox synchronization
- Fixed Select All/Deselect All buttons to properly handle shoulder mode transitions

**Fixed Weapon Enchant Selection**
- Fixed Select All button not selecting weapon enchant checkboxes
- Fixed Deselect All button not deselecting weapon enchant checkboxes
- Weapon enchant checkboxes now properly respond to bulk selection buttons

**Code Improvements**
- Removed debug mode spam that was accidentally left enabled
- Cleaned up shoulder handling logic for better reliability
- Improved checkbox state management

## Version 1.4.0 (2025-01-18)

### ✨ ElvUI Integration

**Full ElvUI Compatibility**
- Added automatic detection and skinning support for ElvUI
- Checkboxes now use ElvUI's custom checkbox style when ElvUI is installed  
- Buttons (Random, All, None) now match ElvUI's dark theme aesthetic
- Adjusted button positioning for better alignment with ElvUI's layout
- Seamless visual integration with ElvUI's transmog window modifications

**UI Improvements**
- Removed checkbox background for cleaner appearance
- Button positioning now adapts when ElvUI is detected (5px vs 10px bottom offset)
- No additional dependencies required - works with or without ElvUI

## Version 1.3.2 (2025-01-17)

### 🐛 Critical Bug Fixes

**Fixed Split Shoulder Checkbox Issues**
- Fixed head checkbox disappearing when transmog window opens
- Fixed shoulder checkboxes not properly swapping between single/split modes
- Fixed orphan checkbox cleanup incorrectly removing non-shoulder checkboxes
- Fixed checkbox state persistence when switching between characters

**Fixed Shoulder Randomization Logic**
- Fixed issue where unchecked shoulders were still being randomized
- Fixed split mode only randomizing when both shoulders were selected
- Now correctly randomizes only selected shoulder(s) in split mode
- Removed incorrect shoulder preservation logic that was causing both to change

**UI Improvements**
- Cleaned up debug output from production code
- Fixed checkbox creation for all slot buttons
- Improved checkbox state management across mode switches

## Version 1.3.1 (2025-01-16)

### 🎯 Major Update - Split Shoulders, Weapon Enchants & More!

**Split Shoulder Support** 
- Full support for WoW's "Transmog Each Shoulder Separately" option
- Automatically detects when split shoulders are enabled
- Independent checkboxes for left and right shoulders
- Each shoulder randomizes to different appearances

**Weapon Enchant (Illusion) Support**
- New checkboxes for weapon enchants - control illusion randomization
- Separate checkboxes for main hand and off-hand enchants  
- Automatically applies random illusions from your collection
- Smart detection - only applies to weapons that can display illusions

**BetterWardrobe Compatibility**
- Full compatibility with the popular BetterWardrobe addon
- Both random buttons work together without conflicts
- Adjusted UI positioning to prevent overlaps

### 💡 New Features & Improvements

- **Shift-Click for Instant**: Hold Shift while clicking Random for instant changes (no animation)
- **Legion Artifacts Fixed**: Now includes Legion artifact appearances in weapon randomization
- **Better Animation Order**: Shoulders randomize third for more natural flow
- **Smarter Weapon Selection**: Properly includes all compatible weapon types
- **Cleaner UI**: All checkboxes align properly, enchant checkboxes have no background

### 🐛 Bug Fixes

- Fixed: Right shoulder not randomizing independently
- Fixed: Legion artifacts not appearing in random selection
- Fixed: Checkbox positioning issues
- Fixed: RefreshUnit error when using /rm command
- Fixed: Various UI conflicts with other addons

## Version 1.1.0 (2025-01-16)

### Added
- **Slot Selection System**: Choose which equipment slots to randomize
  - Checkboxes appear next to each equipment slot in the transmog window
  - Easily toggle individual slots on/off for randomization
  - Visual feedback with larger, more visible checkboxes
- **All/None Buttons**: Quickly select or deselect all slots at once
- **SavedVariables Support**: Your slot preferences are saved between sessions
- **Smart Defaults**: Shirt and Tabard slots disabled by default (cosmetic slots)
- **Enhanced Tooltips**: Shows which slots are currently selected for randomization

### Improved
- Better UI positioning with checkboxes on the inside of equipment slots
- Cleaner button layout: All | Random! | None
- More informative messages showing how many slots will be randomized

### Fixed
- Wrist slot checkbox positioning corrected

## Version 1.0.1 (2025-08-16)

### Fixed
- Fixed incorrect "No slots could be randomised" message appearing even when randomization was successful
- Fixed compatibility issue preventing the addon from loading properly