import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:simansam/Pages/OnAppStart/sign_in_page.dart';
import 'package:simansam/Pages/OnAppStart/user_guide.dart';
import 'package:simansam/Pages/OnAppStart/welcome_guide_page.dart';

import '../../Theme/theme_provider.dart';
import '../../Widgets/button_widgets.dart';
import '../../Widgets/toast_messages.dart';

class SignUpPage extends StatefulWidget {
/*  SignUpPage({Key key, this.title}) : super(key: key);
  final String title;*/
  SignUpPage({required this.app});

  final FirebaseApp app;

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  ToastMessages _toastMessages = new ToastMessages();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController homeAddressController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  String defaultUserAvatar =
      "https://firebasestorage.googleapis.com/v0/b/trashpick-db.appspot.com/o/Default%20User%20Avatar%2Fsimansam_user_avatar.png?alt=media&token=734f7e74-2c98-4c27-b982-3ecd072ced79";

  bool _isHidden = true;
  bool _isHiddenC = true;

  late double circularProgressVal;
  bool isUserCreated = false;
  bool isAnError = false;

  String formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  String formattedTime = DateFormat('kk:mm:a').format(DateTime.now());

  String accountTypeName = "Pengumpul Sampah";
  late int accountTypeID;

  void _togglePasswordView() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  void _toggleConfirmPasswordView() {
    setState(() {
      _isHiddenC = !_isHiddenC;
    });
  }

  bool validateUser() {
    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regExp = RegExp(pattern);

    if (nameController.text.isEmpty &&
        emailController.text.isEmpty &&
        phoneNumberController.text.isEmpty &&
        homeAddressController.text.isEmpty &&
        passwordController.text.isEmpty &&
        confirmPasswordController.text.isEmpty) {
      _toastMessages.toastInfo('Harap isi detail', context);
    } else if (nameController.text.isEmpty) {
      _toastMessages.toastInfo('Nama kosong', context);
    } else if (emailController.text.isEmpty) {
      _toastMessages.toastInfo('Email kosong', context);
    } else if (!regExp.hasMatch(emailController.text)) {
      _toastMessages.toastInfo('Polanya email salah', context);
    } else if (phoneNumberController.text.isEmpty) {
      _toastMessages.toastInfo('Nomor telepon kosong', context);
    } else if (homeAddressController.text.isEmpty) {
      _toastMessages.toastInfo('Alamat rumah kosong', context);
    } else if (passwordController.text.length < 6) {
      _toastMessages.toastInfo(
          'Password Harus Setidaknya 6 Karakter!', context);
    } else if (passwordController.text.isEmpty) {
      _toastMessages.toastInfo('Password kosong', context);
    } else if (confirmPasswordController.text != passwordController.text) {
      _toastMessages.toastInfo('Konfirmasi password salah', context);
    } else {
      print('Validasi Sukses!');
      return true;
    }

    return false;
  }

