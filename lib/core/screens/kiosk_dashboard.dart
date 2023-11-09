import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:debug_logger/debug_logger.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/foundation.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobex_kiosk/core/blocs/auth_bloc/auth_bloc.dart';
import 'package:mobex_kiosk/core/blocs/digital_signage_bloc/digital_signage_bloc.dart';
import 'package:mobex_kiosk/core/screens/loading_screen/loading_screen.dart';
import 'package:mobex_kiosk/core/screens/screen_saver_app.dart';
import 'package:mobex_kiosk/core/screens/signin_screen.dart';
import 'package:mobex_kiosk/core/screens/widgets/custom_in_app_webview.dart';
import 'package:mobex_kiosk/core/screens/widgets/kiosk_back_button.dart';
import 'package:mobex_kiosk/core/screens/widgets/kiosk_scaffold.dart';
import 'package:mobex_kiosk/core/screens/widgets/navigation_drawer_widget.dart';
import 'package:mobex_kiosk/core/screens/widgets/pdf_viewer_screen.dart';
import 'package:mobex_kiosk/core/screens/widgets/windows_qr_reader.dart';
import 'package:mobex_kiosk/core/theme/dashboard_bloc/dashboard_bloc.dart';
import 'package:mobex_kiosk/core/theme/theme_builder_bloc/theme_builder_bloc.dart';
import 'package:advance_pdf_viewer2/advance_pdf_viewer.dart' as pdfview;
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';

// import 'package:pdfx/pdfx.dart';
import 'package:shimmer/shimmer.dart';
import 'package:simple_barcode_scanner/enum.dart';
import 'package:simple_barcode_scanner/screens/io_device.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:wakelock/wakelock.dart';

import 'package:webview_windows/webview_windows.dart';
import 'package:window_manager/window_manager.dart';

import '../../shared/fc_material_button.dart';
import '../../utils/config/color_pallet.dart';
import '../../utils/config/maternal.theme.dart';
import '../blocs/digital_signage_bloc/digital_signage_event.dart';
import '../blocs/digital_signage_bloc/digital_signage_state.dart';
import '../theme/entity/main_module_item.dart';
import 'kiosk_sub_dashboard.dart';

class KioskDashboard extends StatefulWidget {
  const KioskDashboard({super.key, this.refreshData});

  final bool? refreshData;

  @override
  State<KioskDashboard> createState() => _KioskDashboardState();

  static double getResponsiveFontSize(
      BuildContext context, double baseFontSize) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Define breakpoints for different screen widths
    if (screenWidth >= 1200) {
      // Large screen, use baseFontSize * 1.5
      return baseFontSize * 2;
    } else if (screenWidth >= 600) {
      // Medium screen, use baseFontSize * 1.2
      return baseFontSize * 1.2;
    } else {
      // Small screen, use baseFontSize
      return baseFontSize;
    }
  }
}

class _KioskDashboardState extends State<KioskDashboard> {
  // final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _controller = WebviewController();

  final _textController = TextEditingController();

  final List<StreamSubscription> _subscriptions = [];

  final navigatorKey = GlobalKey<NavigatorState>();

