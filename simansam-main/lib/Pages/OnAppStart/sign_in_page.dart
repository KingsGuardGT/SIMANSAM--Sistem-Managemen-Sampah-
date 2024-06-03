import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simansam/Pages/BottomNavBar/bottom_nav_bar.dart';
import 'package:simansam/Pages/OnAppStart/welcome_page.dart';

import '../../Theme/theme_provider.dart';
import '../../Widgets/button_widgets.dart';
import '../../Widgets/toast_messages.dart';
import 'user_guide.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  ToastMessages _toastMessages = new ToastMessages();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isHidden = true;
  bool isUserSigned = false;
  bool isInValidaAccount = false;
  late double circularProgressVal;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late String accountType;

  void _togglePasswordView() {
    setState(() {
      _isHidden = _isHidden;
    });
  }

  showAlertDialog(BuildContext context) {
    // tampilkan dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: isUserSigned
                  ? Center(child: Text("Masuk"))
                  : Center(child: Text("Selamat Datang Kembali")),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isUserSigned)
                    !isInValidaAccount
                        ? Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 30.0,
                        ),
                        CircularProgressIndicator(
                          value: circularProgressVal,
                          strokeWidth: 6,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppThemeData().primaryColor),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        Text("Masuk ke akun anda...",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16.0)
                                .copyWith(color: Colors.grey.shade900)),
                      ],
                    )
                        : Container(
                        child: Column(
                          children: [
                            Text("Error!",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                )),
                            SizedBox(
                              height: 50.0,
                            ),
                            new ButtonWidget(
                                text: "Coba Lagi",
                                color: AppThemeData().redColor,
                                textColor: AppThemeData().whiteColor,
                                onClicked: () {
                                  setState(() {
                                    isUserSigned = false;
                                    isInValidaAccount = false;
                                    Navigator.pop(context);
                                  });
                                }, ),
                          ],
                        ))
                  else
                    Container(
                        child: Column(
                          children: [
                            Text("Selamat Datang!",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                )),
                            SizedBox(
                              height: 50.0,
                            ),
                            Image.asset(
                              'assets/images/welcome.png',
                              height: 100,
                              width: 100,
                            ),
                            SizedBox(
                              height: 50.0,
                            ),
                            new ButtonWidget(
                                text: "Lanjutkan",
                                textColor: AppThemeData().whiteColor,
                                color: AppThemeData().primaryColor,
                                onClicked: () {
                                  Navigator.pop(context);
                                }, key: null,),
                          ],
                        )),
                ],
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
            );
          },
        );
      },
    );
  }

  void ifAnError() {
    Navigator.pop(context);
    setState(() {
      isUserSigned = false;
      isInValidaAccount = true;
      //Navigator.pop(context);
      showAlertDialog(context);
    });
  }

  bool validateUser() {
    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regExp = RegExp(pattern);

    if (emailController.text.isEmpty && passwordController.text.isEmpty) {
      _toastMessages.toastInfo('Harap isi detail', context);
    } else if (emailController.text.isEmpty) {
      _toastMessages.toastInfo('Email kosong', context);
    } else if (!regExp.hasMatch(emailController.text)) {
      _toastMessages.toastInfo('Polanya email salah', context);
    } else if (passwordController.text.isEmpty) {
      _toastMessages.toastInfo('Password kosong', context);
    } else {
      print('Validasi Berhasil!');
      return true;
    }

    return false;
  }

  geAccountType(String userID) async {
    print("----------------------- CEK TIPE AKUN -----------------------");
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userID)
        .get()
        .then((value) {
      if (value.exists && value.data() != null) {
        // Periksa jika dokumen ada dan data tidak null
        accountType = value.data()!['accountType'] ?? 'default';
        // Gunakan operator null-aware '??' untuk memberikan nilai default jika accountType null
      } else {
        print('Dokumen tidak ada atau tidak memiliki data');
        accountType = 'default'; // Tetapkan nilai default jika dokumen tidak ada atau tidak memiliki data
      }
    });
  }

  void _signInWithEmailAndPassword() async {
    showAlertDialog(context);

    setState(() {
      isUserSigned = false;
      isInValidaAccount = false;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      print(userCredential.user?.uid.toString());
      await geAccountType(userCredential.user!.uid.toString());
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => BottomNavBar(accountType),
        ),
            (route) => false,
      );
      //Navigator.pop(context);
      print('Pengguna masuk!');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ifAnError();
        print('Tidak ada pengguna ditemukan untuk email tersebut.');
        _toastMessages.toastError("Tidak ada pengguna ditemukan untuk email tersebut", context);
      } else if (e.code == 'wrong-password') {
        ifAnError();
        print('Kata sandi yang salah.');
        _toastMessages.toastError("Kata sandi salah!", context);
      } else {
        _toastMessages.toastError("Ada Kesalahan.", context);
        _toastMessages.toastError(e.toString(), context);
        print(e.toString());
      }
    }
  }

  Future<void> firebaseSignIn() async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      _toastMessages.toastSuccess("Masuk", context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _toastMessages.toastError("Tidak ada pengguna ditemukan untuk email tersebut.", context);
      } else if (e.code == 'wrong-password') {
        _toastMessages.toastError(
            "Kata sandi yang salah diberikan untuk pengguna tersebut.", context);
      } else {
        _toastMessages.toastError("Ada Kesalahan.", context);
        _toastMessages.toastError(e.toString(), context);
        print(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          print("test");
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => WelcomePage()),
                (Route<dynamic> route) => false,
          );
          return true; // Add this line
        },
        child: Scaffold(
            backgroundColor: AppThemeData().greenAccentColor,
            body: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Container(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                                icon: Icon(Icons.arrow_back_ios_rounded),
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => WelcomePage()),
                                        (Route<dynamic> route) => false,
                                  );
                                })),
                        SizedBox(height: 20),
                        Image.asset(
                          'assets/logos/trashpick_logo_banner.png',
                          height: 200,
                          width: 200,
                        ),
                        SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.all(10),
                          height: 70.0,
                          child: TextFormField(
                            controller: emailController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              prefixIcon: Icon(Icons.email_outlined),
                              border: OutlineInputBorder(),
                              labelText: 'Email',
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          height: 70.0,
                          child: TextFormField(
                            obscureText: _isHidden,
                            controller: passwordController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Kata Sandi',
                              prefixIcon: Icon(Icons.lock_outline_rounded),
                              suffix: InkWell(
                                onTap: _togglePasswordView,
                                child: Icon(
                                  _isHidden
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ).copyWith(isDense: true),
                          ),
                        ),
                        SizedBox(height: 20),
                        new ButtonWidget(
                          textColor: AppThemeData().whiteColor,
                          color: AppThemeData().secondaryColor,
                          text: "Masuk",
                          onClicked: () {
                            if (validateUser()) {
                              _signInWithEmailAndPassword();
                              print("Masuk");
                            } else {
                              _toastMessages.toastInfo(
                                  'Coba lagi dengan detail yang benar!', context);
                            }
                          }, key: null,
                        ),
                        SizedBox(height: 20),
/*                    new TextButtonWidget(
                        onClicked: () {
*/ /*                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ForgotPassword()),
                                  (Route<dynamic> route) => false,
                            );*/ /*
                          print("Switch to Forgot Password!");
                        },
                        text: "Forgot Password?"),*/
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("Baru di SIMANSAM?",
                                  style: TextStyle(
                                    fontSize:
                                    Theme.of(context).textTheme.labelLarge?.fontSize,
                                    fontWeight: FontWeight.bold,
                                  )),
                              SizedBox(width: 10),
                              new RadiusFlatButtonWidget(
                                text: "Daftar",
                                onClicked: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => UserGuidePage()),
                                        (Route<dynamic> route) => false,
                                  );
                                  print("Beralih ke Pendaftaran");
                                }, key: null,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ))));
  }
}