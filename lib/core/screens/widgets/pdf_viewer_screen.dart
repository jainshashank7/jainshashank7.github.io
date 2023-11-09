import 'package:advance_pdf_viewer2/advance_pdf_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobex_kiosk/core/blocs/digital_signage_bloc/digital_signage_bloc.dart';
import 'package:mobex_kiosk/core/blocs/digital_signage_bloc/digital_signage_state.dart';
import 'package:mobex_kiosk/core/screens/loading_screen/loading_screen.dart';
import 'package:mobex_kiosk/core/screens/screen_saver_app.dart';
import 'kiosk_back_button.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl; // The URL of the PDF to load
  final String pdfTitle;

  PdfViewerScreen({required this.pdfUrl, required this.pdfTitle});

  @override
  _PdfViewerScreenState createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  PDFDocument? pdfDocument;
  bool isPdfLoading = true;

  @override
  void initState() {
    super.initState();
    loadPdf(widget.pdfUrl);
  }

  Future<void> loadPdf(String pdfUrl) async {
    pdfDocument = await PDFDocument.fromURL(pdfUrl + "#view=fitH");
    setState(() {
      isPdfLoading = false;
    });
  }

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
                  // leadingWidth: width * 0.04,
                  // toolbarOpacity: 0.1,
                  title: Padding(
                    padding: EdgeInsets.only(
                        bottom: 0.003 * MediaQuery.of(context).size.width),
                    child: Text(
                      widget.pdfTitle,
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
                body: isPdfLoading
                    ? LoadingScreen() // Loading screen
                    : PDFViewer(
                        document: pdfDocument!,
                        scrollDirection: Axis.vertical,
                        lazyLoad: true,
                        enableSwipeNavigation: true), // PDF viewer
              );
      },
    );
  }
}
