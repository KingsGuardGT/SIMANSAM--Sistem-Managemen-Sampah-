import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simansam/Pages/BottomNavBar/PickMyTrash/pick_my_trash_page.dart';
import 'package:simansam/Pages/BottomNavBar/TrashToBeCollected/trash_to_be_collected_page.dart';


import '../../Theme/theme_provider.dart';
import 'package:simansam/Pages/BottomNavBar/BeAware/be_aware.dart';
import 'package:simansam/Pages/BottomNavBar/Home/home_page.dart';
import 'RecyclingCenters/recycling_centers_page.dart';
import 'Settings/settings_page.dart';

class BottomNavBar extends StatefulWidget {
  final String accountType;

  BottomNavBar(this.accountType);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedPage = 0;
  List<Widget> pageList = [];

  String uuid = FirebaseAuth.instance.currentUser!.uid.toString();

  @override
  void initState() {
    checkAccountType();
    super.initState();
  }

  List<BottomNavigationBarItem> appBottomNavBarItems =
  const <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(
        Icons.home_rounded,
        size: 30.0,
      ),
      label: 'Beranda',
    ),
    BottomNavigationBarItem(
      icon: Icon(
        Icons.transfer_within_a_station_rounded,
        size: 30.0,
      ),
      label: 'Sampah untuk dikumpulkan',
    ),
    BottomNavigationBarItem(
      icon: Icon(
        Icons.restore_from_trash,
        size: 30.0,
      ),
      label: 'Pusat Daur Ulang',
    ),
    BottomNavigationBarItem(
      icon: Icon(
        Icons.notifications_rounded,
        size: 30.0,
      ),
      label: 'Tetap Sadar',
    ),
    BottomNavigationBarItem(
      icon: Icon(
        Icons.settings_rounded,
        size: 30.0,
      ),
      label: 'Profil Saya',
    ),
  ];

  appBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedPage,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: AppThemeData().primaryColor,
      unselectedItemColor: AppThemeData().greyColor,
      onTap: _onItemTapped,
      items: appBottomNavBarItems,
    );
  }

  checkAccountType() async {
    pageList.add(HomePage(widget.accountType));
    print(
        "----------------------- SWITCH TAB FOR ACCOUNT TYPE: ${widget.accountType} -----------------------");
    if (widget.accountType == "Pengumpul Sampah") {
      print("Current User Account Type: Pengumpul Sampah");
      pageList.add(PickMyTrash(widget.accountType));
    } else {
      print("Current User Account Type: Pemungut Sampah");
      pageList.add(TrashToBeCollected());
    }
    pageList.add(RecyclingCenters());
    pageList.add(BeAware());
    pageList.add(SettingsPage());
  }

  @override
    Widget build(BuildContext context) {
      return WillPopScope(
        onWillPop: () async {
          final result = await showDialog<bool>(
            context: context,
            builder: (c) => AlertDialog(
              title: Text('Keluar dari SIMANSAM'),
              content: Text('Apakah Anda benar-benar ingin keluar?'),
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
          );
          return result?? false; // return false if result is null
        },
        child: Scaffold(
          backgroundColor: AppThemeData().whiteColor,
          body: IndexedStack(
            index: _selectedPage,
            children: pageList,
          ),
          bottomNavigationBar: appBottomNavBar(),
        ),
      );
    }

  void _onItemTapped(int index) {
    setState(() {
      _selectedPage = index;
    });
  }
}