# For machines that also boot Windows.
{
  flake.modules.nixos.windows-dual-boot =
    { pkgs, ... }:
    let
      # Each OS makes its own Bluetooth link key when it pairs, and a device
      # only keeps the newest one, so pairing in one OS unpairs the other.
      # This copies Windows's keys over NixOS's, so both use the same one.
      # Classic (BR/EDR) devices only, which covers most headphones.
      bt-sync-windows-keys = pkgs.writeShellApplication {
        name = "bt-sync-windows-keys";
        runtimeInputs = [
          pkgs.chntpw
          pkgs.coreutils
          pkgs.gawk
          pkgs.util-linux
        ];
        text = ''
          if [ "$(id -u)" -ne 0 ]; then
            exec /run/wrappers/bin/sudo "$0" "$@"
          fi

          windows=''${1:-}
          if [ -z "$windows" ]; then
            while read -r target; do
              if [ -f "$target/Windows/System32/config/SYSTEM" ]; then
                windows=$target
                break
              fi
            done < <(findmnt -rn -t ntfs3,ntfs,fuseblk -o TARGET)
          fi
          hive=$windows/Windows/System32/config/SYSTEM
          if [ -z "$windows" ] || [ ! -f "$hive" ]; then
            echo "Mount the Windows partition (or pass its mount point) first." >&2
            exit 1
          fi

          tmp=$(mktemp -d)
          trap 'rm -rf "$tmp"' EXIT
          reged -x "$hive" 'HKEY_LOCAL_MACHINE\SYSTEM' \
            '\ControlSet001\Services\BTHPORT\Parameters\Keys' "$tmp/keys.reg" > /dev/null

          # Sections are named by adapter address; classic devices are values
          # named by their address, holding the 16-byte key as hex bytes.
          # Prints "ADAPTER DEVICE KEY" with addresses as BlueZ writes them.
          gawk '
            function mac(s) { return toupper(gensub(/(..)(..)(..)(..)(..)(..)/, "\\1:\\2:\\3:\\4:\\5:\\6", 1, s)) }
            { sub(/\r$/, "") }
            /\\$/ { joined = joined substr($0, 1, length($0) - 1); next }
            { line = joined $0; joined = "" }
            line ~ /^\[/ { adapter = gensub(/.*\\([^\\]*)\]$/, "\\1", 1, line); next }
            adapter ~ /^[0-9a-f]{12}$/ && line ~ /^"[0-9a-f]{12}"=hex:/ {
              key = substr(line, 20)
              gsub(/[ ,]/, "", key)
              print mac(adapter), mac(substr(line, 2, 12)), toupper(key)
            }
          ' "$tmp/keys.reg" > "$tmp/keys"

          if [ ! -s "$tmp/keys" ]; then
            echo "Windows has no paired classic Bluetooth devices." >&2
            exit 1
          fi

          # bluetoothd keeps keys in memory and writes them back on exit.
          systemctl stop bluetooth.service
          trap 'systemctl start bluetooth.service; rm -rf "$tmp"' EXIT

          while read -r adapter device key; do
            info=/var/lib/bluetooth/$adapter/$device/info
            if ! grep -q '^\[LinkKey\]' "$info" 2>/dev/null; then
              echo "Skipping $device: pair it in NixOS first, then in Windows."
              continue
            fi
            gawk -v key="$key" '
              /^\[/ { section = $0 }
              section == "[LinkKey]" && /^Key=/ { $0 = "Key=" key }
              { print }
            ' "$info" > "$tmp/info"
            cat "$tmp/info" > "$info"
            echo "Updated $device"
          done < "$tmp/keys"
        '';
      };
    in
    {
      # Windows keeps the hardware clock in local time.
      time.hardwareClockInLocalTime = true;

      environment.systemPackages = [ bt-sync-windows-keys ];
    };
}
