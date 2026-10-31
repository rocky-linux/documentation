---
title: QA:Hardware Probe
author: Chris Stackpole
contributors:
tested_with: 8.10, 9.8, 10.2
tags:
  - Softwaretest
  - qa
revision_date: 2026-10-20
rc:
  prod: Rocky Linux
  ver:
    - 8
    - 9
    - 10
  level: Final
render_macros: true
---

## Beschreibung

Die Durchführung physischer Hardwaretests unter der neuesten Version hilft dabei, Hardwarekonfigurationen zu identifizieren, die nachweislich einwandfrei funktionieren. Das verwendete Werkzeug ist `hw-probe`.

Alle Tests haben ⬇️ – niedrige Priorität. Es wäre gut, dies testen zu lassen; sollte dies jedoch nicht geschehen oder sollte der Test fehlschlagen, so ist der Test unerheblich.

## Releases, Architekturen und ISOs

| Distro         | aarch64 | ppc64le | riscv64 | s390x | x86_64 |
| -------------- | ------- | ------- | ------- | ----- | --------------------------- |
| Rocky Linux  9 | ⬇️      | ⬇️      | N/A     | ⬇️    | ⬇️                          |
| Rocky Linux 10 | ⬇️      | ⬇️      | ⬇️      | ⬇️    | ⬇️                          |

## Setup

1. Das Dokument zur [Hardwarekompatibilität](https://docs.rockylinux.org/teams/testing/documentation/hardware/hardware_compat/) ist die beste Anlaufstelle für Informationen zur Installation auf allen Rocky-Versionen.

## Test-Hinweise

1. `sudo -E hw-probe -all -upload` (oder ein entsprechender Befehl; weitere Optionen finden Sie unter [Hardware-Kompatibilität](https://docs.rockylinux.org/teams/testing/documentation/hardware/hardware_compat/))
2. Posten Sie den vom Tool bereitgestellten Link (z. B. https://linux-hardware.org/?probe=a42dbc6763) zusammen mit den Informationen im nächsten Abschnitt.

## Erwartete Ergebnisse

Bitte überprüfen Sie anhand des Links, den der Befehl ausgibt:-

1. Das Feld `System` enthält die korrekte Version des Releases. Dies gilt insbesondere nach dem Update von einer früheren Version.
2. Das Feld `Kernel` enthält die korrekte Kernel-Version.
3. Es sind keine Fehler oder Warnungen bekannt. (Hardware-Warnungen – etwa bei einer defekten SMART-Festplatte – sind hierbei ausgenommen, da sie sich spezifisch auf das jeweilige defekte Gerät beziehen und kein Indiz dafür sind, dass ansonsten einwandfrei funktionierende Hardware nicht ordnungsgemäß arbeitet).

{% include 'teams/testing/qa_testcase_bottom.md' %}
