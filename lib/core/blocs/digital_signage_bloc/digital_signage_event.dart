// part of 'digital_signage_bloc.dart';

import 'package:equatable/equatable.dart';

abstract class DigitalSignageEvent extends Equatable{}

class EnableScreenSaverTimer extends DigitalSignageEvent{
  @override
  List<Object?> get props => [];
}

class ResetScreenSaverTimer extends DigitalSignageEvent{
  bool logout;

  ResetScreenSaverTimer({required this.logout});

  @override
  List<Object?> get props => [];
}

class ShowScreenSaver extends DigitalSignageEvent{
  List<Object?> get props => [];
}

class StopScreenSaverTimer extends DigitalSignageEvent{
  List<Object?> get props => [];
}

class AddDigitalSignageData extends DigitalSignageEvent{
  // final List<dynamic> digitalSignageData;
  // final int screenTimeout;
  // final int imageDuration;
  // AddDigitalSignageData({required this.digitalSignageData,required this.screenTimeout,required this.imageDuration});
  @override
  List<Object?> get props => [];
}