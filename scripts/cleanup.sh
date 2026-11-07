#!/bin/bash
# Turn off NetTV's ad and extra apps on a NETTV-1000 and make a new launcher Home.
# Everything here is reversible with restore.sh. Nothing is uninstalled.
#
# Usage:
#   bash cleanup.sh <box ip:port> [launcher package/.Activity]
# Example:
#   bash cleanup.sh 192.168.0.50:5789 me.efesser.flauncher/.MainActivity
#
# Optional: PRIVATE_DNS=yourid.dns.nextdns.io bash cleanup.sh ...
#   sets Android Private DNS so ad blocking also works on the ISP's Ethernet.
set -e
BOX="${1:?usage: bash cleanup.sh <box ip:port> [launcher component]}"
HOME_COMPONENT="${2:-}"
STATE="cleanup-state"
mkdir -p "$STATE"
a() { adb -s "$BOX" "$@"; }
adb connect "$BOX" >/dev/null
a get-state >/dev/null

# Apps I turned off. Keep anything you use: delete its line.
# Never add these: stb.iptv (Live TV), stb.launcher (login and subscription),
# nettv.myaccount (payments), or any com.android.* core package.
DISABLE=(
  np.com.geniussystems.screensaver
  np.com.nettv.movies
  np.com.geniussystems.android.stb.nettvprime
  np.com.geniussystems.android.stb.tvshows
)
# Uncomment if you installed SmartTube and want the stock YouTube off:
# DISABLE+=(com.google.android.youtube.tv)

for p in "${DISABLE[@]}"; do
  if a shell pm list packages | grep -q "package:$p\$"; then
    a shell pm disable-user --user 0 "$p" && echo "$p" >> "$STATE/disabled.txt"
  fi
done

if [ -n "$HOME_COMPONENT" ]; then
  a shell cmd package set-home-activity --user 0 "$HOME_COMPONENT"
  echo "$HOME_COMPONENT" > "$STATE/home.txt"
fi

if [ -n "${PRIVATE_DNS:-}" ]; then
  a shell settings put global private_dns_specifier "$PRIVATE_DNS"
  a shell settings put global private_dns_mode hostname
  echo "$PRIVATE_DNS" > "$STATE/private-dns.txt"
fi

sleep 15   # Android writes package state about ten seconds after a change
a shell sync
echo "Done. Disabled now:"; a shell pm list packages -d
echo "Restart the box, then open Live TV to check it still plays."
