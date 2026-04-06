#!/bin/bash
# Nickel Browser - Build Windows Installer Package
set -e

echo "=== STEP START: Build Windows Installer Package ==="

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Nickel directory is the parent of the scripts directory
NICKEL_DIR="${NICKEL_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
# Default SRC_DIR if not set
SRC_DIR="${SRC_DIR:-$HOME/nickel-src/src}"

VERSION="${NICKEL_VERSION:-1.0.0-alpha}"
BUILD_DIR="${SRC_DIR}/out/Release"

if [ ! -d "$BUILD_DIR" ]; then
    echo "❌ Error: Nickel build not found at $BUILD_DIR"
    exit 1
fi

cd "$SRC_DIR"

echo "📂 Creating Windows installer package structure..."
mkdir -p installer
cp -r "$BUILD_DIR"/* installer/

echo "📝 Creating NSIS installer script..."
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
; Fallback to generic icon if specific icon not found
!define MUI_ICON "installer\chrome.exe"
!define MUI_UNICON "installer\chrome.exe"

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; License page
; Skip license page for now if LICENSE file not in build dir
; !insertmacro MUI_PAGE_LICENSE "LICENSE"
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

; MUI end ----

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

Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "Nickel Browser was successfully removed from your computer."
FunctionEnd

Function un.onInit
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to completely remove Nickel Browser?" IDYES +2
  Abort
FunctionEnd

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

echo "📦 Creating Windows installer package..."
# Fallback method if NSIS fails or not present
makensis installer.nsi || {
    echo "⚠️  makensis failed. Creating .zip fallback."
    zip -r "NickelBrowser-${VERSION}-windows-x64.zip" installer/
}

echo "✅ Windows installer package created!"
echo "=== STEP END: Build Windows Installer Package ==="
