import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/digital_signage_bloc/digital_signage_bloc.dart';
import '../../blocs/digital_signage_bloc/digital_signage_state.dart';
import '../screen_saver_app.dart';
import 'kiosk_back_button.dart';

class KioskScaffold extends StatefulWidget {
  const KioskScaffold({super.key, required this.body, required this.title});

  final String title;
  final Widget body;

  @override
  State<KioskScaffold> createState() => _KioskScaffoldState();
}

class _KioskScaffoldState extends State<KioskScaffold> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DigitalSignageBloc, DigitalSignageState>(
      builder: (context, state) {
        return state.showScreensaver
            ? ScreensaverContent(
                imagesUrls: state.imagesUrls,
                screenTimeout: state.screenTimeout,
                imageDuration: state.imageDuration)
            : Scaffold(
                appBar: AppBar(
                  titleSpacing: MediaQuery.of(context).size.width * 0.04,
                  leading: KioskBackButton(),
                  title: Padding(
                    padding: EdgeInsets.only(
                        bottom: 0.003 * MediaQuery.of(context).size.width),
                    child: Text(
                      widget.title,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? MediaQuery.of(context).size.height / 44
                              : MediaQuery.of(context).size.width / 44,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  toolbarHeight:
                      MediaQuery.of(context).orientation == Orientation.portrait
                          ? MediaQuery.of(context).size.height * 0.06
                          : MediaQuery.of(context).size.width * 0.04,
                  backgroundColor: Colors.white.withOpacity(0.85),
                  //Color(0xff7E869D),
                ),
                body: widget.body,
              );
      },
    );
  }
}
