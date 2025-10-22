# sotf-cli

A small command-line tool to help you inspect and edit "Sons of the Forest" game saves on Windows.

This CLI is intended to make common savefile operations simple, for example listing saves, reading save metadata (difficulty, days survived, last modified) and — in future or by request — editing properties like resetting the number of days survived.

Features
- list: scans your save folders and prints discovered saves grouped by Singleplayer / Multiplayer
- Read save metadata: difficulty, days survived, last modified timestamp
- (Planned / optional) edit commands: reset game days, change difficulty, rename saves — these operations can be implemented on demand and will be documented with examples and safety notes.

Safety & backups
- Always backup the entire save folder before performing edit operations.
- The CLI will never modify files unless you explicitly run an edit command.