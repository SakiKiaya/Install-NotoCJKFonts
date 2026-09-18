<#
.SYNOPSIS
  Download and install Noto CJK fonts for Windows, then use the included Advanced Font Settings JSON.

.DESCRIPTION
  Downloads official Noto CJK release packages:
    - Sans2.004 / 02_NotoSansCJK-TTF-VF.zip
    - Serif2.003 / 03_NotoSerifCJK-TTF-VF.zip

  Default target regions:
    - TC: Traditional Chinese
    - SC: Simplified Chinese
    - JP: Japanese

  The Sans package contains both Sans and Mono. By default this script installs:
    - Noto Sans CJK TC / SC / JP
    - Noto Sans Mono CJK TC / SC / JP
    - Noto Serif CJK TC / SC / JP

.PARAMETER InstallScope
  CurrentUser: install fonts under %LOCALAPPDATA%\Microsoft\Windows\Fonts and HKCU registry. No admin required.
  AllUsers: install fonts under C:\Windows\Fonts and HKLM registry. Requires Administrator.

.PARAMETER WorkDir
  Temporary working directory used for downloads and extraction.

.PARAMETER SkipSerif
  Install Sans and Mono only.

.PARAMETER SkipMono
  Install Sans only from the Sans package.

.PARAMETER SkipVariableFonts
  Skip font files whose filename/path contains VF or Variable.

.PARAMETER KeepDownloads
  Keep downloaded ZIP files and extracted font files after installation.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\Install-NotoCJKFonts.ps1

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\Install-NotoCJKFonts.ps1 -InstallScope AllUsers

.NOTES
  Noto CJK releases:
    https://github.com/notofonts/noto-cjk/releases
#>

