#!/bin/bash
# scripts/build-windows-installer.sh
# Creates an NSIS installer for Nickel Browser on Windows

set -euo pipefail

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Nickel directory is the parent of the scripts directory
NICKEL_DIR="${NICKEL_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"

VERSION="${NICKEL_VERSION:-1.0.0-alpha}"
BINARY_DIR="${BINARY_DIR:-$NICKEL_DIR/uc-binary}"
DIST_DIR="${DIST_DIR:-$NICKEL_DIR/dist}"

echo "📦 Building Windows Installer..."

# Find the Chromium root in the binary dir (it's often the root for Windows)
CHROME_ROOT=$(find "$BINARY_DIR" -maxdepth 2 -name "chrome.exe" -type f | xargs dirname | head -n 1)

if [ -z "$CHROME_ROOT" ]
then
    echo "❌ Error: Could not find 'chrome.exe' binary in $BINARY_DIR"
    exit 1
fi

echo "📍 CHROME_ROOT: $CHROME_ROOT"

# Rename the main binary to nickel-browser.exe for consistency
if [ -f "$CHROME_ROOT/chrome.exe" ]
then
    mv "$CHROME_ROOT/chrome.exe" "$CHROME_ROOT/nickel-browser.exe"
fi

# Create a basic NSIS script if not present
cat > "$NICKEL_DIR/nickel-installer.nsi" << EOF
!include "MUI2.nsh"

Name "Nickel Browser"
OutFile "NickelBrowser-\${VERSION}-Setup.exe"
InstallDir "\$PROGRAMFILES64\Nickel Browser"
InstallDirRegKey HKLM "Software\Nickel Browser" "Install_Dir"

!define MUI_ABORTWARNING
!define MUI_ICON "$NICKEL_DIR/src/nickel/branding/product_logo_256.ico"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

!insertmacro MUI_LANGUAGE "English"

Section "Nickel Browser (Required)"
    SectionIn RO
    SetOutPath "\$INSTDIR"
    File /r "$CHROME_ROOT\*"

    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NickelBrowser" "DisplayName" "Nickel Browser"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NickelBrowser" "UninstallString" "\$INSTDIR\uninstall.exe"
    WriteUninstaller "\$INSTDIR\uninstall.exe"

    CreateShortCut "\$SMPROGRAMS\Nickel Browser.lnk" "\$INSTDIR\nickel-browser.exe"
SectionEnd

Section "Uninstall"
    Delete "\$INSTDIR\uninstall.exe"
    Delete "\$SMPROGRAMS\Nickel Browser.lnk"
    RMDir /r "\$INSTDIR"
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\NickelBrowser"
SectionEnd
EOF

# Note: In Windows GHA, 'makensis' needs to be in PATH or called directly.
# For now, we'll assume it's available via choco install nsis.
if command -v makensis &> /dev/null
then
    makensis -DVERSION="$VERSION" "$NICKEL_DIR/nickel-installer.nsi"
    mkdir -p "$DIST_DIR"
    mv "NickelBrowser-${VERSION}-Setup.exe" "$DIST_DIR/"
    echo "✅ Windows installer created: NickelBrowser-${VERSION}-Setup.exe"
else
    echo "⚠️  makensis not found. Skipping installer build."
    # Fallback: create a zip of the binary
    mkdir -p "$DIST_DIR"
    cd "$CHROME_ROOT" && zip -r "$DIST_DIR/NickelBrowser-${VERSION}-windows-x64.zip" .
    echo "✅ ZIP package created instead of installer: NickelBrowser-${VERSION}-windows-x64.zip"
fi
