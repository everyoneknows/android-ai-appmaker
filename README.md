# android-ai-appmaker

## やることは4つだけです

1. Termuxをインストールしてください。
2. 次の1行をコピペしてください。
3. ブラウザで電卓をダウンロードし、Androidのインストール画面からインストール・起動してください。
4. 電卓で `123 × 456 = 56088` を確認したら、次のアプリを入力してください。

### 1行セットアップ

```sh
curl -fsSL https://github.com/everyoneknows/android-ai-appmaker/raw/RELEASE_BOOTSTRAP_SHA/setup.sh | bash
```

rootは不要です。setupは自動的に電卓をbuild・署名し、`http://127.0.0.1:8765/` をブラウザで開きます。「電卓をインストール」からAPKをHTTPダウンロードし、Android Package Installerで必要な「この提供元を許可」「インストール」を利用者が確認してください。インストール後に電卓を起動し、画面の「インストールできました → 次へ」から次のアプリへ進みます。

初回電卓はCodexなしで動作します。四則演算、0〜9、小数点、AC/C、⌫、タッチ操作、portraitに対応し、ネットワーク権限・特別なpermission・外部libraryは使用しません。`123 × 456 =` は `56088` になります。ゼロ除算や不正な連打はクラッシュせずErrorまたは現在の入力を表示します。

## あなたの番です

電卓生成後の画面で「どんなアプリを作りますか？」に自由入力、貼り付け、Gboard音声入力ができます。「税込10%ボタンを付ける」「計算履歴を付ける」「買い物メモ」などの例もあります。AI自由生成にはOpenAI公式Codexの導入とログインが必要です。未導入・未ログイン時は成功を偽装せず、明確に案内します。第三者forkは使用しません。

AI生成アプリは試作版です。生成後に実際に操作して確認してください。動かない・希望と違う場合の自動修正機能は今後追加予定です。

AI生成画面で「Codexは準備できています。OpenAIへのログインだけ必要です」と表示された場合は、Termuxに戻って `codex login` を実行し、ログイン後に画面の「状態を再確認」を押してください。Codex CLIが見つからない場合は、画面のコピー buttonsから、OpenAI Docsに記載された公式導入コマンド `curl -fsSL https://chatgpt.com/codex/install.sh | sh` をTermuxで実行してください。導入後に `codex` を起動してChatGPTへログインします。OpenAI DocsはTermux/Androidを対応環境として明記していないため、導入できない場合に第三者forkや非公式代替を使わず、AI生成を利用できない状態として扱います。

## 技術者向け

setup.shはbootstrap commitから取得され、内部に固定したimmutable content commitからすべてのプロジェクトファイルを取得します。初心者経路はGoogle Play版Termuxでも試験継続中です。現時点の実機確認ではJDKはopenjdk-25を使い、compile/target platformはAndroid API 34（android-34）です。必須Termux packageはcurl、unzip、zip、python、openjdk-25、coreutils、aapt、aapt2です。aapt2とzipalignはTermux native commandを使い、Google build-tools archiveのx86_64 native executableには依存しません。Google archiveからはAndroid API 34のandroid.jar、Javaで動くd8.jar、apksigner.jarを取得し、署名・検証もJDK25の明示パスで実行します。Termuxのapksigner packageは使用しません。openssh、Node.js、Codexは初心者ルートの必須依存ではありません。Web serverは127.0.0.1だけにbindし、Host/Origin、起動時CSRF token、Content-Type、POST size、prompt length、ビルド排他、subprocess timeout、APK署名検証を行います。

詳細は [docs/architecture.md](docs/architecture.md)、[docs/security.md](docs/security.md)、[docs/troubleshooting.md](docs/troubleshooting.md) を参照してください。公式の導入手順は [OpenAI Docs: Codex CLI](https://learn.chatgpt.com/docs/codex/cli) です。

## 確認状態

Linux上で、archive HTTP 200、内部path、SHA-256、Java、D8、aapt2、zip、zipalign、apksigner、APK verify、localhost health checkを確認しています。fixture bootstrap、stub toolchain、production network、real toolchain buildは別テストです。Android実機ではGoogle Play版Termuxの初回APK生成まで継続試験中です。APKインストール、アプリ起動、Android unknown-source確認、Codexログイン済みの自由生成は **UNVERIFIED** です。

## License

MIT License。詳細は [LICENSE](LICENSE) を参照してください。
