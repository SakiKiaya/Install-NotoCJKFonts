# Noto CJK Windows Font Installer

一套給 Windows 新系統使用的 Noto CJK 字型快速安裝腳本，目標是改善 Chrome、Edge 等 Chromium 瀏覽器在繁體中文、簡體中文、日文混排時，因字型 fallback 不一致造成的字重、字形、風格不統一問題。

本專案提供：

- `Install-NotoCJKFonts.ps1`：自動下載並安裝 Noto CJK 字型
- `Advanced_Font_Settings_Noto_CJK_TC_SC_JP.json`：Advanced Font Settings 匯入設定
- 預設安裝 TC、SC、JP
- 安裝 Sans 時會同時安裝 Mono

---

## 下載來源

腳本改用 Noto CJK 官方 GitHub Releases 的完整發布檔案：

```text
https://github.com/notofonts/noto-cjk/releases
```

預設下載：

```text
https://github.com/notofonts/noto-cjk/releases/download/Sans2.004/02_NotoSansCJK-TTF-VF.zip
https://github.com/notofonts/noto-cjk/releases/download/Serif2.003/03_NotoSerifCJK-TTF-VF.zip
```

| 發布檔案 | 安裝內容 |
|---|---|
| `02_NotoSansCJK-TTF-VF.zip` | Noto Sans CJK TC / SC / JP，以及 Noto Sans Mono CJK TC / SC / JP |
| `03_NotoSerifCJK-TTF-VF.zip` | Noto Serif CJK TC / SC / JP |

---

## 預設安裝內容

| 類型 | 繁體中文 | 簡體中文 | 日文 |
|---|---|---|---|
| Sans | Noto Sans CJK TC | Noto Sans CJK SC | Noto Sans CJK JP |
| Serif | Noto Serif CJK TC | Noto Serif CJK SC | Noto Serif CJK JP |
| Mono | Noto Sans Mono CJK TC | Noto Sans Mono CJK SC | Noto Sans Mono CJK JP |

---

## 專案結構

```text
noto_cjk_windows_installer_v2/
├── Install-NotoCJKFonts.ps1
├── Advanced_Font_Settings_Noto_CJK_TC_SC_JP.json
└── README.md
```

---

## 快速開始

進入資料夾：

```powershell
cd C:\Tools\noto_cjk_windows_installer_v2
```

允許本次 PowerShell 執行腳本：

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

安裝到目前使用者：

```powershell
.\Install-NotoCJKFonts.ps1
```

安裝給所有使用者，需要系統管理員 PowerShell：

```powershell
.\Install-NotoCJKFonts.ps1 -InstallScope AllUsers
```

---

## 參數說明

| 參數 | 說明 |
|---|---|
| `-InstallScope CurrentUser` | 安裝到目前使用者，不需要系統管理員權限 |
| `-InstallScope AllUsers` | 安裝到全系統，需要系統管理員權限 |
| `-SkipSerif` | 不安裝 Serif，只安裝 Sans / Mono |
| `-SkipMono` | 不安裝 Mono，只安裝 Sans |
| `-SkipVariableFonts` | 跳過檔名或路徑包含 `VF` / `Variable` 的字型 |
| `-KeepDownloads` | 保留下載與解壓縮暫存檔 |
| `-WorkDir <path>` | 指定暫存目錄 |

範例：

```powershell
.\Install-NotoCJKFonts.ps1 -SkipSerif
```

```powershell
.\Install-NotoCJKFonts.ps1 -InstallScope AllUsers -KeepDownloads
```

---

## Advanced Font Settings 匯入設定

本專案提供：

```text
Advanced_Font_Settings_Noto_CJK_TC_SC_JP.json
```

建議對應如下：

| Script | Standard | Sans-serif | Serif | Fixed-width |
|---|---|---|---|---|
| Default / Zyyy | Noto Sans CJK TC | Noto Sans CJK TC | Noto Serif CJK TC | Noto Sans Mono CJK TC |
| Traditional Han / Hani | Noto Sans CJK TC | Noto Sans CJK TC | Noto Serif CJK TC | Noto Sans Mono CJK TC |
| Simplified Han / Hans | Noto Sans CJK SC | Noto Sans CJK SC | Noto Serif CJK SC | Noto Sans Mono CJK SC |
| Japanese / Jpan | Noto Sans CJK JP | Noto Sans CJK JP | Noto Serif CJK JP | Noto Sans Mono CJK JP |

匯入後建議重新啟動 Chrome / Edge。

---

## 為什麼 Sans 要連 Mono 一起安裝？

Advanced Font Settings 除了 `standard`、`sansserif`、`serif`，也會設定 `fixed` 字型。

若沒有安裝 Mono，程式碼區塊、表格、等寬文字可能 fallback 到：

```text
Consolas
Courier New
Microsoft JhengHei
```

這會讓同一頁中的中文顯示風格不一致。因為 `02_NotoSansCJK-TTF-VF.zip` 內含 Sans 與 Mono，本腳本預設會一起安裝 Mono。

---

## 為什麼改成下載 Releases 的完整發布檔？

逐一下載 TC / SC / JP 的語系包比較容易遇到：

- 發布資產名稱變動
- Mono 需要另外處理
- 字型來源不完整
- 下載清單較長

改用官方 Releases 的完整 ZIP 後，腳本只需要下載 Sans 與 Serif 兩個主要壓縮檔，再從裡面篩選 TC / SC / JP。

---

## 注意事項

- 預設會安裝 ZIP 中符合 TC / SC / JP 的 Sans、Mono、Serif 字型。
- 若你不想安裝 variable font，可加上 `-SkipVariableFonts`。
- 若系統中已經安裝過 Noto Sans TC、Noto Sans CJK TC、Source Han Sans TC 等相似字型，瀏覽器字型清單可能會較混亂。
- 安裝完成後若 Advanced Font Settings 找不到字型，請重新啟動瀏覽器，或登出再登入 Windows。

---

## 疑難排解

### PowerShell 無法執行腳本

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

### 下載失敗

請確認：

1. 可以連線到 GitHub
2. 沒有被公司 Proxy / 防火牆阻擋
3. PowerShell 可使用 TLS 1.2 以上連線
4. 暫存目錄有足夠空間

### 字型沒有出現在 Advanced Font Settings

請確認：

1. 字型是否安裝完成
2. 是否重新啟動 Chrome / Edge
3. 是否匯入 `Advanced_Font_Settings_Noto_CJK_TC_SC_JP.json`
4. Windows 字型清單是否能搜尋到 `Noto Sans CJK`

---

## 授權

本專案腳本可依你的需求自行修改與使用。

Noto CJK 字型本身請依照官方字型授權條款使用。
