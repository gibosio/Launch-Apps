#     Launch-App: CLI tool for launching Windows applications interactively
#     Copyright (C) 2026  gbosio https://github.com/gibosio/

#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.

#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.

#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <https://www.gnu.org/licenses/>.

<#
.SYNOPSIS
  CLI tool for interactively launching Windows applications using fuzzy search.

.DESCRIPTION
  Uses fzf to search through Start Menu shortcuts and executables in standard folders.
  Can launch executables normally or with elevated privileges via -RunAsAdmin.

.PARAMETER RunAsAdmin
  Launch the selected application with administrator privileges.

.EXAMPLE
  Launch-App
  Launch an app by selecting it interactively.

.EXAMPLE
  Launch-App -RunAsAdmin
  Launch an app as administrator.
#>

<# private #> function Get-AppsList {
    [CmdletBinding()]
    param ()

    $startFolders = @(
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs",
        "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
    )

   $apps = Get-ChildItem -Path $startFolders -Recurse -Filter *.lnk |
            Select-Object @{Name='Name';Expression={$_.BaseName}},
                          @{Name='Path';Expression={$_.FullName}}

    $exeFolders = @("C:\Program Files", "C:\Program Files (x86)")
    $exeApps = Get-ChildItem -Path $exeFolders -Recurse -Filter *.exe |
           Select-Object @{Name='Name';Expression={$_.BaseName}},
                         @{Name='Path';Expression={$_.FullName}}
    $apps += $exeApps


    return $apps | Sort-Object Name -Unique
}
<# private #> function Get-AppsList {
    [CmdletBinding()]
    param ()

    $startFolders = @(
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs",
        "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
    ) | Where-Object { Test-Path $_ }

    $exeFolders = @(
        "C:\Program Files", 
        "C:\Program Files (x86)"
        ) | Where-Object { Test-Path $_ }

    $lnkApps = $startFolders |
        ForEach-Object { Get-ChildItem -Path $_ -Recurse -Filter *.lnk -ErrorAction SilentlyContinue } |
        Select-Object @{Name='Name'; Expression = {$_.BaseName}},
                      @{Name='Path'; Expression = {$_.FullName}}

    $exeApps = $exeFolders |
        ForEach-Object { Get-ChildItem -Path $_ -Recurse -Filter *.exe -ErrorAction SilentlyContinue } |
        Select-Object @{Name='Name'; Expression = {$_.BaseName}},
                      @{Name='Path'; Expression = {$_.FullName}}

    # Unisce, rimuove duplicati e ordina
    return ($lnkApps + $exeApps) | Sort-Object Name -Unique
}

<# private #> function Start-AppFromPath {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [switch]$RunAsAdmin
    )
    if ($PSCmdlet.ShouldProcess($Path, "Launch application")) {
        try {
            if ($RunAsAdmin) {
                Start-Process -FilePath $Path -Verb RunAs
            }
            else {
                Start-Process -FilePath $Path
            }
            Write-Host "✔️ Launched: $Path" -ForegroundColor Green
        }
        catch {
            Write-Warning "⚠️ Failed to launch $Path: $_"
        }
    }
}

<# public #> function Launch-App {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    param(
        [switch]$RunAsAdmin
    )

    $apps = Get-AppsList
    if (-not $apps) {
        Write-Warning "⚠️ No applications found in Start Menu or standard folders." 
        return
    }

    $selection = $apps.Name | fzf --prompt="Select app> " --height=40% --layout=reverse

    if ($selection) {
        $app = $apps | Where-Object { $_.Name -eq $selection }
        if ($app) {
            Start-AppFromPath -Path $app.Path -RunAsAdmin $RunAsAdmin -WhatIf:$PSCmdlet.WhatIfPreference -Confirm:$PSCmdlet.ConfirmPreference
        }
    }
}

Set-Alias fzl Launch-App