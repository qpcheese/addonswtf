# Mythic-Plus-Key-Announcer

Mythic-Plus-Key-Announcer is a small World of Warcraft addon that announces when you join a Mythic+ (or related) group and shows a popup with the group's key and details.

## Features

- Announce the Mythic+ key info to a configurable chat channel (Say, Party, Raid, Guild, Instance, Yell, Whisper, or a custom Channel).
- Optional popup when you join a group, with configurable message color.
- Test announcement button and slash commands to show/resend the last announcement.
- Localization-ready (enUS, esES, frFR, ptBR, ruRU, zhCN included).

## Installation

Copy the addon folder into your World of Warcraft `_retail_/Interface/AddOns/` directory or use your preferred addon manager.

## Usage

- Open options with the slash command `/mpk` or via the AddOns options panel.
- Configure the Announcement Channel and, if needed, the Target (player name for whispers or channel number for custom channels).
- Toggle the popup and select the message color from the options.

## Slash Commands

- `/mpk` — Open the addon options.
- `/mpk testpopup` — Show a test popup and send a test announcement.
- `/mpk last` — Print and show the last announced group popup.
- `/mpk resend` — Re-send the last plain announcement to the configured channel.

## Documentation

- Usage guide: `docs/USAGE.md`
- Changelog: `CHANGELOG.md`

## Notes

- The addon strips `|` characters from outgoing messages to avoid invalid chat escape code errors.
- Uses Ace3 libraries bundled in `Libs/`.

## Contributing

Contributions are welcome — open an issue or a pull request with changes. If you add translations, put them in the `Locales/` folder.

## License

See `Libs/LICENSE.txt` for Ace3 library licensing. The addon code itself is available under the same terms as the rest of the project (see repository LICENCE files).