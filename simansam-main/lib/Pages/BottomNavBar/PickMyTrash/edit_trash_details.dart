import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simansam/Models/trash_pick_ups_model.dart';
import 'package:simansam/Widgets/button_widgets.dart';


class EditTrashDetails extends StatefulWidget {
  final String userID, trashID, accountType;

  EditTrashDetails(this.userID, this.trashID, this.accountType);

  @override
  _EditTrashDetailsState createState() => _EditTrashDetailsState();
}

class _EditTrashDetailsState extends State<EditTrashDetails> {
  final userReference = FirebaseFirestore.instance.collection('Users');
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  late String _trashName, _trashDescription, _trashLocationAddress, _startDate, _returnDate, _startTime, _returnTime, _postedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Tentang Sampah"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(widget.userID)
            .collection('PengambilanSampah')
            .where('trashID', isEqualTo: widget.trashID)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          } else {
            TrashPickUpsModel trashPickUpsModel =
            TrashPickUpsModel.fromDocument(snapshot.data!.docs[0]);

            _trashName = trashPickUpsModel.trashName;
            _trashDescription = trashPickUpsModel.trashDescription;
            _trashLocationAddress = trashPickUpsModel.trashLocationAddress;
            _startDate = trashPickUpsModel.startDate;
            _returnDate = trashPickUpsModel.returnDate;
            _startTime = trashPickUpsModel.startTime;
            _returnTime = trashPickUpsModel.returnTime;
            _postedDate = trashPickUpsModel.postedDate;

            return Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nama Sampah",
                      style: TextStyle(
                          fontSize:
                          Theme.of(context).textTheme.titleMedium?.fontSize,
                          fontWeight: FontWeight.bold),
                    ),
                    TextFormField(
                      initialValue: _trashName,
                      decoration: InputDecoration(
                        hintText: "Masukkan nama sampah",
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Nama sampah tidak boleh kosong";
                        }
                        return null;
                      },
                      onSaved: (value) => _trashName = value!,
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Text(
                      "Deskripsi Sampah",
                      style: TextStyle(
                          fontSize:
                          Theme.of(context).textTheme.titleMedium?.fontSize,
                          fontWeight: FontWeight.bold),
                    ),
                    TextFormField(
                      initialValue: _trashDescription,
                      decoration: InputDecoration(
                        hintText: "Masukkan deskripsi sampah",
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Deskripsi sampah tidak boleh kosong";
                        }
                        return null;
                      },
                      onSaved: (value) => _trashDescription = value!,
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Text(
                      "Lokasi Sampah",
                      style: TextStyle(
                          fontSize:
                          Theme.of(context).textTheme.titleMedium?.fontSize,
                          fontWeight: FontWeight.bold),
                    ),
                    TextFormField(
                      initialValue: _trashLocationAddress,
                      decoration: InputDecoration(
                        hintText: "Masukkan lokasi sampah",
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Lokasi sampah tidak boleh kosong";
                        }
                        return null;
                      },
                      onSaved: (value) => _trashLocationAddress = value!,
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Text(
                      "Tanggal Diposting",
                      style: TextStyle(
                          fontSize:
                          Theme.of(context).textTheme.titleMedium?.fontSize,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Center(
                      child: MinButtonWidget(
                        text: "Simpan Perubahan",
                        color: Theme.of(context).colorScheme.background,
                        onClicked: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState?.save();

                            await userReference
                                .doc(widget.userID)
                                .collection('PengambilanSampah')
                                .doc(trashPickUpsModel.trashID)
                                .update({
                              'trashName': _trashName,
                              'trashDescription': _trashDescription,
                              'trashLocationAddress': _trashLocationAddress,
                              'tartDate': _startDate,
                              'eturnDate': _returnDate,
                              'tartTime': _startTime,
                              'eturnTime': _returnTime,
                              'postedDate': _postedDate,
                            });

                            Navigator.pop(context);
                          }
                        },
                        // or any other unique value
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}