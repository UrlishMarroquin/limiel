import 'package:firebase_core/firebase_core.dart';
import 'package:limielapp/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:limielapp/provider/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyBoHkvxmktYdxbcvhVwKMcz4_bj_NcEd6k",
        appId: "1:930147174936:android:c3907f2850e8603cd4916d",
        messagingSenderId: "930147174936",
        projectId: "limiel-f55b2"),
  );
  runApp(
    ProviderUser(),
  );
}

class ProviderUser extends StatelessWidget {
  const ProviderUser({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider())
      ],
      child: MaterialApp(
        home: LoginPage(),
        debugShowCheckedModeBanner: false,
        theme:ThemeData(
          inputDecorationTheme: const InputDecorationTheme(
            errorStyle: TextStyle(
              color: Colors.yellow,
            ),
          ),
        ),
      ),
    );
  }
}
