import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hello_me/auth_repository.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

const DEFAULT_PICTURE = 'https://t3.ftcdn.net/jpg/03/46/83/96/360_F_346839683_6nAPzbhpSkIpb8pmAwufkC7c5eD7wYws.jpg';

class UserProfile extends StatefulWidget {
  final AuthRepository? authRepository;

  UserProfile({this.authRepository});

  @override
  _UserProfileState createState() =>
      _UserProfileState(authRepository: authRepository);
}

class _UserProfileState extends State<UserProfile> {
  final AuthRepository? authRepository;
  FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  static const FILE_NAME = 'avatar.png';


  Future<String> _getImageUrl(File file, String name) {
    return _storage
        .ref('images')
        .child(name)
        .putFile(file)
        .then((snapshot) => snapshot.ref.getDownloadURL());
  }

  _UserProfileState({this.authRepository});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthRepository>(builder: (context, auth, _) {
      return Container(
          color: Colors.white,
          child: Row(children: [
            Container(
                margin: EdgeInsets.all(20),
                height: 90,
                width: 90,
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: CircleAvatar(
                    backgroundImage:
                        NetworkImage(auth.user?.photoURL ?? DEFAULT_PICTURE),
                    radius: 20)),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  auth.user?.email as String,
                  style: TextStyle(fontSize: 22),
                ),
                Container(
                  width: 130,
                  height: 40,
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.teal),
                  child: TextButton(
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform
                          .pickFiles(type: FileType.image);

                      if (result != null) {
                        File file = File(result.files.single.path!);
                        String? uid = auth.user?.uid;
                        String fileName =
                            uid == null ? FILE_NAME : uid + FILE_NAME;
                        String _imageUrl = await _getImageUrl(file, fileName);
                        await auth.user?.updateProfile(photoURL: _imageUrl);
                        setState(() {});
                      } else {
                        final snackBar = SnackBar(
                          content: Text('No image selected'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    },
                    child: Text(
                      'Change avatar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            )
          ]));
    });
  }
}

class UserProfileBanner extends StatelessWidget {
  final VoidCallback? changeUserProfileMode;
  final bool? isUserProfileOpen;

  UserProfileBanner({this.changeUserProfileMode, this.isUserProfileOpen});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthRepository>(builder: (context, auth, _) {
      return GestureDetector(
          onTap: () {
            changeUserProfileMode?.call();
          },
          child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey,
              child: Row(children: [
                Expanded(
                    flex: 1,
                    child: Text(
                      'Welcome back, ${auth.user?.email as String}',
                      style: TextStyle(fontSize: 15),
                    )),
                isUserProfileOpen ?? false
                    ? Icon(Icons.expand_more)
                    : Icon(Icons.expand_less)
              ])));
    });
  }
}
