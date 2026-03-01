
# 🚀 Launch-App

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/Launch-App?color=blue)](https://www.powershellgallery.com/packages/Launch-App)

**Launch-App** is a PowerShell module to interactively launch Windows applications using fuzzy search (`fzf`).  
It supports:
- Start Menu shortcuts (`.lnk`)
- Executables in `C:\Program Files` and `C:\Program Files (x86)`
- Launch apps normally or as administrator (`-RunAsAdmin`)

---

## 🛠 Installation

Clone the repository or download the files:

```powershell
> git clone https://github.com/gibosio/Launch-App.git
> cd Launch-App\Launch-App
```

Copy the module to a folder in `$env:PSModulePath`:

```powershell
> $target = "$env:USERPROFILE\Documents\PowerShell\Modules\Launch-App"
> New-Item -ItemType Directory -Force -Path $target
> Copy-Item -Recurse -Path .\* -Destination $target
```

Import the module:

```powershell
> Import-Module Launch-App
```

Verify:

```powershell
Get-Command -Module Launch-App -CommandType All
```

You should see `Launch-App` and alias `fzl`.

---

## ⚡ Usage

Main command:

```powershell
> Launch-App [-RunAsAdmin]
```

Alias:

```powershell
> fzl [-RunAsAdmin]
```

### Parameters

- **-RunAsAdmin** – Launch the selected application with administrator privileges.  
- **-WhatIf / -Confirm** – Standard PowerShell safety switches. 

---

## 📝 Examples

Launch an application normally:

```powershell
> Launch-App
> fzl
```

Launch as administrator:

```powershell
> Launch-App -RunAsAdmin
> fzl -RunAsAdmin
```

---

## 💡 Notes

- Only applications in the Start Menu or standard program folders are listed.  
- If no apps are found, a warning is displayed.  
- Requires [`fzf`](https://github.com/junegunn/fzf) installed in your PATH.

---

## 🤝 Contributing

Contributions welcome!  
Open issues or submit pull requests on GitHub.

---

## 📜 License

This project is licensed under **GNU GPL v3**.  
See [https://www.gnu.org/licenses/gpl-3.0.html](https://www.gnu.org/licenses/gpl-3.0.html) for details.
