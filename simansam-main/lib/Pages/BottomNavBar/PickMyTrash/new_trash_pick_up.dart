import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:simansam/Generators/uui_generator.dart';
import 'package:simansam/Pages/BottomNavBar/PickMyTrash/pick_trash_location.dart';
import 'package:simansam/Theme/theme_provider.dart';
import 'package:simansam/Widgets/button_widgets.dart';
import 'package:simansam/Widgets/secondary_app_bar_widget.dart';
import 'package:simansam/Widgets/toast_messages.dart';

import '../../../Models/user_model.dart';
import '../bottom_nav_bar.dart';

class NewTrashPickUp extends StatefulWidget {
  final String accountType;

  NewTrashPickUp(this.accountType);

  @override
  _NewTrashPickUpState createState() => _NewTrashPickUpState();
}

class _NewTrashPickUpState extends State<NewTrashPickUp> {
  TextEditingController _trashNameController = new TextEditingController();
  TextEditingController _trashDescriptionController =
  new TextEditingController();
  TextEditingController _trashLocationController = new TextEditingController();
  int charLength = 0;
  File? _image;
  final String userProfileID = FirebaseAuth.instance.currentUser!.uid.toString();

  // Proses Mengunggah
  bool isStartToUpload = false;
  bool isUploadComplete = false;
  bool isAnError = false;
  double? circularProgressVal;

  // Sementara hingga dihapus
  CollectionReference? imgRef;
  firebase_storage.Reference? ref;
  String? imageURL;
  final firestoreInstance = FirebaseFirestore.instance;
  String formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  String formattedTime = DateFormat('kk:mm:a').format(DateTime.now());

  String trashID = new UUIDGenerator().uuidV4();

  // ------------------------------ Pemilih Jenis Sampah ------------------------------ \\

  Map<String, bool> trashTypeValues = {
    'Plastik & Polietilena': false,
    'Kaca': false,
    'Kertas': false,
    'Logam & Tempurung Kelapa': false,
    'Limbah Klinis': false,
    'Limbah Elektronik': false,
  };

  List trashTypeArray = [];
  List? trashTypes;

  getCheckboxItems() {
    trashTypeArray.clear();
    trashTypeValues.forEach((key, value) {
      if (value == true) {
        trashTypeArray.add(key);
      }
    });
    trashTypes = trashTypeArray;
    //print(trashTypeArray);
    //print(trashTypes);
  }

  // ------------------------------ Pemilih Lokasi ------------------------------ \\

  String locationName = "Lokasi Saya";
  String userHomeLocation = "Rumah Saya";
  int? locationTypeID;

  final userReference = FirebaseFirestore.instance.collection('Users');
  final FirebaseAuth auth = FirebaseAuth.instance;
  Position? _currentPosition;

  List? _trashLocationDetails;
  String userCurrentAddress = "Tidak Ada Lokasi yang Dipilih!";
  String selectedFromMapAddress = "Tidak Ada Lokasi yang Dipilih!";
  String trashLocationAddress = "Tidak Ada Lokasi yang Dipilih!";
  double? trashLocationLatitude, trashLocationLongitude;

  // ------------------------------ Pemilih Tanggal ------------------------------ \\

  String startDate = DateTime
      .now()
      .day
      .toString() +
      "/" +
      DateTime
          .now()
          .month
          .toString() +
      "/" +
      DateTime
          .now()
          .year
          .toString();
  String returnDate = DateTime
      .now()
      .day
      .toString() +
      "/" +
      DateTime
          .now()
          .month
          .toString() +
      "/" +
      DateTime
          .now()
          .year
          .toString();
  DateTime _dateS = DateTime(2021, 07, 17);
  DateTime _dateR = DateTime(2021, 07, 18);

  // ------------------------------ Pemilih Waktu ------------------------------ \\

  String startTime = "7:15 PAGI";
  String returnTime = "8:15 PAGI";
  TimeOfDay _timeS = TimeOfDay(hour: 7, minute: 15);
  TimeOfDay _timeR = TimeOfDay(hour: 8, minute: 15);
  var now = DateTime
      .now()
      .hour;
  var nowt = DateTime
      .now()
      .minute;
  TimeOfDay releaseTime = TimeOfDay(hour: 15, minute: 0);
  String nowTime = TimeOfDay(hour: 15, minute: 0).toString();

