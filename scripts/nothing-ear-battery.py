#!/usr/bin/env python3
"""Print the per-component battery levels of a pair of Nothing earbuds as one
line of JSON, for example {"left": 50, "right": 40, "case": 100}.

Usage: nothing-ear-battery.py <bluetooth address>

Only the components the earbuds actually report are included. A bud that has run
flat or the case while it is closed is simply missing, and if nothing can be
read at all the output is {}. Errors go to stderr; the exit code is always 0 so
callers only have to read the JSON.

The earbuds speak Nothing's own protocol over RFCOMM channel 15. Each frame is
55 60 01 | command (2 bytes, little endian) | payload length (2 bytes, little
endian) | sequence number | payload | CRC-16/MODBUS of everything before it
(2 bytes, little endian). Command 0xC007 asks for the battery, and the reply,
command 0x4007, carries a count followed by (component, level) pairs.
"""

import json
import socket
import sys
import time

CHANNEL = 15
HEADER = b"\x55\x60\x01"
BATTERY_REQUEST = 0xC007
BATTERY_REPLY = 0x4007
COMPONENTS = {0x02: "left", 0x03: "right", 0x04: "case"}


def crc16(data):
    crc = 0xFFFF
    for byte in data:
        crc ^= byte
        for _ in range(8):
            crc = (crc >> 1) ^ 0xA001 if crc & 1 else crc >> 1
    return crc.to_bytes(2, "little")


def frame(command, payload=b"", sequence=1):
    body = HEADER + command.to_bytes(2, "little") + len(payload).to_bytes(2, "little") \
        + bytes([sequence]) + payload
    return body + crc16(body)


def next_frame(buffer):
    """Take the first complete, valid frame off the front of the buffer.

    Returns (command, payload, rest of buffer), or (None, None, buffer) when no
    complete frame has arrived yet. Bytes that cannot start a valid frame are
    dropped, so one corrupt frame does not block the ones after it.
    """
    while True:
        start = buffer.find(HEADER)
        if start < 0:
            # Keep a possible partial header at the very end.
            return None, None, buffer[-2:]
        buffer = buffer[start:]
        if len(buffer) < 8:
            return None, None, buffer

        command = int.from_bytes(buffer[3:5], "little")
        length = int.from_bytes(buffer[5:7], "little")
        end = 8 + length + 2
        if len(buffer) < end:
            return None, None, buffer

        if crc16(buffer[:end - 2]) == buffer[end - 2:end]:
            return command, buffer[8:8 + length], buffer[end:]

        # Not a real frame after all; look for the next header.
        buffer = buffer[1:]


def parse_battery(payload):
    """Turn a battery reply into {"left": 50, ...}, trusting only what is there.

    The count and the payload length can disagree, for example when a bud drops
    out, so read only as many whole pairs as both allow, and skip components or
    levels that do not make sense.
    """
    if not payload:
        return {}
    pairs = min(payload[0], (len(payload) - 1) // 2)
    levels = {}
    for i in range(pairs):
        component, raw = payload[1 + 2 * i], payload[2 + 2 * i]
        level = raw & 0x7F  # The top bit is a charging flag, which is ignored.
        if component in COMPONENTS and level <= 100:
            levels[COMPONENTS[component]] = level
    return levels


def read_battery(address, timeout=4.0):
    with socket.socket(socket.AF_BLUETOOTH, socket.SOCK_STREAM, socket.BTPROTO_RFCOMM) as sock:
        sock.settimeout(timeout)
        sock.connect((address, CHANNEL))
        sock.sendall(frame(BATTERY_REQUEST))

        # The earbuds may send other frames first, so keep reading until the
        # battery reply turns up or time runs out.
        deadline = time.monotonic() + timeout
        buffer = b""
        while time.monotonic() < deadline:
            sock.settimeout(max(0.1, deadline - time.monotonic()))
            try:
                data = sock.recv(1024)
            except socket.timeout:
                break
            if not data:
                break
            buffer += data
            while True:
                command, payload, buffer = next_frame(buffer)
                if command is None:
                    break
                if command == BATTERY_REPLY:
                    return parse_battery(payload)
    return {}


def main():
    if len(sys.argv) != 2:
        print(__doc__.strip().splitlines()[3], file=sys.stderr)
        print("{}")
        return
    try:
        levels = read_battery(sys.argv[1])
    except OSError as error:
        print(f"Could not read battery: {error}", file=sys.stderr)
        levels = {}
    print(json.dumps(levels))


if __name__ == "__main__":
    main()
