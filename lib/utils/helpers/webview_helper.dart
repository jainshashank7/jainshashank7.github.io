import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/screens/widgets/custom_screen_util.dart';

class WebViewHelper extends StatefulWidget {
  const WebViewHelper({super.key, required this.link});

  final String link;

  @override
  State<WebViewHelper> createState() => _WebViewHelperState();
}

class _WebViewHelperState extends State<WebViewHelper> {
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
      return Padding(
        padding: EdgeInsets.all(20),
        child: Column(
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
                            return LinearProgressIndicator();
                          } else {
                            return SizedBox();
                          }
                        }),
                  ],
                ),
              ),
            ),
          ],
        ),
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
      if(Platform.isWindows){
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
      }
      else{
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
      print('Unable to open the Application.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          compositeView(),
          Positioned(
            top: 0,
            right: 20,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.cancel,
                  color: Colors.red,
                  size:
                  CustomScreenUtil.screenHeight *
                      0.03),
            ),
          ),
        ],
      ),
    );
  }
}
