import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobex_kiosk/core/screens/loading_screen/loading_screen.dart';
import 'package:mobex_kiosk/core/screens/signin_screen.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

import '../blocs/digital_signage_bloc/digital_signage_bloc.dart';
import '../blocs/digital_signage_bloc/digital_signage_event.dart';
import '../blocs/digital_signage_bloc/digital_signage_state.dart';
import 'kiosk_dashboard.dart';

class ScreensaverApp extends StatefulWidget {
  @override
  _ScreensaverAppState createState() => _ScreensaverAppState();
}

class _ScreensaverAppState extends State<ScreensaverApp> {
  late Timer _timer;
  bool _showScreensaver = false;

  @override
  void initState() {
    super.initState();
    // Start the timer when the app starts
    BlocProvider.of<DigitalSignageBloc>(context).add(EnableScreenSaverTimer());
    // _startTimer();
  }

  void _startTimer() {
    _timer = Timer(Duration(seconds: 10000), () {
      setState(() {
        _showScreensaver = true;
      });
    });
  }

  void _resetTimer() {
    _timer.cancel();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DigitalSignageBloc, DigitalSignageState>(
      builder: (context, state) {
        print("ShowScreenSaver ::: ${state.showScreensaver}");
        return GestureDetector(
          // Detect user interaction and reset the timer
          onTap: () {
            print("Inside ScreenSaverState");
            print("Resetting Timer");
            BlocProvider.of<DigitalSignageBloc>(context)
                .add(ResetScreenSaverTimer(logout: false));
          },
          child: Scaffold(
            body: AnimatedSwitcher(
              switchInCurve: Curves.easeInCubic,
              duration: Duration(milliseconds: 500),
              child: state.showScreensaver
                  ? ScreensaverContent(
                      imagesUrls: state.imagesUrls,
                      screenTimeout: state.screenTimeout,
                      imageDuration: state.imageDuration,
                    )
                  : KioskDashboard(
                      refreshData: false,
                    ),
            ),
          ),
        );
      },
    );
  }
}

class MainContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return KioskDashboard(
      refreshData: false,
    );
    // Center(
    // child: Text('Main App Content'),
    // );
  }
}

class ScreensaverContent extends StatefulWidget {
  ScreensaverContent(
      {super.key,
      required this.imagesUrls,
      required this.screenTimeout,
      required this.imageDuration});

  List<dynamic>? imagesUrls;
  int screenTimeout;
  int imageDuration;

  @override
  State<ScreensaverContent> createState() => _ScreensaverContentState();
}

class _ScreensaverContentState extends State<ScreensaverContent> {
  late VideoPlayerController _videoController;

  // List<Map<String, String>> images = [
  //   // {"image": 'assets/images/Countdown4.mp4', "duration": "11"},
  //   {"image": 'assets/back_ground.png', "duration": "5"},
  //   {"image": 'assets/images/giphy.gif', "duration": "5"},
  //   {"image": 'assets/images/giphy1.gif', "duration": "5"},
  //   {"image": 'assets/background1.jpg', "duration": "5"},
  //   {"image": 'assets/background2.jpg', "duration": "5"},
  //
  //   // 'images/back_ground.png',
  //   // 'images/images/giphy.gif',
  //   // 'images/images/giphy1.gif',
  //   // 'images/background.jpeg',
  //   // 'images/background1.jpg',
  //   // 'images/background2.jpg',
  //   // Add more image paths here
  // ];

  // Index to track the current image being displayed
  int currentIndex = 0;

  // Create a timer that triggers after 5 minutes of inactivity
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Wakelock.enable();
    // Initialize the video controller
    if (Platform.isAndroid) {
      // _videoController =
      //     VideoPlayerController.asset(images[currentIndex]['image']!)
      //       ..initialize().then((_) {
      //         _videoController.setLooping(true);
      //         _videoController.play();
      //       });
    }

    // Start the timer when the screen is initialized
    _startTimer();
  }

  // Function to start the 5-minute timer
  void _startTimer() {
    print("Duration :${widget.imageDuration}");
    _timer = Timer(Duration(seconds: widget.imageDuration), () {
      // When the timer triggers, update the UI to display the next image
      setState(() {
        if (widget.imagesUrls![currentIndex].endsWith('.mp4')) {
          print("Videooooo");
          // if (Platform.isAndroid) {
          //   _videoController.pause();
          // }
        }
        currentIndex = (currentIndex + 1) % widget.imagesUrls!.length;
        if (Platform.isAndroid &&
            widget.imagesUrls![currentIndex].endsWith('.mp4')) {
          _videoController =
              VideoPlayerController.asset(widget.imagesUrls![currentIndex])
                ..initialize().then((_) {
                  _videoController.setLooping(true);
                  _videoController.play();
                });
        }
      });

      // Restart the timer for the next 5 minutes
      _startTimer();
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the screen is disposed
    _timer.cancel();
    if (Platform.isAndroid) {
      // _videoController.dispose();
    }
    // Wakelock.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () async {
          print("Clicking on Screen Saver Content");
          if (widget.imagesUrls![currentIndex].endsWith('.mp4')) {
            _videoController.pause();
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UnlockVerifiedUser(
                refreshData: false,
              ),
            ),
          );
          BlocProvider.of<DigitalSignageBloc>(context)
              .add(ResetScreenSaverTimer(logout: false));
        },
        child: CachedNetworkImage(
          imageUrl: widget.imagesUrls![currentIndex],
          fit: BoxFit.fill,
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          // placeholderFadeInDuration: Duration(seconds: 2),
          placeholder: (context, url) => LoadingScreen(),
        ),
      ),
    );
  }
}
