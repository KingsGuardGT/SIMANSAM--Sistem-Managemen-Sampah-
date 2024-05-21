import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simansam/Pages/OnAppStart/welcome_page.dart';
import 'package:simansam/Widgets/toast_messages.dart';

class SignOutAlertDialog {
  void showAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Logout'),
          content: Text("Apakah Anda Yakin Ingin Logout ?"),
          actions: <Widget>[
            TextButton(
              child: Text(
                "TIDAK",
                style: Theme.of(context).textTheme.labelLarge,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                print("Batal Logout");
              },
            ),
            TextButton(
              child: Text(
                "YA",
                style: Theme.of(context).textTheme.labelLarge,
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                ToastMessages().toastSuccess("Logout Berhasil", context);
                print("Logout Berhasil");
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => WelcomePage(),
                  ),
                      (route) => false,
                );
              },
            ),
          ],
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
        );
      },
    );
  }
}
