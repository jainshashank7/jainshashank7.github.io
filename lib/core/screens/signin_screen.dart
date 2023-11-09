import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:mobex_kiosk/core/screens/kiosk_dashboard.dart';
import 'package:mobex_kiosk/core/screens/screen_saver_app.dart';
import 'package:mobex_kiosk/core/screens/widgets/custom_textfeild.dart';
import 'package:wakelock/wakelock.dart';

import '../../utils/config/color_pallet.dart';
import '../../utils/config/maternal.theme.dart';
import '../blocs/auth_bloc/auth_bloc.dart';
import 'loading_screen/loading_screen.dart';

final usernameController = TextEditingController();
final passwordController = TextEditingController();

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool isPasswordHidden = true;

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      // backgroundColor: Colors.pinkAccent.shade100,

      backgroundColor: ColorPallet.kBackGroundGradientColor2,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [ColorPallet.kBackGroundGradientColor1, Colors.grey],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            print(state.status);
            return Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 0.13 * screenHeight,
                  width: screenWidth,
                ),

                SizedBox(
                  height: screenHeight / 6,
                  child: Image.asset(
                    "assets/mobex_new_logo_horizontal.png",
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(
                  height: 0.04 * screenHeight,
                ),

                // Username

                Custom_Texfeild(
                  controller: usernameController,
                  hintText: 'Username',
                  obscureText: false,
                ),

                SizedBox(
                  height: 0.03 * screenHeight,
                ),
                SizedBox(
                  width: 0.6 * screenWidth,
                  child: TextField(
                    obscureText: isPasswordHidden,
                    controller: passwordController,
                    // strutStyle: StrutStyle(height: 3),
                    style: MediaQuery.of(context).orientation ==
                            Orientation.landscape
                        ? TextStyle(fontSize: screenWidth / 60)
                        : TextStyle(fontSize: screenHeight / 60),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0.01 * screenWidth),
                        borderSide: const BorderSide(
                          color: Colors.black,
                        ),
                      ),
                      suffixIcon: Container(
                        // color: Colors.greenAccent,
                        padding: EdgeInsets.only(
                            right: FCStyle.blockSizeHorizontal * 2),
                        child: IconButton(
                          onPressed: () {
                            setState(
                              () {
                                //refresh UI
                                if (isPasswordHidden) {
                                  isPasswordHidden = false;
                                } else {
                                  isPasswordHidden = true;
                                }
                              },
                            );
                          },
                          icon: Icon(
                            !isPasswordHidden
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
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
                ),

                SizedBox(
                  height: 0.025 * screenHeight,
                ),

                if (state.status == AuthStatus.confirmFailed)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Invalid username or password',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 0.02 * screenHeight,
                        color: ColorPallet.kRed,
                      ),
                    ),
                  ),
                SizedBox(
                  height: 0.025 * screenHeight,
                ),

                GestureDetector(
                  onTap: () {
                    if(passwordController.text != "" && usernameController.text != "" ) {
                      context.read<AuthBloc>().add(ConfirmUserSignInAuthEvent(
                        inviteCode: passwordController.text.trim(),
                        email: usernameController.text.trim())) ;
                    }
                  },
                  child: Container(
                    width: 0.5 * screenWidth,
                    height: 0.07 * screenHeight,
                    decoration: BoxDecoration(
                        color: Color(0xEFC9591F),
                        borderRadius:
                            BorderRadius.circular(0.01 * screenWidth)),
                    child: Center(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 0.01 * screenHeight),
                        child: Text(
                          'Login',
                          maxLines: 1,
                          style:
                           TextStyle(
                            color: Colors.white,
                            fontSize: screenHeight / 34,
                            fontWeight: FontWeight.w700,
                          ) ,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  height: 0.03 * screenHeight,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class UnlockVerifiedUser extends StatefulWidget {
  const UnlockVerifiedUser({
    Key? key, required this.refreshData,
  }) : super(key: key);
  final bool refreshData;

  @override
  State<UnlockVerifiedUser> createState() => _UnlockVerifiedUserState();
}

class _UnlockVerifiedUserState extends State<UnlockVerifiedUser> {
  bool isEnabled = false;
  bool isPasswordHidden = true;

  @override
  void initState() {
    if (context.read<AuthBloc>().state.status == AuthStatus.confirmFailed) {
      context.read<AuthBloc>().add(ResetConfirmUserFailedAuthEvent());
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        print(state.status);
        if (state.status == AuthStatus.authenticated) {
          passwordController.text = "";
          usernameController.text = "";
          FocusManager.instance.primaryFocus?.unfocus();
          return KioskDashboard(refreshData: widget.refreshData,);
        } else if (state.status == AuthStatus.confirmationRequired ||
            state.status == AuthStatus.confirmFailed ||
            state.status == AuthStatus.unauthenticated) {
          return const SignInScreen();
        } else if (state.status == AuthStatus.confirming ||
            state.status == AuthStatus.loading ||
            state.status == AuthStatus.unknown) {
          return const Center(child: LoadingScreen());
        }
        return const Center(child: SignInScreen());
      },
    );
  }
}
