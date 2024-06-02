import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class SettingsUserGuide extends StatefulWidget {
  @override
  _SettingsUserGuideState createState() => _SettingsUserGuideState();
}

class _SettingsUserGuideState extends State<SettingsUserGuide> {
  late final key; // corrected: use 'late' keyword instead of 'final'
  bool isLoading = true;
  String siteLink =
      "https://sites.google.com/view/simansam-user-guide";

  @override
  void initState() {
    super.initState();
    key = UniqueKey(); // corrected: initialize 'key' in 'initState'
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: Theme.of(context).iconTheme.color),
          onPressed: () {
            print("Pergi ke Welcome Page");
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Panduan Pengguna",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        elevation: Theme.of(context).appBarTheme.elevation,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              key: Key(key.toString()), // corrected: use 'Key' widget
              initialUrlRequest: URLRequest(url: Uri.parse(siteLink)), // corrected: use 'URLRequest'
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true, // corrected: use 'InAppWebViewOptions'
                ),
              ),
              onLoadStop: (controller, url) {
                setState(() {
                  isLoading = false;
                });
              },
            ),
            isLoading
                ? Center(
              child: CircularProgressIndicator(),
            )
                : Stack(),
          ],
        ),
      ),
    );
  }
}