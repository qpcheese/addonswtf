# Mythic Plus Key Announcer — Usage

This addon announces Mythic+ group keys and shows a popup when you join a group.

## Options

Open the options with `/mpk` or via AddOns → Mythic Plus Key Announcer in the Interface Options.

- **Announcement Channel**

	Choose where to send the announcement. Options include: Say, Party, Raid, Guild, Instance, Yell, Whisper (requires target), Channel (requires channel number).

- **Target**

	Enter a player name for Whisper or a channel number for Channel.

- **Show popup on join**

	Toggle whether a popup appears when you join a group.

- **Message Color**

	Pick the color used in the popup's colored text.

- **Test Announcement**

	Sends a test announcement using your current settings and shows the popup.

## Slash commands

- `/mpk` — Open the addon options.
- `/mpk testpopup` — Show a test popup and send a test announcement.
- `/mpk last` — Print and show the last announced group popup.
- `/mpk resend` — Re-send the last plain announcement to the configured channel.

## Notes

- Whisper requires a valid player name in Target.
- Channel requires a numeric channel ID in Target (for custom chat channels).
- The addon strips any `|` characters from outgoing messages to avoid invalid chat escape codes.

## Testing

1. Reload the UI with `/reload`.
2. Open options with `/mpk`.
3. Configure channel and target if using Whisper/Channel.
4. Click the Test Announcement button or run `/mpk testpopup`.

If you find any missing strings in your locale, add them to the files in the `Locales/` folder.
