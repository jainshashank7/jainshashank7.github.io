import 'package:flutter/material.dart';

import '../../../utils/config/color_pallet.dart';
import '../../../utils/config/maternal.theme.dart';

class Custom_Texfeild extends StatefulWidget {
  final controller;
  final String hintText;
  final bool obscureText;

  const Custom_Texfeild(
      {super.key,
      this.controller,
      required this.hintText,
      required this.obscureText});

  @override
  State<Custom_Texfeild> createState() => _Custom_TexfeildState();
}

class _Custom_TexfeildState extends State<Custom_Texfeild> {
  bool isPasswordHidden = true;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      // color: Colors.red,
      // height: 0.1 * screenHeight,
      width: 0.6 * screenWidth,
      child: TextField(
        obscureText: widget.obscureText == isPasswordHidden ? isPasswordHidden : widget.obscureText,
        controller: widget.controller,
        // strutStyle: StrutStyle(height: 3),
        style: MediaQuery.of(context).orientation == Orientation.landscape
            ? TextStyle(fontSize: screenWidth / 60)
            : TextStyle(fontSize: screenHeight / 60),
        decoration: InputDecoration(
          hintText: widget.hintText,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(0.01 * screenWidth),
            borderSide: const BorderSide(
              color: Colors.black,
            ),
          ),
          suffixIcon: widget.obscureText == true
              ? Container(
                  // color: Colors.greenAccent,
                  padding:
                      EdgeInsets.only(right: FCStyle.blockSizeHorizontal * 2),
                  child: IconButton(
                    onPressed: () {
                      print(
                          "Hello $isPasswordHidden"); //add Icon button at end of TextField
                      setState(() {
                        //refresh UI
                        if (isPasswordHidden) {
                          //if passenable == true, make it false
                          isPasswordHidden = false;
                        } else {
                          isPasswordHidden =
                              true; //if passenable == false, make it true
                        }
                      });
                    },
                    icon: Icon(
                      !isPasswordHidden
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                )
              : SizedBox.shrink(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.shade400,
            ),
            borderRadius: BorderRadius.circular(0.01 * screenWidth),
          ),
          fillColor: Colors.grey.shade200,
          filled: true,
        ),
      ),
    );
  }
}
