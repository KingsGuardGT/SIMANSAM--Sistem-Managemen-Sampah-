import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simansam/Models/trash_pick_ups_model.dart';
import 'package:simansam/Widgets/button_widgets.dart';
import 'package:simansam/Widgets/secondary_app_bar_widget.dart';

import 'edit_trash_details.dart';

class ViewTrashDetails extends StatefulWidget {
  final String userID, trashID, accountType;

  ViewTrashDetails(this.userID, this.trashID, this.accountType);

  @override
  _ViewTrashDetailsState createState() => _ViewTrashDetailsState();
}

class _ViewTrashDetailsState extends State<ViewTrashDetails> {
  final userReference = FirebaseFirestore.instance.collection('Users');
  final FirebaseAuth auth = FirebaseAuth.instance;
  List? trashTypesList;

  Widget trashTypesFilter(TrashPickUpsModel trashPickUpsModel) {
    return Container(
      height: (trashPickUpsModel.trashTypes.length.toDouble() * 45),
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          physics: BouncingScrollPhysics(),
          itemCount: trashPickUpsModel.trashTypes.length,
          itemBuilder: (BuildContext context, int index) {
            Color trashTypeColor;
            String trashTypeDescription;

            switch (trashPickUpsModel.trashTypes[index]) {
              case "Plastik & Polietilen":
                trashTypeColor = Colors.orange.shade700;
                trashTypeDescription = "Plastik & Polietilen";
                break;
              case "Kaca":
                trashTypeColor = Colors.red;
                trashTypeDescription = "Kaca";
                break;
              case "Kertas":
                trashTypeColor = Colors.blue;
                trashTypeDescription = "Kertas";
                break;
              case "Logam & Tempurung Kelapa":
                trashTypeColor = Colors.black;
                trashTypeDescription = "Logam & Tempurung Kelapa";
                break;
              case "Limbah Klinis":
                trashTypeColor = Colors.yellow;
                trashTypeDescription = "Limbah Klinis";
                break;
              case "Limbah Elektronik":
                trashTypeColor = Colors.grey.shade200;
                trashTypeDescription = "Limbah Elektronik";
                break;
              default:
                trashTypeColor = Colors.grey.shade100;
                trashTypeDescription = "Lainnya";
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
              child: Row(
                children: [
                  Container(
                    height: 20.0,
                    width: 20.0,
                    color: trashTypeColor,
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Text(trashPickUpsModel.trashTypes[index]),
                ],
              ),
            );
          }),
    );
  }

  trashTitle(String title) {
    return Text(
      title,
      style: TextStyle(
          fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
          fontWeight: FontWeight.bold),
    );
  }

  trashDetailsData(String detailsData) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: Text(
        detailsData,
        style: TextStyle(
            fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
            fontWeight: FontWeight.normal),
      ),
    );
  }

  trashAvailableDatesTimes(
      bool isDate, String titleS, String dataS, String titleR, String dataR) {
    IconData typeIcon;

    if (isDate) {
      typeIcon = Icons.date_range_rounded;
    } else {
      typeIcon = Icons.access_time_rounded;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              typeIcon,
              size: 35.0,
            ),
            SizedBox(
              width: 10.0,
            ),
            Column(
              children: [
                trashTitle(titleS),
                trashDetailsData(dataS),
              ],
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              typeIcon,
              size: 35.0,
            ),
            SizedBox(
              width: 10.0,
            ),
            Column(
              children: [
                trashTitle(titleR),
                trashDetailsData(dataR),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget trashDetails() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Users")
          .doc(widget.userID)
          .collection('PengambilanSampah')
          .where('trashID', isEqualTo: widget.trashID)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          //return profileHeaderShimmer();
          return Text(
            "Data tidak tersedia",
            style: TextStyle(
                fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                fontWeight: FontWeight.bold),
          );
        } else {
          TrashPickUpsModel trashPickUpsModel =
              TrashPickUpsModel.fromDocument(snapshot.data!.docs[0]);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${trashPickUpsModel.trashName}",
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headlineSmall?.fontSize,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20.0,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  trashPickUpsModel.trashImage,
                  height: 200.0,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  trashTitle("Lokasi Sampah"),
                  trashDetailsData(trashPickUpsModel.trashLocationAddress),
                  SizedBox(
                    height: 20.0,
                  ),
                  trashTitle("Deskripsi Sampah"),
                  trashDetailsData(trashPickUpsModel.trashDescription),
                  SizedBox(
                    height: 20.0,
                  ),
                  trashTitle("Jenis Sampah"),
                  trashDetailsData(trashPickUpsModel.trashTypes.toString()),
                  trashTypesFilter(trashPickUpsModel),
                  trashAvailableDatesTimes(
                      true,
                      "Tanggal Mulai",
                      trashPickUpsModel.startDate,
                      "Tanggal Kembali",
                      trashPickUpsModel.returnDate),
                  SizedBox(
                    height: 20.0,
                  ),
                  trashAvailableDatesTimes(
                      false,
                      "Tanggal Mulai",
                      trashPickUpsModel.startTime,
                      "Tanggal Kembali",
                      trashPickUpsModel.returnTime),
                  SizedBox(
                    height: 20.0,
                  ),
                  trashTitle("Tanggal Diposting"),
                  trashDetailsData(trashPickUpsModel.postedDate),
                  SizedBox(
                    height: 20.0,
                  ),
                  Center(
                    child: widget.accountType == "Pengumpul Sampah"
                        ? MinButtonWidget(
                            text: "Edit Pengambilan Sampah",
                            color: Theme.of(context).colorScheme.background,
                      onClicked: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditTrashDetails(
                              widget.userID,
                              trashPickUpsModel.trashID,
                              widget.accountType,
                            ),
                          ),
                        );

                        // Refresh the trash details screen after editing
                        setState(() {});
                      },
                          )
                        : Container(),
                  ),
                ],
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
      appBar: SecondaryAppBar(
        title: "Tentang Sampah",
        appBar: AppBar(),
        widgets: <Widget>[
          Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
              child: Image.asset(
                "assets/icons/icon_trash_sort.png",
                height: 35.0,
                width: 35.0,
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: trashDetails(),
        ),
      ),
    );
  }
}
