import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../Pages/OnAppStart/welcome_page.dart';
import '../../Theme/theme_provider.dart';
import '../../Widgets/button_widgets.dart';

class CheckAppPermissions extends StatefulWidget {
  @override
  _CheckAppPermissionsState createState() => _CheckAppPermissionsState();
}

class _CheckAppPermissionsState extends State<CheckAppPermissions> {
  bool locationPermission = false;
  bool cameraPermission = false;
  bool storagePermission = false;

  _requestLocationPermission() async {
    print("----------------------- MEMINTA IJIN LOKASI!");
    final serviceStatus = await Permission.locationWhenInUse.serviceStatus;
    final isGpsOn = serviceStatus == ServiceStatus.enabled;
    if (!isGpsOn) {
      print('HIDUPKAN LAYANAN LOKASI SEBELUM MEMINTA IJIN.');
      return;
    }

    final status = await Permission.locationWhenInUse.request();
    if (status == PermissionStatus.granted) {
      print('IJIN LOKASI DITERIMA!');
      setState(() {
        locationPermission = true;
      });
    } else if (status == PermissionStatus.denied) {
      print('IJIN LOKASI DITOLAK!');
      displayPermissionAlert(context, "Lokasi");
      print(
          "----------------------- MENAMPILKAN_ALERT_IJIN - LOKASI DIPANGGIL!");
    } else if (status == PermissionStatus.permanentlyDenied) {
      print('BUKA PENGGATURAN APLIKASI');
      await openAppSettings();
    }
  }

  _requestCameraPermission() async {
    print("----------------------- MEMINTA IJIN KAMERA!");
    final status = await Permission.camera.request();
    if (status == PermissionStatus.granted) {
      print('IJIN KAMERA DITERIMA!');
      setState(() {
        cameraPermission = true;
      });
    } else if (status == PermissionStatus.denied) {
      print('IJIN KAMERA DITOLAK!');
      displayPermissionAlert(context, "Kamera");
      print(
          "----------------------- MENAMPILKAN_ALERT_IJIN - KAMERA DIPANGGIL!");
    } else if (status == PermissionStatus.permanentlyDenied) {
      print('BUKA PENGGATURAN APLIKASI');
      await openAppSettings();
    }
  }

  _requestStoragePermission() async {
    print("----------------------- MEMINTA IJIN PENYIMPANAN!");
    final status = await Permission.storage.request();
    if (status == PermissionStatus.granted) {
      print('Ijin penyimpanan diterima.');
      setState(() {
        storagePermission = true;
      });
    } else if (status == PermissionStatus.denied) {
      print('Ijin penyimpanan ditolak.');
      displayPermissionAlert(context, "Penyimpanan");
      print(
          "----------------------- MENAMPILKAN_ALERT_IJIN - PENYIMPANAN DIPANGGIL!");
    } else if (status == PermissionStatus.permanentlyDenied) {
      print('BUKA PENGGATURAN APLIKASI');
      await openAppSettings();
    }
  }

  _openAppSettings() async {
    await openAppSettings();
  }

