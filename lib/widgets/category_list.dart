import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app_for_grocery/providers/products_provider.dart';
import 'package:vendor_app_for_grocery/services/firebase_services.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({Key? key}) : super(key: key);

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  FirebaseService service = FirebaseService();

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ProductProvider>(context);
    return Dialog(
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).primaryColor,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Select Category",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: service.category.snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text("Something went wrong..");
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Expanded(
                child: ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(document['images']),
                      ),
                      title: Text(document['name']),
                      onTap: () {
                        provider.selectCategory(document['name'],document['images']);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

class SubCategoryList extends StatefulWidget {
  const SubCategoryList({Key? key}) : super(key: key);

  @override
  State<SubCategoryList> createState() => _SubCategoryListState();
}

class _SubCategoryListState extends State<SubCategoryList> {
  FirebaseService service = FirebaseService();
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ProductProvider>(context);
    return Dialog(
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).primaryColor,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Select Sub Category",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          ),
          FutureBuilder<DocumentSnapshot>(
            future: service.category
                .doc(provider.selectedCategory)
                .get(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text("Something went wrong..");
              }
              if (snapshot.connectionState == ConnectionState.done) {
                return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const Text("Main Category : "),
                              Text(
                                provider.selectedCategory!,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          thickness: 3,
                        ),
                        Container(
                          child: Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: ListView.builder(
                                itemBuilder: (BuildContext context, int index) {
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: CircleAvatar(
                                      child: Text('${index + 1}'),
                                    ),
                                    title: Text(
                                        snapshot.data!['subCategory'][index]['name']),
                                    onTap: () {
                                      provider.selectSubCategory(snapshot
                                          .data!['subCategory'][index]['name']);
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                                itemCount: snapshot.data!['subCategory'] == null
                                    ? 0
                                    : snapshot.data!['subCategory'].length,
                              ),
                            ),
                          ),
                        )
                      ],
                    ));
              }
              else{
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

            },
          )
        ],
      ),
    );
  }
}
