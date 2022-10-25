import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';

class OrderService {
  CollectionReference orders = FirebaseFirestore.instance.collection('orders');

  Future updateOrderStatus(documentId, status) async {
    var result = await orders.doc(documentId).update({
      'orderStatus': status,
    });
    return result;
  }

  Color statusColor(DocumentSnapshot documentSnapshot) {
    if (documentSnapshot['orderStatus'] == "Accepted") {
      return Colors.blueGrey;
    }
    if (documentSnapshot['orderStatus'] == "Rejected") {
      return Colors.red;
    }
    if (documentSnapshot['orderStatus'] == "Picked-Up") {
      return Colors.pink;
    }
    if (documentSnapshot['orderStatus'] == "On the Way") {
      return Colors.purple;
    }
    if (documentSnapshot['orderStatus'] == "Delivered") {
      return Colors.green;
    }
    return Colors.orange;
  }

  Icon statusIcon(DocumentSnapshot documentSnapshot) {
    if (documentSnapshot['orderStatus'] == "Accepted") {
      return Icon(
        Icons.assignment_turned_in_outlined,
        color: statusColor(documentSnapshot),
        size: 22,
      );
    }
    if (documentSnapshot['orderStatus'] == "Picked-Up") {
      return Icon(
        Icons.cases,
        color: statusColor(documentSnapshot),
        size: 22,
      );
    }
    if (documentSnapshot['orderStatus'] == "Out For Delivery") {
      return Icon(
        Icons.delivery_dining,
        color: statusColor(documentSnapshot),
        size: 22,
      );
    }
    if (documentSnapshot['orderStatus'] == "Rejected") {
      return Icon(
        Icons.cancel_outlined,
        color: statusColor(documentSnapshot),
        size: 22,
      );
    }
    if (documentSnapshot['orderStatus'] == "Delivered") {
      return Icon(
        Icons.shopping_bag_outlined,
        color: statusColor(documentSnapshot),
        size: 22,
      );
    }
    return Icon(
      Icons.assignment_turned_in_outlined,
      color: statusColor(documentSnapshot),
      size: 22,
    );
  }

  void launchMap(GeoPoint location, name) async {
    final availableMaps = await MapLauncher.installedMaps;

    await availableMaps.first.showMarker(
        coords: Coords(location.latitude, location.longitude), title: name);
  }

  Future selectBoys(orderId, location, name, image, phone, email) {
    var result = orders.doc(orderId).update({
      'deliveryBoy': {
        'location': location,
        'name': name,
        'image': image,
        'phone': phone,
        'email': email,
      }
    });
    return result;
  }
}
