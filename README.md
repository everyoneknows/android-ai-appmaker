# android-ai-appmaker

## やることは4つだけです

1. Termuxをインストールしてください。
2. 次の1行をコピペしてください。
3. ブラウザで電卓をダウンロードし、Androidのインストール画面からインストール・起動してください。
4. 電卓で `123 × 456 = 56088` を確認し、「次の開発に進む」を押してください。

### 1行セットアップ

```sh
curl -fsSL https://github.com/everyoneknows/android-ai-appmaker/raw/a41f0e9959a7cd5576474ffdba95a449d78c5159/setup.sh | bash
```

rootは不要です。setupは自動的に電卓をbuild・署名し、`http://127.0.0.1:8765/` をブラウザで開きます。APKをダウンロードし、Android Package Installerで必要な「この提供元を許可」「インストール」を利用者が確認してください。電卓の「次の開発に進む」ボタンで、完了説明のWeb UIへ戻れます。

初回電卓はCodexなしで動作します。四則演算、0〜9、小数点、AC/C、⌫、タッチ操作、portraitに対応し、ネットワーク権限・特別なpermission・外部libraryは使用しません。`123 × 456 =` は `56088` になります。ゼロ除算や不正な連打はクラッシュせずErrorまたは現在の入力を表示します。

## 第1幕の完了

今回のRCは「スマホだけでAndroidアプリを作れた」ことを確認する第一峰です。電卓からChromeへ戻ると、APKがWebアプリではなくスマホ自身でビルドされたAndroidアプリであることを説明します。

Codex CLIの導入・ログイン・AI生成はv0.3.0相当の第2幕です。Android/Termux向けの安定した導入コマンドが未確定のため、今回のWeb UIには誤ったコマンドを埋め込まず、未確定状態だけを表示します。

## 技術者向け

setup.shはbootstrap commitから取得され、内部に固定したimmutable content commitからすべてのプロジェクトファイルを取得します。初心者経路はGoogle Play版Termuxでも試験継続中です。現時点の実機確認ではJDKはopenjdk-25を使い、compile/target platformはAndroid API 34（android-34）です。必須Termux packageはcurl、unzip、zip、python、openjdk-25、coreutils、aapt、aapt2です。aapt2とzipalignはTermux native commandを使い、Google build-tools archiveのx86_64 native executableには依存しません。Google archiveからはAndroid API 34のandroid.jar、Javaで動くd8.jar、apksigner.jarを取得し、署名・検証もJDK25の明示パスで実行します。Termuxのapksigner packageは使用しません。openssh、Node.js、Codexは初心者ルートの必須依存ではありません。Web serverは127.0.0.1だけにbindし、Host/Origin、起動時CSRF token、Content-Type、POST size、prompt length、ビルド排他、subprocess timeout、APK署名検証を行います。

詳細は [docs/architecture.md](docs/architecture.md)、[docs/security.md](docs/security.md)、[docs/troubleshooting.md](docs/troubleshooting.md) を参照してください。公式の導入手順は [OpenAI Docs: Codex CLI](https://learn.chatgpt.com/docs/codex/cli) です。

## 確認状態

Linux上で、archive HTTP 200、内部path、SHA-256、Java、D8、aapt2、zip、zipalign、apksigner、APK verify、localhost health checkを確認しています。fixture bootstrap、stub toolchain、production network、real toolchain buildは別テストです。Android実機ではGoogle Play版Termuxの初回APK生成まで継続試験中です。APKインストール、アプリ起動、Android unknown-source確認、Codexログイン済みの自由生成は **UNVERIFIED** です。

## License

MIT License。詳細は [LICENSE](LICENSE) を参照してください。
