# Architecture

Termux上の通常ユーザー領域に、SSH、JDK、Android command-line tools、ソースworkspaceを置きます。`appmaker`はAI CLIを任意のアダプタ越しに呼び、結果をJavaソースとしてビルダーへ渡します。ビルダーはaapt2でmanifest、D8でdex、zipalignとapksignerでローカル署名APKを作ります。

公式Codex CLIを優先します。Termux ARM64上の実機可否は端末・配布版に依存するため、CLIが無い場合も最初のサンプルで導線を検証できます。forkは使っていません。
