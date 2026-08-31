# android-ai-appmaker

## やることは3つだけです

1. Termuxを入れる
2. スマホとPCへ、それぞれ1行コピペ
3. AIに欲しいアプリを日本語で頼む

最初の例として、時計＋ストップウォッチを作ってみます。

> 開発中のため、下記URLの `YOUR_GITHUB_USER` と `COMMIT_OR_TAG` は公開後に置き換えます。公開版では必ず確認済みtagまたはcommitを指定してください。

### 1. Termuxで貼る1行

```sh
curl -fsSL https://raw.githubusercontent.com/YOUR_GITHUB_USER/android-ai-appmaker/COMMIT_OR_TAG/setup.sh | bash
```

setupはroot、sudo、Androidシステム領域、bootloaderを使わず、Termuxのホーム以下だけを変更します。SSHパスワードはTermuxが尋ねる場合だけ入力してください。OpenAIのログインやAPIキーは表示・保存・コミットしません。

### 2. PCのPowerShellで貼る1行

```powershell
irm https://raw.githubusercontent.com/YOUR_GITHUB_USER/android-ai-appmaker/COMMIT_OR_TAG/connect.ps1 | iex
```

同一Wi-Fiのプライベートネットワーク上で、Termux SSHの8022番ポートを探索して接続し、`appmaker`を起動します。Windows DefenderやWi-Fi分離設定によって探索できない場合は、表示された候補から選択できます。IPやポートを通常は手入力しません。

### 3. 日本語で依頼

接続後、例えば次のように入力します。

```text
ストップウォッチ機能付きの時計を作って
```

生成されたAPKは `~/android-ai-appmaker/out/` にあります。Androidの「不明なアプリのインストールを許可」は必要に応じて一度だけ設定し、APKをタップしてインストールします。

## このプロトタイプの範囲

- Android Studio・Gradle・root・USBケーブル不要
- Java compiler、aapt2、D8、zipalign、apksignerをTermux内へ取得して使う
- `bin/appmaker`は公式Codex CLIがあればAI入口として使い、無ければ安全なサンプルテンプレートを生成
- AI CLIは `APPMAKER_AI=codex` / `APPMAKER_AI=none` で差し替え可能
- サンプルは通信権限なし、黒背景・白文字、通常のランチャーから起動可能

公式Codex CLIのTermux ARM64での実機動作は、このリポジトリの端末外検証だけでは保証していません。setupは公式コマンドを第一候補にしますが、失敗時はCLI無しのテンプレートモードでビルドできます。第三者forkは採用していません。

## 技術者向け

```text
setup.sh -> scripts/termux-install.sh -> bin/appmaker
                                      -> builder/build-apk.sh
                                      -> examples/stopwatch-clock
```

ビルダーはAndroid SDKの固定版を前提にせず、Termuxパッケージまたは公式Google Maven配布物から必要なツールを解決します。署名鍵はTermuxホームの `~/.android-ai-appmaker/release.keystore` に初回生成し、外部へ送信しません。APKはデバッグ目的のローカル署名です。

詳細は [docs/architecture.md](docs/architecture.md)、[docs/security.md](docs/security.md)、[docs/troubleshooting.md](docs/troubleshooting.md) を参照してください。

## 動作確認の状態

この開発環境ではLinux上でサンプルAPKの生成を確認します。TermuxからAndroidへの実機一連（SSH、AI CLI、日本語依頼、インストール、起動）は、対象端末が接続されていないため未確認です。実機確認済みと表示するには、実際に全経路を通す必要があります。
