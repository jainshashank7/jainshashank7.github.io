import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobex_kiosk/core/blocs/auth_bloc/auth_bloc.dart';
import 'package:mobex_kiosk/core/screens/loading_screen/loading_screen.dart';
import 'package:mobex_kiosk/core/screens/screen_saver_app.dart';
import 'package:mobex_kiosk/core/screens/signin_screen.dart';
import 'package:provider/provider.dart';

import '../../../enitity/navigation_item.dart';
import '../../blocs/digital_signage_bloc/digital_signage_bloc.dart';
import '../../blocs/digital_signage_bloc/digital_signage_event.dart';
import '../../blocs/digital_signage_bloc/digital_signage_state.dart';
import 'navigation_provider.dart';

class NavigationDrawerWidget extends StatefulWidget {
  const NavigationDrawerWidget({super.key});

  @override
  State<NavigationDrawerWidget> createState() => _NavigationDrawerWidgetState();
}

class _NavigationDrawerWidgetState extends State<NavigationDrawerWidget> {
  final padding = EdgeInsets.symmetric(horizontal: 20);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final name = 'Ashfak Sayem';
    final email = 'ashfaksayem@gmail.com';
    final defaultImage =
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=634&q=80';

    return BlocBuilder<DigitalSignageBloc, DigitalSignageState>(
        builder: (context, state) {
      return GestureDetector(
        onTap: () {
          context.read<DigitalSignageBloc>().add(ResetScreenSaverTimer(logout: false));
        },
        child: state.showScreensaver ? ScreensaverContent(imagesUrls: state.imagesUrls,screenTimeout: state.screenTimeout,imageDuration: state.imageDuration,) : Drawer(
          width: MediaQuery.of(context).size.width * 0.6,
          child: Material(
            color: const Color(0xffF9F9F9),
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              return ListView(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      context
                          .read<DigitalSignageBloc>()
                          .add(ResetScreenSaverTimer(logout: false));
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            offset: const Offset(0, 4),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ],
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: height > 1340 ? height * 0.0306 : height * 0.06,
                      width: 10,
                      margin: MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? EdgeInsets.fromLTRB(constraints.maxWidth * 0.05,
                              height * 0.0194, constraints.maxWidth * 0.85, 0)
                          : width > 560
                              ? EdgeInsets.fromLTRB(
                                  constraints.maxWidth * 0.0894,
                                  height * 0.0194,
                                  constraints.maxWidth * 0.6644,
                                  0)
                              : EdgeInsets.fromLTRB(
                                  constraints.maxWidth * 0.0894,
                                  height * 0.0194,
                                  60,
                                  0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.arrow_back_ios,
                              size: MediaQuery.of(context).orientation ==
                                      Orientation.landscape
                                  ? width / 50
                                  : constraints.maxWidth * 0.06,
                            ),
                            Text(
                              "Back",
                              style: GoogleFonts.poppins(
                                  fontSize: height / 50,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      print(
                          "image of user " + state.user.profileUrl.toString());
                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                            constraints.maxWidth * 0.0894,
                            height * 0.05,
                            constraints.maxWidth * 0.0447,
                            0),
                        child: buildHeader(
                          context: context,
                          urlImage: state.user.profileUrl ?? "",
                          name: state.user.name ?? name,
                          email: state.user.email ?? email,
                          onClicked: () {},
                        ),
                      );
                    },
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(
                        constraints.maxWidth * 0.0894,
                        constraints.maxHeight * 0.03,
                        constraints.maxWidth * 0.0894,
                        0),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        buildMenuItem(
                          context: context,
                          item: NavigationItem.dashboard,
                          text: 'Dashboard',
                          image: "assets/Dashboard.svg",
                          onClicked: () {
                            selectItem(context, NavigationItem.dashboard);
                            context
                                .read<DigitalSignageBloc>()
                                .add(ResetScreenSaverTimer(logout: false));
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(height: 14),
                        // const Divider(
                        //   height: 2,
                        //   thickness: 2,
                        //   color: Color(0xffDADADA),
                        // ),
                        // const SizedBox(height: 14),
                        // buildMenuItem(
                        //   context: context,
                        //   item: NavigationItem.editProfile,
                        //   text: 'Edit Profile',
                        //   image: "assets/edit-profle.svg",
                        //   // onClicked: () {},
                        // ),
                        // const SizedBox(height: 14),
                        // const Divider(
                        //   height: 2,
                        //   thickness: 2,
                        //   color: Color(0xffDADADA),
                        // ),
                        // const SizedBox(height: 14),
                        // buildMenuItem(
                        //   context: context,
                        //   item: NavigationItem.changePassword,
                        //   text: 'Change Password',
                        //   image: "assets/change-password.svg",
                        //   // onClicked: () => {},
                        // ),
                        // const SizedBox(height: 14),
                        // const Divider(
                        //   height: 2,
                        //   thickness: 2,
                        //   color: Color(0xffDADADA),
                        // ),
                        // const SizedBox(height: 14),
                        // buildMenuItem(
                        //   context: context,
                        //   item: NavigationItem.about,
                        //   text: 'About',
                        //   image: "assets/about.svg",
                        //   // onClicked: () {},
                        // ),
                        // const SizedBox(height: 14),
                        const Divider(
                          height: 2,
                          thickness: 2,
                          color: Color(0xffDADADA),
                        ),
                        const SizedBox(height: 14),
                        buildMenuItem(
                          context: context,
                          item: NavigationItem.logout,
                          text: 'Logout',
                          image: "assets/logout.svg",
                          onClicked: () {
                            selectItem(context, NavigationItem.logout);

                            print("Logout Clicked 1");
                            context
                                .read<DigitalSignageBloc>()
                                .add(ResetScreenSaverTimer(logout: true));
                            context.read<AuthBloc>().add(SignOutAuthEvent());
                            print("Logout Clicked 2");
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      );
    });
  }

  Widget buildHeader({
    required String urlImage,
    required String name,
    required String email,
    required BuildContext context,
    required VoidCallback onClicked,
  }) =>
      Container(
        child: Row(
          children: [
            (urlImage == null || urlImage == "")
                ? CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.05,
                    backgroundImage:
                        AssetImage("assets/images/avatar_image.png"),
                  )
                : CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.05,
                    backgroundImage: NetworkImage(urlImage),
                  ),
            SizedBox(
                width: MediaQuery.of(context).size.height > 1340 ? 20 : 10),
            Container(
              width: MediaQuery.of(context).size.width * 0.38,
              // color: Colors.blue,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                        fontSize: MediaQuery.of(context).size.height > 1340
                            ? getResponsiveFontSize(context, 20)
                            : getResponsiveFontSize(context, 16),
                        // MediaQuery.of(context).size.height > 1340 ? getResponsiveFontSize(context, 20) : getResponsiveFontSize(context, 16),
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  // Container(
                  //       height: MediaQuery.of(context).size.height * 0.1,
                  //       color: Colors.pinkAccent,
                  //       width: double.infinity,
                  //       child:
                  Text(
                    email,
                    // overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: GoogleFonts.poppins(
                        fontSize: MediaQuery.of(context).size.height > 1340
                            ? getResponsiveFontSize(context, 18)
                            : getResponsiveFontSize(context, 10),
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

Widget buildMenuItem({
  required String text,
  required String image,
  required NavigationItem item,
  required BuildContext context,
  VoidCallback? onClicked,
}) {
  final provider = Provider.of<NavigationProvider>(context);
  final currentItem = NavigationItem.dashboard;
  final isSelected = item == currentItem;

  Color _textColor = isSelected ? Colors.white : Colors.black;

  print(currentItem);

  return Container(
    height: MediaQuery.of(context).size.height > 1340
        ? MediaQuery.of(context).size.height * 0.05
        : MediaQuery.of(context).size.height * 0.07,
    decoration: BoxDecoration(
      color: isSelected ? Color(0xff4A4ABE) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Center(
      child: ListTile(
        // selected: isSelected,
        // selectedTileColor: const Color(0xff4A4ABE),
        leading: SvgPicture.asset(
          image,
          color: _textColor,
          height: MediaQuery.of(context).size.height > 1340
              ? MediaQuery.of(context).size.height * 0.025
              : MediaQuery.of(context).size.height * 0.025,
          width: MediaQuery.of(context).size.width * 0.03,
        ),
        contentPadding:
            EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
        horizontalTitleGap: MediaQuery.of(context).size.height > 1340 ? 30 : 0,
        // horizontalTitleGap: MediaQuery.of(context).size.width * 0.01,
        title: Text(
          text,
          style: GoogleFonts.poppins(
              fontSize: getResponsiveFontSize(context, 16),
              color: _textColor,
              fontWeight: FontWeight.w600),
        ),
        onTap: onClicked,
        //   () {
        // selectItem(context, item);
        // print(text);
        // if (text == "Logout") {
        //   context.read<AuthBloc>().add(SignOutAuthEvent());
        // }
        // else if(text == "Dashboard"){
        //   Navigator.pop(context);
        // }
        // }
      ),
    ),
  );
}

double getResponsiveFontSize(BuildContext context, double baseFontSize) {
  double screenWidth = MediaQuery.of(context).size.width;

  // Define breakpoints for different screen widths
  if (screenWidth >= 1200) {
    // Large screen, use baseFontSize * 1.5
    return baseFontSize * 1.5;
  } else if (screenWidth >= 700) {
    // Medium screen, use baseFontSize * 1.2
    return baseFontSize * 1.3;
  } else {
    // Small screen, use baseFontSize
    return baseFontSize;
  }
}

selectItem(BuildContext context, NavigationItem item) {
  final provider = Provider.of<NavigationProvider>(context, listen: false);
  provider.setNavigationItem(item);
}
