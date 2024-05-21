import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simansam/Models/user_model.dart';

import '../../../Widgets/primary_app_bar_widget.dart';

class HomePage extends StatefulWidget {
  final String accountType;

  HomePage(this.accountType);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final userReference = FirebaseFirestore.instance.collection('Users');
  final FirebaseAuth auth = FirebaseAuth.instance;
  String badgeType;

  @override
  void initState() {
    _setBadgeType();
    super.initState();
  }

  _setBadgeType() {
    if (widget.accountType == "Pengumpul Sampah") {
      badgeType = "Pengumpul";
    } else if (widget.accountType == "Pemungut Sampah") {
      badgeType = "Pemungut";
    }
  }

  _statTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
          fontSize: Theme.of(context).textTheme.titleMedium.fontSize,
          fontWeight: FontWeight.bold),
    );
  }

  _statDetail(double numberValue, bool isDouble) {
    String detailString;
    if (isDouble) {
      detailString = numberValue.toString();
    } else {
      detailString = numberValue.toInt().toString();
    }

    return Text(
      detailString,
      textAlign: TextAlign.center,
      style: TextStyle(
          fontSize: Theme.of(context).textTheme.titleMedium.fontSize,
          fontWeight: FontWeight.bold),
    );
  }

  _badgeRequiresPoints(String points) {
    return Text(
      points,
      textAlign: TextAlign.center,
      style: TextStyle(
          fontSize: Theme.of(context).textTheme.titleMedium.fontSize,
          fontWeight: FontWeight.normal),
    );
  }

  _badgeDesignsWidget(String image, String badgeName, String badgePoints) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          image,
          height: 60.0,
          width: 60.0,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _statTitle(badgeName),
            _badgeRequiresPoints(badgePoints),
          ],
        )
      ],
    );
  }

  welcomeHeader() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Users")
          .where('uuid', isEqualTo: "${auth.currentUser.uid}")
          .snapshots(),
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          //return profileHeaderShimmer();
          return Text(
            "Hai! ",
            style: TextStyle(
                fontSize: Theme.of(context).textTheme.titleLarge.fontSize,
                fontWeight: FontWeight.bold),
          );
        } else {
          UserModelClass userModelClass =
          UserModelClass.fromDocument(dataSnapshot.data.docs[0]);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hai! ${userModelClass.name}",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.titleLarge.fontSize,
                    fontWeight: FontWeight.normal),
              ),
            ],
          );
        }
      },
    );
  }

  _profileStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _statTitle("Total Pengumpulan Sampah"),
                SizedBox(
                  height: 10.0,
                ),
                _statTitle("Total Poin"),
              ],
            ),
            SizedBox(
              width: 20.0,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _statDetail(4, false),
                SizedBox(
                  height: 10.0,
                ),
                _statDetail(52, false),
              ],
            )
          ],
        ),
        Column(
          children: [
            Image.asset(
              'assets/images/badge_starter.png',
              height: 70.0,
              width: 70.0,
            ),
            SizedBox(
              height: 5.0,
            ),
            _statTitle("Pemula\n$badgeType"),
          ],
        )
      ],
    );
  }

  _badgeDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        widget.accountType == "Pengumpul Sampah"
            ? _statTitle("Jadwalkan pengumpulan sampah lebih banyak untuk membuka,")
            : _statTitle("Kumpulkan sampah lebih banyak untuk membuka,"),
        SizedBox(
          height: 10.0,
        ),
        _badgeDesignsWidget('assets/images/badge_bronze.png',
            "Perunggu $badgeType", "100 Poin"),
        SizedBox(
          height: 10.0,
        ),
        _badgeDesignsWidget('assets/images/badge_silver.png',
            "Perak $badgeType", "1000 Poin"),
        SizedBox(
          height: 10.0,
        ),
        _badgeDesignsWidget(
            'assets/images/badge_gold.png', "Emas $badgeType", "10000 Poin"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PrimaryAppBar(
        title: "SIMANSAM",
        appBar: AppBar(),
        widgets: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
            child: Icon(
              Icons.home_rounded,
              color: Theme.of(context).iconTheme.color,
              size: 35.0,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  'assets/logos/trashpick_logo_curved.png',
                  height: 75.0,
                  width: 75.0,
                ),
                SizedBox(
                  height: 10.0,
                ),
                welcomeHeader(),
                Center(
                  child: Text(
                    "Selamat Datang!",
                    style: TextStyle(
                        fontSize:
                        Theme.of(context).textTheme.headlineSmall.fontSize,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
/*                Text(
                  "${widget.accountType}",
                  style: TextStyle(
                      fontSize: Theme.of(context).textTheme.headline4.fontSize,
                      fontWeight: FontWeight.bold),
                ),*/
                _profileStats(),
                SizedBox(
                  height: 30.0,
                ),
                _badgeDetails(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
