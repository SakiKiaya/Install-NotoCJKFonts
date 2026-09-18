# Noto CJK Windows Font Installer

這是一套給 Windows 使用者快速完成 **Noto CJK 字型安裝 + Chrome/Edge 中文字型統一 + 2K/4K 顯示設定套用** 的小型部署工具。

如果你曾遇到以下情況：

- 同一句中文裡，部分字突然變成另一種字型
- 繁體、簡體、日文混排時，字重、字面大小或筆畫風格不一致
- Chrome / Edge 在不同網站上使用 Microsoft YaHei、SimSun、Yu Gothic 等不同 fallback 字型
- 換到 32 吋 2K / 4K 螢幕後，瀏覽器預設字體大小不舒服

本專案的做法是：

```text
PowerShell 自動安裝 Noto CJK
        ↓
安裝 Advanced Font Settings v1.0.0
        ↓
依螢幕選擇 2K / 4K JSON profile
        ↓
將繁中、簡中 fallback 優先統一到 Noto CJK TC
```

目標不是改變所有網站設計，而是盡量讓 Chromium 瀏覽器的中文 fallback 保持在同一套 Noto CJK 字型家族中，降低繁簡混排時出現突兀字型差異的機率。

## 快速開始

以下流程可以在新安裝的 Windows 上，一次完成字型、瀏覽器插件與顯示設定。

### 1. 執行字型安裝腳本

- 先下載或 Clone 本專案，進入專案資料夾：

  ```powershell
  cd C:\Tools\noto_cjk_windows_installer
  ```

- 允許目前 PowerShell 工作階段執行腳本：

  ```powershell
  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
  ```

- 執行安裝：

  ```powershell
  .\Install-NotoCJKFonts.ps1
  ```

  - 預設會安裝：

    ```text
    Noto Sans CJK TC / SC / JP
    Noto Sans Mono CJK TC / SC / JP
    Noto Serif CJK TC / SC / JP
    ```

    > [!TIP]
    > Sans 安裝時會一併安裝 Mono，以便 Advanced Font Settings 的 Monospace / Fixed-width 能使用同一套 CJK 字型家族。

  - 如果要安裝給所有 Windows 使用者，請以系統管理員身分開啟 PowerShell：

    ```powershell
    .\Install-NotoCJKFonts.ps1 -InstallScope AllUsers
    ```

### 2. 安裝 Advanced Font Settings v1.0.0

本專案的 JSON profile 是依照 **Advanced Font Settings v1.0.0** 的匯入格式產生。

Chrome Web Store：

<https://chromewebstore.google.com/detail/lnclooleldbpcjljnlhiebkmecplicpa?utm_source=item-share-cb>

Chrome 可直接安裝；Edge 使用者若從 Chrome Web Store 安裝，需先允許「來自其他商店的擴充功能」。

### 3. 匯入對應的顯示設定

設定檔位於：

```text
settings/
```

- 32 吋 2K / 2560×1440：

  ```text
  settings/Advanced_Font_Settings_v1.0.0_Noto_CJK_UnifiedTC_32inch_2K.json
  ```

  建議值：

  ```text
  Default font size     = 16
  Fixed-width font size = 13
  Minimum font size     = 0
  ```

- 32 吋 4K / 3840×2160：

  ```text
  settings/Advanced_Font_Settings_v1.0.0_Noto_CJK_UnifiedTC_32inch_4K.json
  ```

  建議值：

  ```text
  Default font size     = 18
  Fixed-width font size = 15
  Minimum font size     = 10
  ```

在 Advanced Font Settings 中使用 Import 功能匯入對應 JSON，完成後建議關閉所有 Chrome / Edge 視窗再重新開啟。

> [!NOTE]
> 兩個 profile 都採用以下核心策略：
>
> ```text
> Default / Zyyy → Noto Sans CJK TC
> Hant           → Noto Sans CJK TC
> Hans           → Noto Sans CJK TC
> Jpan           → Noto Sans CJK JP
> ```
>
> 其中 `Hans` 也刻意指向 TC，是為了優先追求繁簡混排時的視覺一致性；如果更重視簡體中文的地區字形正確性，可以自行改回 SC。

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
  | --- | --- |
  | `02_NotoSansCJK-TTF-VF.zip` | Noto Sans CJK TC / SC / JP，以及 Noto Sans Mono CJK TC / SC / JP |
  | `03_NotoSerifCJK-TTF-VF.zip` | Noto Serif CJK TC / SC / JP |

