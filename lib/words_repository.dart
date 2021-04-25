import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/auth_repository.dart';

class WordsRepository with ChangeNotifier {
  final Set<WordPair> _saved = <WordPair>{};
  final AuthRepository _auth;
  final CollectionReference users = FirebaseFirestore.instance.collection(
      'users');

  WordsRepository(this._auth);

  void update(AuthRepository auth) async {
    if (_auth.user != auth.user) {
      if (_auth.isAuthenticated) {
        DocumentReference reference = users.doc(_auth.user?.uid);
        DocumentSnapshot snapshot = await reference.get();
        if (snapshot.exists) {
          Map<String, dynamic>? data = snapshot.data();
          Set<WordPair> wordPairs = data ? ['words']
              .map<WordPair>((o) => WordPair(o['first'], o['second'])).toSet();
          _saved.addAll(wordPairs);
        }
        await reference.set({
          'words': _saved.map((o) => {'first': o.first, 'second': o.second})
              .toList()
        });
      } else {
        _saved.clear();
      }
      notifyListeners();
    }
  }

  Set<WordPair> get saved => _saved;

  Stream<Set<WordPair>> get _savedStream async* {
    yield _saved;
  }

  Stream<Set<WordPair>> savedWordsStream() {
    if (_auth.isAuthenticated) {
      return users.doc(_auth.user?.uid).snapshots()
          .map<Set<WordPair>>((snapshot) {
        Map<String, dynamic>? data = snapshot.data();
        return data ? ['words'].map<WordPair>((o) =>
            WordPair(o['first'], o['second'])).toSet();
      });
    }
    return _savedStream;
  }

  void clearSaved(){
    _saved.clear();
}

  Future<Set<WordPair>> savedSet() async{
      DocumentSnapshot snapshot = await users.doc(_auth.user?.uid).get();
      Set<WordPair> savedWords = {};
      if(snapshot.exists){
        Map<String, dynamic>? data = snapshot.data();
        Set<WordPair> wordPairs = data?['words'].map<WordPair>((o) =>
            WordPair(o['first'], o['second'])).toSet();
        savedWords.addAll(wordPairs);
      }
      return savedWords;
  }

  void addWord(WordPair pair) async {
    if(_auth.isAuthenticated){
      DocumentReference reference = users.doc(_auth.user?.uid);
      Set<WordPair> words = await savedSet();
      words.add(pair);
      await reference.set({
        'words': words.map((o) => {'first': o.first, 'second': o.second}).toList()});
    } else {
      _saved.add(pair);
    }
    notifyListeners();
  }

  void removeWord(WordPair pair) async {
    if(_auth.isAuthenticated){
      DocumentReference reference = users.doc(_auth.user?.uid);
      Set<WordPair> words = await savedSet();
      words.remove(pair);
      await reference.set({
        'words': words.map((o) => {'first': o.first, 'second': o.second}).toList()});
    } else {
      _saved.remove(pair);
    }
    notifyListeners();
  }
}