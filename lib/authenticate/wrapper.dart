import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forjob/authenticate/authenticate.dart';
import 'package:forjob/pages/intro.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  User? username;
  final CollectionReference<Map<String, dynamic>> usersCollection = FirebaseFirestore.instance.collection('users');
 
  @override
  void initState() {
    //checkuserprefs();
    username = FirebaseAuth.instance.currentUser;
    super.initState();
  }
  //void checkuserprefs()async{
  //   //await usersCollection.doc('Default').set({'nickname':'Default'});
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //  if(prefs.getString('nickname') == null){
  //    setState(() {
  //      userr = null;
  //    });
  //  }
  //  if(prefs.getString('nickname') != null){
  //    setState(() {
  //      userr = Userr(name: 'Default');
  //    });
  //  }
  //}
  @override
  Widget build(BuildContext context) {
     //checkuserprefs();
    if (username == null) {
      return const Authenticate();
  } else{
    return const Intro();//Registerdan gelen userrr (Userr?)
  }
  }
}
