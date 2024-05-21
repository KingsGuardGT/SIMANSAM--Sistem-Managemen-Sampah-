import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
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
  var currentUserID = FirebaseAuth.instance.currentUser.uid;
  CollectionReference imgRef;
  firebase_storage.Reference ref;
  File _userSelectedFileImage;
  String firebaseStorageUploadedImageURL;
  String _userLatestProfileImage;

  // Proses Pengunggahan
  bool isStartToUpload = false;
  bool isUploadComplete = false;
  bool isAnError = false;
  double circularProgressVal;

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
              title: !isUploadComplete
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

  void validateEdits() {
    if (_userSelectedFileImage == null) {
      ToastMessages().toastError("Silakan pilih gambar", context);
    } else {
      showAlertDialog(context);
      uploadImagesToStorage();
    }
  }

  // -------------------------------- UBAH GAMBAR -------------------------------- \\

  _imgFromCamera() async {
    final pickedFile = await ImagePicker().getImage(
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
    final pickedFile = await ImagePicker().getImage(
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
      FirebaseStorage.instance.refFromURL(_userLatestProfileImage).delete();

      try {
        ref = firebase_storage.FirebaseStorage.instance.ref().child(
            'Gambar Profil Pengguna/${FirebaseAuth.instance.currentUser.uid}/${FirebaseAuth.instance.currentUser.uid}');
        await ref.putFile(_userSelectedFileImage);

        String downloadURL = await firebase_storage.FirebaseStorage.instance
            .ref()
            .child(
            'Gambar Profil Pengguna/${FirebaseAuth.instance.currentUser.uid}/${FirebaseAuth.instance.currentUser.uid}')
            .getDownloadURL();
        firebaseStorageUploadedImageURL = downloadURL.toString();
        print("Gambar Diunggah ke Firebase Storage!");
        print("URL Gambar: " + firebaseStorageUploadedImageURL);
        saveEditProfileToFireStore(firebaseStorageUploadedImageURL);
      } catch (e) {
        print(e.toString());
        ifAnError();
      }
    } else {
      saveEditProfileToFireStore(_userLatestProfileImage);
    }
  }

  saveEditProfileToFireStore(String firebaseStorageUploadedImageURL) {
    print("GAMBAR: " + firebaseStorageUploadedImageURL);

    FirebaseFirestore.instance
        .collection('Pengguna')
        .doc(currentUserID.toString())
        .update({
      'gambarProfil': firebaseStorageUploadedImageURL,
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
            fontSize: Theme.of(context).textTheme.titleMedium.fontSize,
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
            fontSize: Theme.of(context).textTheme.titleMedium.fontSize,
            fontWeight: FontWeight.normal),
      ),
    );
  }

  Widget _profileDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Pengguna")
            .where('uuid', isEqualTo: "${currentUserID.toString()}")
            .snapshots(),
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return Text(
              "Hai! ",
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.titleLarge.fontSize,
                  fontWeight: FontWeight.bold),
            );
          } else {
            UserModelClass userModelClass =
            UserModelClass.fromDocument(dataSnapshot.data.docs[0]);

            _userLatestProfileImage = userModelClass.profileImage;

            return ListView(
              physics: BouncingScrollPhysics(),
              children: [
                SizedBox(
                  height: 5.0,
                ),
                Center(
                  child: _userSelectedFileImage != null
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
                    _columnDetail(userModelClass.name),
                    _columnTitle("Jenis Akun"),
                    _columnDetail(userModelClass.accountType),
                    _columnTitle("Nomor Kontak"),
                    _columnDetail(userModelClass.contactNumber),
                    _columnTitle("Email"),
                    _columnDetail(userModelClass.email),
                    _columnTitle("Alamat Rumah"),
                    _columnDetail(userModelClass.homeAddress),
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
                  },
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
}