  displayPermissionAlert(
      BuildContext contextDisplayPermissionAlert, String permissionName) {
    Widget cancelButton = TextButton(
      child: Text("Batal"),
      onPressed: () {
        print('MENAMPILKAN_ALERT_IJIN - DIBATALKAN!');
        Navigator.pop(contextDisplayPermissionAlert);
        displayPermissionRequest(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Berikan Izin"),
      onPressed: () {
        print("MENAMPILKAN_ALERT_IJIN - BERIKAN IZIN!");
        if (permissionName == "Lokasi") {
          _requestLocationPermission();
        } else if (permissionName == "Kamera") {
          _requestCameraPermission();
        } else if (permissionName == "Penyimpanan") {
          _requestStoragePermission();
        }

        Navigator.pop(contextDisplayPermissionAlert);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Izin $permissionName Diperlukan"),
      content: Text("Anda harus memberikan izin $permissionName untuk melanjutkan."),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: contextDisplayPermissionAlert,
      barrierDismissible: false,
      builder: (BuildContext contextDisplayPermissionAlert) {
        return WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: alert);
      },
    );
  }

  displayPermissionRequest(BuildContext contextDisplayPermissionRequest) {
    Widget denyButton = TextButton(
      child: Text("Keluar dari Aplikasi"),
      onPressed: () {
        print("----------------------- KELUAR DARI APLIKASI!");
        SystemNavigator.pop();
      },
    );
    Widget allowButton = TextButton(
      child: Text("Izinkan Izin"),
      onPressed: () async {
        print("----------------------- TOMBOL IZIN DITEKAN!");
        Navigator.pop(contextDisplayPermissionRequest);
        _requestLocationPermission();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Izin Diperlukan"),
      content: Text(
          "Kami meminta akses ke lokasi, kamera, dan ruang penyimpanan Anda. "
              "Aplikasi akan mengambil lokasi Anda untuk menemukan Anda dan memberi Anda akses ke peta. "
              "Kamera akan digunakan untuk mengambil foto untuk digunakan dalam postingan dan acara. "
              "Akses penyimpanan mencari foto untuk digunakan dalam pemilih Anda."),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      actions: [
        denyButton,
        allowButton,
      ],
    );

    showDialog(
      context: contextDisplayPermissionRequest,
      barrierDismissible: false,
      builder: (BuildContext contextDisplayPermissionRequest) {
        return WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: alert);
      },
    );
  }

  @override
  void initState() {
    print(
        "----------------------- HALAMAN PENGECEKAN IZIN DIINISIALISASI -----------------------");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => (await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text('Keluar dari SIMANSAM'),
          content: Text('Apakah Anda benar-benar ingin keluar'),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          actions: [
            TextButton(
              child: Text('Ya'),
              onPressed: () => Navigator.pop(c, true),
            ),
            TextButton(
              child: Text('Tidak'),
              onPressed: () => Navigator.pop(c, false),
            ),
          ],
        ),
      ))?? false,
      child: Scaffold(
        backgroundColor: AppThemeData().greenAccentColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 20),
                  Image.asset(
                    'assets/logos/trashpick_logo_banner.png',
                    height: 150,
                    width: 150,
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Izin diperlukan ',
                    style:
                    TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Image.asset(
                            'assets/images/location.png',
                            scale: 3.0,
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            "Lokasi",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.fontSize),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Image.asset(
                            'assets/images/camera.png',
                            scale: 3.0,
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            "Kamera",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.fontSize),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Image.asset(
                            'assets/images/storage.png',
                            scale: 3.0,
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            "Penyimpanan",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.fontSize),
                          )
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "Kami meminta akses ke lokasi, kamera, dan ruang penyimpanan Anda. "
                          "Aplikasi akan mengambil lokasi Anda untuk menemukan Anda dan memberi Anda akses ke peta. "
                          "Kamera akan digunakan untuk mengambil foto untuk digunakan dalam postingan dan acara. "
                          "Akses penyimpanan mencari foto untuk digunakan dalam pemilih Anda.",
                      style: TextStyle(
                          fontSize:
                          Theme.of(context).textTheme.titleMedium?.fontSize),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            locationPermission
                                ? Image.asset(
                              'assets/icons/icon_approval.png',
                              scale: 4.0,
                            )
                                : Image.asset(
                              'assets/icons/icon_access_denied.png',
                              scale: 4.0,
                            ),
                            TextButton(
                              child: Text(
                                'Klik untuk mengizinkan izin lokasi',
                                style: TextStyle(
                                    color: AppThemeData().secondaryColor),
                              ),
                              onPressed: _requestLocationPermission,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            cameraPermission
                                ? Image.asset(
                              'assets/icons/icon_approval.png',
                              scale: 4.0,
                            )
                                : Image.asset(
                              'assets/icons/icon_access_denied.png',
                              scale: 4.0,
                            ),
                            TextButton(
                              child: Text(
                                'Klik untuk mengizinkan izin kamera',
                                style: TextStyle(
                                    color: AppThemeData().secondaryColor),
                              ),
                              onPressed: _requestCameraPermission,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            storagePermission
                                ? Image.asset(
                              'assets/icons/icon_approval.png',
                              scale: 4.0,
                            )
                                : Image.asset(
                              'assets/icons/icon_access_denied.png',
                              scale: 4.0,
                            ),
                            TextButton(
                              child: Text(
                                'Klik untuk mengizinkan izin penyimpanan',
                                style: TextStyle(
                                    color: AppThemeData().secondaryColor),
                              ),
                              onPressed: _requestStoragePermission,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  locationPermission && cameraPermission && storagePermission
                      ? ButtonWidget(
                    color: AppThemeData().secondaryColor,
                    onClicked: () {
                      print(
                          "----------------------- Lanjutkan ke Aplikasi -----------------------");
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              WelcomePage(),
                        ),
                            (route) => false,
                      );
                    },
                    text: "Lanjutkan ke Aplikasi",
                    textColor: AppThemeData().whiteColor, 
                  )
                      : Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}