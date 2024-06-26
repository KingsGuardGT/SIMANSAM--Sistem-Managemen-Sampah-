import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SettingsUserGuide extends StatefulWidget {
  @override
  _SettingsUserGuideState createState() => _SettingsUserGuideState();
}

class _SettingsUserGuideState extends State<SettingsUserGuide> {
  final _key = UniqueKey();
  bool isLoading = true;
  String siteLink =
      "https://sites.google.com/view/simansam-user-guide";

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
            WebView(
              key: _key,
              initialUrl: siteLink,
              javascriptMode: JavascriptMode.unrestricted,
              onPageFinished: (finish) {
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