import 'dart:async';
import 'dart:core';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendor_driver/LoginPage.dart';
import 'HomePage.dart';
import 'LoginPage.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final storeDb = Firestore.instance;
  bool sign_up_failed = false;

  String _email = "";
  String _password = "";

  void signUp() {
    bool validated = validateForm();
    if (validated) {
      createUser();
    } else {}
  }

  bool validateForm() {
    if (_formKey.currentState.validate())
      return true;
    else
      return false;
  }

  void createUser() async {
    showLoading();
    SharedPreferences shared_prefs = await SharedPreferences.getInstance();

    // FirebaseAuth.instance
    //     .signInWithEmailAndPassword(email: _email, password: _password)
    //     .then((user) {
    //   Navigator.of(context).pop();
    //   shared_prefs.setString("uid", user.uid);
    //   jumpToPage(user);
      
    // }).catchError((onError) {
      // sign_up_failed = true;
      // _formKey.currentState..validate();
      // sign_up_failed = false;
      // Navigator.of(context).pop();
    // });

    FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: _email, password: _password)
        .then((user) {
          Navigator.of(context).pop();
          shared_prefs.setString("uid", user.uid);
          saveUser(user.uid);
          jumpToPage(user);
        })
        .catchError((onError){
            sign_up_failed = true;
            _formKey.currentState..validate();
            sign_up_failed = false;
            Navigator.of(context).pop();
        });
  }

  saveUser(String uid)async{
    await storeDb.collection("vendor_drivers").document(uid).setData({uid: uid});
  }

  jumpToPage(
    FirebaseUser user,
  ) async {
    SharedPreferences shared_prefs = await SharedPreferences.getInstance();

    Timer(Duration(milliseconds: 2000), () {
      setState(() {
          Navigator.push(context, new MaterialPageRoute(builder: (context) {
            return new HomePage();
          }));
      });
    });
  }

  jumpToLogIn(){
    Navigator.push(context, new CupertinoPageRoute(builder: (context) {
            return new LoginPage();
    }));
  }

  Color hexToColor(String code) {
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(13.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // TITLE
                  new Text(
                    "Sign Up",
                    style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  new Padding(
                    padding: EdgeInsets.all(15.0),
                  ),

                  // EMAIL
                  new TextFormField(
                      style: TextStyle(color: Colors.blue),
                      decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: TextStyle(color: Colors.blue),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(3.3))),
                      validator: (value) {
                        if (value.isEmpty || sign_up_failed) {
                          return "Please enter a valid email";
                        } else {
                          setState(() {
                            _email = value;
                          });
                        }
                      }),
                  new Padding(
                    padding: EdgeInsets.all(5.0),
                  ),
                  // PASSWORD
                  new TextFormField(
                    style: TextStyle(color: Colors.blue),
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(color: Colors.blue),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(3.3))),
                    validator: (value) {
                      if (value.isEmpty || sign_up_failed) {
                        return "Please enter a valid password";
                      } else {
                        setState(() {
                          _password = value;
                        });
                      }
                    },
                  ),
                  new Padding(
                    padding: EdgeInsets.all(15.0),
                  ),
                  // LOGIN BUTTON
                  ButtonTheme(
                    minWidth: double.infinity,
                    height: 50.0,
                    child: new RaisedButton(
                      child: Text(
                        "Sign Up",
                        style: TextStyle(color: Colors.white, fontSize: 17.0),
                      ),
                      color: hexToColor("#ef5350"),
                      onPressed: signUp,
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.only(top: 15.0),
                    child: InkWell(
                            onTap: ()=>{jumpToLogIn()},
                            child:Text("Log In", style: TextStyle(fontSize: 17.0, color: Colors.blue),
                     )
                    )
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  showLoading(){
    showCupertinoModalPopup(
         context: context,
         builder: (context) {
            return Center(
              child: Container(
                width: 200.0,
                height: 200.0,
                child: Center(
                  child: Card(
                    
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    )
                  ),
                ),
              ),
            );
          }
       );
  }
}