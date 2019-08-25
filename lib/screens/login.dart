import 'package:flutter/material.dart';

import 'package:cms/services/auth.dart';

import 'package:cms/elements/round_text_form_field.dart';
import 'package:cms/elements/primary_button.dart';

import 'package:cms/routes.dart';
import 'package:cms/helpers/alert_helper.dart';

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
                child: Icon(Icons.folder,
                  size: 80.0,
                  color: Theme.of(context).primaryColor,
                ),
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
                icon: Icons.account_circle
              ),
              RoundTextFormField(
                controller: passwordController,
                labelText: 'Password',
                obscureText: true,
                icon: Icons.lock
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
        await AlertHelper.showSuccessDialog(context, "Login successful");
        Navigator.of(context).pushReplacementNamed(Routes.HOME);
      }
      else {
        await AlertHelper.showErrorDialog(context, "Invalid username or password");
      }
    }

    setState(() {
      isProcessing = false;
    });
  }

}