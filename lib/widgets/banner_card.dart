import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vendor_app_for_grocery/services/firebase_services.dart';

class BannerCard extends StatelessWidget {
  const BannerCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseService _services = FirebaseService();
    return StreamBuilder<QuerySnapshot>(
      stream: _services.vendorBanner.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("");
        }

        return Container(
          height: 180,
          width: MediaQuery.of(context).size.width,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return Stack(
                children: [
                  SizedBox(
                    height: 180,
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                      child: Image.network(
                        data['imageUrl'],
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 10,
                    child: CircleAvatar(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        child: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            EasyLoading.show(status: "Deleting...");
                            _services.deleteBannerVendor(id: document.id);
                            EasyLoading.dismiss();
                          },
                        )),
                  )
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
