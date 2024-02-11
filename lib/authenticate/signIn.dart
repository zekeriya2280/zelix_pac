
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forjob/authenticate/wrapper.dart';
import 'package:forjob/services/auth.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> with SingleTickerProviderStateMixin {
  double width = 0.0;
  double height = 0.0;
  double _scale = 0.0;
  AnimationController? _controller;
  final AuthService auth = AuthService();
  final _formkey = GlobalKey<FormState>();
  String nickname = '';
  String msgPersonNotFound = '';
  bool nosamenickname = false;
  String currentuserid = '';
 final CollectionReference<Map<String, dynamic>> usersCollection = FirebaseFirestore.instance.collection('users');
  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 500,
      ),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }

  Widget _animatedButton(String text) {
    return Container(
      height: 100,
      width: 300,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.0),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(142, 255, 255, 255),
              blurRadius: 36.0,
              offset: Offset(0.0, 7.0),
            ),
          ],
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 226, 139, 17),
              Colors.transparent,
              Color.fromARGB(255, 226, 139, 17),
            ],
          )),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 40.0,
              letterSpacing: 5,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Colors.white),
        ),
      ),
    );
  }

  void _tapDown(TapDownDetails details) {
    _controller!.forward();
  }

  void _tapUp(TapUpDetails details) {
    _controller!.reverse();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 0.9 - _controller!.value;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 201, 131, 27),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(142, 211, 74, 25),
        elevation: 0.0,
        title: const Center(child: Padding(
          padding: EdgeInsets.only(left: 18.0),
          child: Text('Enter Nickname'),
        )),
      ),
      body:StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: usersCollection.snapshots(),
            builder: (context, snapshot) {
              if(!snapshot.hasData){const CircularProgressIndicator(strokeWidth: 10,);}
              return Center(
                  child: SingleChildScrollView(
                    child: SizedBox(
                      height: height*0.9,
                      child: Column(
                            children: [
                              const Expanded(
                                flex: 0,
                                child: Text(''),
                              ),
                              SizedBox(
                                height: height * 0.2,
                                child: Form(
                                   key : _formkey,
                                     child: Center(
                                   child: Column(
                                     children: [
                                       const SizedBox(
                                         height: 10,
                                       ),
                                       SizedBox(
                                         width: width * 0.8,
                                         child: TextFormField(
                                           validator: (v)=> (v==''||v==null||v.length<6) ? 'Enter a valid and at least 6 char. nickname' : null,
                                           
                                           decoration: InputDecoration(
                                             border: OutlineInputBorder(
                                               borderRadius: BorderRadius.circular(10.0),
                                             ),
                                     
                                             focusedBorder: OutlineInputBorder(
                                               borderSide:
                                                   const BorderSide(color: Colors.white, width: 1.0),
                                               borderRadius: BorderRadius.circular(10.0),
                                             ),
                                             fillColor: Colors.grey,
                                     
                                             hintText: "Nickname",
                                     
                                             //make hint text
                                             hintStyle: const TextStyle(
                                               color: Colors.grey,
                                               fontSize: 16,
                                               fontFamily: "verdana_regular",
                                               fontWeight: FontWeight.w400,
                                             ),
                                     
                                             //create lable
                                             labelText: 'Nickname',
                                             labelStyle: const TextStyle(color: Colors.white)
                                           ),
                                           cursorColor: Colors.black,
                                           style: const TextStyle(fontSize: 30),
                                           maxLength: 50,
                                           textAlign: TextAlign.center,
                                           onChanged: (v) =>setState(() {
                                             nickname = v;
                                           }),
                                         ),
                                       ),
                                     ],
                                   ),
                                )),
                              ),
                              SizedBox(
                                    height: 20,
                                    child: Center(child: Text(msgPersonNotFound,style: TextStyle(fontSize: 15,color: Colors.red[700]),)),
                              ),
                              SizedBox(
                                height: height * 0.18,
                                width: width * 0.8,
                                child: Center(
                                  child: GestureDetector(
                                    onTap: () async {
                                      if(_formkey.currentState!.validate()){
                                          setState(() {
                                              nosamenickname = snapshot.data!.docs.every((doc) =>
                                           doc.data()['nickname'].toString() != nickname);
                                          });
                                          //print(nosamenickname);
                                          if(nosamenickname){
                                               
                                               await auth.signInWithNickname(nickname: nickname).then((value)async => 
                                                await FirebaseAuth.instance.currentUser!.updateDisplayName(nickname)
                                               );
                                               
                                               await Navigator.pushReplacement(context,
                                                      MaterialPageRoute(builder: (context) => const Wrapper()));
                                          }
                                          else{
                                            
                                            setState(() {
                                              msgPersonNotFound = 'Try to enter another nickname';
                                            });
                                          }
                                    } },
                                    onTapDown: _tapDown,
                                    onTapUp: _tapUp,
                                    child: Transform.scale(
                                      scale: _scale,
                                      child: _animatedButton('Enter'),
                                    ),
                                    
                                  ),
                                )),
                            // const Expanded(
                            //   flex: 20,
                            //   child: Text(''),
                            // )
                            ],
                          ),
                    ),
                  ));
            }
          ),
    );
  }
}
