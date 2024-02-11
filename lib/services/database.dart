import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService{
   DatabaseService();

  final CollectionReference<Map<String, dynamic>> playersCollection = FirebaseFirestore.instance.collection('users');
  
  Future<void> updateUserData(String nickname)async{
      await FirebaseAuth.instance.signInAnonymously();
      await playersCollection.doc(nickname).set({
        'nickname':nickname,
        'time':Random().nextInt(1000)+9000,
        'score':'0'
      });
      //print('DATABASE UPDATED');
      await playersCollection.doc('Default').delete();
  }
}