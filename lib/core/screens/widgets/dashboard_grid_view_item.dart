import 'dart:async';
import 'dart:io';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_svg/svg.dart';
import 'package:advance_pdf_viewer2/advance_pdf_viewer.dart' as pdfview;
import 'package:mobex_kiosk/core/screens/widgets/kiosk_scaffold.dart';
import 'package:mobex_kiosk/core/screens/widgets/pdf_viewer_screen.dart';
import 'package:mobex_kiosk/utils/barrel.dart';

// import 'package:pdfx/pdfx.dart';
import 'package:url_launcher/url_launcher.dart';

// import 'package:url_launcher_windows/url_launcher_windows.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:window_manager/window_manager.dart';

import '../../blocs/digital_signage_bloc/digital_signage_bloc.dart';
import '../../blocs/digital_signage_bloc/digital_signage_event.dart';
import '../loading_screen/loading_screen.dart';
import 'custom_in_app_webview.dart';
import 'kiosk_back_button.dart';

class DashboardGridViewItem extends StatefulWidget {
  DashboardGridViewItem(
      {super.key,
      required this.title,
      required this.link,
      required this.itemType,
      required this.color,
      required this.textColor});

  final String title;
  final String link;
  final String itemType;
  final Color color;
  final Color textColor;

  @override
  State<DashboardGridViewItem> createState() => _DashboardGridViewItemState();
}

class _DashboardGridViewItemState extends State<DashboardGridViewItem> {
  // final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final pdfUrl = 'https://css4.pub/2017/newsletter/drylab.pdf';

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
      // return Padding(
      //   padding: EdgeInsets.all(8),
      //   child:
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
        // ),
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

