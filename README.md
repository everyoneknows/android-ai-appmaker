# android-ai-appmaker

## Androidだけでアプリを作る

1. AndroidへTermuxを入れる
2. 下の1行をTermuxへ貼り付ける
3. ブラウザで仕様を入力して「アプリを作る」を押す

最初の例文は「ストップウォッチ機能付きの時計」です。

> 公開版は確認済みコミットを固定参照します。

### 1. Termuxで貼る1行

```sh
curl -fsSL https://raw.githubusercontent.com/everyoneknows/android-ai-appmaker/20bac962e390e71c42ca4a7b32c43ef2e654267c/setup.sh | bash
```

setupはroot、sudo、Androidシステム領域、bootloaderを使わず、Termuxのホーム以下だけを変更します。完了すると `http://127.0.0.1:8765/` を開きます。LANには公開しません。

### Web UIで作成

ブラウザの入力欄は自由入力、貼り付け、例文ボタン、Gboard音声入力に対応します。生成・ビルド・署名が終わるとAPKをAndroidのインストール画面へ渡します。

## このプロトタイプの範囲

- Android Studio・Gradle・root・USBケーブル不要
- Java compiler、aapt2、D8、zipalign、apksignerをTermux内へ取得して使う
- `bin/appmaker`は公式Codex CLIがあればAI入口として使い、無ければ安全なサンプルテンプレートを生成
- AI CLIは `APPMAKER_AI=codex` / `APPMAKER_AI=none` で差し替え可能
- サンプルは通信権限なし、黒背景・白文字、通常のランチャーから起動可能

公式Codex CLIは公式npmパッケージ `@openai/codex` の導入だけを試します。公式の対応表にTermux/Androidは含まれないため、導入に失敗しても第三者forkへ切り替えず、テンプレートモードで動作します。利用する場合はTermuxで `codex --login` を一度実行してください。

## 技術者向け

```text
setup.sh -> scripts/termux-install.sh -> bin/appmaker
                                      -> builder/build-apk.sh
                                      -> examples/stopwatch-clock
```

ビルダーはAndroid SDKの固定版を前提にせず、Termuxパッケージまたは公式Google Maven配布物から必要なツールを解決します。署名鍵はTermuxホームの `~/.android-ai-appmaker/release.keystore` に初回生成し、外部へ送信しません。APKはデバッグ目的のローカル署名です。

詳細は [docs/architecture.md](docs/architecture.md)、[docs/security.md](docs/security.md)、[docs/troubleshooting.md](docs/troubleshooting.md) を参照してください。

## 動作確認の状態

Linux上でシェル構文、固定URLからの取得経路、127.0.0.1 Web UIを確認済みです。Android実機でのTermux、公式Codex CLI、APKインストールは未確認です。

## 上級者向け補助機能

PCから接続したい場合だけ `connect.ps1` とTermux SSHを利用できます。初心者向けの通常手順では使用しません。

## Contributing

バグ報告、対応端末の情報、改善Pull Requestを歓迎します。PR前の過度な手続きは求めません。AIで生成した修正も歓迎しますが、提出者自身で内容を確認し、動作確認した範囲をPR本文に記載してください。セキュリティ上の問題は、公開Issueに機密情報を書かず、非公開の連絡手段で報告してください。詳しくは [CONTRIBUTING.md](CONTRIBUTING.md) を参照してください。

## License

MIT Licenseで公開しています。利用、改変、再配布が可能です。無保証で提供しています。詳細は [LICENSE](LICENSE) を参照してください。
