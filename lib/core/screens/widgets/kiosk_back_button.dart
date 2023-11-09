import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import '../../blocs/digital_signage_bloc/digital_signage_bloc.dart';
import '../../blocs/digital_signage_bloc/digital_signage_event.dart';

class KioskBackButton extends StatelessWidget {
  const KioskBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<DigitalSignageBloc>().state.isWebviewOpen = false;
        context.read<DigitalSignageBloc>().add(ResetScreenSaverTimer(logout: false));
        Navigator.pop(context);
      },
      child: LayoutBuilder(builder: (context, constraints) {
        return Container(
          margin: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * 0.03,
            // right: MediaQuery.of(context).size.width * 0.05,
          ),
          // color: Color(0xff7E869D),
          // padding: EdgeInsets.all(10),
          child: Icon(
            Icons.arrow_back_ios,
            size: MediaQuery.of(context).orientation == Orientation. landscape ? MediaQuery.of(context).size.height * 0.06 : MediaQuery.of(context).size.width * 0.06,
            color: Colors.black,
          ),
        );
      }),
    );
  }
}
