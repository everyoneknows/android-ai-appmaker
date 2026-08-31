# Security

setupはroot/sudoを要求せず、`$HOME`以下だけを変更します。初心者向けsetupはopensshを導入しません。SSHを使う上級者は別途opensshを導入し、Termux側で明示的に `sshd -p 8022` を起動してください。

Web UIは127.0.0.1にだけbindします。`/build`はHost、Origin、起動時生成のCSRF token、`application/json`、同時実行ロックを検査し、画面側もビルド中の二重送信を無効化します。

APIキー・パスワード・トークンをログへ出さず、リポジトリへ保存しません。署名鍵は端末内にのみ置きます。curl|bashは公開tag/commitを固定し、実行前にsetup.shを確認してください。
