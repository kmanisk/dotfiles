# Hardware & Driver Inventory — ASUS TUF Gaming F16 (2025)

* **Laptop Model**: ASUS TUF Gaming F16 (2025) \FX608JM\ (Sub-model \FX608JH\)
* **Official ASUS Support Hub**: [ASUS FX608JM HelpDesk Download](https://www.asus.com/laptops/for-gaming/tuf-gaming/asus-tuf-gaming-f16-2025/helpdesk_download?model2Name=FX608JM)
* **Last Inspected**: August 28, 2026

---

## 1. 📶 Wi-Fi / WLAN Driver

| Property | Value |
| :--- | :--- |
| **Device Name** | \Realtek 8852CE WiFi 6E PCI-E NIC\ |
| **Hardware ID** | \PCI\VEN_10EC&DEV_C852&SUBSYS_E110105B&REV_01\ |
| **Driver Provider** | Realtek Semiconductor Corp. |
| **Installed Driver Version** | \6001.16.174.103\ |
| **Driver Date** | \2026-03-13\ |
| **Category on ASUS Support** | **Networking / Wireless** |

---

## 2. 🔷 Bluetooth Driver

| Property | Value |
| :--- | :--- |
| **Device Name** | \Realtek Bluetooth Adapter\ |
| **Hardware ID** | \USB\VID_0489&PID_E122&REV_0000\ |
| **Driver Provider** | Realtek Semiconductor Corp. |
| **Installed Driver Version** | \178.4039.2510.902\ |
| **Driver Date** | \2026-03-03\ |
| **Installer in Downloads** | \Bluetooth_ROG_Realtek_J_V178.4039.2510.0902Sub2_49946.exe\ |
| **Category on ASUS Support** | **Bluetooth** |

---

## 3. ⚙️ ASUS System Control Interface v3 (G-Helper Bridge)

| Property | Value |
| :--- | :--- |
| **Device Name** | \ASUS System Control Interface v3\ |
| **Hardware ID** | \ACPI\VEN_ASUS&DEV_2018\ |
| **Driver Provider** | ASUS |
| **Installed Driver Version** | \3.1.67.0\ |
| **Driver Date** | \2026-06-16\ |
| **Category on ASUS Support** | **System & Chipset / Utilities** |
| **Why Needed** | **Crucial for G-Helper** to communicate with ASUS BIOS/Embedded Controller (EC) for fan curves, battery charging thresholds (80%), GPU MUX modes, screen overdrive, keyboard RGB, and hotkeys. |

---

## 4. 🖱️ ASUS Precision TouchPad Driver

| Property | Value |
| :--- | :--- |
| **Device Name** | \ASUS Precision Touchpad\ (I2C HID Device) |
| **Hardware ID** | \ACPI\VEN_ASCE&DEV_1200\ / \HID\VEN_ASCE&DEV_1200&Col01\ |
| **Driver Provider** | Microsoft / ASUS (Native Windows Precision Touchpad stack) |
| **Driver Version** | \10.0.22621.6133\ |
| **Category on ASUS Support** | **Pointing Device** |
| **Notes** | Uses Windows 11 built-in Precision Touchpad engine natively for multi-touch gestures (pinch-to-zoom, 3/4-finger swipe). No standalone bloated tray app required. |

---

## 5. 💽 Intel Rapid Storage Technology (IRST / VMD)

| Property | Value |
| :--- | :--- |
| **Device Name** | \Intel RST VMD Controller A77F\ |
| **Hardware ID** | \PCI\VEN_8086&DEV_A77F\ |
| **Driver Provider** | Intel Corporation |
| **Installed Driver Version** | \20.0.0.1038\ |
| **Installer in Downloads** | \VMD_ROG_Intel_J_V20.0.0.1038_39707_1.exe\ |
| **Category on ASUS Support** | **Chipset / SATA / Storage** |
| **Notes** | Required during clean Windows setup if NVMe SSD is managed under Intel VMD volume mode. |

---

## 6. 🔊 Dolby Atmos & Realtek Audio (\C:\DRIVERS\)

### Active Installed Audio Configuration:
* **Registry Version**: \HKLM:\SOFTWARE\ASUS\Dolby_Atmos_for_Consumer_driver\ -> \10.314.535.34\
* **Realtek High Definition Audio**: \6.0.9885.1\ (\INTELAUDIO\FUNC_01&VEN_10EC&DEV_0256&SUBSYS_10431084\)
* **Intel Smart Sound Technology (OED/BUS)**: \10.29.0.12030\
* **Dolby APO Components**: \3.30803.830.0\ (HSA) / \3.30807.872.0\ (SWC)

### Local Driver Packages in \C:\DRIVERS\:
1. \C:\DRIVERS\DolbyAtmosdriverforConsumer_ASUS_Z_V10.314.535.34_16587_20260525220539\ *(Active: 10.314.535.34)*
2. \C:\DRIVERS\DolbyAtmosdriverforConsumer_ASUS_Z_V11.121.533.21_17478_20260508201719\ *(Available Update: 11.121.533.21)*
3. Installer in Downloads: \ASUS_Z_V10.314.535.34_16587_2.exe\

### Reinstall / Update Command:
\\\cmd
pnputil /add-driver "C:\DRIVERS\DolbyAtmosdriverforConsumer_ASUS_Z_V11.121.533.21_17478_20260508201719\*.inf" /subdirs /install
\\\

---

## 7. ❓ Realtek Audio Console / Codec Console Popup Guide

### What is it?
* **Realtek Audio Control** (\RealtekSemiconductorCorp.RealtekAudioControl\) is a companion UWP application from the Microsoft Store.
* When you plug into the 3.5mm audio jack, the Realtek service detects impedance change and triggers a pop-up asking: *"Which device did you plug in: Headset / Headphones / Mic?"*

### Do you need it?
* **NO**. The audio driver, DAC, headphone output, microphone input, and Dolby Atmos all function 100% natively without this app.

### How to stop the popup:
1. **Option 1 (Keep app, disable popup - Recommended)**:
   * Open **Realtek Audio Control** from the Start Menu.
   * Click **Advanced Device Settings** (Gear icon at bottom-left).
   * Toggle **"Enable auto popup dialog when device is plugged in"** to **OFF**.
2. **Option 2 (Uninstall app completely)**:
   * Run in PowerShell:
     \\\powershell
     Get-AppxPackage *RealtekAudioControl* | Remove-AppxPackage
     \\\
   * *This will NOT break audio playback, headphone switching, or Dolby Atmos.*