  void openApp(String url) async {
    // final url = 'ms-store://'; // URL scheme for the Microsoft Store
    var res = await canLaunchUrl(Uri.parse(url));

    if (res) {
      await launchUrl(Uri.parse(url));
    } else {
      // Handle the case where the Microsoft Store app is not installed
      // or the URL scheme is not recognized.
      if (Platform.isWindows) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Error"),
                content: Text(
                    "Unable to open the App. Would you like to Open Microsoft Store?"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await launchUrl(Uri.parse("ms-windows-store://"));
                    },
                    child: Container(
                      color: Colors.black,
                      padding: const EdgeInsets.all(14),
                      child: const Text(
                        "okay",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
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
      } else {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Error"),
                content: Text(
                    "Unable to open the App. Would you like to Open Play Store?"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await launchUrl(Uri.parse("ms-windows-store://"));
                    },
                    child: Container(
                      color: Colors.black,
                      padding: const EdgeInsets.all(14),
                      child: const Text(
                        "okay",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
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
      print('Unable to open the Microsoft Store.');
    }
  }

  Future<void> _showPdfDialog(BuildContext context, String pdfUrl) async {
    var pdfDocument = await pdfview.PDFDocument.fromURL(pdfUrl);
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      pageBuilder: (BuildContext context, _, __) {
        return Scaffold(
          appBar: AppBar(
            // titleSpacing: width * 0.04,
            leading: KioskBackButton(),
            // leadingWidth: width * 0.04,
            // toolbarOpacity: 0.1,
            title: Padding(
              padding: EdgeInsets.only(
                  bottom: 0.003 * MediaQuery.of(context).size.width),
              child: Text(
                widget.title,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.height / 44,
                    fontWeight: FontWeight.w600),
              ),
            ),
            toolbarHeight: MediaQuery.of(context).size.height * 0.06,
            backgroundColor: Colors.white.withOpacity(0.85),
            //Color(0xff7E869D),
          ),
          body: Stack(
            children: [
              pdfview.PDFViewer(
                document: pdfDocument,
                scrollDirection: Axis.vertical,
                lazyLoad: true,
                enableSwipeNavigation: true,
              ),
              // Positioned(
              //   top: MediaQuery.of(context).size.width * 2 / 100,
              //   left: MediaQuery.of(context).size.width * 2 / 100,
              //   child: KioskBackButton(),
              // ),
            ],
          ),
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPortrait = size.width < size.height;
    final isSmallScreen = size.shortestSide <= 600;
    final buttonTextFontSize = isSmallScreen ? 12.0 : 16.0;
    final titleFontSize = isSmallScreen ? 16.0 : 20.0;
    final iconSize = isSmallScreen ? 24.0 : 32.0;

    return GestureDetector(
      onTap: () async {
        context
            .read<DigitalSignageBloc>()
            .add(ResetScreenSaverTimer(logout: false));
        if (Platform.isWindows) {
          if (widget.itemType == "app")
            openApp(widget.link);
          else if (widget.itemType == "pdf") {
            await _controller.resume();
            await _controller.loadUrl(widget.link + "#view=fitH");
            context.read<DigitalSignageBloc>().state.isWebviewOpen = true;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return KioskScaffold(
                      body: compositeView(), title: widget.title);
                },
              ),
            );
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => Scaffold(
            //       appBar: AppBar(
            //         titleSpacing: size.width * 0.04,
            //         leading: KioskBackButton(),
            //         // leadingWidth: width * 0.04,
            //         // toolbarOpacity: 0.1,
            //         title: Padding(
            //           padding: EdgeInsets.only(bottom: 0.003 * size.width),
            //           child: Text(
            //             widget.title,
            //             style: TextStyle(
            //                 color: Colors.black,
            //                 fontSize: size.height / 44,
            //                 fontWeight: FontWeight.w600),
            //           ),
            //         ),
            //         toolbarHeight: size.height * 0.06,
            //         backgroundColor: Colors.white.withOpacity(0.85),
            //         //Color(0xff7E869D),
            //       ),
            //       body: Stack(
            //         children: [
            //           compositeView(),
            //           // Padding(
            //           //   padding: const EdgeInsets.all(8.0),
            //           //   child: SfPdfViewer.network(
            //           //     widget.link,
            //           //     key: _pdfViewerKey,
            //           //     canShowPaginationDialog: true,
            //           //     pageLayoutMode: PdfPageLayoutMode.single,
            //           //     scrollDirection: PdfScrollDirection.vertical,
            //           //     initialZoomLevel: size.width / size.height,
            //           //   ),
            //           // ),
            //         ],
            //       ),
            //     ),
            //   ),
            // );
          } else {
            await _controller.resume();
            await _controller.loadUrl(widget.link);
            context.read<DigitalSignageBloc>().state.isWebviewOpen = true;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    KioskScaffold(body: compositeView(), title: widget.title),
              ),
            );
          }
        } else {
          print("Widget Link :: ${widget.link}");
          widget.itemType == "pdf"
              ? Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return PdfViewerScreen(
                          pdfUrl: widget.link, pdfTitle: widget.title);
                    },
                  ),
                )
              : widget.itemType == "link"
                  ? Navigator.of(context).push(
                      PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (BuildContext context, _, __) {
                          return KioskScaffold(
                              body: CustomInAppWebView(url: widget.link,) ,
                              // InAppWebView(
                              //   initialUrlRequest: URLRequest(
                              //     url: Uri.parse(widget.link),
                              //   ),
                              // ),
                              title: widget.title);
                        },
                      ),
                    )
                  : openApp(widget.link);
        }
      },
      child: Container(
        padding: EdgeInsets.all(isPortrait ? 8 : 16),
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.15),
              offset: Offset(0, 4),
              blurRadius: 15,
              spreadRadius: 5,
            ),
          ],
          color: widget.color.withOpacity(0.6),
          // Color.fromRGBO(22, 204, 130, 1),
          borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 30),
        ),
        height: isSmallScreen ? size.height * 0.25 : size.height * 0.3,
        width: isPortrait ? size.width * 0.1 : size.width * 0.15,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Positioned(
                //   top: constraints.maxHeight * 0.3,
                //   left: 16,
                //   right: 16,
                //   child:
                Container(
                  child: Center(
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: widget.textColor,
                          fontSize: size.height / 60,
                          // titleFontSize,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none),
                    ),
                  ),
                ),
                // ),
                // Positioned(
                //   top: constraints.maxHeight * 0.6,
                //   left: 16,
                //   right: 16,
                //   child:
                Container(
                  height: size.width < 400
                      ? constraints.maxHeight * 0.3
                      : constraints.maxHeight * 0.35,
                  width: constraints.maxWidth * 0.35,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.8),
                    // Color(0xff7E869D).withOpacity(0.7),

                    // Color.fromRGBO(0, 0, 0, 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isPortrait
                        ? constraints.maxWidth * 0.06
                        : constraints.maxWidth * 0.05),
                    child: SvgPicture.asset(
                      "assets/88.svg",
                      color: widget.textColor,
                    ),
                  ),
                ),
                // ),
              ],
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
