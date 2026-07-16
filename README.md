# メモアプリ

レビュアー向けの起動手順です。

## 1. リポジトリをクローン

```bash
cd ~/work
git clone https://github.com/s-kuroki-being/memo-app.git
cd memo-app
```

## 2. 必要なGemをインストール

```bash
bundle install
```

## 3. アプリケーションを起動

```bash
bundle exec ruby app.rb -o 0.0.0.0
```

## 4. ブラウザでアクセス

以下のURLにアクセスしてください。

```text
http://localhost:4567/memos
```
