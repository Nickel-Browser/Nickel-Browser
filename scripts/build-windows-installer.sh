#!/bin/bash
# Nickel Browser - Build Windows Installer (Production Grade)
# Author: FimuFixer CI Engine for Showaib Islam

set -euo pipefail

echo "=== [$(date +'%Y-%m-%dT%H:%M:%S')] NICKEL WINDOWS INSTALLER START ==="

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Nickel directory is the parent of the scripts directory
NICKEL_DIR="${NICKEL_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
# Default SRC_DIR if not set
SRC_DIR="${SRC_DIR:-$HOME/nickel-src/src}"
BUILD_DIR="${BUILD_DIR:-$SRC_DIR/out/Nickel}"
VERSION="${NICKEL_VERSION:-1.0.0-alpha}"

echo "DEBUG: SCRIPT_DIR=$SCRIPT_DIR"
echo "DEBUG: NICKEL_DIR=$NICKEL_DIR"
echo "DEBUG: SRC_DIR=$SRC_DIR"
echo "DEBUG: BUILD_DIR=$BUILD_DIR"
echo "DEBUG: VERSION=$VERSION"

# Validation
if [ ! -d "$BUILD_DIR" ]; then
    echo "ERROR: Build directory not found at $BUILD_DIR. Fatal."
    exit 1
fi

# Create installer directory
INSTALLER_DIR="installer"
echo "LOG: Creating installer directory..."
rm -rf "$INSTALLER_DIR"
mkdir -p "$INSTALLER_DIR"

# Copy build files
echo "LOG: Copying build artifacts to installer dir..."
cp -r "$BUILD_DIR"/* "$INSTALLER_DIR/"

# Create NSIS installer script
echo "LOG: Creating NSIS script..."
cat > installer.nsi << EOF
!define PRODUCT_NAME "Nickel Browser"
!define PRODUCT_VERSION "$VERSION"
!define PRODUCT_PUBLISHER "Nickel Browser Team"
!define PRODUCT_WEB_SITE "https://nickel-browser.org"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\NickelBrowser"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

SetCompressor lzma

; MUI Settings
!include "MUI.nsh"
!define MUI_ABORTWARNING

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!define MUI_FINISHPAGE_RUN "\$INSTDIR\chrome.exe"
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "English"

Name "\${PRODUCT_NAME} \${PRODUCT_VERSION}"
OutFile "NickelBrowser-\${PRODUCT_VERSION}-windows-x64.exe"
InstallDir "\$PROGRAMFILES64\Nickel Browser"
InstallDirRegKey HKLM "\${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails show
ShowUnInstDetails show

Section "MainSection" SEC01
  SetOutPath "\$INSTDIR"
  SetOverwrite ifnewer
  File /r "installer\*"
  
  CreateDirectory "\$SMPROGRAMS\Nickel Browser"
  CreateShortcut "\$SMPROGRAMS\Nickel Browser\Nickel Browser.lnk" "\$INSTDIR\chrome.exe"
  CreateShortcut "\$DESKTOP\Nickel Browser.lnk" "\$INSTDIR\chrome.exe"
  
  WriteRegStr HKLM "\${PRODUCT_DIR_REGKEY}" "" "\$INSTDIR\chrome.exe"
SectionEnd

Section -Post
  WriteUninstaller "\$INSTDIR\uninst.exe"
  WriteRegStr HKLM "\${PRODUCT_UNINST_KEY}" "DisplayName" "\$(^Name)"
  WriteRegStr HKLM "\${PRODUCT_UNINST_KEY}" "UninstallString" "\$INSTDIR\uninst.exe"
  WriteRegStr HKLM "\${PRODUCT_UNINST_KEY}" "DisplayIcon" "\$INSTDIR\chrome.exe"
  WriteRegStr HKLM "\${PRODUCT_UNINST_KEY}" "DisplayVersion" "\${PRODUCT_VERSION}"
  WriteRegStr HKLM "\${PRODUCT_UNINST_KEY}" "URLInfoAbout" "\${PRODUCT_WEB_SITE}"
  WriteRegStr HKLM "\${PRODUCT_UNINST_KEY}" "Publisher" "\${PRODUCT_PUBLISHER}"
SectionEnd

Section Uninstall
  Delete "\$INSTDIR\uninst.exe"
  Delete "\$SMPROGRAMS\Nickel Browser\Nickel Browser.lnk"
  Delete "\$DESKTOP\Nickel Browser.lnk"
  RMDir "\$SMPROGRAMS\Nickel Browser"
  RMDir /r "\$INSTDIR"
  
  DeleteRegKey HKLM "\${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "\${PRODUCT_DIR_REGKEY}"
  SetAutoClose true
SectionEnd
EOF

# Build installer with NSIS
echo "LOG: Running makensis..."
if command -v makensis &> /dev/null; then
    makensis installer.nsi
else
    echo "WARNING: NSIS not available. Creating ZIP fallback."
    zip -r "NickelBrowser-${VERSION}-windows-x64.zip" "$INSTALLER_DIR/"
fi

echo "=== [$(date +'%Y-%m-%dT%H:%M:%S')] NICKEL WINDOWS INSTALLER COMPLETE ==="