  Future<void> initPlatformState() async {
    try {
      await _controller.initialize();
      _subscriptions.add(_controller.url.listen((url) {
        _textController.text = url;
      }));

      // _subscriptions
      //     .add(_controller.containsFullScreenElementChanged.listen((flag) {
      //   debugPrint('Contains fullscreen element: $flag');
      //   windowManager.setFullScreen(flag);
      // }));

      await _controller.setBackgroundColor(Colors.transparent);
      await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      // await _controller.loadUrl("https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4");
      // await _controller.loadUrl("https://css4.pub/2017/newsletter/drylab.pdf");
      // url = await controller.url.toString();
      if (!mounted) return;
      setState(() {});
    } on PlatformException catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: Text('Error'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Code: ${e.code}'),
                      Text('Message: ${e.message}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      child: Text('Continue'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ));
      });
    }
  }

  Widget compositeView() {
    if (!_controller.value.isInitialized) {
      return const Text(
        'Not Initialized',
        style: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      // context.read<MyAppsCubit>().gameLoaded();
      return Column(
        children: [
          Expanded(
            child: Card(
              color: Colors.transparent,
              elevation: 0,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Stack(
                children: [
                  // Container(height:200,width:double.infinity,color:Colors.pinkAccent,child: Center(child:Text(Directory(GamePath.jigsaw).absolute.path)),),
                  Webview(
                    _controller,
                    permissionRequested: _onPermissionRequested,
                  ),
                  StreamBuilder<LoadingState>(
                      stream: _controller.loadingState,
                      builder: (context, snapshot) {
                        print("Inside composite View");
                        if (snapshot.hasData &&
                            snapshot.data == LoadingState.loading) {
                          return LoadingScreen();
                        } else {
                          return SizedBox();
                        }
                      }),
                ],
              ),
            ),
          ),
        ],
      );
    }
  }

  Future<WebviewPermissionDecision> _onPermissionRequested(
      String url, WebviewPermissionKind kind, bool isUserInitiated) async {
    final decision = await showDialog<WebviewPermissionDecision>(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('WebView permission requested'),
        content: Text('WebView has requested permission \'$kind\''),
        actions: <Widget>[
          TextButton(
            onPressed: () =>
                Navigator.pop(context, WebviewPermissionDecision.deny),
            child: const Text('Deny'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, WebviewPermissionDecision.allow),
            child: const Text('Allow'),
          ),
        ],
      ),
    );

    return decision ?? WebviewPermissionDecision.none;
  }

  @override
  void initState() {
    if (widget.refreshData!) {
      context.read<DashboardBloc>().add(FetchMainModuleDetailsEvent());
      context.read<ThemeBuilderBloc>().add(FetchDetailsEvent());
      context.read<DigitalSignageBloc>().add(AddDigitalSignageData());
    }
    // context.read<DigitalSignageBloc>().add(EnableScreenSaverTimer());
    super.initState();
    if (kIsWeb) {
    } else if (Platform.isWindows) {
      initPlatformState();
    }
  }

  @override
  Widget build(BuildContext context) {
    Wakelock.enable();
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final _qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();
    String? code;

    // return BlocListener<AuthBloc,AuthState>(listener: (context, state) {
    //   if(AuthStatus.unauthenticated == state.status){
    //     Navigator.push(context, MaterialPageRoute(builder: (context) => SignInScreen()));
    //   }
    //   else if(state.status == AuthStatus.authenticated){
    //
    //   }
    // },
    //   child:
    return BlocBuilder<DigitalSignageBloc, DigitalSignageState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            context
                .read<DigitalSignageBloc>()
                .add(ResetScreenSaverTimer(logout: false));
          },
          child: Scaffold(
            key: _scaffoldKey,
            drawer: NavigationDrawerWidget(),
            body: BlocBuilder<ThemeBuilderBloc, ThemeBuilderState>(
              builder: (context, themeState) {
                return AnimatedSwitcher(
                  switchInCurve: Curves.easeInCubic,
                  duration: Duration(milliseconds: 100),
                  child: state.showScreensaver
                      ? ScreensaverContent(
                          imagesUrls: state.imagesUrls,
                          screenTimeout: state.screenTimeout,
                          imageDuration: state.imageDuration)
                      : Container(
                          height: height,
                          width: width,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              // image: AssetImage("assets/background.png"),
                              image: NetworkImage("assets/back_ground.png"
                                  // themeState.themeData.background
                                  ),
                              alignment: MediaQuery.of(context).orientation ==
                                      Orientation.portrait
                                  ? Alignment.topLeft
                                  : Alignment.center,
                              fit: MediaQuery.of(context).orientation ==
                                      Orientation.portrait
                                  ? BoxFit.fitHeight
                                  : BoxFit.fill,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 0.02239 * height,
                                left: 0.03125 * width,
                                right: 0.03125 * width,
                                child: Container(
                                  width: 0.9275 * width,
                                  height: MediaQuery.of(context).orientation ==
                                          Orientation.landscape
                                      ? 0.08 * height
                                      : 0.06 * height,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(0.0074 * width),
                                    color: Colors.white.withOpacity(1),
                                  ),
                                  child: LayoutBuilder(
                                    builder: (BuildContext context,
                                        BoxConstraints constraints) {
                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                                0.0377 * constraints.maxWidth),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                _scaffoldKey.currentState
                                                    ?.openDrawer();
                                                context
                                                    .read<DigitalSignageBloc>()
                                                    .add(ResetScreenSaverTimer(
                                                        logout: false));
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: SvgPicture.asset(
                                                  "assets/humberger-menu.svg",
                                                  height: 0.4218 *
                                                      constraints.maxHeight,
                                                  width: 0.0727 *
                                                      constraints.maxWidth,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: constraints.maxHeight *
                                                      0.2,
                                                  bottom:
                                                      constraints.maxHeight *
                                                          0.2,
                                                  left: constraints.maxWidth *
                                                      0.1,
                                                  right: constraints.maxWidth *
                                                      0.1),
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    "assets/mobex_new_logo_horizontal.png",
                                                // themeState.themeData.logo,
                                                fit: BoxFit.values[2],
                                                height:
                                                    0.8 * constraints.maxHeight,
                                                placeholder: (context, url) =>
                                                    SizedBox(
                                                  height: height * 0.04,
                                                  child: Shimmer.fromColors(
                                                      baseColor:
                                                          ColorPallet.kWhite,
                                                      highlightColor:
                                                          ColorPallet
                                                              .kPrimaryGrey,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.photo,
                                                            size: height * 0.04,
                                                          ),
                                                        ],
                                                      )),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        SizedBox(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    // crossAxisAlignment: CrossAxisAlignment.center => Center Column contents horizontally,
                                                    children: <Widget>[
                                                      Icon(
                                                        Icons.broken_image,
                                                        color: ColorPallet
                                                            .kPrimaryTextColor,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                fadeInCurve: Curves.easeIn,
                                                fadeInDuration: const Duration(
                                                    milliseconds: 100),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                if(kIsWeb){
                                                  _qrBarCodeScannerDialogPlugin.getScannedQrBarCode(
                                                      context: context,
                                                      onCode: (code) {
                                                        // showDialog(
                                                        //   context: context,
                                                        //   barrierDismissible:
                                                        //   false,
                                                        //   builder: (context) {
                                                        //     return AlertDialog(
                                                        //       title: Text(
                                                        //           "QR Details"),
                                                        //       content:
                                                        //       Text(code!),
                                                        //       actions: <Widget>[
                                                        //         TextButton(
                                                        //           onPressed:
                                                        //               () async {
                                                        //             Navigator.of(
                                                        //                 context)
                                                        //                 .pop();
                                                        //             // await launchUrl(Uri.parse("ms-windows-store://"));
                                                        //           },
                                                        //           child:
                                                        //           Container(
                                                        //             color: Colors
                                                        //                 .black,
                                                        //             padding:
                                                        //             const EdgeInsets.all(
                                                        //                 14),
                                                        //             child: const Text(
                                                        //                 "Close"),
                                                        //           ),
                                                        //         ),
                                                        //       ],
                                                        //     );
                                                        //   },
                                                        // );
                                                      });
                                                }else
                                                {
                                                  var res =
                                                      await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => kIsWeb
                                                          ? BarcodeScanner(
                                                              lineColor:
                                                                  "#ff6677",
                                                              cancelButtonText:
                                                                  "Cancel",
                                                              isShowFlashIcon:
                                                                  true,
                                                              scanType:
                                                                  ScanType.qr,
                                                              onScanned: (res) {
                                                                Navigator.pop(
                                                                    context,
                                                                    res);
                                                              },
                                                            )
                                                          : Platform.isAndroid
                                                              ? BarcodeScanner(
                                                                  lineColor:
                                                                      "#ff6677",
                                                                  cancelButtonText:
                                                                      "Cancel",
                                                                  isShowFlashIcon:
                                                                      true,
                                                                  scanType:
                                                                      ScanType
                                                                          .qr,
                                                                  onScanned:
                                                                      (res) {
                                                                    Navigator.pop(
                                                                        context,
                                                                        res);
                                                                  },
                                                                )
                                                              : WindowQRcodeScanner(
                                                                  centerTitle:
                                                                      true,
                                                                  lineColor:
                                                                      "#000000",
                                                                  cancelButtonText:
                                                                      "Cancel",
                                                                  isShowFlashIcon:
                                                                      true,
                                                                  scanType:
                                                                      ScanType
                                                                          .qr,
                                                                  onScanned:
                                                                      (res) {
                                                                    Navigator.pop(
                                                                        context,
                                                                        res);
                                                                  },
                                                                ),
                                                    ),
                                                  );
                                                  if (res is String) {
                                                    var response =
                                                        jsonDecode(res);
                                                    print(
                                                        "QR Reader Data ::: $response");
                                                    response['type'] == null ||
                                                            response['type'] !=
                                                                'link'
                                                        ? showDialog(
                                                            context: context,
                                                            barrierDismissible:
                                                                false,
                                                            builder: (context) {
                                                              return AlertDialog(
                                                                title: Text(
                                                                    "QR Details"),
                                                                content:
                                                                    Text(res),
                                                                actions: <
                                                                    Widget>[
                                                                  TextButton(
                                                                    onPressed:
                                                                        () async {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                      // await launchUrl(Uri.parse("ms-windows-store://"));
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      color: Colors
                                                                          .black,
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              14),
                                                                      child: const Text(
                                                                          "Close"),
                                                                    ),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          )
                                                        : {
                                                            if (Platform
                                                                .isWindows)
                                                              {
                                                                await _controller
                                                                    .loadUrl(response[
                                                                            'data']
                                                                        [
                                                                        'url']),
                                                                Navigator.of(
                                                                        context)
                                                                    .push(
                                                                  PageRouteBuilder(
                                                                    pageBuilder:
                                                                        (BuildContext
                                                                                context,
                                                                            _,
                                                                            __) {
                                                                      return KioskScaffold(
                                                                          body:
                                                                              compositeView(),
                                                                          title:
                                                                              response['data']['title']);
                                                                    },
                                                                  ),
                                                                )
                                                              }
                                                            else
                                                              {
                                                                Navigator.of(
                                                                        context)
                                                                    .push(
                                                                  PageRouteBuilder(
                                                                    pageBuilder:
                                                                        (BuildContext
                                                                                context,
                                                                            _,
                                                                            __) {
                                                                      return KioskScaffold(
                                                                          body: CustomInAppWebView(
                                                                              url: response['data'][
                                                                                  'url']),
                                                                          title:
                                                                              response['data']['title']);
                                                                    },
                                                                  ),
                                                                )
                                                              }
                                                          };
                                                  } else {
                                                    print("HELLLOOOO!!!!");
                                                    DebugLogger.info(res);
                                                  }
                                                }
                                              },
                                              child: Icon(
                                                  Icons.qr_code_scanner_sharp),
                                            ),
                                            // GestureDetector(
                                            //   onTap: () {
                                            //     // context
                                            //     //     .read<DashboardBloc>()
                                            //     //     .add(FetchMainModuleDetailsEvent());
                                            //   },
                                            //   child: Container(
                                            //       padding:
                                            //           const EdgeInsets.fromLTRB(
                                            //               1, 4, 1, 4),
                                            //       // decoration: BoxDecoration(
                                            //       //   borderRadius: BorderRadius.circular(
                                            //       //       0.104 * constraints.maxHeight),
                                            //       //   color: Colors.white,
                                            //       // ),
                                            //       height: 0.625 *
                                            //           constraints.maxHeight,
                                            //       width: 0.080 *
                                            //           constraints.maxWidth,
                                            //       child: SizedBox()
                                            //       // SvgPicture.asset(
                                            //       //   'assets/globe-language.svg',
                                            //       //   fit: BoxFit.contain,
                                            //       //   // height: 0.375 * constraints.maxHeight,
                                            //       //   // width: 0.0485 * constraints.maxWidth,
                                            //       // ),
                                            //       ),
                                            // ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0.121 * height,
                                left: 0.015625 * width,
                                right: 0.015625 * width,
                                child:
                                    BlocBuilder<DashboardBloc, DashboardState>(
                                  buildWhen: (cur, prev) =>
                                      cur.mainModuleItems.length !=
                                      prev.mainModuleItems.length,
                                  builder: (context, state) {
                                    return Container(
                                      width: double.infinity,
                                      height: height * 0.9,
                                      child: ListView(
                                        shrinkWrap: true,
                                        children: [
                                          StaggeredGrid.count(
                                            crossAxisCount:
                                                MediaQuery.of(context)
                                                            .orientation ==
                                                        Orientation.landscape
                                                    ? 4
                                                    : width <= 600
                                                        ? 3
                                                        : width <= 900
                                                            ? 3
                                                            : 3,
                                            children: state.mainModuleItems
                                                .map((value) {
                                              return _widget(
                                                  value.color, context, value);
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _widget(Color color, BuildContext context, MainModuleItem index) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return StaggeredGridTile.count(
      crossAxisCellCount: 1,
      mainAxisCellCount: 1,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            0.015625 * MediaQuery.of(context).size.width,
            0,
            0.015625 * MediaQuery.of(context).size.width,
            0.02910 * MediaQuery.of(context).size.height),
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            return index.title == 'empty-we-made-it'
                ? SizedBox()
                : GestureDetector(
                    onTap: () async {
                      context
                          .read<DigitalSignageBloc>()
                          .add(ResetScreenSaverTimer(logout: false));
                      if (Platform.isWindows) {
                        if (index.type == "module") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => KioskSubDashboard(
                                title: index.title,
                                id: index.id,
                                color: index.color,
                                textColor: index.textColor,
                              ),
                            ),
                          );
                        } else if (index.type == "pdf") {
                          await _controller.resume();
                          await _controller.loadUrl(index.url + "#view=fitH");
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (BuildContext context, _, __) {
                                return KioskScaffold(
                                    body: compositeView(), title: index.title);
                              },
                            ),
                          );
                        } else if (index.type == "weblink" ||
                            index.type == "video") {
                          await _controller.resume();
                          await _controller.loadUrl(index.url);
                          // await _controller.setZoomFactor(1);
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (BuildContext context, _, __) {
                                return KioskScaffold(
                                    body: compositeView(), title: index.title);
                                // return Scaffold(
                                //   appBar: AppBar(
                                //     titleSpacing: width * 0.04,
                                //     leading: KioskBackButton(),
                                //     // leadingWidth: width * 0.04,
                                //     // toolbarOpacity: 0.1,
                                //     title: Padding(
                                //       padding: EdgeInsets.only(
                                //           bottom: 0.003 * width),
                                //       child: Text(
                                //         index.title,
                                //         style: TextStyle(
                                //             color: Colors.black,
                                //             fontSize: MediaQuery.of(context)
                                //                         .orientation ==
                                //                     Orientation.portrait
                                //                 ? height / 44
                                //                 : width / 44,
                                //             fontWeight: FontWeight.w600),
                                //       ),
                                //     ),
                                //     toolbarHeight:
                                //         MediaQuery.of(context).orientation ==
                                //                 Orientation.portrait
                                //             ? height * 0.06
                                //             : width * 0.04,
                                //     backgroundColor:
                                //         Colors.white.withOpacity(0.85),
                                //     //Color(0xff7E869D),
                                //   ),
                                //   body: Stack(
                                //     children: [
                                //       compositeView(),
                                //     ],
                                //   ),
                                // );
                              },
                            ),
                          );
                        } else if (index.type == "3rdParty") {
                          var res = await canLaunchUrlString(index.windowsId);
                          if (res) {
                            await launchUrlString(index.windowsId);
                          } else {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(
                                      "Alert!",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    content: Text(
                                        "This App is not available on Windows...."),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          // await launchUrl(Uri.parse("ms-windows-store://"));
                                        },
                                        child: Container(
                                          color: Colors.black,
                                          padding: const EdgeInsets.all(14),
                                          child: const Text("Go Back!"),
                                        ),
                                      ),
                                    ],
                                  );
                                });
                          }
                        } else {
                          print("Not implemented");
                        }
                      } else {
                        switch (index.type) {
                          case "weblink":
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                opaque: false,
                                pageBuilder: (BuildContext context, _, __) {
                                  return KioskScaffold(
                                      body: CustomInAppWebView(
                                        url: index.url,
                                      ),
                                      // InAppWebView(
                                      //   initialUrlRequest: URLRequest(
                                      //     url: Uri.parse(index.url),
                                      //   ),
                                      // ),
                                      title: index.title);
                                },
                              ),
                            );
                            break;
                          case "pdf":
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return PdfViewerScreen(
                                      pdfUrl: index.url, pdfTitle: index.title);
                                },
                              ),
                            );
                            break;
                          case "video":
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                opaque: false,
                                pageBuilder: (BuildContext context, _, __) {
                                  return KioskScaffold(
                                      body: CustomInAppWebView(
                                        url: index.url,
                                      ),
                                      // InAppWebView(
                                      //   initialUrlRequest: URLRequest(
                                      //     url: Uri.parse(index.url),
                                      //   ),
                                      // ),
                                      title: index.title);
                                },
                              ),
                            );
                            break;
                          case "module":
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => KioskSubDashboard(
                                  title: index.title,
                                  id: index.id,
                                  color: index.color,
                                  textColor: index.textColor,
                                ),
                              ),
                            );
                            break;
                          case "3rdParty":
                            await LaunchApp.openApp(
                              androidPackageName: index.androidId,
                              // openStore: false
                            );
                            break;
                          default:
                            print("Not implemented");
                            break;
                        }
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            offset: const Offset(0, 4),
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                        color: color.withOpacity(0.85),
                        borderRadius: width >= 1200
                            ? BorderRadius.circular(60)
                            : width >= 600
                                ? BorderRadius.circular(30)
                                : BorderRadius.circular(20),
                      ),
                      child: LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                    0,
                                    // 0.3306 * constraints.maxWidth,
                                    0.1695 * constraints.maxHeight,
                                    0,
                                    // 0.3306 * constraints.maxWidth,
                                    0),
                                child: CachedNetworkImage(
                                  imageUrl: index.imageUrl,
                                  fit: BoxFit.values[2],
                                  height: 0.3302 * constraints.maxHeight,
                                  placeholder: (context, url) => SizedBox(
                                    height: height * 0.04,
                                    child: Shimmer.fromColors(
                                        baseColor: ColorPallet.kWhite,
                                        highlightColor:
                                            ColorPallet.kPrimaryGrey,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.photo,
                                              size: height * 0.04,
                                            ),
                                          ],
                                        )),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      SizedBox(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      // crossAxisAlignment: CrossAxisAlignment.center => Center Column contents horizontally,
                                      children: <Widget>[
                                        Icon(
                                          Icons.broken_image,
                                          color: ColorPallet.kPrimaryTextColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                  fadeInCurve: Curves.easeIn,
                                  fadeInDuration:
                                      const Duration(milliseconds: 100),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      0.0652 * constraints.maxWidth,
                                      0.1173 * constraints.maxHeight,
                                      0.0652 * constraints.maxWidth,
                                      0.0652 * constraints.maxHeight),
                                  child: Text(
                                    index.title,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: index.textColor,
                                      fontFamily:
                                          GoogleFonts.poppins().fontFamily,
                                      fontSize:
                                          MediaQuery.of(context).orientation ==
                                                  Orientation.landscape
                                              ? width / 70
                                              : height / 70,
                                      overflow: TextOverflow.ellipsis,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _textController.dispose();
    _controller.dispose();
    super.dispose();
  }
}

class LeadingWidget extends StatelessWidget {
  const LeadingWidget({
    Key? key,
    this.child,
  }) : super(key: key);

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (child != null) {
      return Container(child: child);
    } else if (Navigator.canPop(context)) {
      return FCBackButton();
    }

    return SizedBox.shrink();
  }
}

