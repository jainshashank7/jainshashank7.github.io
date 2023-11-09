import 'package:flutter/cupertino.dart';

class AdaptiveSize {
  static MediaQueryData _mediaQueryData = MediaQueryData();
  static double screenWidth = 0;
  static double screenHeight = 0;
  static double blockSizeHorizontal = 0;
  static double blockSizeVertical = 0;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
  }
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Define breakpoints for different screen widths
    if (screenWidth >= 1200) {
      // Large screen, use baseFontSize * 1.5
      return baseFontSize * 1.8;
    } else if (screenWidth >= 600) {
      // Medium screen, use baseFontSize * 1.2
      return baseFontSize * 1.4;
    } else {
      // Small screen, use baseFontSize
      return baseFontSize;
    }
  }


  getadaptiveTextSize(BuildContext context, dynamic value) {
    // return value / 2;
    return (value / 720) * MediaQuery.of(context).size.height;
  }
}
