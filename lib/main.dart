import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/login.dart';
import 'package:hello_me/random_words.dart';
import 'package:hello_me/saved_words.dart';
import 'package:provider/provider.dart';
import 'auth_repository.dart';
import 'words_repository.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(providers: [
            ChangeNotifierProvider<AuthRepository>(
                create: (_)=> AuthRepository.instance()),
            ChangeNotifierProxyProvider<AuthRepository, WordsRepository>(
                create: (_)=> WordsRepository(AuthRepository.instance()),
                update: (_, authRepository, wordsRepository) {
                    wordsRepository?.update(authRepository);
                      return wordsRepository as WordsRepository;
            })
  ],
      child: App()));
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text(snapshot.error.toString(),
                      textDirection: TextDirection.ltr)));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(
        primaryColor: Colors.red,
      ),
      home: RandomWords(),
      routes: {
        '/LoginScreen': (context) => LoginScreen(),
        '/SavedWords': (context) => SavedWords()
      }
    );
  }
}




