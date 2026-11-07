# NetTV box ad-free setup (WorldLink NETTV-1000)

Scripts and notes I used to clean up my WorldLink NetTV box in Nepal: no home screen ads, no ad before Live TV, ad-free YouTube, an Apple TV style home screen, and Live TV plus the monthly subscription still working.

Full write-up with screenshots: [How I Removed Ads From My WorldLink NetTV Box](https://www.bikrambhujel.com.np/2026/11/how-i-removed-ads-from-my-worldlink.html) on bikrambhujel.com.np.

> Tested on one box: NETTV-1000, Android 10, build `NETTV-1000_20240111-1728`, Live TV app 3.2.3. Other NetTV models (GX1001, NX3000, Streamz+) are different. Check yours under Settings > Device Preferences > About.

## What is in here

| Path | What it does |
|---|---|
| `scripts/find-adb-port.py` | Scans the box for open ports. ADB on this model is **not** on 5555 (mine was 5789). |
| `scripts/backup.sh` | Saves the app list, settings and current home app before you change anything. |
| `scripts/cleanup.sh` | Turns off the NetTV screensaver, Movies, Cine+ and TV Shows, sets a new Home, optional Private DNS. |
| `scripts/restore.sh` | Undoes `cleanup.sh`. |
| `blocklists/nettv-ads.txt` | The five ad servers to block in Pi-hole, NextDNS or AdGuard. |
| `launcher/` | Settings and tile icons for an Apple TV style home screen built from [cleanyourtv](https://github.com/Gathin23/cleanyourtv). |

## Before you start

- You need a computer on the same network with [Android platform-tools](https://developer.android.com/tools/releases/platform-tools) (`adb`).
- On the box: Settings > Device Preferences > About, press OK on **Build** 7 times, then turn on **USB debugging** in Developer options.
- This changes your own box. It disables apps, it does not root anything or uninstall system apps, and everything can be undone. You do it at your own risk.

## Steps

```bash
# 1. find the box and its ADB port
python3 scripts/find-adb-port.py 192.168.0.50
adb connect 192.168.0.50:5789          # press Allow on the TV

# 2. back up
bash scripts/backup.sh 192.168.0.50:5789

# 3. (optional) install a launcher and SmartTube
adb -s 192.168.0.50:5789 install -r flauncher.apk
adb -s 192.168.0.50:5789 install -r SmartTube_stable_armeabi-v7a.apk   # the box is 32-bit ARM

# 4. clean up
bash scripts/cleanup.sh 192.168.0.50:5789 me.efesser.flauncher/.MainActivity
```

Then block the servers in `blocklists/nettv-ads.txt`:

- **Pi-hole:** Domains > add each one as an exact deny.
- **ISP router Ethernet:** WorldLink's router uses its own DNS, so Pi-hole is skipped when the box is on that cable. Either plug the cable into your own router, or use Android Private DNS with NextDNS:

```bash
PRIVATE_DNS=yourid.dns.nextdns.io bash scripts/cleanup.sh 192.168.0.50:5789
```

If the Live TV start screen still shows an ad after blocking, the app is showing a copy it saved earlier. Clear only the Live TV app's data once (it does not reset the box, and channels come back from WorldLink's server):

```bash
adb -s 192.168.0.50:5789 backup -f livetv.ab -noapk np.com.geniussystems.android.stb.iptv   # confirm on the TV
adb -s 192.168.0.50:5789 shell pm clear np.com.geniussystems.android.stb.iptv
```

## Do not disable these

| Package | Why |
|---|---|
| `np.com.geniussystems.android.stb.iptv` | Live TV |
| `np.com.geniussystems.android.stb.launcher` | Login and subscription (device admin) |
| `np.com.nettv.myaccount` | Account and payments |
| any `com.android.*` core package | The box may not boot |

## Rollback

```bash
bash scripts/restore.sh 192.168.0.50:5789 me.efesser.flauncher com.gathin.tvhome
```

No computer? On the box: Settings > Apps > Default apps > Home app > NetTV Launcher, then enable any disabled app from Settings > Apps.

Restore the Live TV data backup with `adb restore livetv.ab`.

## Credits

- [cleanyourtv](https://github.com/Gathin23/cleanyourtv) by Gathin, for the launcher and the safe debloat approach.
- [833M0L3/NETTV](https://833m0l3.github.io/NETTV/) for the NetTV box notes.
- [SmartTube](https://github.com/yuliskov/SmartTube), [FLauncher](https://gitlab.com/flauncher/flauncher), [Jellyfin](https://jellyfin.org).

MIT licence. Not affiliated with WorldLink, NetTV or Genius Systems.
