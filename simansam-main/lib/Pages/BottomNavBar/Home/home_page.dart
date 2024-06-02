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
  late String badgeType;

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

  // _statTitle(String title) {
  //   return Text(
  //     title,
  //     textAlign: TextAlign.center,
  //     style: TextStyle(
  //         fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
  //         fontWeight: FontWeight.bold),
  //   );
  // }

  welcomeHeader() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Users")
          .where('uuid', isEqualTo: "${auth.currentUser?.uid}")
          .snapshots(),
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          //return profileHeaderShimmer();
          return Text(
            "Hai! ",
            style: TextStyle(
                fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                fontWeight: FontWeight.bold),
          );
        } else {
          UserModelClass userModelClass =
          UserModelClass.fromDocument(dataSnapshot.data!.docs[0]);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hai! ${userModelClass.name}",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                    fontWeight: FontWeight.normal),
              ),
            ],
          );
        }
      },
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
         // or any other unique value
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
                        Theme.of(context).textTheme.headlineSmall?.fontSize,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
