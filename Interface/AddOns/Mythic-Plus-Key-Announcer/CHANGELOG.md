# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased] - ui branch updates (2025-09-13)

### Added

- New options in the addon's configuration panel:
  - Announcement Channel: choose where announcements are sent (Say, Party, Raid, Guild, Instance, Yell, Whisper, Channel).
  - Target: player name (for Whisper) or channel number (for Channel).
  - Show popup on join: toggle the popup when joining a Mythic+ group.
  - Message Color: color picker for the popup's colored text.
  - Test Announcement: an execute option to send a test announcement and show the popup.

### Commands

- New slash commands:
  - `/mpk` — Open the addon options.
  - `/mpk testpopup` — Show a test popup and send a test announcement.
  - `/mpk last` — Print and show the last announced group popup.
  - `/mpk resend` — Re-send the last plain announcement to the configured channel.

### Fixes

- Strip `|` characters from outgoing messages to avoid invalid chat escape code errors.
- Use `C_ChatInfo.SendChatMessage` for chat output and added graceful fallbacks when configured channel is unavailable.

