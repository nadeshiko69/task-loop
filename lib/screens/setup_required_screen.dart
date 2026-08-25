import 'package:flutter/material.dart';

/// Firebase 未接続でもアプリが起動するようにする。
class SetupRequiredScreen extends StatelessWidget {
  const SetupRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            children: const [
              SizedBox(height: 24),
              Text(
                'Firebase の接続がまだです',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'iMac で次を実行すると、この画面は出なくなります。',
              ),
              SizedBox(height: 16),
              SelectableText(
                '1. Firebase プロジェクトを作る\n'
                '2. Authentication で Apple を有効化\n'
                '3. Firestore を作成し、firebase/firestore.rules をデプロイ\n'
                '4. このフォルダで:\n'
                '   dart pub global activate flutterfire_cli\n'
                '   flutterfire configure \\\n'
                '     --project=<FirebaseのプロジェクトID> \\\n'
                '     --platforms=ios,android \\\n'
                '     --ios-bundle-id=jp.taskl.taskLoop',
              ),
              SizedBox(height: 16),
              Text(
                'Xcode では Signing & Capabilities に '
                'Sign in with Apple を追加してください。',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
