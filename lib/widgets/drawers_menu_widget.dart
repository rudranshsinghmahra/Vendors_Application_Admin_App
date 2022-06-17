import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app_for_grocery/providers/products_provider.dart';
import 'package:vendor_app_for_grocery/screens/add_edit_coupon_screen.dart';
import 'package:vendor_app_for_grocery/screens/banners_screen.dart';
import 'package:vendor_app_for_grocery/screens/coupon_screen.dart';
import 'package:vendor_app_for_grocery/screens/products_screen.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  User? user = FirebaseAuth.instance.currentUser;
  var vendorsData;

  @override
  void initState() {
    getVendorsData();
    super.initState();
  }

  Future<DocumentSnapshot> getVendorsData() async {
    var result = await FirebaseFirestore.instance
        .collection('vendors')
        .doc(user?.uid)
        .get();

    setState(() {
      vendorsData = result;
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ProductProvider>(context);
    provider.getShopName(vendorsData != null ? vendorsData['shopName'] : "");
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(0.0),
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
              vendorsData != null ? vendorsData['shopName'] : 'ShopName',
              style: const TextStyle(color: Colors.black),
            ),
            accountEmail: Text(
              vendorsData != null ? vendorsData['email'] : 'abc@gmail.com',
              style: const TextStyle(color: Colors.black),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: vendorsData != null
                  ? NetworkImage(vendorsData['imageUrl'])
                  : null,
            ),
            onDetailsPressed: () {},
          ),
          ListTile(
            title: const Text('Dashboard'),
            leading: const Icon(Icons.dashboard_outlined),
            onTap: () {},
          ),
          ListTile(
            onTap: () {
              Navigator.pushNamed(context, ProductScreen.id);
            },
            title: Text('Products'),
            leading: Icon(Icons.shopping_bag_outlined),
          ),
          const Divider(),
          ListTile(
            onTap: () {
              Navigator.pushNamed(context, BannerScreen.id);
            },
            title: Text('Banners'),
            leading: Icon(Icons.photo),
          ),
          const Divider(),
          ListTile(
            title: const Text('Coupons'),
            leading: const Icon(CupertinoIcons.gift),
            onTap: () {
              Navigator.pushNamed(context, CouponScreen.id);
            },
          ),
          ListTile(
            title: const Text('Orders'),
            leading: const Icon(Icons.list_alt_outlined),
            onTap: () {},
          ),
          ListTile(
            title: Text('Reports'),
            leading: Icon(Icons.stacked_bar_chart),
            onTap: () {},
          ),
          Divider(),
          Divider(),
          ListTile(
            title: Text('Settings'),
            leading: Icon(Icons.settings_outlined),
            onTap: () {},
          ),
          ListTile(
            title: Text('Logout'),
            leading: Icon(Icons.arrow_back),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