[CmdletBinding()]
param(
    [ValidateSet('CurrentUser','AllUsers')]
    [string]$InstallScope = 'CurrentUser',

    [string]$WorkDir = "$env:TEMP\NotoCJKFonts",

    [switch]$SkipSerif,

    [switch]$SkipMono,

    [switch]$SkipVariableFonts,

    [switch]$KeepDownloads
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$TargetRegions = @('TC','SC','JP')

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Invoke-DownloadFile {
    param(
        [Parameter(Mandatory=$true)][string]$Url,
        [Parameter(Mandatory=$true)][string]$OutputPath
    )

    if (Test-Path -LiteralPath $OutputPath) {
        Write-Host "[SKIP] Already downloaded: $OutputPath"
        return
    }

    Write-Host "[DOWNLOAD] $Url"
    Invoke-WebRequest `
        -Uri $Url `
        -OutFile $OutputPath `
        -UseBasicParsing `
        -Headers @{ 'User-Agent' = 'PowerShell-Noto-CJK-Installer' }
}

function Expand-ZipFile {
    param(
        [Parameter(Mandatory=$true)][string]$ZipPath,
        [Parameter(Mandatory=$true)][string]$Destination
    )

    if (Test-Path -LiteralPath $Destination) {
        Remove-Item -LiteralPath $Destination -Recurse -Force
    }

    New-Item -ItemType Directory -Path $Destination -Force | Out-Null
    Write-Host "[EXTRACT] $ZipPath"
    Expand-Archive -LiteralPath $ZipPath -DestinationPath $Destination -Force
}

function Get-FontRegistrySuffix {
    param([Parameter(Mandatory=$true)][string]$Extension)

    switch ($Extension.ToLowerInvariant()) {
        '.ttf' { return 'TrueType' }
        '.ttc' { return 'TrueType' }
        '.otf' { return 'OpenType' }
        '.otc' { return 'OpenType' }
        default { return 'Font' }
    }
}

function Install-FontFile {
    param(
        [Parameter(Mandatory=$true)][System.IO.FileInfo]$FontFile,
        [Parameter(Mandatory=$true)][string]$Scope
    )

    $suffix = Get-FontRegistrySuffix -Extension $FontFile.Extension
    $valueName = "$($FontFile.BaseName) ($suffix)"

    if ($Scope -eq 'AllUsers') {
        $fontDir = Join-Path $env:WINDIR 'Fonts'
        $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
        $destPath = Join-Path $fontDir $FontFile.Name
        $regValue = $FontFile.Name
    }
    else {
        $fontDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
        $regPath = 'HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
        $destPath = Join-Path $fontDir $FontFile.Name
        $regValue = $destPath
    }

    New-Item -ItemType Directory -Path $fontDir -Force | Out-Null

    if (Test-Path -LiteralPath $destPath) {
        Write-Host "[SKIP] Installed file exists: $($FontFile.Name)"
    }
    else {
        Write-Host "[INSTALL] $($FontFile.Name)"
        Copy-Item -LiteralPath $FontFile.FullName -Destination $destPath -Force
    }

    New-Item -Path $regPath -Force | Out-Null
    New-ItemProperty -Path $regPath -Name $valueName -Value $regValue -PropertyType String -Force | Out-Null
}

function Send-FontChangeBroadcast {
    Add-Type -Namespace Win32 -Name NativeMethods -MemberDefinition @"
[System.Runtime.InteropServices.DllImport("user32.dll", SetLastError=true, CharSet=System.Runtime.InteropServices.CharSet.Auto)]
public static extern System.IntPtr SendMessageTimeout(
    System.IntPtr hWnd,
    uint Msg,
    System.IntPtr wParam,
    System.IntPtr lParam,
    uint fuFlags,
    uint uTimeout,
    out System.IntPtr lpdwResult);
"@
    $HWND_BROADCAST = [IntPtr]0xffff
    $WM_FONTCHANGE = 0x001D
    $SMTO_ABORTIFHUNG = 0x0002
    $result = [IntPtr]::Zero
    [void][Win32.NativeMethods]::SendMessageTimeout($HWND_BROADCAST,$WM_FONTCHANGE,[IntPtr]::Zero,[IntPtr]::Zero,$SMTO_ABORTIFHUNG,5000,[ref]$result)
}

function Test-TargetRegionFont {
    param([Parameter(Mandatory=$true)][System.IO.FileInfo]$FontFile)
    foreach ($region in $TargetRegions) {
        if ($FontFile.Name -match "(?i)CJK$region(?=[\._-])") { return $true }
        if ($FontFile.Name -match "(?i)CJK$region\b") { return $true }
    }
    return $false
}

function Test-VariableFont {
    param([Parameter(Mandatory=$true)][System.IO.FileInfo]$FontFile)
    if ($FontFile.Name -match '(?i)(VF|Variable)') { return $true }
    if ($FontFile.FullName -match '(?i)(\\|/)(VF|Variable)(\\|/)') { return $true }
    return $false
}

function Get-SelectedFontFiles {
    param(
        [Parameter(Mandatory=$true)][string]$ExtractedPath,
        [Parameter(Mandatory=$true)][ValidateSet('Sans','Serif')][string]$Family
    )

    $allFonts = Get-ChildItem -LiteralPath $ExtractedPath -Recurse -File |
        Where-Object { $_.Extension -match '^\.(ttf|ttc|otf|otc)$' }

    if (-not $allFonts -or $allFonts.Count -eq 0) {
        throw "No font files found under: $ExtractedPath"
    }

    $selected = foreach ($font in $allFonts) {
        $fileName = $font.Name

        if ($SkipVariableFonts -and (Test-VariableFont -FontFile $font)) { continue }
        if (-not (Test-TargetRegionFont -FontFile $font)) { continue }

        if ($Family -eq 'Sans') {
            if ($SkipMono -and $fileName -match '(?i)NotoSansMonoCJK') { continue }
            if ($fileName -match '(?i)(NotoSansCJK|NotoSansMonoCJK)') { $font }
        }
        elseif ($Family -eq 'Serif') {
            if ($fileName -match '(?i)NotoSerifCJK') { $font }
        }
    }

    $selected = @($selected | Sort-Object FullName -Unique)
    if ($selected.Count -eq 0) {
        throw "No selected $Family font files found. The release package layout may have changed."
    }
    return $selected
}

if ($InstallScope -eq 'AllUsers' -and -not (Test-IsAdministrator)) {
    throw 'InstallScope=AllUsers requires an elevated PowerShell session. Run PowerShell as Administrator or use -InstallScope CurrentUser.'
}

$packages = @(
    @{
        Name   = 'Noto Sans CJK TTF-VF package, includes Sans and Mono'
        Family = 'Sans'
        Url    = 'https://github.com/notofonts/noto-cjk/releases/download/Sans2.004/02_NotoSansCJK-TTF-VF.zip'
        File   = '02_NotoSansCJK-TTF-VF.zip'
    }
)

if (-not $SkipSerif) {
    $packages += @(
        @{
            Name   = 'Noto Serif CJK TTF-VF package'
            Family = 'Serif'
            Url    = 'https://github.com/notofonts/noto-cjk/releases/download/Serif2.003/03_NotoSerifCJK-TTF-VF.zip'
            File   = '03_NotoSerifCJK-TTF-VF.zip'
        }
    )
}

$downloadDir = Join-Path $WorkDir 'downloads'
$extractDir = Join-Path $WorkDir 'extracted'
New-Item -ItemType Directory -Path $downloadDir -Force | Out-Null
New-Item -ItemType Directory -Path $extractDir -Force | Out-Null

Write-Host "Install scope       : $InstallScope"
Write-Host "Work dir            : $WorkDir"
Write-Host "Target regions      : $($TargetRegions -join ', ')"
Write-Host "Install Mono        : $(-not $SkipMono)"
Write-Host "Install Serif       : $(-not $SkipSerif)"
Write-Host "Skip variable fonts : $SkipVariableFonts"
Write-Host "Packages            : $($packages.Count)"
Write-Host ''

$totalProcessed = 0
foreach ($pkg in $packages) {
    Write-Host ''
    Write-Host "== $($pkg.Name) =="
    $zipPath = Join-Path $downloadDir $pkg.File
    $pkgExtractDir = Join-Path $extractDir ([IO.Path]::GetFileNameWithoutExtension($pkg.File))

    Invoke-DownloadFile -Url $pkg.Url -OutputPath $zipPath
    Expand-ZipFile -ZipPath $zipPath -Destination $pkgExtractDir

    $fontFiles = @(Get-SelectedFontFiles -ExtractedPath $pkgExtractDir -Family $pkg.Family)
    Write-Host "[INFO] Selected font files: $($fontFiles.Count)"

    foreach ($font in $fontFiles) {
        Install-FontFile -FontFile $font -Scope $InstallScope
        $totalProcessed++
    }
}

Send-FontChangeBroadcast

$settingsJson = Join-Path $PSScriptRoot 'Advanced_Font_Settings_Noto_CJK_TC_SC_JP.json'
if (Test-Path -LiteralPath $settingsJson) {
    Write-Host ''
    Write-Host '[INFO] Advanced Font Settings import file:'
    Write-Host "       $settingsJson"
}

if (-not $KeepDownloads) {
    Write-Host ''
    Write-Host "[CLEANUP] Removing work directory: $WorkDir"
    Remove-Item -LiteralPath $WorkDir -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host ''
Write-Host 'Done.'
Write-Host "Processed font files: $totalProcessed"
Write-Host 'Recommended next steps:'
Write-Host '1. Restart Chrome / Edge.'
Write-Host '2. Open Advanced Font Settings extension.'
Write-Host '3. Import Advanced_Font_Settings_Noto_CJK_TC_SC_JP.json.'
Write-Host '4. If font names do not appear immediately, sign out/in or reboot Windows.'
