import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobex_kiosk/core/blocs/digital_signage_bloc/digital_signage_bloc.dart';
import 'package:mobex_kiosk/core/blocs/digital_signage_bloc/digital_signage_event.dart';
import 'package:mobex_kiosk/core/screens/loading_screen/loading_screen.dart';
import 'package:mobex_kiosk/core/screens/widgets/custom_in_app_webview.dart';
import 'package:mobex_kiosk/core/screens/widgets/custom_screen_util.dart';
import 'package:mobex_kiosk/core/screens/widgets/kiosk_back_button.dart';
import 'package:mobex_kiosk/core/screens/widgets/kiosk_scaffold.dart';
import 'package:mobex_kiosk/core/screens/widgets/pdf_viewer_screen.dart';
import 'package:mobex_kiosk/core/theme/entity/sub_module_link.dart';
import 'package:advance_pdf_viewer2/advance_pdf_viewer.dart' as pdfview;

// import 'package:pdfx/pdfx.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:window_manager/window_manager.dart';

import '../../utils/config/color_pallet.dart';
import '../theme/dashboard_bloc/dashboard_bloc.dart';
import 'grid_items.dart';

class DashboardListItem extends StatefulWidget {
  const DashboardListItem(
      {super.key,
      required this.title,
      required this.description,
      required this.hasSubModule,
      required this.icon,
      required this.iconColor,
      required this.id,
      required this.index,
      required this.color,
      required this.textColor});

  final String icon;
  final String title;
  final String description;
  final bool hasSubModule;
  final Color iconColor;
  final int id;
  final int index;
  final Color color;
  final Color textColor;

  @override
  State<DashboardListItem> createState() => _DashboardListItemState();
}

class _DashboardListItemState extends State<DashboardListItem> {
  // final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  bool _isExpanded = false;

  final _controller = WebviewController();

  final _textController = TextEditingController();

