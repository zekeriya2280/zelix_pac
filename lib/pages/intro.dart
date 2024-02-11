
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forjob/authenticate/signIn.dart';
import 'package:forjob/pages/game.dart';
import 'package:forjob/pages/howtoplay.dart';
import 'package:forjob/pages/playerlist.dart';

class Intro extends StatefulWidget {
  const Intro({super.key});

  @override
  State<Intro> createState() => _IntroState();
}

class _IntroState extends State<Intro>{

  double width = 0.0;
  double height = 0.0;
  //double _scale = 0.0;
  //AnimationController? _controller;
  ////BannerAd? _banner;
  //Widget? startingWidget;

  @override
  void initState() {
   // controllercaller();
    //_createBanner();
   //_scale = 0.0;
   //startingWidget = startingTextFN();
    super.initState();
  }
  //void controllercaller(){
  //  _controller = AnimationController(
  //    vsync: this,
  //    duration: const Duration(
  //      milliseconds: 2000,
  //    ),
  //    lowerBound: 0.0,
  //    upperBound: 0.2,
  //  )..addListener(() {
  //    setState(() {});
  //  });
  //}
//verride
//void dispose() {
//  super.dispose();
//  _controller!.dispose();
//}
 Widget _buttons(String text) {
   return Container(
     height: 160,
     decoration: BoxDecoration(
       color: const Color.fromARGB(85, 0, 255, 213),
       borderRadius: BorderRadius.circular(38)
     ),
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
  //void _createBanner(){
  //  _banner = BannerAd(size: AdSize.fullBanner, adUnitId: AdMobService.bannerAdUnitId!, 
  //                     listener: AdMobService.bannerListener, request: const AdRequest())..load();
  //}
//void _tapDown() async{
//    _controller!.forward();
//    await Future.delayed(const Duration(milliseconds: 1000),(){_controller!.reverse();});
//}
//Widget startingTextFN(){
//  return Container(
//        child: Transform(
//          transform: Matrix4.diagonal3(vector.Vector3(1.0,_scale*15,1.0))..translate(1.0,_scale*5,1.0) ,
//          child: Container(
//            margin: const EdgeInsets.only(bottom: 200),
//            height: height/2,
//            width: width,
//            decoration: const BoxDecoration(
//
//              color: Color.fromARGB(234, 255, 255, 255),
//              shape: BoxShape.circle
//            ),
//            child: Center(child: Text('Starting...\n\n     ${(_scale*1000).floor()}',style: const TextStyle(fontSize: 40),))),
//        ),
//      );
//}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    
    //print(_controller);
   // _scale = (_controller!.value/2);
   ////_tapDown();
   /// print((_scale*1000).floor());
   //f((_scale*1000).floor() == 100){
   //// print('AAAAAAAAA');
   //  startingWidget = null;
   //}
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    
    return Scaffold(
    // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    // floatingActionButton: startingWidget == null ? null : startingTextFN(),

      appBar: AppBar(
        
        backgroundColor: const Color.fromARGB(255, 119, 109, 94),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              child: const Icon(Icons.playlist_add_check_circle_outlined,color: Colors.white),
              onTap: ()async{
                await Navigator.push(context,
                            MaterialPageRoute(builder: (context) => const PlayerList()));
              },
              ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              child: const Icon(Icons.question_mark,color: Colors.white),
              onTap: ()async{
                await Navigator.push(context,
                            MaterialPageRoute(builder: (context) => const HowToPlay()));
              },
              ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              child: const Icon(Icons.settings,color: Colors.white),
              onTap: ()async{
              //  await Navigator.push(context,
              //              MaterialPageRoute(builder: (context) => HowToPlay()));
              },
              ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: ElevatedButton(
              style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.red)),
              onPressed: ()async {
                   await FirebaseAuth.instance.signOut().then((value) async => await Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) => const SignIn())));
              },
              child: const Icon(Icons.logout,color: Colors.white)),
          ),
        ],
        title: const Padding(
          padding: EdgeInsets.only(left:5),
          child: Text('Zelix Pac',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,letterSpacing: 2,fontFamily: 'Times New Roman'),),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.89,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/bg.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
              child: Column(
            children: [
              Expanded(
                  child: Center(
                child: SizedBox(
                    height: height * 0.25,
                    width: width * 0.8,
                    child: Center(
                      child: 
                      GestureDetector(
                        onTap: ()async =>await Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) => const Game())),
                      child: _buttons('START'),
                    
                  ),
               
                    )
                    ),
                )
              ),
              Expanded(
                  child: Center(
                child: SizedBox(
                    height: height * 0.25,
                    width: width * 0.8,
                    child: Center(
                      child: 
                      GestureDetector(
                        onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (context) => const HowToPlay())),
                      //angle: _scale2,
                      child: _buttons('HOW TO PLAY'),
                    
                  ),
               
                    )
                    ),
                )
              ),
              Expanded(
                  child: Center(
                child: SizedBox(
                    height: height * 0.25,
                    width: width * 0.8,
                    child: Center(
                      child: 
                      GestureDetector(
                        onTap: () {
                        if (Platform.isAndroid) {
                            SystemNavigator.pop();
                          } else if (Platform.isIOS) {
                            exit(0);
                          }
                        },
                      //angle: _scale2,
                      child: _buttons('QUIT'),
                    
                  ),
               
                    )
                    ),
                )
              ),
            ],
          )),
        ),
      ),
      //bottomNavigationBar: _banner == null ?  Container()
      //:
      //Container(
      //  margin: const EdgeInsets.only(bottom: 12),
      //  height:62,
      //  child: AdWidget(ad: _banner!),
      //)
      //,
    );
  }
}