---

## 預設安裝內容

| 類型 | 繁體中文 | 簡體中文 | 日文 |
| --- | --- | --- | --- |
| Sans | Noto Sans CJK TC | Noto Sans CJK SC | Noto Sans CJK JP |
| Serif | Noto Serif CJK TC | Noto Serif CJK SC | Noto Serif CJK JP |
| Mono | Noto Sans Mono CJK TC | Noto Sans Mono CJK SC | Noto Sans Mono CJK JP |

---

## 專案結構

```text
noto_cjk_windows_installer/
├── Install-NotoCJKFonts.ps1
├── settings/
│   ├── settings/Advanced_Font_Settings_v1.0.0_Noto_CJK_UnifiedTC_32inch_2K.json
│   └── settings/Advanced_Font_Settings_v1.0.0_Noto_CJK_UnifiedTC_32inch_4K.json
└── README.md
```

### `settings/` 資料夾

  `settings/` 專門保存 Advanced Font Settings v1.0.0 可直接匯入的顯示器 profile。

  目前提供：

  | Profile | 建議尺寸 / 解析度 | Default | Fixed | Minimum |
  | --- | --- | ---: | ---: | ---: |
  | `Advanced_Font_Settings_v1.0.0_Noto_CJK_UnifiedTC_32inch_2K.json` | 32 吋 / 2560×1440 | 16 | 13 | 0 |
  | `Advanced_Font_Settings_v1.0.0_Noto_CJK_UnifiedTC_32inch_4K.json` | 32 吋 / 3840×2160 | 18 | 15 | 10 |

  > [!NOTE]
  > 兩個 profile 都採用 Unified TC 策略：`Zyyy`、`Hant`、`Hans` 優先使用 Noto CJK TC，以降低繁簡混排時出現不同 fallback 字型的機率；`Jpan` 則保留 Noto CJK JP。

---

## 下載腳本參數說明

