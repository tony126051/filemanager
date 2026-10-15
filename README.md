# Windows 11 File Manager for macOS

<p align="center">
  <img src="filemanager/Assets.xcassets/AppIcon.appiconset/icon_128x128@2x.png" width="128" height="128" alt="Windows 11 File Manager Icon" />
</p>

<p align="center">
  <b>A modern, native Windows 11 Fluent Design File Explorer experience built for macOS.</b><br/>
  <b>為 macOS 打造的原生 Windows 11 Fluent 設計風格檔案總管。</b>
</p>

<p align="center">
  <a href="https://github.com/tony126051/filemanager/releases/latest"><img src="https://img.shields.io/github/v/release/tony126051/filemanager?color=0078D4&label=Release" alt="Latest Release"></a>
  <img src="https://img.shields.io/badge/Platform-macOS%2013.0%2B-lightgrey?logo=apple" alt="macOS 13+">
  <img src="https://img.shields.io/badge/Swift-5.9%20%7C%206.0-orange?logo=swift" alt="Swift">
  <img src="https://img.shields.io/badge/UI-SwiftUI%20%26%20AppKit-blue" alt="SwiftUI">
</p>

---

## 🌐 Language / 語言選擇
- [English](#english)
- [繁體中文 (Traditional Chinese)](#繁體中文-traditional-chinese)

---

<a name="english"></a>
## English

### ✨ Key Features

- 🪟 **Windows 11 Fluent Design**: Mica-inspired translucent aesthetics, rounded corners, ribbon command bar, and classic Windows 11 icons.
- 📑 **Tabbed Navigation**: Multi-tab browsing support. Open new tabs (`Cmd+T`), close tabs (`Cmd+W`), and navigate directories independently.
- 🎨 **Multiple View Modes**: 
  - Details View (with sortable columns: Name, Date Modified, Type, Size)
  - Large, Medium, and Small Icons Grid
  - List View
  - Tiles View
- 🧭 **Smart Navigation Bar & Breadcrumbs**: Clickable path hierarchy, back/forward/up history navigation, and integrated live search.
- 🌐 **Runtime Multi-Language Support**: Seamlessly switch between **Traditional Chinese (繁體中文)**, **Simplified Chinese (简体中文)**, **English**, and **Japanese (日本語)** without restarting the app.
- ⚡ **Productivity & Shortcuts**:
  - Full keyboard shortcut support (`Cmd+C` Copy, `Cmd+X` Cut, `Cmd+V` Paste, `Cmd+Delete` Move to Trash, `Enter` Rename, `Cmd+R` Refresh).
  - Rich right-click context menu (batch operations, duplicate, copy path, reveal in Finder).
  - Built-in Properties dialog and "Open in Terminal" button.
- 🔄 **In-App Update Mechanism**: Check GitHub releases with one click from the About dialog (`?` button or App Menu) and download the latest version directly.

---

### 📥 Download & Installation

#### Option 1: One-Line Terminal Install (Recommended)
This method automatically downloads and installs the app to `/Applications` without triggering macOS browser quarantine flags:

```bash
curl -sL https://github.com/tony126051/filemanager/releases/download/v1.0.0/filemanager-v1.0.0-macos.zip -o /tmp/fm.zip && unzip -q -o /tmp/fm.zip -d /Applications && rm /tmp/fm.zip
```

#### Option 2: Manual Download
1. Download `filemanager-v1.0.0-macos.zip` from [GitHub Releases](https://github.com/tony126051/filemanager/releases/latest).
2. Unzip the file to extract `filemanager.app`.
3. Drag `filemanager.app` into your **`/Applications`** folder.

---

### 🛡️ Fixing macOS Gatekeeper ("App is damaged" or "Unidentified Developer")

When downloading apps outside the Mac App Store that are not signed with an Apple Developer Program certificate ($99/yr), macOS Gatekeeper attaches a quarantine flag and may show:

> ⚠️ **"filemanager.app is damaged and can't be opened. You should move it to the Trash."**<br/>
> or **"Apple cannot check it for malicious software."**

This is an expected macOS Gatekeeper security behavior. To resolve it:

#### Method A: Terminal Command (Fastest & Cleanest)
Run the following command in Terminal to strip the quarantine attribute:
```bash
xattr -cr /Applications/filemanager.app
```
*(If the app is still in your `Downloads` folder, run: `xattr -cr ~/Downloads/filemanager.app`)*

#### Method B: macOS System Settings
1. Open **System Settings** ➔ **Privacy & Security**.
2. Scroll down to the **Security** section.
3. You will see a notice: *"filemanager.app was blocked from use because it is not from an identified developer."*
4. Click **"Open Anyway"** and enter your Mac password.

---

### 🛠️ Building from Source

```bash
git clone https://github.com/tony126051/filemanager.git
cd filemanager
xcodebuild -scheme filemanager -configuration Release -derivedDataPath ./build CODE_SIGNING_ALLOWED=NO build
codesign --force --deep --sign - build/Build/Products/Release/filemanager.app
```

---

<br/>

---

<a name="繁體中文-traditional-chinese"></a>
## 繁體中文 (Traditional Chinese)

### ✨ 專案特色

- 🪟 **Windows 11 Fluent 設計美學**：完美重現 Windows 11 的 Mica 半透明質感、圓角、Ribbon 功能列（Command Bar）與經典圖示風格。
- 📑 **分頁標籤瀏覽（Tabs）**：支援多個分頁同時瀏覽。使用快捷鍵 `Cmd+T` 新增分頁、`Cmd+W` 關閉分頁，各分頁獨立記憶瀏覽路徑與歷史。
- 🎨 **多種檢視模式切換**：
  - **詳細資料 (Details)**：提供名稱、修改日期、類型、大小等欄位排序
  - **大圖示 / 中圖示 / 小圖示** 格狀檢視
  - **清單 (List)** 檢視
  - **並排 (Tiles)** 檢視
- 🧭 **智慧導覽列與階層路徑**：麵包屑路徑點擊切換、前進／後退／上一層導覽、以及即時檔案搜尋功能。
- 🌐 **即時多語言切換**：內建多語言引擎，可於執行中即時切換 **繁體中文**、**簡體中文**、**English**、**日本語**，無需重新啟動程式。
- ⚡ **豐富的操作與快捷鍵**：
  - 完整支援常用快捷鍵（`Cmd+C` 複製、`Cmd+X` 剪下、`Cmd+V` 貼上、`Cmd+Delete` 移至垃圾桶、`Enter` 重新命名、`Cmd+R` 重新整理）。
  - 右鍵選單支援批次操作、複製檔案路徑、在 Finder 中顯示等功能。
  - 內建 Windows 11 風格「屬性對話框 (Properties)」與「於終端機打開」按鈕。
- 🔄 **內建更新機制與關於視窗**：透過工具列 `?` 按鈕或選單列「關於檔案總管」，即可一鍵透過 GitHub API 檢查最新 Release 版本並下載更新。

---

### 📥 下載與安裝說明

#### 方式一：終端機一行自動安裝（推薦，最順暢）
此方式直接透過命令列下載解壓至「應用程式」目錄，**不會被瀏覽器附加網路隔離旗標**：

```bash
curl -sL https://github.com/tony126051/filemanager/releases/download/v1.0.0/filemanager-v1.0.0-macos.zip -o /tmp/fm.zip && unzip -q -o /tmp/fm.zip -d /Applications && rm /tmp/fm.zip
```

#### 方式二：手動下載
1. 前往 [GitHub Releases](https://github.com/tony126051/filemanager/releases/latest) 下載最新版 `filemanager-v1.0.0-macos.zip`。
2. 雙擊解壓縮出 **`filemanager.app`**。
3. 將 **`filemanager.app`** 拖移至你的 **「應用程式 (Applications)」** 資料夾。

---

### 🛡️ 解決 macOS Gatekeeper 安全提示（「已損毀」或「無法打開」）

若你透過瀏覽器下載本 App，因開源軟體尚未購買每年 $99 美元的 Apple 開發者帳號進行線上公證，macOS 的 Gatekeeper 安全機制會對從網路下載的檔案打上隔離旗標，並彈出下列提示：

> ⚠️ **「『filemanager.app』已損毀，您應該將它丟到垃圾桶。」**<br/>
> 或 **「無法打開，因為 Apple 無法檢查其是否包含惡意軟體。」**

此為 macOS 對未付費公證開源軟體的預期阻擋機制，請依下列方式之一解除：

#### 方式 A：終端機一行指令解除隔離（最推薦）
打開 Mac 的「終端機 (Terminal)」，貼上以下指令並按 Enter：
```bash
xattr -cr /Applications/filemanager.app
```
*(若檔案尚未移至應用程式資料夾，仍在「下載」，請執行：`xattr -cr ~/Downloads/filemanager.app`)*

#### 方式 B：透過系統設定手動允許
1. 打開 Mac **「系統設定」 ➔「隱私權與安全性」**。
2. 滑動至下方 **「安全性」** 區域。
3. 會看見提示：*「已阻擋使用『filemanager.app』，因為它不是來自已識別的開發者。」*
4. 點擊旁邊的 **「仍要打開 (Open Anyway)」**，並輸入 Mac 解鎖密碼即可。

---

### 🛠️ 從原始碼建置

本專案使用原生 Swift 與 SwiftUI 開發：

```bash
# 複製專案
git clone https://github.com/tony126051/filemanager.git
cd filemanager

# 編譯 Release 版本
xcodebuild -scheme filemanager -configuration Release -derivedDataPath ./build CODE_SIGNING_ALLOWED=NO build

# 執行本地 Ad-hoc 代碼簽署
codesign --force --deep --sign - build/Build/Products/Release/filemanager.app
```

---

### 📄 License

Copyright © 2026 tony126051. Released under the [MIT License](LICENSE).
