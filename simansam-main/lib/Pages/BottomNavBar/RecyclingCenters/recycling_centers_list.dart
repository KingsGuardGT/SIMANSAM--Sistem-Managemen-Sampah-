import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:simansam/Models/recycling_center_model.dart';
import 'package:simansam/Theme/theme_provider.dart';

class RecyclingCentersList extends StatefulWidget {
  @override
  _RecyclingCentersListState createState() => _RecyclingCentersListState();
}

class _RecyclingCentersListState extends State<RecyclingCentersList> {
  final firestoreInstance = FirebaseFirestore.instance;
  RecyclingCenterModel recyclingCenterModel;
  String accountType = "Pengumpul Sampah";
  bool viewTrashPicker = false;
  GoogleMapController _mapController;
  LatLng _initialPosition = LatLng(37.42796133580664, -122.085749655962);
  LatLng _selectedPosition;

  Future<void> addRecyclingCenter(
      String name, String address, String phone, GeoPoint location) async {
    await FirebaseFirestore.instance.collection("PusatDaurUlang").add({
      "name": name,
      "address": address,
      "phone": phone,
      "location": location,
    });
  }

  Future<void> editRecyclingCenter(
      String id, String name, String address, String phone, GeoPoint location) async {
    await FirebaseFirestore.instance
        .collection("PusatDaurUlang")
        .doc(id)
        .update({
      "name": name,
      "address": address,
      "phone": phone,
      "location": location,
    });
  }

  Future<void> deleteRecyclingCenter(String id) async {
    await FirebaseFirestore.instance.collection("PusatDaurUlang").doc(id).delete();
  }

  loadingProgress() {
    return Container(
      child: Center(
        child: SizedBox(
          child: CircularProgressIndicator(),
          height: 40.0,
          width: 40.0,
        ),
      ),
    );
  }

  Widget recyclingCentersDetailsCard(AsyncSnapshot<QuerySnapshot> snapshot,
      RecyclingCenterModel recyclingCenterModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: Colors.grey.shade100,
          child: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            onTap: () {
              print('Sampah Terpilih: ${recyclingCenterModel.id}');
              _showEditDialog(recyclingCenterModel);
            },
            child: snapshot.data.docs.length == null
                ? Container()
                : Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipOval(
                    child: Image.asset(
                      "assets/icons/icon_recycle.png",
                      fit: BoxFit.cover,
                      height: 80,
                      width: 80,
                    ),
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          recyclingCenterModel.name,
                          style: TextStyle(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  .fontSize,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).primaryColor),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(
                          recyclingCenterModel.address,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: AppThemeData
                                  .lightTheme.iconTheme.color),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(
                          recyclingCenterModel.phone,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: AppThemeData
                                  .lightTheme.iconTheme.color),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _recyclingCentersList() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("PusatDaurUlang")
            .orderBy('name', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loadingProgress();
          }
          return!snapshot.hasData
              ? Container()
              : snapshot.data.docs.length.toString() == "0"
              ? Container(
            height: 250.0,
            width: 200.0,
            child: Column(
              children: [
                SizedBox(
                  height: 30.0,
                ),
                Text(
                  "Belum Ada Pusat Daur Ulang",
                  style: TextStyle(
                      fontSize: Theme.of(context)
                          .textTheme
                          .titleLarge
                          .fontSize),
                ),
                ClipOval(
                  child: Image.asset(
                    'assets/images/simansam_user_avatar.png',
                    height: 60.0,
                    width: 60.0,
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
            scrollDirection: Axis.vertical,
            physics: BouncingScrollPhysics(),
            itemCount: snapshot.data.docs.length,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot documentSnapshot = snapshot.data.docs[index];
              if (documentSnapshot.exists) {
                recyclingCenterModel = RecyclingCenterModel.fromDocument(
                    documentSnapshot);
                return recyclingCentersDetailsCard(
                    snapshot, recyclingCenterModel);
              } else {
                return Container(); // or some other widget to display when the document doesn't exist
              }
            },
          );
        },
      ),
    );
  }

  _selectLocation() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          initialPosition: _initialPosition,
          onPositionChanged: (position) {
            setState(() {
              _selectedPosition = position;
            });
          },
        ),
      ),
    );
  }

  _showEditDialog(RecyclingCenterModel recyclingCenterModel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Recycling Center'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: recyclingCenterModel.name,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: recyclingCenterModel.address,
                decoration: InputDecoration(
                  labelText: 'Address',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: recyclingCenterModel.phone,
                decoration: InputDecoration(
                  labelText: 'Phone',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await _selectLocation();
                if (_selectedPosition!= null) {
                  await editRecyclingCenter(
                    recyclingCenterModel.id,
                    recyclingCenterModel.name,
                    recyclingCenterModel.address,
                    recyclingCenterModel.phone,
                    GeoPoint(_selectedPosition.latitude, _selectedPosition.longitude),
                  );
                }
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
            ElevatedButton(
              onPressed: () async {
                await deleteRecyclingCenter(recyclingCenterModel.id);
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 10.0,
              ),
              _recyclingCentersList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _selectLocation();
          if (_selectedPosition!= null) {
            await addRecyclingCenter(
              'New Recycling Center',
              '123 Example Street',
              '12345678',
              GeoPoint(_selectedPosition.latitude, _selectedPosition.longitude),
            );
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  final LatLng initialPosition;
  final Function(LatLng) onPositionChanged;

  MapScreen({this.initialPosition, this.onPositionChanged});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController _mapController;
  Marker _marker;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.initialPosition,
          zoom: 12,
        ),
        onMapCreated: (controller) {
          setState(() {
            _mapController = controller;
          });
        },
        onTap: (position) {
          setState(() {
            _marker = Marker(
              markerId: MarkerId('1'),
              position: position,
            );
            widget.onPositionChanged(position);
          });
        },
        markers: _marker!= null? {_marker} : {},
      ),
    );
  }
}