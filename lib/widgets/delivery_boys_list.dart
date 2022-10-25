import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vendor_app_for_grocery/services/firebase_services.dart';
import 'package:vendor_app_for_grocery/services/order_services.dart';

class DeliveryBoysList extends StatefulWidget {
  const DeliveryBoysList({Key? key, this.documentSnapshot}) : super(key: key);
  final DocumentSnapshot? documentSnapshot;

  @override
  State<DeliveryBoysList> createState() => _DeliveryBoysListState();
}

class _DeliveryBoysListState extends State<DeliveryBoysList> {
  final FirebaseService _services = FirebaseService();
  final OrderService _orderService = OrderService();
  GeoPoint? shopLocation;
  double? shopLatitude = 0.0;
  double? shopLongitude = 0.0;
  @override
  void initState() {
    _services.getShopDetails().then((value) {
      if (value != null) {
        if (mounted) {
          setState(() {
            shopLocation = value['location'];
            shopLatitude = shopLocation?.latitude;
            shopLongitude = shopLocation?.longitude;
          });
        }
      } else {
        print("No Data Found");
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text(
                "Selected Delivery Boy",
                style: TextStyle(color: Colors.white),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: _services.deliveryBoys
                  .where('accVerified', isEqualTo: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return ListView(
                  shrinkWrap: true,
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    GeoPoint location = document['location'];
                    double distanceInMeters = Geolocator.distanceBetween(
                            shopLatitude!,
                            shopLongitude!,
                            location.latitude,
                            location.longitude) /
                        100;
                    if (distanceInMeters > 10) {
                      return Container();
                    }
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    return Column(
                      children: [
                        ListTile(
                          onTap: () {
                            EasyLoading.show();
                            _orderService
                                .selectBoys(
                                    widget.documentSnapshot?.id,
                                    document['location'],
                                    document['name'],
                                    document['imageUrl'],
                                    document['mobile'],
                                    document['email'])
                                .then((value) {
                              EasyLoading.showSuccess("Delivery Boy Assigned");
                              Navigator.pop(context);
                            });
                          },
                          leading: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: SizedBox(
                                width: 40,
                                child: Image.network(
                                  data['imageUrl'],
                                  fit: BoxFit.fill,
                                )),
                          ),
                          title: Text(data['name']),
                          subtitle:
                              Text("${distanceInMeters.toStringAsFixed(0)} Km"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  GeoPoint location = document['location'];
                                  _orderService.launchMap(
                                      location, "${document['location']}");
                                },
                                icon: const Icon(Icons.map),
                              ),
                              IconButton(
                                onPressed: () {
                                  FlutterPhoneDirectCaller.callNumber(
                                      document['mobile']);
                                },
                                icon: const Icon(Icons.phone),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          height: 2,
                          color: Colors.grey,
                        )
                      ],
                    );
                  }).toList(),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
