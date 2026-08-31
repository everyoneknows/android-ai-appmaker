# Security

setupはroot/sudoを要求せず、`$HOME`以下だけを変更します。初心者向けsetupはopensshを導入しません。SSHを使う上級者は別途opensshを導入し、Termux側で明示的に `sshd -p 8022` を起動してください。

Web UIは127.0.0.1にだけbindします。`/build`はHost、Origin、起動時生成のCSRF token、`application/json`、POSTサイズ、prompt長、同時実行ロックを検査し、画面側もビルド中の二重送信を無効化します。ビルド subprocess にはtimeoutを設定し、署名検証済みAPKをatomicに公開します。setupはPIDの実体を確認して旧serverを停止し、`/health` readiness後にだけURLを開きます。

APIキー・パスワード・トークンをログへ出さず、リポジトリへ保存しません。署名鍵は端末内にのみ置きます。curl|bashはGitHubのimmutable bootstrap commitからsetupを取得し、setup内部でimmutable content commitを固定します。Google archiveはSHA-256と内部pathを検証します。実行前にsetup.shを確認してください。