| 參數 | 說明 |
| --- | --- |
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
settings/Advanced_Font_Settings_v1.0.0_Noto_CJK_UnifiedTC_32inch_2K.json
```

建議對應如下：

| Script | Standard | Sans-serif | Serif | Fixed-width |
| --- | --- | --- | --- | --- |
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

> [!NOTE]
>
> ## 注意事項
>
> - 預設會安裝 ZIP 中符合 TC / SC / JP 的 Sans、Mono、Serif 字型。
> - 若你不想安裝 variable font，可加上 `-SkipVariableFonts`。
> - 若系統中已經安裝過 Noto Sans TC、Noto Sans CJK TC、Source Han Sans TC 等相似字型，瀏覽器字型清單可能會較混亂。
> - 安裝完成後若 Advanced Font Settings 找不到字型，請重新啟動瀏覽器，或登出再登入 Windows。

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
  3. 是否匯入 `settings/Advanced_Font_Settings_v1.0.0_Noto_CJK_UnifiedTC_32inch_2K.json`
  4. Windows 字型清單是否能搜尋到 `Noto Sans CJK`

---

---

## 選用瀏覽器插件

本專案建議搭配 **Advanced Font Settings** 使用，用來指定不同語系 script 的預設字型與字體大小。

目前建議優先使用仍有維護、且支援 JSON 匯入/匯出的版本：

```text
Advanced Font Settings v1.0.0
```

Chrome Web Store：

[https://chromewebstore.google.com/detail/lnclooleldbpcjljnlhiebkmecplicpa?utm_source=item-share-cb](https://chromewebstore.google.com/detail/lnclooleldbpcjljnlhiebkmecplicpa?utm_source=item-share-cb)

新版的設定格式與舊版不同，主要結構如下：

```json
{
  "version": 1,
  "fonts": {
    "Zyyy|standard": "Noto Sans CJK TC",
    "Hant|standard": "Noto Sans CJK TC",
    "Hans|standard": "Noto Sans CJK TC",
    "Jpan|standard": "Noto Sans CJK JP"
  },
  "sizes": {
    "default": 16,
    "fixed": 13,
    "minimum": 0
  }
}
```

<details>
  <summary>建議設定策略</summary>
  為了減少繁體、簡體混排時出現不同 fallback 字型，建議：

  ```text
  Default / Zyyy → Noto Sans CJK TC
  Hant           → Noto Sans CJK TC
  Hans           → Noto Sans CJK TC
  Jpan           → Noto Sans CJK JP
  ```

  對應 Serif 與 Monospace：

  ```text
  Traditional Chinese:
    Serif      → Noto Serif CJK TC
    Monospace  → Noto Sans Mono CJK TC

  Simplified Chinese:
    Serif      → Noto Serif CJK TC
    Monospace  → Noto Sans Mono CJK TC

  Japanese:
    Serif      → Noto Serif CJK JP
    Monospace  → Noto Sans Mono CJK JP
  ```

  > 注意：將 Hans 也指向 TC 是刻意的設定，用來優先追求繁簡混排時的視覺一致性。  
  > 如果更重視簡體中文的地區字形正確性，可以改回 `Noto Sans CJK SC / Noto Serif CJK SC / Noto Sans Mono CJK SC`。

### Cursive / Fantasy

  這兩個 generic family 一般不需要特別修改：

  ```text
  Cursive → 保留系統預設，例如 標楷體 / KaiTi
  Fantasy → 保留系統預設，例如 Impact
  ```

  ---

## 2K / 4K 字體大小客製化

  Advanced Font Settings v1.0.0 的字體大小設定位於：

  ```json
  "sizes": {
    "default": 16,
    "fixed": 13,
    "minimum": 0
  }
  ```

  三個欄位分別代表：

  | 欄位 | 說明 |
  | --- | --- |
  | `default` | 一般比例字型的預設大小 |
  | `fixed` | 等寬字型 / Monospace 的預設大小 |
  | `minimum` | 瀏覽器允許顯示的最小字體大小 |

  本專案建議依螢幕解析度使用不同 profile。

### 32" 2K 建議值

  適合 2560×1440、32 吋螢幕：

  ```json
  "sizes": {
    "default": 16,
    "fixed": 13,
    "minimum": 0
  }
  ```

  建議搭配：

  ```text
  Windows 縮放：100%～125%
  Chrome / Edge 頁面縮放：100%
  ```

  對應設定檔：

  ```text
  settings/Advanced_Font_Settings_v1.0.0_Noto_CJK_UnifiedTC_32inch_2K.json
  ```

### 32" 4K 建議值

  適合 3840×2160、32 吋螢幕：

  ```json
  "sizes": {
    "default": 18,
    "fixed": 15,
    "minimum": 10
  }
  ```

  建議搭配：

  ```text
  Windows 縮放：125%～150%
  Chrome / Edge 頁面縮放：100%
  ```

  對應設定檔：

  ```text
  settings/Advanced_Font_Settings_v1.0.0_Noto_CJK_UnifiedTC_32inch_4K.json
  ```

### 為什麼 4K 不直接把字體加倍？

  Advanced Font Settings 的字體大小是 CSS pixel 邏輯，Windows DPI scaling 已經會先放大整體 UI。

  因此 32" 4K 不需要把：

  ```text
  16px → 32px
  ```

  而是通常只需要調整成：

  ```text
  16px → 18px
  13px → 15px
  ```

  就能獲得比較舒服的閱讀大小。

### Minimum font size 建議

  2K profile 預設：

  ```text
  minimum = 0
  ```

  可以最大程度避免破壞網站排版。

  4K profile 建議：

  ```text
  minimum = 10
  ```

  可以避免部分網站把註解、標籤、時間資訊顯示得過小。

  不建議把 minimum 設得太高，例如 12～14px，因為可能造成：

  ```text
  表格高度改變
  按鈕跑版
  側邊欄變寬
  網站原本的小字資訊被放大
  ```

</details>
---

## 授權

本專案腳本可依你的需求自行修改與使用。

Noto CJK 字型本身請依照官方字型授權條款使用。
