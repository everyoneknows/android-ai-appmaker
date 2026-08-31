# Troubleshooting

- SSHが見つからない: Termuxで `sshd -p 8022` を実行し、PCと同じWi-Fiに接続する。
- 探索範囲が違う: PowerShellで `$env:APPMAKER_TERMUX_USER` を設定し、`connect.ps1`をローカル保存してCIDR探索部を自宅LANに合わせる。
- APKビルド失敗: `ANDROID_SDK_ROOT`、`ANDROID_PLATFORM`、`ANDROID_BUILD_TOOLS`を確認する。
- Codex認証: OpenAIログインは人間が行う。認証情報を画面共有・ログ保存しない。
