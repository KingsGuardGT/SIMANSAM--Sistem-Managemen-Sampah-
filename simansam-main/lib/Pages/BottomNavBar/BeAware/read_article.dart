import 'dart:io';

import 'package:flutter/material.dart';
import 'package:simansam/Theme/theme_provider.dart';
import 'package:simansam/Widgets/secondary_app_bar_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ReadArticle extends StatefulWidget {
  final String articleLink;

  ReadArticle(this.articleLink);

  @override
  _ReadArticleState createState() => _ReadArticleState();
}

class _ReadArticleState extends State<ReadArticle> {
  final _key = UniqueKey();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SecondaryAppBar(
        title: "Artikel dari Website",
        appBar: AppBar(),
        widgets: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
            child: Icon(
              Icons.notifications_rounded,
              color: AppThemeData().secondaryColor,
              size: 35.0,
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            WebView(
              key: _key,
              initialUrl: widget.articleLink,
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
