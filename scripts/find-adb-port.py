#!/usr/bin/env python3
"""Scan every TCP port on the TV box and print the open ones.

The NETTV-1000 does not use the usual ADB port 5555. On my box it was 5789.
Usage: python3 find-adb-port.py 192.168.0.50
Takes about 90 seconds on a home network.
"""
import asyncio
import sys

if len(sys.argv) != 2:
    sys.exit("usage: python3 find-adb-port.py <box ip>")
HOST = sys.argv[1]
found = []

async def check(port, sem):
    async with sem:
        try:
            _, w = await asyncio.wait_for(asyncio.open_connection(HOST, port), 1.5)
            found.append(port)
            w.close()
        except Exception:
            pass

async def main():
    sem = asyncio.Semaphore(800)
    await asyncio.gather(*(check(p, sem) for p in range(1, 65536)))
    print("open ports:", sorted(found) or "none")
    if found:
        print("try each one with: adb connect %s:<port>" % HOST)

asyncio.run(main())
