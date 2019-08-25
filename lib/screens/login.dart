import 'package:flutter/material.dart';

import 'package:cms/services/auth.dart';

import 'package:cms/elements/round_text_form_field.dart';
import 'package:cms/elements/primary_button.dart';

import 'package:cms/routes.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isProcessing;

  @override
  void initState() {
    // TODO: implement initState
    isProcessing = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('CMS Login'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.folder, size: 80.0),
              ),
              Text(
                'Container Management System',
                style: TextStyle(
                  fontSize: 16.0
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
              ),
              RoundTextFormField(
                controller: usernameController,
                labelText: 'Username',
              ),
              RoundTextFormField(
                controller: passwordController,
                labelText: 'Password',
                obscureText: true,
              ),
              PrimaryButton(
                label: 'Submit',
                onPressed: this.processLogin,
                isProcessing: isProcessing,
              )
            ],
          ),
        ),
      ),
    );
  }

  void processLogin() async {
    setState(() {
      isProcessing = true;
    });

    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      var authService = AuthService();
      if (await authService.isValidUser(usernameController.text, passwordController.text)) {
        Navigator.of(context).pushReplacementNamed(Routes.HOME);
      }
      else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Icon(
                Icons.error,
                size: 80.0,
                color: Colors.red,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)
              ),
              content: Text("Invalid username or password"),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("Try again"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }

    setState(() {
      isProcessing = false;
    });
  }

}