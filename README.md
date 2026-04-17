# homebrew-roachnet

Homebrew tap for installing RoachNet on Apple Silicon Macs.

## Install

```bash
brew update
brew tap --force AHGRoach/roachnet
brew install --cask roachnet
open ~/RoachNet/app/RoachNet.app
```

RoachNet lands in `~/RoachNet/app/RoachNet.app` so the app, storage, and local tools stay grouped inside the RoachNet folder instead of scattering across the machine.

The Homebrew lane also writes the contained RoachNet config automatically, disables the companion bridge on first boot, skips the launch intro, and stages the compiled runtime in `~/RoachNet/storage/state/runtime-cache` so a fresh Apple Silicon install does not depend on host Homebrew dylibs.

Current desktop build notes:

- RoachClaw can read the full local workbench context when the user arms vault, captured-web, project, and app-state access.
- Vault content opens in built-in reader/player/preview lanes instead of bouncing everything out to Finder.
- Dev Studio keeps a contained terminal history and richer editor/status chrome so the app feels closer to a real IDE desk.
