import 'package:english_words/english_words.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/user_profile.dart';
import 'package:hello_me/words_repository.dart';
import 'package:provider/provider.dart';
import 'auth_repository.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _snappingSheetController = SnappingSheetController();
  final _suggestions = <WordPair>[];
  final _biggerFont = const TextStyle(fontSize: 18);
  final _snappingPosition = [
    SnappingPosition.factor(
        positionFactor: 0.0,
        grabbingContentOffset: GrabbingContentOffset.top),
    SnappingPosition.pixels(positionPixels: 150)
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthRepository, WordsRepository>(
        builder: (context, auth, words, _) {
      return StreamBuilder<Set<WordPair>>(
          stream: words.savedWordsStream(),
          builder: (context, snapshot) {
            Set<WordPair> savedStream = snapshot.data ?? {};
            return Scaffold(
                appBar: AppBar(
                  title: Text('Startup Name Generator'),
                  actions: [
                    IconButton(
                        icon: Icon(Icons.list),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/SavedWords')),
                    auth.isAuthenticated
                        ? IconButton(
                            icon: Icon(Icons.exit_to_app),
                            onPressed: () => pushExit(auth, words))
                        : IconButton(
                            icon: Icon(Icons.login),
                            onPressed: () =>
                                Navigator.pushNamed(context, '/LoginScreen'))
                  ],
                ),
                body: auth.isAuthenticated
                    ? SnappingSheet(
                        controller: _snappingSheetController,
                        child: _buildSuggestions(words, savedStream),
                        grabbingHeight: 50,
                        grabbing: UserProfileBanner(changeUserProfileMode: _changeUserProfileMode, isUserProfileOpen: _isUserProfileOpen),
                        snappingPositions: [
                          SnappingPosition.factor(
                              positionFactor: 0.0,
                              grabbingContentOffset: GrabbingContentOffset.top),
                          SnappingPosition.pixels(positionPixels: 150)
                        ],
                        sheetBelow: SnappingSheetContent(
                          sizeBehavior: SheetSizeFill(),
                          draggable: true,
                          child: UserProfile(),
                        ),
                      )
                    : _buildSuggestions(words, savedStream));
          });
    });
  }

  void pushExit(AuthRepository auth, WordsRepository words) {
    words.clearSaved();
    auth.signOut();
  }

  Widget _buildRow(WordPair pair, WordsRepository words, savedStream) {
    final alreadySaved = savedStream.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            words.removeWord(pair);
          } else {
            words.addWord(pair);
          }
        });
      },
    );
  }

  bool get _isUserProfileOpen{
   return (_snappingSheetController.isAttached) && (_snappingPosition.indexOf(_snappingSheetController.currentSnappingPosition) == 1);
  }

  void _changeUserProfileMode() {
    setState(() {
      if (_snappingSheetController.isAttached) {
        int currentSnapIndex = _snappingPosition
            .indexOf(_snappingSheetController.currentSnappingPosition);
        _snappingSheetController
            .snapToPosition(_snappingPosition[1 - currentSnapIndex]);
      }
    });
  }

  Widget _buildSuggestions(WordsRepository words, savedStream) {
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        // The itemBuilder callback is called once per suggested
        // word pairing, and places each suggestion into a ListTile
        // row. For even rows, the function adds a ListTile row for
        // the word pairing. For odd rows, the function adds a
        // Divider widget to visually separate the entries. Note that
        // the divider may be difficult to see on smaller devices.
        itemBuilder: (BuildContext _context, int i) {
          // Add a one-pixel-high divider widget before each row
          // in the ListView.
          if (i.isOdd) {
            return Divider();
          }

          // The syntax "i ~/ 2" divides i by 2 and returns an
          // integer result.
          // For example: 1, 2, 3, 4, 5 becomes 0, 1, 1, 2, 2.
          // This calculates the actual number of word pairings
          // in the ListView,minus the divider widgets.
          final int index = i ~/ 2;
          // If you've reached the end of the available word
          // pairings...
          if (index >= _suggestions.length) {
            // ...then generate 10 more and add them to the
            // suggestions list.
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(_suggestions[index], words, savedStream);
        });
  }
}