  void _startTime() async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _timeS,
    );
    if (newTime != null) {
      setState(() {
        _timeS = newTime;
        startTime = _timeS.format(context);
      });
    }
  }

  void _returnTime() async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _timeR,
    );
    if (newTime != null) {
      setState(() {
        _timeR = newTime;
        returnTime = _timeR.format(context);
      });
    }
  }

  _onChanged(String value) {
    setState(() {
      charLength = value.length;
    });
  }

  _imgFromCamera() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
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
        _image = File(pickedFile.path);
      });
    }
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Galeri Foto'),
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

  void ifAnError() {
    Navigator.pop(context);
    setState(() {
      isStartToUpload = false;
      isUploadComplete = false;
      isAnError = true;
      //Navigator.pop(context);
      showAlertDialog(context);
    });
  }

  void sendErrorCode(String error) {
    ToastMessages().toastError(error, context);
    ifAnError();
  }

  void sendSuccessCode() {
    print("Posting Sukses!");
    Navigator.pop(context);
    setState(() {
      isStartToUpload = false;
      isUploadComplete = true;
    });
    showAlertDialog(context);
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
              title: !isUploadComplete
                  ? Center(child: Text("Mengunggah Posting"))
                  : Center(child: Text("Unggah Sukses")),
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
                        Text("Harap tunggu hingga postingan Anda diunggah.",
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
                            Text("Kesalahan!",
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
                                color: AppThemeData().redColor,
                                onClicked: () {
                                  Navigator.pop(context);
                                }, ),
                          ],
                        ))
                  else
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/icons/icon_recycle.png',
                              height: 50,
                              width: 50,
                            ),
                            SizedBox(height: 30),
                            Text("Posting telah diunggah!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 22.0)
                                    .copyWith(
                                    color: Colors.grey.shade900,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 50),
                            new ButtonWidget(
                                text: "Lanjutkan",
                                textColor: AppThemeData().whiteColor,
                                color: AppThemeData().primaryColor,
                                onClicked: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          BottomNavBar(widget.accountType),
                                    ),
                                        (route) => false,
                                  );
                                }, ),
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

  Future<void> uploadImagesToStorage() async {
    try {
      ref = firebase_storage.FirebaseStorage.instance
          .ref()
      //.child('Posts/$userProfileID/$postID/${Path.basename(_image.path)}');
          .child('Pengambilan Sampah/$userProfileID/$trashID/$trashID');
      await ref?.putFile(_image!);

      String downloadURL = await firebase_storage.FirebaseStorage.instance
          .ref()
      //.child('Posts/$userProfileID/$postID/${Path.basename(_image.path)}')
          .child('Pengambilan Sampah/$userProfileID/$trashID/$trashID')
          .getDownloadURL();
      imageURL = downloadURL.toString();
      print("Gambar Diunggah ke Firebase Storage!");
      print("URL Gambar: " + imageURL!);
      addPostToFireStore(imageURL!);
    } catch (e) {
      print(e.toString());
      ifAnError();
    }
  }

  Future<void> addPostToFireStore(String trashImage) async {
    firestoreInstance
        .collection('Users')
        .doc(userProfileID)
        .collection('PengambilanSampah')
        .doc(trashID)
        .set({
      'trashID': trashID,
      'postedDate': formattedDate + ", " + formattedTime,
      'trashName': _trashNameController.text,
      'trashDescription': _trashDescriptionController.text,
      'trashImage': trashImage,
      'trashTypes': trashTypes,
      'trashLocationAddress': trashLocationAddress,
      'trashLocationLocation':
      new GeoPoint(trashLocationLatitude!, trashLocationLongitude!),
      'startDate': startDate,
      'returnDate': returnDate,
      'startTime': startTime,
      'returnTime': returnTime,
    })
        .then(
          (value) => sendSuccessCode(),
    )
        .catchError((error) => sendErrorCode(error.toString()));
  }

  /*void validatePost() {
    if (_newPostCaptionController.text.isEmpty ||
        _newPostCaptionController.text == null) {
      ToastMessages().toastError("Harap masukkan caption sampah", context);
    } else if (_image == null) {
      ToastMessages().toastError("Harap pilih gambar", context);
    } else {
      showAlertDialog(context);
      uploadImagesToStorage();
    }
  }*/

  _getCurrentUserLocation() async {
    try {
      Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          forceAndroidLocationManager: true)
          .then((Position position) {
        setState(() {
          _currentPosition = position;
        });
        _getCurrentUserAddressFromLatLng(
            _currentPosition?.latitude, _currentPosition?.longitude);
      }).catchError((e) {
        print(e);
      });
    } catch (error) {
      ToastMessages().toastError(error.toString(), context);
    }
  }

  _getCurrentUserAddressFromLatLng(latitude, longitude) async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(latitude, longitude);
      Placemark place = p[0];
      setState(() {
        trashLocationLatitude = latitude;
        trashLocationLongitude = longitude;

        _trashLocationDetails = [
          latitude, // 00
          longitude, // 01
          "${place.name}", // 02
          "${place.street}", // 03
          "${place.postalCode}", // 04
          "${place.administrativeArea}", // 05
          "${place.subAdministrativeArea}", // 06
          "${place.thoroughfare}", // 07
          "${place.subThoroughfare}", // 08
          "${place.locality}", // 09
          "${place.subLocality}", // 10
          "${place.country}", // 11
          "${place.isoCountryCode}", // 12
        ];

        userCurrentAddress = ""
            "${_trashLocationDetails![0].toString()}, "
            "${_trashLocationDetails![1].toString()}, "
            "${_trashLocationDetails![2].toString()}, "
            "${_trashLocationDetails![3].toString()}, "
            "${_trashLocationDetails![4].toString()}, "
            "${_trashLocationDetails![5].toString()}, "
            "${_trashLocationDetails![6].toString()}, "
            "${_trashLocationDetails![7].toString()}, "
            "${_trashLocationDetails![8].toString()}, "
            "${_trashLocationDetails![9].toString()}, "
            "${_trashLocationDetails![10].toString()}, "
            "${_trashLocationDetails![11].toString()}, "
            "${_trashLocationDetails![12].toString()}";

        ToastMessages().toastSuccess("Lokasi Dipilih: \n"
          "$trashLocationAddress", context);
      });
    } catch (error) {
      ToastMessages().toastError(error.toString(), context);
      print("ERROR=> _getTrashLocationAddressFromLatLng: $error");
    }
  }

  void _startDate() async {
    final DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: _dateS,
      firstDate: DateTime(2021, 1),
      lastDate: DateTime(2031, 1),
      helpText: 'Pilih tanggal',
    );
    if (newDate != null) {
      setState(() {
        _dateS = newDate;
        startDate = _dateS.day.toString() +
            "/" +
            _dateS.month.toString() +
            "/" +
            _dateS.year.toString();
      });
    }
  }

  void _returnDate() async {
    final DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: _dateR,
      firstDate: DateTime(2017, 1),
      lastDate: DateTime(2022, 7),
      helpText: 'Pilih tanggal',
    );
    if (newDate != null) {
      setState(() {
        _dateR = newDate;
        returnDate = _dateR.day.toString() +
            "/" +
            _dateR.month.toString() +
            "/" +
            _dateR.year.toString();
      });
    }
  }

  printTrashPickUpDetails() {
    String info =
        "------------------------- Detail Pengambilan Sampah -------------------------\n"
            "Nama Sampah: " +
            _trashNameController.text +
            "\n" +
            "Deskripsi Sampah: " +
            _trashDescriptionController.text +
            "\n" +
            "Gambar Sampah: " +
            _image.toString() +
            "\n" +
            "Jenis Sampah: " +
            trashTypes.toString() +
            "\n" +
            "Alamat Lokasi Sampah: " +
            trashLocationAddress.toString() +
            "\n" +
            "Garis Lintang Lokasi Sampah: " +
            trashLocationLatitude.toString() +
            "\n" +
            "Garis Bujur Lokasi Sampah: " +
            trashLocationLongitude.toString() +
            "\n" +
            "Tanggal Mulai: $startDate\n" +
            "Tanggal Kembali: $returnDate\n" +
            "Waktu Mulai: $startTime\n" +
            "Waktu Kembali: $returnTime\n";
    print(info);
  }

  void validatePickUp() {
    if (_trashNameController.text.isEmpty) {
      new ToastMessages().toastError(
          "Tidak bisa meninggalkan nama sampah", context);
    } else if (_trashDescriptionController.text.isEmpty) {
      new ToastMessages().toastError(
          "Tidak bisa meninggalkan deskripsi sampah", context);
    } else if (_image == null) {
      new ToastMessages().toastError("Harap pilih gambar", context);
    } else if (trashTypes!.isEmpty) {
      new ToastMessages()
          .toastError("Harap pilih setidaknya satu jenis", context);
    } else if (trashLocationAddress == "Tidak Ada Lokasi Dipilih!") {
      new ToastMessages().toastError("Harap pilih lokasi", context);
    } else if (startDate.isEmpty) {
      new ToastMessages().toastError("Harap pilih Tanggal Mulai", context);
    } else if (returnDate.isEmpty) {
      new ToastMessages().toastError("Harap pilih Tanggal Kembali", context);
    } else if (_dateS.day + _dateS.month + _dateS.year >
        _dateR.day + _dateR.month + _dateR.year) {
      new ToastMessages()
          .toastError(
          "Tanggal Kembali tidak bisa lebih awal dari Tanggal Mulai", context);
    } else if (startTime.isEmpty) {
      new ToastMessages().toastError("Harap Pilih Waktu Mulai", context);
    } else if (returnTime.isEmpty) {
      new ToastMessages().toastError("Harap pilih Waktu Kembali", context);
    } else if (startDate == returnDate && _timeS.hour > _timeR.hour) {
      new ToastMessages().toastError(
          "Waktu Kembali tidak bisa lebih awal dari Waktu Mulai pada hari yang sama",
          context);
    } else {
      printTrashPickUpDetails();
      showAlertDialog(context);
      uploadImagesToStorage();
    }
    //printTrashPickUpDetails();
  }

  @override
  void initState() {
    _getCurrentUserLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void navigateAndDisplaySelection(BuildContext context) async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PickTrashLocation(_currentPosition!)),
      );
      setState(() {
        if (result == null) {
          selectedFromMapAddress = "Tidak Ada Lokasi Dipilih!";
        } else {
          _trashLocationDetails = result;
          selectedFromMapAddress = ""
              "${_trashLocationDetails![0].toString()}, "
              "${_trashLocationDetails![1].toString()}, "
              "${_trashLocationDetails![2].toString()}, "
              "${_trashLocationDetails![3].toString()}, "
              "${_trashLocationDetails![4].toString()}, "
              "${_trashLocationDetails![5].toString()}, "
              "${_trashLocationDetails![6].toString()}, "
              "${_trashLocationDetails![7].toString()}, "
              "${_trashLocationDetails![8].toString()}, "
              "${_trashLocationDetails![9].toString()}, "
              "${_trashLocationDetails![10].toString()}, "
              "${_trashLocationDetails![11].toString()}, "
              "${_trashLocationDetails![12].toString()}";
          trashLocationAddress = selectedFromMapAddress;
        }
      });
    }

    showInfoAlert(BuildContext context) {
      String infoTitle = "Panduan untuk memilih lokasi";
      String infoMessage =
          "Untuk memilih lokasi, cukup tekan pada peta dan tempat yang dipilih akan ditandai dengan penanda ini.";
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(infoTitle),
            content: Container(
              height: 160.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    infoMessage,
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                  Image.asset(
                    'assets/icons/icon_bin.png',
                    scale: 1.0,
                  )
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  "Ok dan Pilih Lokasi",
                  style: TextStyle(color: AppThemeData().primaryColor),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  navigateAndDisplaySelection(context);
/*                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            PickTrashLocation(_currentPosition)),
                  );*/
                },
              ),
            ],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
          );
        },
      );
    }

    garbageTypes() {
      return Container(
        height: 430.0,
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: trashTypeValues.keys.map((String key) {
            Color color;
            String description;

            switch (key) {
              case "Plastik & Politena":
                color = Colors.orange.shade700;
                description = "Plastik & Politena";
                break;
              case "Kaca":
                color = Colors.red;
                description = "Kaca";
                break;
              case "Kertas":
                color = Colors.blue;
                description = "Kertas";
                break;
              case "Logam & Tempurung Kelapa":
                color = Colors.black;
                description = "Logam & Tempurung Kelapa";
                break;
              case "Limbah Klinis":
                color = Colors.yellow;
                description = "Limbah Klinis";
                break;
              case "Limbah Elektronik":
                color = Colors.grey.shade200;
                description = "Limbah Elektronik";
                break;
              default:
                color = Colors.grey.shade100;
                description = "Lainnya";
            }

            return new CheckboxListTile(
              secondary: Container(
                color: color,
                height: 30.0,
                width: 30.0,
              ),
              title: new Text(key),
              subtitle: Text(description),
              value: trashTypeValues[key],
              onChanged: (bool? value) {
                setState(() {
                  if (value!= null) {
                    trashTypeValues[key] = value;
                  }
                });
              },
            );
          }).toList(),
        ),
      );
    }

    // ignore: unused_element
    Widget getMyHomeAddress() {
      return FutureBuilder(
        future: userReference.doc(auth.currentUser?.uid).get(),
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            _trashLocationController =
            new TextEditingController(text: "Tidak Ada Lokasi Dipilih!");
            return TextFormField(
              controller: _trashLocationController,
              style: TextStyle(fontWeight: FontWeight.normal),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.home_rounded,
                  color: Theme
                      .of(context)
                      .iconTheme
                      .color,
                  size: 35.0,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
              keyboardType: TextInputType.text,
            );
          } else {
            UserModelClass userModelClass =
            UserModelClass.fromDocument(dataSnapshot.data as DocumentSnapshot<Object?>);
            _trashLocationController =
            new TextEditingController(text: userModelClass.homeAddress);
            return TextFormField(
              controller: _trashLocationController,
              style: TextStyle(fontWeight: FontWeight.normal),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.home_rounded,
                  color: Theme
                      .of(context)
                      .iconTheme
                      .color,
                  size: 35.0,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
              keyboardType: TextInputType.text,
            );
          }
        },
      );
    }

    Widget trashLocation() {
      Widget widget;

      switch (locationName) {
        case "Lokasi Saat Ini":
          widget = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_rounded,
                color: Theme
                    .of(context)
                    .iconTheme
                    .color,
                size: 35.0,
              ),
              Text(
                "Lokasi Saat Ini",
                style: TextStyle(
                    fontSize: Theme
                        .of(context)
                        .textTheme
                        .titleLarge
                        ?.fontSize,
                    fontWeight: FontWeight.bold),
              ),
            ],
          );
          break;
        case "Pilih dari Peta":
          widget = Center(
            child: MinButtonWidget(
              text: "Pilih dari Peta",
              color: Theme
                  .of(context)
                  .colorScheme
                  .background,
              onClicked: () {
                print("Ditekan: Pilih dari Peta");
                showInfoAlert(context);
              }, 
            ),
          );
          break;
        default:
          widget = Container();
      }
      return widget;
    }

    radioButtonList() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Radio(
                value: 1,
                groupValue: locationTypeID,
                onChanged: (val) {
                  setState(() {
                    locationName = 'Lokasi Saat Ini';
                    locationTypeID = 1;
                    trashLocationAddress = userCurrentAddress;
                  });
                },
              ),
              Text(
                'Lokasi Saat Ini',
                style: new TextStyle(
                    fontSize: Theme
                        .of(context)
                        .textTheme
                        .titleMedium
                        ?.fontSize),
              ),
              Radio(
                value: 2,
                groupValue: locationTypeID,
                onChanged: (val) {
                  setState(() {
                    locationName = 'Pilih dari Peta';
                    locationTypeID = 2;
                    trashLocationAddress = selectedFromMapAddress;
                  });
                },
              ),
              Text(
                'Pilih dari Peta',
                style: new TextStyle(
                  fontSize: Theme
                      .of(context)
                      .textTheme
                      .titleMedium
                      ?.fontSize,
                ),
              ),
            ],
          ),
        ],
      );
    }

    dateSelectCard(String title, VoidCallback onCardTap, String dateType) {
      return Container(
        alignment: Alignment.topLeft,
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600),
            ),
            SizedBox(
              height: 10.0,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Container(
                  color: Colors.grey.shade200,
                  child: new GestureDetector(
                      onTap: onCardTap,
                      child: new Container(
                        height: 50.0,
                        width: 150.0,
                        color: Colors.white,
                        child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 20.0,
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                  dateType,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            )),
                      ))),
            ),
          ],
        ),
      );
    }

    timeSelectCard(String title, VoidCallback onCardTap, String timeType) {
      return Container(
        alignment: Alignment.topLeft,
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600),
            ),
            SizedBox(
              height: 10.0,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Container(
                  color: Colors.grey.shade200,
                  child: new GestureDetector(
                      onTap: onCardTap,
                      child: new Container(
                        height: 50.0,
                        width: 150.0,
                        color: Colors.white,
                        child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 20.0,
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                  timeType,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            )),
                      ))),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: SecondaryAppBar(
        title: "Jadwalkan Pengambilan Sampah",
        appBar: AppBar(),
        widgets: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
            child: Icon(
              Icons.cancel_rounded,
              size: 30.0,
            ),
          )
        ], 
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _trashNameController,
                  style: TextStyle(fontWeight: FontWeight.normal),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                    hintText: "Berikan nama pada sampah",
                    labelText: 'Nama Sampah',
                    focusedBorder: UnderlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    labelStyle: TextStyle(
                        color: Colors.grey.shade900,
                        fontWeight: FontWeight.bold),
                  ),
                  keyboardType: TextInputType.text,
                ),
                SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                  controller: _trashDescriptionController,
                  style: TextStyle(fontWeight: FontWeight.normal),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
                    helperText: "$charLength",
                    hintText: "Deskripsikan sesuatu tentang sampah",
                    labelText: 'Deskripsi Sampah',
                    focusedBorder: UnderlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    labelStyle: TextStyle(
                        color: Colors.grey.shade900,
                        fontWeight: FontWeight.bold),
                  ),
                  onChanged: _onChanged,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  "Pilih Gambar Sampah",
                  style: TextStyle(
                      fontSize: Theme
                          .of(context)
                          .textTheme
                          .titleMedium
                          ?.fontSize,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      _showPicker(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: _image != null
                          ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: Image.file(
                          _image!,
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          height: 300,
                          fit: BoxFit.cover,
                        ),
                      )
                          : Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10)),
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        height: 300,
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Tekan untuk memilih gambar",
                              style: TextStyle(
                                fontSize: Theme
                                    .of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.fontSize,
                                fontWeight: FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Icon(
                              Icons.camera_alt_rounded,
                              size: 80.0,
                              color: Colors.grey.shade700,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  "Pilih Jenis Sampah",
                  style: TextStyle(
                      fontSize: Theme
                          .of(context)
                          .textTheme
                          .titleMedium
                          ?.fontSize,
                      fontWeight: FontWeight.bold),
                ),
                garbageTypes(),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  "Pilih Lokasi",
                  style: TextStyle(
                      fontSize: Theme
                          .of(context)
                          .textTheme
                          .titleMedium
                          ?.fontSize,
                      fontWeight: FontWeight.bold),
                ),
                radioButtonList(),
                trashLocation(),
                SizedBox(
                  height: 20.0,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Lokasi Sampah",
                      style: TextStyle(
                          fontSize:
                          Theme
                              .of(context)
                              .textTheme
                              .titleMedium
                              ?.fontSize,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      "$trashLocationAddress",
                      style: TextStyle(
                          fontSize:
                          Theme
                              .of(context)
                              .textTheme
                              .titleMedium
                              ?.fontSize,
                          fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  "Pilih Periode Tanggal Tersedia",
                  style: TextStyle(
                      fontSize: Theme
                          .of(context)
                          .textTheme
                          .titleMedium
                          ?.fontSize,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        dateSelectCard("Tanggal Mulai", _startDate, startDate),
                        dateSelectCard(
                            "Tanggal Pengembalian", _returnDate, returnDate),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  "Pilih Periode Waktu Tersedia",
                  style: TextStyle(
                      fontSize: Theme
                          .of(context)
                          .textTheme
                          .titleMedium
                          ?.fontSize,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        timeSelectCard(
                            "Waktu Mulai", _startTime, _timeS.format(context)),
                        timeSelectCard(
                            "Waktu Pengembalian", _returnTime,
                            _timeR.format(context)),
                      ],
                    ),
                  ),
                ),
                MinButtonWidget(
                  onClicked: () {
                    getCheckboxItems();
                    //printTrashPickUpDetails();
                    validatePickUp();
                  },
                  color: AppThemeData().secondaryColor,
                  text: "OK", 
                ),
                SizedBox(
                  height: 40.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}