import 'dart:async';

import 'package:equatable/equatable.dart';

// part of 'digital_signage_bloc.dart';

class DigitalSignageState extends Equatable {
  DigitalSignageState(
      {
      // required this.timer,
      required this.showScreensaver,
      required this.screenTimeout,
      required this.imagesUrls,
      required this.imageDuration,
      required this.stateUpdate,
      required this.isWebviewOpen});

  // final Timer timer;
  final bool showScreensaver;
  final int screenTimeout;
  final List<dynamic> imagesUrls;
  final int imageDuration;
  final int stateUpdate;
  bool isWebviewOpen = false;

  factory DigitalSignageState.initial() {
    return DigitalSignageState(
        showScreensaver: false,
        screenTimeout: 20,
        imagesUrls: [],
        imageDuration: 10,
        stateUpdate: 0,
        isWebviewOpen: false);
  }

  DigitalSignageState copyWith(
      {bool? showScreenSaver,
      int? screenTimeout,
      List<dynamic>? imagesUrls,
      int? imageDuration,
      int? stateUpdate,
      bool? isWebViewOpen}) {
    return DigitalSignageState(
        // timer: timer ?? this.timer,
        showScreensaver: showScreenSaver ?? showScreensaver,
        screenTimeout: screenTimeout ?? this.screenTimeout,
        imagesUrls: imagesUrls ?? this.imagesUrls,
        imageDuration: imageDuration ?? this.imageDuration,
        stateUpdate: stateUpdate ?? this.stateUpdate,
        isWebviewOpen: isWebViewOpen ?? this.isWebviewOpen);
  }

  @override
  // TODO: implement props
  List<Object?> get props =>
      [showScreensaver, screenTimeout, imagesUrls, imageDuration, stateUpdate];

  @override
  String toString() {
    return ''' showScreenSaver:$showScreensaver, 
               screenTimeout:$screenTimeout,
               imagesUrls:$imagesUrls,
               imageDuration:$imageDuration,
               stateUpdate:$stateUpdate''';
  }
}
