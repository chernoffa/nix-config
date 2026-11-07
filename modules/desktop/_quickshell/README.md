# Quickshell config

Bar, notifications, on-screen display, and calendar sidebar, copied from
[fufexan/dotfiles](https://github.com/fufexan/dotfiles/tree/b3029bf982d371903652e0b1e07eed8f5fa95b3e/home/services/quickshell)
under the MIT license in `LICENSE`.

Changed from the original:

- `utils/Config.qml`: `preferredMonitor` falls back to the first screen
  when there is no `eDP-1`, for desktops with several monitors.
- `bar/Bluetooth.qml`: clicking the icon opens Blueman.

`../quickshell.nix` links this directory to `~/.config/quickshell`.
