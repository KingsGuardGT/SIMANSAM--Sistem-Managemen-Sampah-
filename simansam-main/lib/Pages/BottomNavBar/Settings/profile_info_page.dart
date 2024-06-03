import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simansam/Models/user_model.dart';
import 'package:simansam/Theme/theme_provider.dart';
import 'package:simansam/Widgets/button_widgets.dart';
import 'package:simansam/Widgets/image_frames_widgets.dart';
import 'package:simansam/Widgets/secondary_app_bar_widget.dart';
import 'package:simansam/Widgets/toast_messages.dart';

class ProfileInfoPage extends StatefulWidget {
  @override
  _ProfileInfoPageState createState() => _ProfileInfoPageState();
}

class _ProfileInfoPageState extends State<ProfileInfoPage> {
  var currentUserID = FirebaseAuth.instance.currentUser?.uid;
  CollectionReference? imgRef;
  Reference? ref;
  File? _userSelectedFileImage;
  String? firebaseStorageUploadedImageURL;
  String? _userLatestProfileImage;

  // Proses Pengunggahan
  bool isStartToUpload = false;
  bool isUploadComplete = false;
  bool isAnError = false;
  double? circularProgressVal;

  // -------------------------------- PROSES PENGUNGGAHAN -------------------------------- \\

  void ifAnError() {
    Navigator.pop(context);
    setState(() {
      isStartToUpload = false;
      isUploadComplete = false;
      isAnError = true;
      showAlertDialog(context);
    });
  }

  void sendErrorCode(String error) {
    ToastMessages().toastError(error, context);
    ifAnError();
  }

  void sendSuccessCode() {
    print("Berhasil Memperbarui Profil!");
    Navigator.pop(context);
    setState(() {
      isStartToUpload = false;
      isUploadComplete = true;
    });
    showAlertDialog(context);
  }

  showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title:!isUploadComplete
                  ? Center(child: Text("Memperbarui Profil"))
                  : Center(child: Text("Profil Diperbarui")),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isUploadComplete)
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
                              Colors.teal.shade700),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        Text("Tunggu sampai profil Anda diperbarui.",
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
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                )),
                            SizedBox(
                              height: 50.0,
                            ),
                            new ButtonWidget(
                                text: "Coba Lagi",
                                textColor: AppThemeData().whiteColor,
                                color: AppThemeData().primaryColor,
                                onClicked: () {
                                  Navigator.pop(context);
                                }),
                          ],
                        ))
                  else
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/icons/icon_profile_upload.png',
                              height: 50,
                              width: 50,
                            ),
                            SizedBox(height: 30),
                            Text("Profil telah diunggah!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 22.0)
                                    .copyWith(
                                    color: Colors.grey.shade900,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 50),
                            new ButtonWidget(
                              textColor: AppThemeData().whiteColor,
                              color: AppThemeData().secondaryColor,
                              text: "OK",
                              onClicked: () {
                                Navigator.pop(context);
                              },
                            )
                          ],
                        ),
                      ),
                    )
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

  // -------------------------------- UBAH GAMBAR -------------------------------- \\

  _imgFromCamera() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      setState(() {
        _userSelectedFileImage = File(pickedFile.path);
      });
    }
  }

  _imgFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      setState(() {
        _userSelectedFileImage = File(pickedFile.path);
      });
    }
  }

  changeProfilePicture(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Perpustakaan Foto'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Kamera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<void> uploadImagesToStorage() async {
    if (_userSelectedFileImage != null) {
      FirebaseStorage.instance.refFromURL(_userLatestProfileImage!).delete();

      try {
        var firebaseStorage;
        ref = firebaseStorage.FirebaseStorage.instance.ref().child(
            'Gambar Profil Pengguna/${FirebaseAuth.instance.currentUser?.uid}/${FirebaseAuth.instance.currentUser?.uid}');
        await ref?.putFile(_userSelectedFileImage!);

        String downloadURL = await firebaseStorage.FirebaseStorage.instance
            .ref()
            .child(
            'Gambar Profil Pengguna/${FirebaseAuth.instance.currentUser?.uid}/${FirebaseAuth.instance.currentUser?.uid}')
            .getDownloadURL();
        firebaseStorageUploadedImageURL = downloadURL.toString();
        print("Gambar Diunggah ke Firebase Storage!");
        print("URL Gambar: " + firebaseStorageUploadedImageURL!);
        saveEditProfileToFireStore(firebaseStorageUploadedImageURL!);
      } catch (e) {
        print(e.toString());
        ifAnError();
      }
    } else {
      saveEditProfileToFireStore(_userLatestProfileImage!);
    }
  }

  saveEditProfileToFireStore(String firebaseStorageUploadedImageURL) {
    print("GAMBAR: " + firebaseStorageUploadedImageURL);

    FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserID.toString())
        .update({
      'profileImage': firebaseStorageUploadedImageURL,
    })
        .then(
          (value) => sendSuccessCode(),
    )
        .catchError((error) => sendErrorCode(error.toString()));
  }

  // -------------------------------- DETAIL PROFIL -------------------------------- \\

  _columnTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  _columnDetail(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
            fontWeight: FontWeight.normal),
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();

  String? _nama, _nomorKontak, _email, _alamatRumah;

  Widget _profileDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .where('uuid', isEqualTo: "${currentUserID.toString()}")
            .snapshots(),
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return Text(
              "Hai! ",
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                  fontWeight: FontWeight.bold),
            );
          } else {
            UserModelClass userModelClass =
            UserModelClass.fromDocument(dataSnapshot.data!.docs[0]);

            _userLatestProfileImage = userModelClass.profileImage;

            return ListView(
              physics: BouncingScrollPhysics(),
              children: [
                SizedBox(
                  height: 5.0,
                ),
                Center(
                  child: _userSelectedFileImage!= null
                      ? new ImageFramesWidgets().userProfileFrame(
                      _userSelectedFileImage, 150.0, 65.0, false)
                      : new ImageFramesWidgets().userProfileFrame(
                      _userLatestProfileImage, 150.0, 65.0, true),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Center(
                  child: TextWithIconButtonWidget(
                    text: "Klik untuk Mengubah Gambar",
                    icon: Icons.camera_alt_rounded,
                    iconToLeft: true,
                    onClicked: () {
                      print('Ubah Gambar Profil');
                      changeProfilePicture(context);
                    },
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _columnTitle("Nama"),
                    Row(
                      children: [
                        _columnDetail(userModelClass.name),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Ubah Nama"),
                                  content: Form(
                                    key: _formKey,
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Nama',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Nama tidak boleh kosong';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) => _nama = value!,
                                    ),
                                  ),
                                  actions: [
                                    new ButtonWidget(
                                      text: "Batal",
                                      textColor: AppThemeData().whiteColor,
                                      color: AppThemeData().primaryColor,
                                      onClicked: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    new ButtonWidget(
                                      text: "Simpan",
                                      textColor: AppThemeData().whiteColor,
                                      color: AppThemeData().secondaryColor,
                                      onClicked: () {
                                        if (_formKey.currentState!.validate()) {
                                          _formKey.currentState?.save();
                                          FirebaseFirestore.instance
                                              .collection('Users')
                                              .doc(currentUserID.toString())
                                              .update({
                                            'name': _nama,
                                          });
                                          Navigator.pop(context);
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    _columnTitle("Jenis Akun"),
                    _columnDetail(userModelClass.accountType),
                    _columnTitle("Nomor Kontak"),
                    Row(
                      children: [
                        _columnDetail(userModelClass.contactNumber),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Ubah Nomor Kontak"),
                                  content: Form(
                                    key: _formKey,
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Nomor Kontak',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Nomor kontak tidak boleh kosong';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) => _nomorKontak = value!,
                                    ),
                                  ),
                                  actions: [
                                    new ButtonWidget(
                                      text: "Batal",
                                      textColor: AppThemeData().whiteColor,
                                      color: AppThemeData().primaryColor,
                                      onClicked: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    new ButtonWidget(
                                      text: "Simpan",
                                      textColor: AppThemeData().whiteColor,
                                      color: AppThemeData().secondaryColor,
                                      onClicked: () {
                                        if (_formKey.currentState!.validate()) {
                                          _formKey.currentState?.save();
                                          FirebaseFirestore.instance
                                              .collection('Users')
                                              .doc(currentUserID.toString())
                                              .update({
                                            'contactNumber': _nomorKontak,
                                          });
                                          Navigator.pop(context);
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    _columnTitle("Email"),
                    Row(
                      children: [
                        _columnDetail(userModelClass.email),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Ubah Email"),
                                  content: Form(
                                    key: _formKey,
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Email tidak boleh kosong';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) => _email = value!,
                                    ),
                                  ),
                                  actions: [
                                    new ButtonWidget(
                                      text: "Batal",
                                      textColor: AppThemeData().whiteColor,
                                      color: AppThemeData().primaryColor,
                                      onClicked: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    new ButtonWidget(
                                      text: "Simpan",
                                      textColor: AppThemeData().whiteColor,
                                      color: AppThemeData().secondaryColor,
                                      onClicked: () {
                                        if (_formKey.currentState!.validate()) {
                                          _formKey.currentState?.save();
                                          FirebaseFirestore.instance
                                              .collection('Users')
                                              .doc(currentUserID.toString())
                                              .update({
                                            'email': _email,
                                          });
                                          Navigator.pop(context);
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    _columnTitle("Alamat Rumah"),
                    Row(
                      children: [
                        _columnDetail(userModelClass.homeAddress),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Ubah Alamat Rumah"),
                                  content: Form(
                                    key: _formKey,
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Alamat Rumah',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Alamat rumah tidak boleh kosong';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) => _alamatRumah = value!,
                                    ),
                                  ),
                                  actions: [
                                    new ButtonWidget(
                                      text: "Batal",
                                      textColor: AppThemeData().whiteColor,
                                      color: AppThemeData().primaryColor,
                                      onClicked: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    new ButtonWidget(
                                      text: "Simpan",
                                      textColor: AppThemeData().whiteColor,
                                      color: AppThemeData().secondaryColor,
                                      onClicked: () {
                                        if (_formKey.currentState!.validate()) {
                                          _formKey.currentState?.save();
                                          FirebaseFirestore.instance
                                              .collection('Users')
                                              .doc(currentUserID.toString())
                                              .update({
                                            'homeAddress': _alamatRumah,
                                          });
                                          Navigator.pop(context);
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.0,
                ),
                MinButtonWidget(
                  text: "Perbarui Profil",
                  color: AppThemeData().secondaryColor,
                  onClicked: () {
                    validateEdits();
                  }, key: null,
                ),
                SizedBox(
                  height: 20.0,
                ),
              ],
            );
          }
        },
      ),
    );
  }

  // -------------------------------- BANGUNAN -------------------------------- \\

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SecondaryAppBar(
        title: "Informasi Profil",
        appBar: AppBar(),
        widgets: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
            child: Icon(
              Icons.person_rounded,
              color: Theme.of(context).iconTheme.color,
              size: 35.0,
            ),
          )
        ],
      ),
      body: _profileDetails(),
    );
  }

  void validateEdits() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      uploadImagesToStorage();
    }
  }
}