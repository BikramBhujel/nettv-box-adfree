#!/bin/bash
# Save the box's app list, settings and home app before changing anything.
# Usage: bash backup.sh 192.168.0.50:5789
set -e
BOX="${1:?usage: bash backup.sh <box ip:port>}"
OUT="backup-$(date +%Y-%m-%d-%H%M)"
mkdir -p "$OUT"
adb connect "$BOX" >/dev/null
adb -s "$BOX" get-state >/dev/null
adb -s "$BOX" shell pm list packages -f   > "$OUT/packages-all.txt"
adb -s "$BOX" shell pm list packages -d   > "$OUT/packages-disabled.txt"
adb -s "$BOX" shell pm list packages -3   > "$OUT/packages-thirdparty.txt"
adb -s "$BOX" shell getprop               > "$OUT/getprop.txt"
for ns in global secure system; do
  adb -s "$BOX" shell settings list "$ns" > "$OUT/settings-$ns.txt"
done
adb -s "$BOX" shell cmd package resolve-activity --brief \
  -a android.intent.action.MAIN -c android.intent.category.HOME > "$OUT/home-activity.txt"
echo "Backup saved in $OUT"
