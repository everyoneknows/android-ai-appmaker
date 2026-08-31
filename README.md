# android-ai-appmaker

## やることは4つだけです

1. Termuxをインストールしてください。
2. 次の1行をコピペしてください。
3. 電卓をインストールしてください。APKもスマホ内へ保存されます。
4. あなたの番です。欲しいアプリを入力してください。

### 1行セットアップ

```sh
curl -fsSL https://github.com/everyoneknows/android-ai-appmaker/raw/7dd85d635984b66f031fa1d032b7e93917175040/setup.sh | bash
```

rootは不要です。setupは自動的に電卓をbuild・署名し、保存場所を表示してから `http://127.0.0.1:8765/` を開きます。Androidのインストール画面で必要な「この提供元を許可」「インストール」は利用者が確認してください。アプリがホーム画面へ自動追加されるとは限りません。通常のアプリ一覧から「電卓」を起動できます。

初回電卓はCodexなしで動作します。四則演算、0〜9、小数点、AC/C、⌫、タッチ操作、portraitに対応し、ネットワーク権限・特別なpermission・外部libraryは使用しません。`123 × 456 =` は `56088` になります。ゼロ除算や不正な連打はクラッシュせずErrorまたは現在の入力を表示します。

## あなたの番です

電卓生成後の画面で「どんなアプリを作りますか？」に自由入力、貼り付け、Gboard音声入力ができます。「税込10%ボタンを付ける」「計算履歴を付ける」「買い物メモ」などの例もあります。AI自由生成にはOpenAI公式Codexの導入とログインが必要です。未導入・未ログイン時は成功を偽装せず、明確に案内します。第三者forkは使用しません。

AI生成アプリは試作版です。生成後に実際に操作して確認してください。動かない・希望と違う場合の自動修正機能は今後追加予定です。

## 技術者向け

setup.shはbootstrap commitから取得され、内部に固定したimmutable content commitからすべてのプロジェクトファイルを取得します。初心者経路はGoogle Play版Termuxでも試験継続中です。現時点の実機確認ではJDKはopenjdk-25を使います。必須Termux packageはcurl、unzip、zip、python、openjdk-25、coreutils、aapt、aapt2、apksigner、zipalignです。aapt2、zipalign、apksignerはTermux packageを使い、Google build-tools archiveのx86_64 native executableには依存しません。Google archiveからはandroid.jarとJavaで動くd8.jarだけを取得します。openssh、Node.js、Codexは初心者ルートの必須依存ではありません。Web serverは127.0.0.1だけにbindし、Host/Origin、起動時CSRF token、Content-Type、POST size、prompt length、ビルド排他、subprocess timeout、APK署名検証を行います。

詳細は [docs/architecture.md](docs/architecture.md)、[docs/security.md](docs/security.md)、[docs/troubleshooting.md](docs/troubleshooting.md) を参照してください。

## 確認状態

Linux上で、archive HTTP 200、内部path、SHA-256、Java、D8、aapt2、zip、zipalign、apksigner、APK verify、localhost health checkを確認しています。fixture bootstrap、stub toolchain、production network、real toolchain buildは別テストです。Android実機ではGoogle Play版Termuxの初回APK生成まで継続試験中です。APKインストール、アプリ起動、Android unknown-source確認、Codexログイン済みの自由生成は **UNVERIFIED** です。

## License

MIT License。詳細は [LICENSE](LICENSE) を参照してください。