class TitleWidget extends StatelessWidget {
  const TitleWidget({
    Key? key,
    this.child,
  }) : super(key: key);

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (child != null) {
      return Container(child: child);
    }

    return SizedBox.shrink();
  }
}

class TopRightWidget extends StatelessWidget {
  const TopRightWidget({
    Key? key,
    this.child,
  }) : super(key: key);

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (child != null) {
      return Container(child: child);
    }

    return SizedBox.shrink();
  }
}

class TrailingWidget extends StatelessWidget {
  const TrailingWidget({
    Key? key,
    this.trailing,
  }) : super(key: key);

  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    if (trailing != null) {
      return Container(child: trailing);
    }

    return SizedBox.shrink();
  }
}

class FCBackButton extends StatelessWidget {
  const FCBackButton({
    Key? key,
    this.label,
    this.iconData,
    this.onPressed,
    this.size,
  }) : super(key: key);

  final String? label;

  final IconData? iconData;

  final VoidCallback? onPressed;

  final Size? size;

  @override
  Widget build(BuildContext context) {
    return FCMaterialButton(
      elevation: 0,
      color: Colors.white,
      isBorder: true,
      borderColor: ColorPallet.kPrimary,
      defaultSize: true,
      borderRadius: BorderRadius.circular(8),
      onPressed: onPressed ??
          () {
            Navigator.pop(context);
          },
      child: Container(
        padding: EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData ?? Icons.arrow_back_ios_rounded,
              color: ColorPallet.kPrimary,
              size: 36.h,
            ),
            SizedBox(width: 2.0),
            Text(
              label ?? "Back",
              style: FCStyle.textStyle.copyWith(
                color: ColorPallet.kPrimary,
                fontSize: 30 * FCStyle.fem,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
