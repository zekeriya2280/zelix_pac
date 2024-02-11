import 'package:flutter/material.dart';

class MyPlayer extends StatelessWidget {
  final String color;
  final int powerlevel ;
  const MyPlayer({super.key, required this.color, required this.powerlevel});

  @override
  Widget build(BuildContext context) {
    //print(powerlevel);
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: color == 'yellow' ?  Image.asset(
      'assets/images/pac.png'
      ) : powerlevel == 0 ? Image.asset(
      'assets/images/pac_red.png'
      ) : powerlevel==1 ?  Image.asset(
      'assets/images/pac_red_onestar.png'
      ) : powerlevel==2 ? Image.asset(
      'assets/images/pac_red_twostar.png'
      ) : powerlevel == 3 ? Image.asset(
      'assets/images/pac_red_threestar.png'
      ) :  powerlevel == -1 ? Image.asset(
      'assets/images/pac.png'
      ): Image.asset(
      'assets/images/pac.png'
      ),
    );
  }
}