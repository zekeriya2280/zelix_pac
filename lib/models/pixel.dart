import 'package:flutter/material.dart';

class MyPixel extends StatelessWidget {
  const MyPixel({super.key, this.innercolor,this.outercolor, this.child});
  final innercolor;
  final outercolor;
  final child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Container(
        color: Colors.blue,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(1),
          child: Container(
            padding: const EdgeInsets.all(2),
              color: outercolor,
              child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
              color: innercolor,
              child: Center(
                child: child,
              )),
        ),
        ),
      ),
    ));
  }
}
