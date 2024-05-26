import 'package:flutter/material.dart';
import 'package:simansam/Pages/OnAppStart/sign_up_page.dart';
import 'package:simansam/Pages/OnAppStart/welcome_page.dart';
import 'package:webview_flutter/webview_flutter.dart';

class UserGuidePage extends StatefulWidget {
  @override
  _UserGuidePageState createState() => _UserGuidePageState();
}

class _UserGuidePageState extends State<UserGuidePage> {
  final _key = UniqueKey();
  bool isLoading = true;
  String siteLink =
      "https://sites.google.com/view/simansam-panduan-pengguna/halaman-muka";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          print("tes");
          return Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => WelcomePage()),
                (Route<dynamic> route) => false,
          );
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded,
                  color: Theme.of(context).iconTheme.color),
              onPressed: () {
                print("Kembali ke Halaman Selamat Datang");
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomePage()),
                      (Route<dynamic> route) => false,
                );
              },
            ),
            title: Text(
              "Panduan Pengguna",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            elevation: Theme.of(context).appBarTheme.elevation,
            actions: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                child: TextButton(
                  child: Text(
                    "Lanjutkan ke Pendaftaran",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                          (Route<dynamic> route) => false,
                    );
                    print("Beralih ke Pendaftaran");
                  },
                ),
              )
            ],
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
        ));
  }
}
