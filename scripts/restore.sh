#!/bin/bash
# Undo cleanup.sh: re-enable the apps, give Home back to the NetTV launcher,
# switch Private DNS back to automatic. Optionally remove extra launchers.
# Usage: bash restore.sh <box ip:port> [package to uninstall ...]
BOX="${1:?usage: bash restore.sh <box ip:port> [launcher packages to remove]}"; shift
STATE="cleanup-state"
a() { adb -s "$BOX" "$@"; }
adb connect "$BOX" >/dev/null
a get-state >/dev/null || { echo "Cannot reach $BOX"; exit 1; }

if [ -f "$STATE/disabled.txt" ]; then
  while read -r p; do [ -n "$p" ] && a shell pm enable "$p"; done < "$STATE/disabled.txt"
fi
a shell cmd package set-home-activity --user 0 np.com.geniussystems.android.stb.launcher/.MainActivity
a shell settings put global private_dns_mode opportunistic
a shell settings delete global private_dns_specifier
for p in "$@"; do a shell pm uninstall "$p"; done
a shell sync
echo "Restored. Restart the box (Settings > Device Preferences > About > Restart)."
