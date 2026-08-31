# android-ai-appmaker

## Androidだけでアプリを作る

1. AndroidへTermuxを入れる
2. 下の1行をTermuxへ貼り付ける
3. ブラウザで仕様を入力して「アプリを作る」を押す

最初の例文は「ストップウォッチ機能付きの時計」です。

> 公開版は確認済みコミットを固定参照します。

### 1. Termuxで貼る1行

```sh
curl -fsSL https://raw.githubusercontent.com/everyoneknows/android-ai-appmaker/v0.1.0/setup.sh | bash
```

setupはroot、sudo、Androidシステム領域、bootloaderを使わず、Termuxのホーム以下だけを変更します。完了すると `http://127.0.0.1:8765/` を開きます。LANには公開しません。

### Web UIで作成

ブラウザの入力欄は自由入力、貼り付け、例文ボタン、Gboard音声入力に対応します。生成・ビルド・署名が終わるとAPKをAndroidのインストール画面へ渡します。

## このプロトタイプの範囲

- Android Studio・Gradle・root・USBケーブル不要
- Java compiler、aapt2、D8、zipalign、apksignerをTermux内へ取得して使う
- `bin/appmaker`は公式Codex CLIが利用可能・認証済みの場合だけAI生成を行う。利用不能時に自由入力を別アプリとして生成することはない
- AI CLIは `APPMAKER_AI=codex` / `APPMAKER_AI=none` で差し替え可能
- サンプルは通信権限なし、黒背景・白文字、通常のランチャーから起動可能

公式Codex CLIは公式standalone installer、次に公式npmパッケージ `@openai/codex` の順で試します。Termux/Androidでの動作は実機確認が必要です。利用する場合はTermuxで `codex login`、状態確認は `codex login status` を使います。第三者forkは使用しません。

## 技術者向け

```text
setup.sh -> scripts/termux-install.sh -> bin/appmaker
                                      -> builder/build-apk.sh
                                      -> examples/stopwatch-clock
```

ビルダーはAndroid SDKの固定版を前提にせず、Termuxパッケージまたは公式Google Maven配布物から必要なツールを解決します。署名鍵はTermuxホームの `~/.android-ai-appmaker/release.keystore` に初回生成し、外部へ送信しません。APKはデバッグ目的のローカル署名です。

詳細は [docs/architecture.md](docs/architecture.md)、[docs/security.md](docs/security.md)、[docs/troubleshooting.md](docs/troubleshooting.md) を参照してください。

## 動作確認の状態

Linux上でシェル構文、固定URLからの取得経路、127.0.0.1 Web UIを確認済みです。Android実機でのAPKビルド・インストールは未確認です。

Android 10 / ARM64のTermuxでは、公式standalone installer（`curl -fsSL https://chatgpt.com/codex/install.sh | sh`）でCodex CLI 0.151.0の導入と `codex login status` の実行を確認しました（未ログイン状態）。公式npm packageは、同端末のTermuxリポジトリミラーが利用できずNode.js/npmを導入できなかったため未確認です。第三者forkは使用していません。

## 上級者向け補助機能

PCから接続したい場合だけ、上級者向け追加手順として `connect.ps1` とTermux SSHを利用できます。初心者向けsetupではopensshを導入しません。

## Contributing

バグ報告、対応端末の情報、改善Pull Requestを歓迎します。PR前の過度な手続きは求めません。AIで生成した修正も歓迎しますが、提出者自身で内容を確認し、動作確認した範囲をPR本文に記載してください。セキュリティ上の問題は、公開Issueに機密情報を書かず、非公開の連絡手段で報告してください。詳しくは [CONTRIBUTING.md](CONTRIBUTING.md) を参照してください。

## License

MIT Licenseで公開しています。利用、改変、再配布が可能です。無保証で提供しています。詳細は [LICENSE](LICENSE) を参照してください。
