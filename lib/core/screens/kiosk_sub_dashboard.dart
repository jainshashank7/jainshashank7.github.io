import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobex_kiosk/core/screens/screen_saver_app.dart';
import 'package:mobex_kiosk/core/theme/dashboard_bloc/dashboard_bloc.dart';
import '../blocs/digital_signage_bloc/digital_signage_bloc.dart';
import '../blocs/digital_signage_bloc/digital_signage_event.dart';
import '../blocs/digital_signage_bloc/digital_signage_state.dart';
import '../theme/theme_builder_bloc/theme_builder_bloc.dart';
import 'dashboard_list.dart';

class KioskSubDashboard extends StatefulWidget {
  const KioskSubDashboard(
      {super.key,
      required this.title,
      required this.id,
      required this.color,
      required this.textColor});

  final String? title;
  final int id;
  final Color color;
  final Color textColor;

  @override
  State<KioskSubDashboard> createState() => _KioskSubDashboardState();
}

class _KioskSubDashboardState extends State<KioskSubDashboard> {
  final ScrollController _scroller = ScrollController();

  @override
  void initState() {
    context
        .read<DashboardBloc>()
        .add(FetchSubModuleDetailsEvent(id: widget.id));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    print("Height ::: ${size.height}");
    print("Width ::: ${size.width}");

    return BlocBuilder<DigitalSignageBloc, DigitalSignageState>(
        buildWhen: (previous, current) {
      return current.isWebviewOpen == false;
    }, builder: (context, state) {
      return GestureDetector(
        onTap: () {
          context
              .read<DigitalSignageBloc>()
              .add(ResetScreenSaverTimer(logout: false));
        },
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, dashboardState) {
            return BlocBuilder<ThemeBuilderBloc, ThemeBuilderState>(
              builder: (context, themeState) {
                return AnimatedSwitcher(
                    switchInCurve: Curves.bounceIn,
                    duration: Duration(milliseconds: 500),
                    child: state.showScreensaver
                        ? ScreensaverContent(
                            imagesUrls: state.imagesUrls,
                            screenTimeout: state.screenTimeout,
                            imageDuration: state.imageDuration)
                        : Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                    themeState.themeData.background),
                                alignment: MediaQuery.of(context).orientation ==
                                        Orientation.portrait
                                    ? Alignment.topLeft
                                    : Alignment.center,
                                fit: MediaQuery.of(context).orientation ==
                                        Orientation.portrait
                                    ? BoxFit.fitHeight
                                    : BoxFit.fill,
                                opacity: 0.5,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 0.02239 * height,
                                  left: MediaQuery.of(context).orientation ==
                                          Orientation.landscape
                                      ? 0.02 * width
                                      : 0.03125 * width,
                                  right: MediaQuery.of(context).orientation ==
                                          Orientation.landscape
                                      ? 0.02 * width
                                      : 0.03125 * width,
                                  child: Container(
                                    width: 0.9275 * width,
                                    height:
                                        MediaQuery.of(context).orientation ==
                                                Orientation.landscape
                                            ? 0.08 * height
                                            : 0.06 * height,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(0.0074 * width),
                                      color: Colors.white.withOpacity(0.85),
                                    ),
                                    child: LayoutBuilder(
                                      builder: (BuildContext context,
                                          BoxConstraints constraints) {
                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 0.0377 *
                                                  constraints.maxWidth),
                                          child: Row(
                                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  context
                                                      .read<
                                                          DigitalSignageBloc>()
                                                      .add(
                                                          ResetScreenSaverTimer(
                                                              logout: false));
                                                  Navigator.pop(context);
                                                },
                                                child: Container(
                                                  // padding: EdgeInsets.all(10),
                                                  child: SvgPicture.asset(
                                                    "assets/Large.svg",
                                                    height: 0.4218 *
                                                        constraints.maxHeight,
                                                    width: 0.0727 *
                                                        constraints.maxWidth,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 15,
                                              ),
                                              Flexible(
                                                child: Text(
                                                  widget.title ?? '',
                                                  textAlign: TextAlign.start,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontFamily:
                                                          GoogleFonts.poppins()
                                                              .fontFamily,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black,
                                                      fontSize: MediaQuery.of(
                                                                      context)
                                                                  .orientation ==
                                                              Orientation
                                                                  .landscape
                                                          ? width / 50
                                                          : height / 44,
                                                      decoration:
                                                          TextDecoration.none),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: MediaQuery.of(context).orientation ==
                                          Orientation.landscape
                                      ? 0.13 * height
                                      : 0.1 * height,
                                  left: MediaQuery.of(context).orientation ==
                                          Orientation.landscape
                                      ? 0.02 * width
                                      : 0.03125 * width,
                                  right: MediaQuery.of(context).orientation ==
                                          Orientation.landscape
                                      ? 0.02 * width
                                      : 0.03125 * width,
                                  child: Container(
                                    height: height * 0.9,
                                    width: double.infinity,
                                    // margin: EdgeInsets.all(40),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            0.0074 * width),
                                        color: Color.fromRGBO(
                                            255, 255, 255, 0.85)),
                                    // child: Expanded(
                                    // height: CustomScreenUtil.screenHeight * 0.1,
                                    child: Padding(
                                        padding: EdgeInsets.only(top: 20),
                                        // child:
                                        // : MediaQuery.of(context).orientation ==
                                        //         Orientation.portrait
                                        //     ?
                                        child: ListView.separated(
                                          controller: _scroller,
                                          separatorBuilder: (ctx, int index) {
                                            return SizedBox(
                                              height: 10,
                                            );
                                          },
                                          physics: BouncingScrollPhysics(),
                                          itemCount: dashboardState
                                              .subModuleItems.length,
                                          itemBuilder: (context, int index) {
                                            //return dashboardState.subModuleItems[index].allow3rdParty == true && Platform.isWindows ?  SizedBox.shrink() :
                                            return DashboardListItem(
                                              hasSubModule: false,
                                              title: dashboardState
                                                  .subModuleItems[index].title,
                                              description: dashboardState
                                                  .subModuleItems[index]
                                                  .description,
                                              icon: dashboardState
                                                  .subModuleItems[index]
                                                  .imageUrl,
                                              iconColor: Colors.black,
                                              id: dashboardState
                                                  .subModuleItems[index].id,
                                              index: index,
                                              color: widget.color,
                                              textColor: widget.textColor,
                                            );
                                          },
                                        )
                                        // : Container(
                                        //     // height: height * 0.1,
                                        //     // width: double.infinity,
                                        //     child: GridView.builder(
                                        //         shrinkWrap: true,
                                        //         itemCount: dashboardState
                                        //             .subModuleItems.length,
                                        //         gridDelegate:
                                        //             SliverGridDelegateWithFixedCrossAxisCount(
                                        //           crossAxisCount: 1,
                                        //         ),
                                        //         itemBuilder:
                                        //             (BuildContext context,
                                        //                 int index) {
                                        //           return DashboardListItem(
                                        //             hasSubModule: false,
                                        //             title: dashboardState
                                        //                 .subModuleItems[index]
                                        //                 .title,
                                        //             description: dashboardState
                                        //                 .subModuleItems[index]
                                        //                 .description,
                                        //             icon: dashboardState
                                        //                 .subModuleItems[index]
                                        //                 .imageUrl,
                                        //             iconColor: Colors.black,
                                        //             id: dashboardState
                                        //                 .subModuleItems[index]
                                        //                 .id,
                                        //             index: index,
                                        //           );
                                        //         }),
                                        //   ),
                                        // ],
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ));
              },
            );
          },
        ),
      );
    });
  }
}
