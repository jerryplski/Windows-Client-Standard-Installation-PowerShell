# Windows Client Provisioning Script

## Overview

This project provides an automated PowerShell-based solution to prepare and configure Windows 10/11 client systems in a standardized and reproducible way.

It is designed for IT administrators, homelab environments and training purposes, focusing on automation, system hardening and software deployment.

---

## Features

* Automatic elevation to Administrator
* System restore point creation (before & after setup)
* Windows Update installation
* Network configuration (Private network, discovery enabled)
* Package management via Chocolatey
* Automated installation of common software
* Third-party software updates
* Basic system preparation

---

## Technologies Used

* PowerShell
* Chocolatey
* Windows Update API (PSWindowsUpdate module)

---

## Installation & Usage

### 1. Run the script

```powershell
.\setup.ps1
```

### 2. Requirements

* Windows 10 / 11
* Administrator privileges
* Internet connection

---

## Configuration (Planned Improvements)

Future versions will support:

* Custom software selection
* Configuration via JSON/YAML
* Logging & error handling
* Integration with Active Directory / Domain Join
* Remote execution support (WinRM)

---

## Example Use Cases

* Preparing new company laptops
* Lab environments
* Rapid workstation deployment
* Standardized system configuration

---

## Disclaimer

This script modifies system settings and installs software.
Use in production environments only after testing.

---

## Roadmap

* [ ] Logging implementation
* [ ] Parameter support
* [ ] Modular structure
* [ ] Domain join automation
* [ ] Security improvements

---

## Author

Jeremy – IT enthusiast focused on networking, infrastructure and automation
