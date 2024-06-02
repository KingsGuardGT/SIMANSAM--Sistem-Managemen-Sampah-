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
  late RecyclingCenterModel recyclingCenterModel;
  String accountType = "Pengumpul Sampah";
  bool viewTrashPicker = false;
  late GoogleMapController _mapController;
  LatLng _initialPosition = LatLng(37.42796133580664, -122.085749655962);
  late LatLng _selectedPosition;

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
            child: snapshot.data?.docs.length == null
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
                                  ?.fontSize,
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
              : snapshot.data?.docs.length.toString() == "0"
              ? Container(
              height: 250.0,
              width: 200.0,
              child: Column(
                children: [
                  SizedBox(
                    height: 30.0,
                  ),
                  Text(
                    "Belum Ada Data",
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              ))
              : ListView.builder(
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (context, index) {
              RecyclingCenterModel recyclingCenterModel =
              RecyclingCenterModel.fromDocument(
                  snapshot.data!.docs[index]);
              return recyclingCentersDetailsCard(
                  snapshot, recyclingCenterModel);
            },
          );
        },
      ),
    );
  }

  _addRecyclingCenterDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController addressController = TextEditingController();
    TextEditingController phoneController = TextEditingController();

    return AlertDialog(
      title: Text("Tambah Pusat Daur Ulang"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Nama",
                  hintText: "Masukkan Nama Pusat Daur Ulang",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: "Alamat",
                  hintText: "Masukkan Alamat Pusat Daur Ulang",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: "Telepon",
                  hintText: "Masukkan Nomor Telepon Pusat Daur Ulang",
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            _addRecyclingCenter(nameController.text, addressController.text,
                phoneController.text);
            Navigator.of(context).pop();
          },
          child: Text("Tambah"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Batal"),
        ),
      ],
    );
  }

  _showAddDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _addRecyclingCenterDialog();
      },
    );
  }

  _addRecyclingCenter(String name, String address, String phone) {
    CollectionReference collectionReference =
    FirebaseFirestore.instance.collection("PusatDaurUlang");
    Map<String, dynamic> recyclingCenter = {
      "name": name,
      "address": address,
      "phone": phone,
    };
    collectionReference.add(recyclingCenter);
  }

  _showEditDialog(RecyclingCenterModel recyclingCenterModel) {
    TextEditingController nameController =
    TextEditingController(text: recyclingCenterModel.name);
    TextEditingController addressController =
    TextEditingController(text: recyclingCenterModel.address);
    TextEditingController phoneController =
    TextEditingController(text: recyclingCenterModel.phone);

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Ubah Pusat Daur Ulang"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Nama",
                      hintText: "Masukkan Nama Pusat Daur Ulang",
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: "Alamat",
                      hintText: "Masukkan Alamat Pusat Daur Ulang",
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: "Telepon",
                      hintText: "Masukkan Nomor Telepon Pusat Daur Ulang",
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _editRecyclingCenter(recyclingCenterModel.id, nameController.text,
                    addressController.text, phoneController.text);
                Navigator.of(context).pop();
              },
              child: Text("Ubah"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Batal"),
            ),
          ],
        );
      },
    );
  }

  _editRecyclingCenter(String id, String name, String address, String phone) {
    DocumentReference documentReference =
    FirebaseFirestore.instance.collection("PusatDaurUlang").doc(id);
    Map<String, dynamic> recyclingCenter = {
      "name": name,
      "address": address,
      "phone": phone,
    };
    documentReference.update(recyclingCenter);
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
        onPressed: _showAddDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  final LatLng initialPosition;
  final Function(LatLng) onPositionChanged;

  MapScreen({required this.initialPosition, required this.onPositionChanged});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  late Marker _marker;

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