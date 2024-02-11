import 'package:firebase_auth/firebase_auth.dart';
import 'package:forjob/models/user.dart';
import 'package:forjob/services/database.dart';

class AuthService{
 
 final FirebaseAuth _auth = FirebaseAuth.instance;

 //create user obj from FirebaseUser
 Userr _userFromFirebaseUser(User? user){
   return user != null ? Userr(uid: user.uid) : Userr();
 }
 //
 Stream<Userr> get user{
  return _auth.authStateChanges().map( _userFromFirebaseUser);
 }
 //sign in anon:
 Future<Userr> signInAnon()async{
  try {
     UserCredential result = await _auth.signInAnonymously();
     User? user = result.user;
     return _userFromFirebaseUser(user);
  } catch (e) {
    print(e.toString());
    return Userr();
    
  }
 }
 //signoutanon
 Future signOut()async{
  try {
    return await _auth.signOut();
  } catch (e) {
    print('CAN NOT SIGN OUT : $e');
    return;
  }
 }
 Future<void> signInWithNickname({required String nickname})async{
  try {
     await DatabaseService().updateUserData(nickname);
     
  } catch (e) {
    print('can not signed in : $e');
    return;
  }
 }
 
}