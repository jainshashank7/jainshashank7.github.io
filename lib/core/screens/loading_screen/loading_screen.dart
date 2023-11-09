import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:rive/rive.dart';
import 'package:wakelock/wakelock.dart';

import '../../../utils/constants/assets_paths.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key, this.width, this.height}) : super(key: key);

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    Wakelock.enable();
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.9),
      body: Center(
        child: SizedBox(
          width: width ?? 100,
          height: height ?? 100,
          child: const RiveAnimation.asset(
            AnimationPath.loader,
          ),
        ),
      ),
    );
  }
}
