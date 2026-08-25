# task-loop
家族をタスケル、Task-L

iOS 先行の家事共有アプリです。間隔は「最終実行日 + N日」で数えます。

## 起動までの手順（iMac）

1. [Flutter](https://docs.flutter.dev/get-started/install/macos) と Xcode を入れる
2. [Firebase](https://console.firebase.google.com/) でプロジェクトを作る
3. Authentication → Sign-in method → **Apple** を有効化
4. Firestore を作成し、このリポジトリのルールをデプロイする

```bash
firebase deploy --only firestore:rules
```

5. Apple Developer で App ID `jp.taskl.taskLoop` に Sign in with Apple を付ける
6. このフォルダで Firebase 設定を生成する

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=<FirebaseのプロジェクトID> --platforms=ios,android --ios-bundle-id=jp.taskl.taskLoop
```

7. Xcode で `ios/Runner.xcworkspace` を開き、Signing にチームを設定する
8. iPhone またはシミュレータで実行する

```bash
flutter pub get
flutter test
flutter run
```

Firebase 未設定でもアプリは起動し、セットアップ案内画面になります。

## ※Security

- 環境変数は `.env` で管理
- 機密情報はリポジトリに含めない
- `lib/firebase_options.dart` は gitignore 対象。初回は `lib/firebase_options.example.dart` をコピーし、その後 `flutterfire configure` で上書きする

## フォルダ

```
lib/
  main.dart                 起動
  app.dart                  MaterialApp
  models/                   Firestore の形
  repositories/             Appleログイン / 世帯 / タスク
  screens/                  画面
  utils/jst_date.dart       日本時間の日付
  utils/remaining_days.dart 残り日数
firebase/firestore.rules    セキュリティルール
```

`sql/` は以前のカレンダー週方式の下書きです。実装には使いません。
