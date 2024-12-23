import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:salescheck/Service/ApiTransaksi.dart';
import 'package:salescheck/component/customButtonPrimary.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:salescheck/component/notifSucces.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webcontent_converter/webcontent_converter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:http/http.dart' as http;

class Viewstruck extends StatefulWidget {
  final int idTransaksi;
  const Viewstruck({super.key, required this.idTransaksi});

  @override
  State<Viewstruck> createState() => _ViewstruckState();
}

class _ViewstruckState extends State<Viewstruck> {
  final Apitransaksi _apitransaksi = new Apitransaksi();
  String? html;
  late Future<void> _loadDataFuture;
  late final WebViewController _controller;
  double? progres;
  Future<void> _readPrintStruck() async {
    html = await _apitransaksi.getTransaksiStruck(widget.idTransaksi);
    setState(() {
      html;
    });
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(html ?? ''));
  }

  Future<void> downloadFile(String url, String fileName) async {
    try {
      // Get the root directory path
      final Directory rootDir = Directory('/storage/emulated/0/Download');

      final String downloadsPath = '${rootDir.path}/Sirqu';

      // Buat direktori download jika belum ada
      final Directory downloadsDir = Directory(downloadsPath);
      await downloadsDir.create(recursive: true);

      // Set the destination file path
      final File file = File('$downloadsPath/$fileName.jpg');

      // Use webcontent_converter to download the file
      final Uint8List bytes = await WebcontentConverter.webUriToImage(
        uri: url,
      );

      // Simpan file ke direktori download
      await file.writeAsBytes(bytes);

      debugPrint('File downloaded successfully to ${file.path}');
      Notifsucces.showNotif(
          context: context, description: 'Letak Struk ${file.path}');
    } catch (e) {
      debugPrint('Error downloading file: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadDataFuture = _readPrintStruck();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8FA),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Struck',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Color(0xFF121212)),
        ),
      ),
      body: SafeArea(
          minimum: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                      child: customButtonPrimary(
                          height: 48,
                          alignment: Alignment.center,
                          onPressed: () async {
                            final bytes =
                                await WebcontentConverter.webUriToImage(
                              uri: html ?? '',
                              args: {
                                'headers': {
                                  'ngrok-skip-browser-warning': 69420,
                                },
                              },
                            );
                            final temp = await getTemporaryDirectory();
                            final path = "${temp.path}/index.jpg";
                            File(path).writeAsBytesSync(bytes);
                            await Share.shareXFiles([XFile(path)]);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset('asset/viewStruck/share.svg'),
                              const SizedBox(
                                width: 10,
                              ),
                              const Text(
                                'Bagikan',
                                style: TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              )
                            ],
                          ))),
                  const SizedBox(
                    width: 12,
                  ),
                  Flexible(
                      child: customButtonPrimary(
                          height: 48,
                          alignment: Alignment.center,
                          onPressed: () async {
                            // print('$html/download');
                            // FileDownloader.downloadFile(
                            //     url: '$html',
                            //     notificationType: NotificationType.progressOnly,
                            //     onProgress: (fileName, progress) {
                            //       print('FILE fileName HAS PROGRESS $progress');
                            //       setState(() {
                            //         progres = progress;
                            //       });
                            //     },
                            //     onDownloadCompleted: (String path) {
                            //       print('FILE DOWNLOADED TO PATH: $path');
                            //       Notifsucces.showNotif(
                            //           context: context,
                            //           description: 'Download Struck Sukses');
                            //       setState(() {
                            //         progres = null;
                            //       });
                            //     },
                            //     onDownloadError: (String error) {
                            //       print('DOWNLOAD ERROR: $error');
                            //     });
                            await downloadFile(
                                html ?? '', widget.idTransaksi.toString());
                          },
                          child: progres == null
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                        'asset/viewStruck/import.svg'),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    const Text(
                                      'Download',
                                      style: TextStyle(
                                          color: Color(0xFFFFFFFF),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    )
                                  ],
                                )
                              : Text(
                                  '$progres %',
                                  style: const TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                )))
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Expanded(
                child: FutureBuilder(
                  future: _loadDataFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else {
                      return Container(
                        width: double.infinity,
                        child: WebViewWidget(controller: _controller),
                      );
                    }
                  },
                ),
              )
            ],
          )),
    );
  }
}