  final List<StreamSubscription> _subscriptions = [];

  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    if (Platform.isWindows) {
      initPlatformState();
    }
  }

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
                      if (e.message == "") Text('Message: ${e.message}'),
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
                    },
                  ),
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
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            List<SubModuleLink> list = state.subModuleLinks[widget.id] ?? [];
            return Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    context
                        .read<DigitalSignageBloc>()
                        .add(ResetScreenSaverTimer(logout: false));
                    if (state.subModuleItems[widget.index].allow3rdParty ==
                        true) {
                      if (Platform.isAndroid) {
                        await LaunchApp.openApp(
                          androidPackageName:
                              state.subModuleItems[widget.index].androidId,
                          // openStore: false
                        );
                      } else if (Platform.isIOS) {
                        await LaunchApp.openApp(
                          iosUrlScheme:
                              state.subModuleItems[widget.index].iosId,
                          // openStore: false
                        );
                      } else if (Platform.isWindows) {
                        var res = await canLaunchUrlString(
                            state.subModuleItems[widget.index].windowsId);
                        if (res) {
                          await launchUrlString(
                              state.subModuleItems[widget.index].windowsId);
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
                      }
                    } else if (state.subModuleItems[widget.index].url == "") {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    } else {
                      if (Platform.isWindows) {
                        if (state.subModuleItems[widget.index].url
                            .endsWith(".pdf")) {
                          print("Hello");
                          await _controller.resume();
                          await _controller.loadUrl(
                              state.subModuleItems[widget.index].url +
                                  "#view=fitH");
                          context
                              .read<DigitalSignageBloc>()
                              .state
                              .isWebviewOpen = true;
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (BuildContext context, _, __) {
                                return KioskScaffold(
                                    body: compositeView(), title: widget.title);
                              },
                            ),
                          );
                        } else {
                          await _controller.resume();
                          await _controller
                              .loadUrl(state.subModuleItems[widget.index].url);
                          context
                              .read<DigitalSignageBloc>()
                              .state
                              .isWebviewOpen = true;
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (BuildContext context, _, __) {
                                return KioskScaffold(
                                    body: compositeView(), title: widget.title);
                              },
                            ),
                          );
                          // Navigator.of(context).push(
                          //   PageRouteBuilder(
                          //     pageBuilder: (BuildContext context, _, __) {
                          //       return Scaffold(
                          //         appBar: AppBar(
                          //           titleSpacing: width * 0.04,
                          //           leading: KioskBackButton(),
                          //           // leadingWidth: width * 0.04,
                          //           // toolbarOpacity: 0.1,
                          //           title: Padding(
                          //             padding: EdgeInsets.only(
                          //                 bottom: 0.003 * size.width),
                          //             child: Text(
                          //               widget.title,
                          //               style: TextStyle(
                          //                   color: Colors.black,
                          //                   fontSize: size.height / 44,
                          //                   fontWeight: FontWeight.w600),
                          //             ),
                          //           ),
                          //           toolbarHeight: size.height * 0.06,
                          //           backgroundColor:
                          //               Colors.white.withOpacity(0.85),
                          //           //Color(0xff7E869D),
                          //         ),
                          //         body: Stack(
                          //           children: [
                          //             compositeView(),
                          //           ],
                          //         ),
                          //       );
                          //     },
                          //   ),
                          // );
                        }
                      } else {
                        if (state.subModuleItems[widget.index].url
                            .endsWith(".pdf")) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return PdfViewerScreen(
                                    pdfUrl:
                                        state.subModuleItems[widget.index].url,
                                    pdfTitle: state
                                        .subModuleItems[widget.index].title);
                              },
                            ),
                          );
                        } else {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              opaque: false,
                              pageBuilder: (BuildContext context, _, __) {
                                return KioskScaffold(
                                    body: CustomInAppWebView(
                                        url: state
                                            .subModuleItems[widget.index].url),
                                    // InAppWebView(
                                    //   initialUrlRequest: URLRequest(
                                    //     url: Uri.parse(state
                                    //         .subModuleItems[widget.index].url),
                                    //   ),
                                    // ),
                                    title: state
                                        .subModuleItems[widget.index].title);
                              },
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: Container(
                    height: MediaQuery.of(context).orientation ==
                            Orientation.landscape
                        ? size.height * 0.14
                        : size.height * 0.11,
                    width: double.infinity,
                    margin: MediaQuery.of(context).orientation ==
                            Orientation.landscape
                        ? EdgeInsets.only(left: 20, right: 20, top: 10)
                        : width >= 1200
                            ? EdgeInsets.only(left: 50, right: 50, top: 50)
                            : EdgeInsets.only(
                                left: width * 0.04,
                                right: width * 0.04,
                                top: height * 0.01),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: state.subModuleItems[widget.index].allow3rdParty ==
                                  true &&
                              Platform.isWindows
                          ? Colors.grey
                          : Colors.white,
                      // Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: size.width * 0.12,
                          height: size.height * 0.07,
                          margin: EdgeInsets.fromLTRB(
                              size.width * 0.03, 10, 10, 10),
                          child: CachedNetworkImage(
                            imageUrl: widget.icon,
                            placeholder: (context, url) => SizedBox(
                              height: size.height * 0.04,
                              child: Shimmer.fromColors(
                                baseColor: ColorPallet.kWhite,
                                highlightColor: ColorPallet.kPrimaryGrey,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.photo,
                                      size: size.height * 0.04,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => SizedBox(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.broken_image,
                                    color: ColorPallet.kPrimaryTextColor,
                                  ),
                                ],
                              ),
                            ),
                            fadeInCurve: Curves.easeIn,
                            fadeInDuration: const Duration(milliseconds: 100),
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Container(
                            margin: MediaQuery.of(context).orientation ==
                                    Orientation.portrait
                                ? EdgeInsets.only(top: 10, bottom: 5)
                                : EdgeInsets.zero,
                            padding: MediaQuery.of(context).orientation ==
                                    Orientation.portrait
                                ? const EdgeInsets.only(
                                    left: 10, right: 10, top: 10)
                                : const EdgeInsets.only(left: 10, right: 10),
                            height: CustomScreenUtil.screenHeight / 100 * 34,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    widget.title,
                                    style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      color: Colors.black,
                                      fontSize:
                                          MediaQuery.of(context).orientation ==
                                                  Orientation.landscape
                                              ? width / 60
                                              : height / 56,
                                      decoration: TextDecoration.none,
                                      fontFamily:
                                          GoogleFonts.poppins().fontFamily,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    widget.description,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          MediaQuery.of(context).orientation ==
                                                  Orientation.landscape
                                              ? width / 70
                                              : height / 80,
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          GoogleFonts.poppins().fontFamily,
                                      decoration: TextDecoration.none,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(right: size.width * 0.015),
                          child: Icon(
                            _isExpanded
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_right,
                            size: MediaQuery.of(context).orientation ==
                                    Orientation.landscape
                                ? size.width / 20
                                : width > 1200
                                    ? 120
                                    : 60,
                            color: widget.iconColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isExpanded)
                  Container(
                    margin: MediaQuery.of(context).orientation ==
                            Orientation.landscape
                        ? EdgeInsets.only(left: 20, right: 20, top: 0)
                        : width >= 1200
                            ? EdgeInsets.only(left: 50, right: 50, top: 0)
                            : EdgeInsets.only(
                                left: width * 0.04,
                                right: width * 0.04,
                                top: 0),
                    // color: Colors.blue,
                    height: width < 400
                        ? height * 0.12 * (list.length / 3).ceil()
                        : width > 900
                            ? size.height * 0.13 * (list.length / 3).ceil()
                            : size.height * 0.13 * (list.length / 3).ceil(),
                    width: double.infinity,
                    child: GridItems(
                      gridViewItemList: list,
                      color: widget.color,
                      textColor: widget.textColor,
                    ),
                  ),
                // )
              ],
            );
          },
        );
      },
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
