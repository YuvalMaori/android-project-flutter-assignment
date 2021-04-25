import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_repository.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final emailController = TextEditingController();
  final key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final AuthRepository authRepository =
        Provider.of<AuthRepository>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          title: Text('Login'),
        ),
        body: Padding(
            padding: EdgeInsets.all(10),
            child: ListView(children: <Widget>[
              Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Welcome to startup Names Generator, please log in below',
                  )),
              Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Email',
                    ),
                  )),
              Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Password',
                    ),
                  )),
              Container(
                margin: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(15)),
                child: TextButton(
                  onPressed: () async {
                    bool isLogin = await authRepository.signIn(
                        emailController.text, passwordController.text);
                    if (isLogin) {
                      Navigator.pushNamed(context, '/');
                    } else {
                      final snackBar = SnackBar(
                        content:
                            Text('There was an error logging into the app'),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  },
                  child: Text(
                    'Log in',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(15)),
                child: TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) => _showSignUp(authRepository));
                  },
                  child: Text(
                    'New user? Click to sign up',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Center(
                  child: Consumer<AuthRepository>(builder: (context, auth, _) {
                return (authRepository.status == Status.Authenticating)
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.black))
                    : Text("");
              }))
            ])));
  }

  Widget _showSignUp(AuthRepository authRepository) {
    return Form(
        key: key,
        child: SizedBox(
            height: 200,
            child: Column(children: <Widget>[
              Center(
                  child: Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: Text('Please confirm your password below:'))),
              Divider(),
              Center(
                  child: Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: TextFormField(
                        validator: (value) {
                          if (value != passwordController.text) {
                            return 'Passwords must match';
                          }
                          return null;
                        },
                        controller: confirmPasswordController,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Password',
                        ),
                      ))),
              Center(
                child: Container(
                  width: 100,
                  height: 40,
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.teal),
                  child: TextButton(
                    onPressed: () async {
                      if (key.currentState!.validate()) {
                        await authRepository.signUp(
                            emailController.text, passwordController.text);
                        Navigator.pushNamed(context, '/');
                      }
                    },
                    child: Text(
                      'Confirm',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              )
            ])));
  }
}
