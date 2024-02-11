import 'package:flutter/material.dart';

class HowToPlay extends StatefulWidget {
  const HowToPlay({super.key});

  @override
  State<HowToPlay> createState() => _HowToPlayState();
}

class _HowToPlayState extends State<HowToPlay> {
  double width = 0.0;
  double height = 0.0;
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: const [
          Padding(
            padding: EdgeInsets.all(3.0),
            child: Icon(Icons.settings),
          ),
        ],
        title: const Padding(
          padding: EdgeInsets.all(70),
          child: Text('Zelix Pac'),
        ),
      ),
      body: Stack(children: <Widget>[
        Image.asset(
          "assets/images/bg2.png",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Center(
          child: SingleChildScrollView(
            child: SizedBox(
              height: height*0.9,
              child: Column(
                children: [
                  Expanded(
                      flex: 5,
                      child: Container(
                          child: const Image(
                              image:
                                  AssetImage('assets/images/ghostandplayer_tp.png'),
                              alignment: Alignment.center))),
                  Expanded(
                      flex: 7,
                      child: Container(
                          child: const Text(
                        '1- Ghost follows the player, \n2- Player gets stronger while picking foods ,\n3- One hit to the player decreases the power of player and the appearance. \n4- The aim is picking up all foods as soon as possible and with highest score! \n Good LUCK!',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      )))
                ],
              ),
            ),
          ),
        )
      ]),
    );
  }
}
