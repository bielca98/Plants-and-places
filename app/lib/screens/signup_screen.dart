import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plants_and_places/screens/login_screen.dart';
import 'package:plants_and_places/services.dart';
import 'package:plants_and_places/widgets/dialogs.dart';
import 'package:plants_and_places/widgets/form_dectorations.dart';

import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  static const String id = "/signup";

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController usernameController = TextEditingController();
  TextEditingController password1Controller = TextEditingController();
  TextEditingController password2Controller = TextEditingController();

  void onSignup() async {
    APIResponse signupResponse = await RESTAPI.signup(usernameController.text,
        password1Controller.text, password2Controller.text);

    if (signupResponse.success) {
      RESTAPI
          .login(usernameController.text, password1Controller.text)
          .then((response) async {
        if (response.success) {
          Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute(builder: (_) => HomeScreen()),
            (Route<dynamic> route) => false,
          );
        } else {
          await showErrorDialog(context,
              title: "Error", message: response.message);
        }
      });
    } else {
      await showErrorDialog(context,
          title: "Error", message: signupResponse.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          FlatButton(
            child: Text("Inicia la sessió"),
            textColor: Theme.of(context).primaryColor,
            onPressed: () => Navigator.push(
                context, CupertinoPageRoute(builder: (_) => LoginScreen())),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 36.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Registra\'t',
                  style: TextStyle(fontSize: 32),
                ),
                SizedBox(
                  height: 48,
                ),
                TextFormField(
                  controller: usernameController,
                  decoration:
                      customDecoration(context, "Usuari", Icons.account_circle),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Si us plau, introdueix un usuari.';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 12.0,
                ),
                TextFormField(
                  controller: password1Controller,
                  decoration:
                      customDecoration(context, "Contrasenya", Icons.lock),
                  obscureText: true,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Si us plau, introdueix una contrasenya.';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 12.0,
                ),
                TextFormField(
                  controller: password2Controller,
                  decoration: customDecoration(
                      context, "Repeteix la contrasenya", Icons.lock),
                  obscureText: true,
                  validator: (value) {
                    if (value.isEmpty || value != password1Controller.text) {
                      return 'Les contrasenyes no coincideixen.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 64),
                OutlineButton(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      "Registra't",
                      style: TextStyle(
                          fontSize: 20, color: Theme.of(context).primaryColor),
                    ),
                  ),
                  borderSide: BorderSide(
                    width: 2.0,
                    color: Theme.of(context).primaryColor,
                    style: BorderStyle.solid,
                  ),
                  focusColor: Theme.of(context).primaryColor,
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      onSignup();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
