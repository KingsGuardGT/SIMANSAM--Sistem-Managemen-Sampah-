import 'package:flutter/material.dart';

class MarkerDetailsCard {
  detailsTitle(BuildContext context, String detailsTitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        detailsTitle,
        style: TextStyle(
            color: Theme.of(context).textTheme.titleSmall.color,
            fontSize: Theme.of(context).textTheme.titleSmall.fontSize,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  detailsName(BuildContext context, String detailsName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        detailsName,
        style: TextStyle(
            color: Theme.of(context).textTheme.titleSmall.color,
            fontSize: Theme.of(context).textTheme.titleSmall.fontSize,
            fontWeight: FontWeight.normal),
      ),
    );
  }

  showSelectLocationDetails(List _trashLocationDetails, context) {
    String latitude,
        longitude,
        name,
        street,
        postalCode,
        administrativeArea,
        subAdministrativeArea,
        thoroughfare,
        subThoroughfare,
        locality,
        subLocality,
        country,
        isoCountryCode;

    if (_trashLocationDetails[0] == "") {
      latitude = "Tidak ditemukan latitude";
    } else {
      latitude = _trashLocationDetails[0].toString();
    }

    if (_trashLocationDetails[1] == "") {
      longitude = "Tidak ditemukan longitude";
    } else {
      longitude = _trashLocationDetails[1].toString();
    }

    if (_trashLocationDetails[2] == "") {
      name = "Tidak ditemukan nama";
    } else {
      name = _trashLocationDetails[2].toString();
    }

    if (_trashLocationDetails[3] == "") {
      street = "Tidak ditemukan jalan";
    } else {
      street = _trashLocationDetails[3].toString();
    }

    if (_trashLocationDetails[4] == "") {
      postalCode = "Tidak ditemukan kode pos";
    } else {
      postalCode = _trashLocationDetails[4].toString();
    }

    if (_trashLocationDetails[5] == "") {
      administrativeArea = "Tidak ditemukan daerah administratif";
    } else {
      administrativeArea = _trashLocationDetails[5].toString();
    }

    if (_trashLocationDetails[6] == "") {
      subAdministrativeArea = "Tidak ditemukan sub daerah administratif";
    } else {
      subAdministrativeArea = _trashLocationDetails[6].toString();
    }

    if (_trashLocationDetails[7] == "") {
      thoroughfare = "Tidak ditemukan jalan utama";
    } else {
      thoroughfare = _trashLocationDetails[7].toString();
    }

    if (_trashLocationDetails[8] == "") {
      subThoroughfare = "Tidak ditemukan sub jalan utama";
    } else {
      subThoroughfare = _trashLocationDetails[8].toString();
    }

    if (_trashLocationDetails[9] == "") {
      locality = "Tidak ditemukan lokasi";
    } else {
      locality = _trashLocationDetails[9].toString();
    }

    if (_trashLocationDetails[10] == "") {
      subLocality = "Tidak ditemukan sub lokasi";
    } else {
      subLocality = _trashLocationDetails[10].toString();
    }

    if (_trashLocationDetails[11] == "") {
      country = "Tidak ditemukan negara";
    } else {
      country = _trashLocationDetails[11].toString();
    }

    if (_trashLocationDetails[12] == "") {
      isoCountryCode = "Tidak ditemukan kode negara ISO";
    } else {
      isoCountryCode = _trashLocationDetails[12].toString();
    }

    return SingleChildScrollView(
      child: Container(
        color: Theme.of(context).appBarTheme.backgroundColor,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 14.0,
                        ),
                        Text(
                          "Alamat Lokasi",
                          style: TextStyle(
                              color:
                              Theme.of(context).textTheme.titleLarge.color,
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  .fontSize,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.cancel_rounded),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                SizedBox(
                  height: 10.0,
                ),
                detailsTitle(context, "Latitude"),
                detailsName(context, latitude),SizedBox(
                  height: 5.0,
                ),
                detailsTitle(context, "Longitude"),
                detailsName(context, longitude),
                SizedBox(
                  height: 5.0,
                ),
                detailsTitle(context, "Nama"),
                detailsName(context, name),
                SizedBox(
                  height: 5.0,
                ),
                detailsTitle(context, "Jalan"),
                detailsName(context, street),
                SizedBox(
                  height: 5.0,
                ),
                detailsTitle(context, "Kode Pos"),
                detailsName(context, postalCode),
                SizedBox(
                  height: 5.0,
                ),
                detailsTitle(context, "Daerah Administratif"),
                detailsName(context, administrativeArea),
                SizedBox(
                  height: 5.0,
                ),
                detailsTitle(context, "Sub Daerah Administratif"),
                detailsName(context, subAdministrativeArea),
                SizedBox(
                  height: 5.0,
                ),
                detailsTitle(context, "Jalan Utama"),
                detailsName(context, thoroughfare),
                SizedBox(
                  height: 5.0,
                ),
                detailsTitle(context, "Sub Jalan Utama"),
                detailsName(context, subThoroughfare),
                SizedBox(
                  height: 5.0,
                ),
                detailsTitle(context, "Lokasi"),
                detailsName(context, locality),
                SizedBox(
                  height: 5.0,
                ),
                detailsTitle(context, "Sub Lokasi"),
                detailsName(context, subLocality),
                SizedBox(
                  height: 5.0,
                ),
                detailsTitle(context, "Negara"),
                detailsName(context, country),
                SizedBox(
                  height: 5.0,
                ),
                detailsTitle(context, "Kode Negara ISO"),
                detailsName(context, isoCountryCode),
                SizedBox(
                  height: 80.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}