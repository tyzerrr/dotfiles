# OmniWM 設定・操作メモ

このディレクトリは、AeroSpaceからOmniWMへ移行するための設定です。
実際の設定ファイルは [`settings.toml`](./settings.toml) です。レイアウトはAeroSpaceの`tiles`に近い`Dwindle`を使っています。

## キー表記

macOSのキー名で書いています。

- `Option` = `⌥` / `Alt`
- `Control` = `⌃` / `Ctrl`
- `Command` = `⌘` / `Cmd`
- `Shift` = `⇧`

## まず覚える操作

| 操作 | ショートカット | 内容 |
| --- | --- | --- |
| 左右上下へフォーカス | `⌥ H/J/K/L` | 左/下/上/右のWindowへ移動 |
| Windowを移動 | `⌥ ⇧ H/J/K/L` | 隣の方向へ移動。Dwindleでは結合/分離になる場合がある |
| 左右を入れ替える | `⌃ ⌥ ⇧ H/L` | Dwindleのタイル/コンテナ全体を左/右と交換 |
| フルスクリーン | `⌥ ⇧ F` | OmniWMのフルスクリーンを切り替え |
| サイズを小さく/大きく | `⌥ -` / `⌥ =` | フォーカス中のWindowをリサイズ |
| 指定方向へ拡大 | `⌃⌥ H/J/K/L` | 左/下/上/右方向へWindowを拡大。縮小は`⌥ -` |
| 前回のWorkspaceへ戻る | `⌥ Tab` | Workspaceをback-and-forth |

### 二つのWindowの左右を交換する

同じWorkspaceにWindowを二つ置いた状態で、フォーカス中のWindowから次を押します。

```text
⌃ ⌥ ⇧ H   左のタイル/コンテナと交換
⌃ ⌥ ⇧ L   右のタイル/コンテナと交換
```

現在の設定ではVimキーを割り当てています。OmniWM標準の矢印キーも使えます。

```text
⌃ ⌥ ⇧ ←   左と交換
⌃ ⌥ ⇧ →   右と交換
```

これはWindowの「結合/分離」ではなく、Dwindleのタイルまたはコンテナ全体を交換する操作です。入れ替わらないときは、まず`⌥ H`または`⌥ L`で対象Windowにフォーカスしてから実行します。

## Workspace操作

Workspace 1〜7はメインディスプレイ、8〜9はセカンダリディスプレイに割り当てています。

| 操作 | ショートカット |
| --- | --- |
| Workspace 1〜9へ移動 | `⌥ 1`〜`⌥ 9` |
| フォーカス中のWindowをWorkspace 1〜9へ移動 | `⌥ ⇧ 1`〜`⌥ ⇧ 9` |
| 前回のWorkspaceへ戻る | `⌥ Tab` |
| Workspaceを右のモニターへ移動 | `⌥ ⇧ Tab` |

セカンダリディスプレイが左側にある場合、`settings.toml`の`moveWorkspaceToMonitor.right`を`left`に変更してください。

## モニター操作

以下はOmniWMの標準ショートカットです。

| 操作 | ショートカット |
| --- | --- |
| 次のモニターへフォーカス | `⌃ ⌘ Tab` |
| 最後に使ったモニターへフォーカス | `⌃ ⌘ \`` |

モニターの配置や`main`/`secondary`の対応は、OmniWM Settings → Monitors → **Run Monitor Setup…**から確認できます。

## 水色のフォーカス枠

フォーカス中のWindowに、Hyprland風の水色の枠を表示しています。

```toml
[borders]
enabled = true
width = 3.0
```

色は`#89DCEB`です。枠の太さや色を変える場合は、`settings.toml`の`[borders]`と`[borders.color]`を編集します。色の値はRGBAそれぞれ`0.0`〜`1.0`で指定します。

Workspace切替後やマウスResize後に枠がクリック待ちになるOmniWM 0.6.0のタイミング問題を避けるため、nix-darwinのユーザー用launchd agentが`refresh-border.sh`を補助Watcherとして常駐させています。Workspace変更後は現在のWindowを再フォーカスし、Resize後はフォーカス中Windowのframeが安定してから一度だけ再フォーカスして枠を再配置します。マウスカーソルを動かしたり、フォーカス追従を有効にしたりはしません。設定反映後は`make switch`を実行してください。

## 困ったときの確認

OmniWMが動作しているか確認します。

```sh
omniwmctl ping
omniwmctl version
```

WindowとWorkspaceの状態を確認します。

```sh
omniwmctl query windows
omniwmctl query workspaces
omniwmctl query displays
```

左右交換をキーボードから直接実行することもできます。

```sh
omniwmctl command move-column left
omniwmctl command move-column right
```

`omniwmctl query windows`にWindowが表示されない場合は、System Settings → Privacy & Security → AccessibilityでOmniWMを許可してください。

## 初回セットアップ

1. System Settings → Desktop & Dock → Mission Controlで**Displays have separate Spaces**を有効にする。
2. OmniWM.appを起動し、Accessibilityを許可する。
3. OmniWM Settings → Monitors → **Run Monitor Setup…**でモニター配置を確認する。
4. `omniwmctl`が見つからなければ、OmniWMのメニューバーから**Install CLI to PATH**を実行する。
5. dotfilesを反映する。

```sh
make switch
```

AeroSpaceとOmniWMは同時に起動しないでください。元に戻す場合に備えて、AeroSpaceの設定は[`../aerospace/aerospace.toml`](../aerospace/aerospace.toml)に残しています。

## 公式ドキュメント

- [OmniWM README](https://github.com/BarutSRB/OmniWM)
- [OmniWM IPC/CLI](https://github.com/BarutSRB/OmniWM/blob/main/docs/IPC-CLI.md)
