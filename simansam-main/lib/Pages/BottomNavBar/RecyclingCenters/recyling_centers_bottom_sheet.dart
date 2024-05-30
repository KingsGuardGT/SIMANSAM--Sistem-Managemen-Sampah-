import 'package:flutter/material.dart';
import 'package:simansam/Models/recycling_center_model.dart';

class RecyclingCentersBottomSheet {
  judulDetail(BuildContext context, String judulDetail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        judulDetail,
        style: TextStyle(
            color: Theme.of(context).textTheme.titleSmall.color,
            fontSize: Theme.of(context).textTheme.titleSmall.fontSize,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  namaDetail(BuildContext context, String namaDetail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        namaDetail,
        style: TextStyle(
            color: Theme.of(context).textTheme.titleSmall.color,
            fontSize: Theme.of(context).textTheme.titleSmall.fontSize,
            fontWeight: FontWeight.normal),
      ),
    );
  }

  showCentersDetails(BuildContext context,
      RecyclingCenterModel recyclingCenterModel, var latitude, var longitude) {
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
                          "PusatDaurUlang",
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
                  height: 5.0,
                ),
                judulDetail(context, "Nama"),
                namaDetail(context, recyclingCenterModel.name),
                SizedBox(
                  height: 5.0,
                ),
                judulDetail(context, "Telepon"),
                namaDetail(context, recyclingCenterModel.phone),
                SizedBox(
                  height: 5.0,
                ),
                judulDetail(context, "Alamat"),
                namaDetail(context, recyclingCenterModel.address),
                SizedBox(
                  height: 10.0,
                ),
                judulDetail(context, "Lintang"),
                namaDetail(context, latitude.toString()),
                SizedBox(
                  height: 5.0,
                ),
                judulDetail(context, "Bujur"),
                namaDetail(context, longitude.toString()),
/*                SizedBox(
                  height: 5.0,
                ),
                judulDetail(context, "Jalan"),
                namaDetail(context, street),
                SizedBox(
                  height: 5.0,
                ),
                judulDetail(context, "Kode Pos"),
                namaDetail(context, postalCode),
                SizedBox(
                  height: 5.0,
                ),
                judulDetail(context, "Area Administratif"),
                namaDetail(context, administrativeArea),
                SizedBox(
                  height: 5.0,
                ),
                judulDetail(context, "Sub Area Administratif"),
                namaDetail(context, subAdministrativeArea),
                SizedBox(
                  height: 5.0,
                ),
                judulDetail(context, "Jalan Raya"),
                namaDetail(context, thoroughfare),
                SizedBox(
                  height: 5.0,
                ),
                judulDetail(context, "Sub Jalan Raya"),
                namaDetail(context, subThoroughfare),
                SizedBox(
                  height: 5.0,
                ),
                judulDetail(context, "Kota"),
                namaDetail(context, locality),
                SizedBox(
                  height: 5.0,
                ),
                judulDetail(context, "Sub Kota"),
                namaDetail(context, subLocality),
                SizedBox(
                  height: 5.0,
                ),
                judulDetail(context, "Negara"),
                namaDetail(context, country),
                SizedBox(
                  height: 5.0,
                ),
                judulDetail(context, "Kode Negara ISO"),
                namaDetail(context, isoCountryCode),*/
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