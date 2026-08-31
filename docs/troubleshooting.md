# Troubleshooting

- SSHが見つからない: Termuxで `sshd -p 8022` を実行し、PCと同じWi-Fiに接続する。
- 探索範囲が違う: PowerShellで `$env:APPMAKER_TERMUX_USER` を設定し、`connect.ps1`をローカル保存してCIDR探索部を自宅LANに合わせる。
- APKビルド失敗: `ANDROID_SDK_ROOT`、`ANDROID_PLATFORM`、`ANDROID_BUILD_TOOLS`を確認する。未指定時のcompile/target platformはAndroid API 34（`android-34`）。
- Codex未導入: Web UIの案内にあるOpenAI公式コマンド `curl -fsSL https://chatgpt.com/codex/install.sh | sh` をTermuxで実行し、その後 `codex` を起動する。公式DocsはTermux/Androidを対応環境として明記していないため、導入エラー時に第三者forkや非公式代替を使わない。
- Codex認証: Web UIの案内に従い、Termuxで `codex login` を実行してから「状態を再確認」を押す。認証情報を画面共有・ログ保存しない。