  showAlertDialog(BuildContext context) {
    // menampilkan dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: !isUserCreated
                  ? Center(child: Text("Membuat Akun"))
                  : Center(child: Text("Akun Dibuat")),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isUserCreated)
                    !isAnError
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
                        Text(
                            "Hai " +
                                nameController.text +
                                ", Mohon tunggu sampai kami membuat akun Anda!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 16.0)
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
                              textColor: AppThemeData().whiteColor,
                              color: AppThemeData().redColor,
                              onClicked: () {
                                Navigator.pop(context);
                              },
                               // or any other unique value
                            ),
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
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => WelcomeGuidePage(
                                            nameController.text.toString(),
                                            accountTypeName)),
                                    ModalRoute.withName("/WelcomeScreen"));
                              },
                              // or any other unique value
                            ),
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
      isUserCreated = false;
      isAnError = true;
      //Navigator.pop(context);
      showAlertDialog(context);
    });
  }


  void printSignUpData() {
    print("JENIS AKUN: " + "$accountTypeName");
    print("NAMA: " + nameController.text.toString());
    print("EMAIL: " + emailController.text.toString());
    print("NOMOR KONTAK: " + phoneNumberController.text.toString());
    print("ALAMAT RUMAH: " + homeAddressController.text.toString());
    print("KATA SANDI: " + passwordController.text.toString());
    print("KONFIRMASI KATA SANDI: " + confirmPasswordController.text.toString());
  }

  void authenticateUser() async {
    showAlertDialog(context);

    setState(() {
      isUserCreated = false;
      isAnError = false;
    });

    try {
      await firebaseAuth.createUserWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);

      if (FirebaseAuth.instance.currentUser?.uid != null) {
        print('Akun Pengguna Terotentikasi!');

        User? user = FirebaseAuth.instance.currentUser;

        if (!user!.emailVerified) {
          await user.sendEmailVerification();
          print('Email Verifikasi Dikirim!');
        }
        try {
          FirebaseFirestore.instance
              .collection("Users")
              .doc(FirebaseAuth.instance.currentUser?.uid.toString())
              .set({
            "uuid": FirebaseAuth.instance.currentUser?.uid.toString(),
            "accountType": "$accountTypeName",
            "name": nameController.text,
            "email": emailController.text,
            "contactNumber": phoneNumberController.text,
            "homeAddress": homeAddressController.text,
            'password': passwordController.text,
            'appearedLocation': new GeoPoint(7.8731, 80.7718),
            'lastAppeared': "Tidak Ditetapkan",
            'accountCreated': "$formattedDate, $formattedTime",
            'profileImage': "$defaultUserAvatar",
          }).then((value) {
            print("Pengguna Ditambahkan ke Firestore dengan Sukses");
            Navigator.pop(context);
            setState(() {
              isUserCreated = true;
              isAnError = false;
              showAlertDialog(context);
            });
          });
        } catch (e) {
          print("Gagal Menambahkan Pengguna ke Firestore!: $e");
          ifAnError();
        }
      } else {
        print('Gagal Mengotentikasi Akun Pengguna!');
        ifAnError();
      }
    } catch (e) {
      print(e.toString());
      if (e.toString() ==
          "[firebase_auth/email-already-in-use] Alamat email sudah digunakan oleh akun lain.") {
        ifAnError();
        new ToastMessages().toastError(
            "Alamat email sudah digunakan oleh akun lain", context);
      } else {
        ifAnError();
        print(e.toString());
      }
    }
  }

  radioButtonList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Pilih Jenis Akun",
          style: TextStyle(
              fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Radio(
              value: 1,
              groupValue: accountTypeID,
              onChanged: (val) {
                setState(() {
                  accountTypeName = 'Pengumpul Sampah';
                  accountTypeID = 1;
                });
              },
            ),
            Text(
              'Pengumpul Sampah',
              style: new TextStyle(fontSize: 17.0),
            ),
            Radio(
              value: 2,
              groupValue: accountTypeID,
              onChanged: (val) {
                setState(() {
                  accountTypeName = 'ADMIN Dinas Lingkungan Hidup';
                  accountTypeID = 2;
                });
              },
            ),
            Text(
              'Admin',
              style: new TextStyle(
                fontSize: 17.0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print("test");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => UserGuidePage()),
              (Route<dynamic> route) => false,
        );
        return false; // Add this line
      },
      child: Scaffold(
        backgroundColor: AppThemeData().greenAccentColor,
        body: SafeArea(
          child: SingleChildScrollView(
              child: Padding(
                  padding: EdgeInsets.all(10),
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
                                      builder: (context) => UserGuidePage()),
                                      (Route<dynamic> route) => false,
                                );
                              })),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/logos/trashpick_logo_banner.png',
                            height: 120,
                            width: 120,
                          ),
                          SizedBox(width: 10),
                          Text("Buat akun \ndengan mendaftar",
                              style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.fontSize,
                                fontWeight: FontWeight.bold,
                              )),
                        ],
                      ),
                      SizedBox(height: 20),
                      radioButtonList(),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                prefixIcon: Icon(Icons.account_circle_outlined),
                                border: OutlineInputBorder(),
                                labelText: 'Nama',
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                prefixIcon: Icon(Icons.email_outlined),
                                border: OutlineInputBorder(),
                                labelText: 'Email',
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            TextFormField(
                              controller: phoneNumberController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                prefixIcon: Icon(Icons.phone_android_rounded),
                                border: OutlineInputBorder(),
                                labelText: 'Nomor Kontak',
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            TextFormField(
                              controller: homeAddressController,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.home_rounded),
                                border: OutlineInputBorder(),
                                labelText: 'Alamat Rumah',
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            TextFormField(
                              obscureText: _isHidden,
                              controller: passwordController,
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                contentPadding:
                                EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                                prefixIcon: Icon(Icons.lock_outline_rounded),
                                border: OutlineInputBorder(),
                                labelText: 'Kata Sandi',
                                suffix: InkWell(
                                  onTap: _togglePasswordView,
                                  child: Icon(
                                    _isHidden
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            TextFormField(
                              obscureText: _isHiddenC,
                              controller: confirmPasswordController,
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                contentPadding:
                                EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                                prefixIcon: Icon(Icons.lock_outline_rounded),
                                border: OutlineInputBorder(),
                                labelText: 'Konfirmasi Kata Sandi',
                                suffix: InkWell(
                                  onTap: _toggleConfirmPasswordView,
                                  child: Icon(
                                    _isHiddenC
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      new ButtonWidget(
                        textColor: AppThemeData().whiteColor,
                        color: AppThemeData().secondaryColor,
                        text: "Daftar",
                        onClicked: () {
                          if (validateUser()) {
                            printSignUpData();
                            authenticateUser();
                          } else {
                            _toastMessages.toastInfo('Coba lagi dengan detail yang benar!', Toast.LENGTH_SHORT as BuildContext);
                          }
                        },

                      ),
                      SizedBox(height: 20),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Sudah Punya Akun?",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                )),
                            SizedBox(width: 10),
                            new RadiusFlatButtonWidget(
                              text: "Masuk",
                              onClicked: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignInPage()),
                                      (Route<dynamic> route) => false,
                                );
                                print("Beralih ke Masuk");
                              },
                              // or any other unique value
                            ),
                          ],
                        ),
                      )
                    ],
                  ))),
        ),
      ),
    );
  }
}
