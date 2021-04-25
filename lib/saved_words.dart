import 'package:english_words/english_words.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/words_repository.dart';
import 'package:provider/provider.dart';

class SavedWords extends StatefulWidget {
  @override
  _SavedWordsState createState() => _SavedWordsState();
}

class _SavedWordsState extends State<SavedWords> {
  final _biggerFont = const TextStyle(fontSize: 18);

  @override
  Widget build(BuildContext context) {
    return Consumer<WordsRepository>(builder: (context, words, _) {
      return StreamBuilder<Set<WordPair>>(
          stream: words.savedWordsStream(),
          builder: (context, snapshot) {
            Set<WordPair> savedStream = snapshot.data ?? {};
            final Iterable<Widget> tiles = savedStream.map(
              (WordPair pair) {
                return ListTile(
                  title: Text(
                    pair.asPascalCase,
                    style: _biggerFont,
                  ),
                  trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => words.removeWord(pair)),
                );
              },
            );
            final divided = tiles.isNotEmpty
                ? ListTile.divideTiles(
                    context: context,
                    tiles: tiles,
                  ).toList()
                : <Widget>[];

            return Scaffold(
                appBar: AppBar(
                  title: Text('Saved Suggestions'),
                ),
                body: ListView(children: divided),
            );
          });
    });
  }
}
