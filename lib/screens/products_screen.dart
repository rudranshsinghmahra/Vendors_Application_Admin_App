import 'package:flutter/material.dart';
import 'package:vendor_app_for_grocery/screens/add_new_product_screen.dart';
import 'package:vendor_app_for_grocery/widgets/published_products.dart';

import '../widgets/unpublished_products.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({Key? key}) : super(key: key);
  static const String id = 'products-screen';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Products Screen"),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Material(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(
                        children: [
                          Text(
                            "Products",
                            style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.black54,
                            maxRadius: 15,
                            child: FittedBox(
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  "20",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, AddNewProductScreen.id);
                      },
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      label: Text(
                        "Add New Product",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            ),
            TabBar(
                labelStyle:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                labelColor: Theme.of(context).primaryColor,
                indicatorColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.black54,
                tabs: [
                  Tab(
                    text: "PUBLISHED",
                  ),
                  Tab(text: "UNPUBLISHED"),
                ]),
            const Expanded(
              child: TabBarView(children: [
                PublishedProducts(),
                UnPublishedProducts(),
              ]),
            )
          ],
        ),
      ),
    );
  }
}
