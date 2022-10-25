import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app_for_grocery/constants.dart';
import 'package:vendor_app_for_grocery/providers/products_provider.dart';
import 'package:vendor_app_for_grocery/widgets/category_list.dart';

class AddNewProductScreen extends StatefulWidget {
  const AddNewProductScreen({Key? key}) : super(key: key);
  static const String id = 'add-new_product-screen';

  @override
  State<AddNewProductScreen> createState() => _AddNewProductScreenState();
}

class _AddNewProductScreenState extends State<AddNewProductScreen> {
  TextEditingController categoryTextController = TextEditingController();
  TextEditingController subCategoryTextController = TextEditingController();
  TextEditingController comparedPriceTextController = TextEditingController();
  TextEditingController brandTextController = TextEditingController();
  TextEditingController lowStockTextController = TextEditingController();
  TextEditingController stockInventoryTextController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  bool _isVisible = false;
  bool _track = false;
  File? _image;
  List<String> collection = [
    'Featured Products',
    'Best Selling',
    'Recently Added',
  ];

  String? dropdownValue;
  String? productName;
  String? description;
  String? sku;
  String? weight;
  double? price;
  double? comparedPrice;
  double? tax;
  int? stockQuantity;

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ProductProvider>(context);
    return DefaultTabController(
      initialIndex: 1,
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            title: const Text("Add Product Screen"),
          ),
          body: Form(
            key: formKey,
            child: Column(
              children: [
                Material(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            "Products/Add",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              if (_image != null) {
                                EasyLoading.show(status: "Saving...");
                                provider
                                    .uploadProductImage(
                                        _image!.path, productName)
                                    .then(
                                  (value) {
                                    if (value != null) {
                                      EasyLoading.dismiss();
                                      provider.saveProductDetailToDatabase(
                                        context: context,
                                        comparedPrice:
                                            int.parse(comparedPriceTextController.text),
                                        brand: brandTextController.text,
                                        collection: dropdownValue,
                                        description: description,
                                        lowStockQty:
                                            int.parse(lowStockTextController.text),
                                        price: price,
                                        sku: sku,
                                        stockQty: int.parse(stockInventoryTextController.text),
                                        tax: tax,
                                        weight: weight,
                                        productName: productName,
                                      );

                                      setState(() {
                                        formKey.currentState?.reset();
                                        comparedPriceTextController.clear();
                                        dropdownValue = null;
                                        subCategoryTextController.clear();
                                        categoryTextController.clear();
                                        brandTextController.clear();
                                        _track = false;
                                        _image = null;
                                        _isVisible = false;
                                      });
                                    } else {
                                      showAlert(
                                          "Failed to Upload Product Image");
                                    }
                                  },
                                );
                              } else {
                                showAlert("Product Image Not Selected");
                              }
                            }
                          },
                          icon: const Icon(
                            Icons.save,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "Save",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                TabBar(
                  labelStyle: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                  labelColor: Theme.of(context).primaryColor,
                  indicatorColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.black54,
                  tabs: const [
                    Tab(
                      text: "GENERAL",
                    ),
                    Tab(
                      text: "INVENTORY",
                    )
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: TabBarView(children: [
                        ListView(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Enter Product Name';
                                      }
                                      setState(() {
                                        productName = value;
                                      });
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                      labelText: "Product Name*",
                                      labelStyle: TextStyle(color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Enter Description';
                                      }
                                      setState(() {
                                        description = value;
                                      });
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                      labelText: "About Product*",
                                      labelStyle: TextStyle(color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(top: 30, bottom: 15),
                                    child: InkWell(
                                      onTap: () {
                                        provider
                                            .getProductImage()
                                            .then((image) {
                                          setState(() {
                                            _image = image;
                                          });
                                        });
                                      },
                                      child: SizedBox(
                                        width: 200,
                                        height: 200,
                                        child: Card(
                                          child: Center(
                                              child: _image == null
                                                  ? const Text("Select Image")
                                                  : Image.file(_image!)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Enter Selling Price';
                                      }
                                      setState(() {
                                        price = double.parse(value);
                                      });
                                      return null;
                                    },
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: "Selling Price*",
                                      labelStyle: TextStyle(color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  TextFormField(
                                    controller: comparedPriceTextController,
                                    validator: (value) {
                                      if(price! > double.parse(value!)){
                                        return 'Compared Price should be greater than price';
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: "Compare Price*",
                                      labelStyle: TextStyle(color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      children: [
                                        Text(
                                          "Collection",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        DropdownButton(
                                          items: collection
                                              .map<DropdownMenuItem<String>>(
                                                  (String value) {
                                            return DropdownMenuItem(
                                              child: Text(value),
                                              value: value,
                                            );
                                          }).toList(),
                                          onChanged: (String? value) {
                                            setState(() {
                                              dropdownValue = value;
                                            });
                                          },
                                          hint: Text("Select Collection"),
                                          value: dropdownValue,
                                          icon:
                                              const Icon(Icons.arrow_drop_down),
                                        )
                                      ],
                                    ),
                                  ),
                                  TextFormField(
                                    controller: brandTextController,
                                    decoration: const InputDecoration(
                                      labelText: "Brand*",
                                      labelStyle: TextStyle(color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Enter SKU*';
                                      }
                                      setState(() {
                                        sku = value;
                                      });
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                      labelText: "SKU*",
                                      labelStyle: TextStyle(color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20, bottom: 10),
                                    child: Row(
                                      children: [
                                        Text(
                                          "Category",
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 16),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: AbsorbPointer(
                                            absorbing: true,
                                            child: TextFormField(
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return 'Enter Category Name';
                                                }
                                                return null;
                                              },
                                              controller:
                                                  categoryTextController,
                                              decoration: const InputDecoration(
                                                hintText: "Not Selected*",
                                                hintStyle: TextStyle(
                                                    color: Colors.grey),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.grey),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return CategoryList();
                                                }).whenComplete(() {
                                              setState(() {
                                                categoryTextController.text =
                                                    provider.selectedCategory!;
                                                _isVisible = true;
                                              });
                                            });
                                          },
                                          icon: Icon(Icons.edit_outlined),
                                        )
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible: _isVisible,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, bottom: 10),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Sub Category',
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: AbsorbPointer(
                                              absorbing: true,
                                              child: TextFormField(
                                                controller:
                                                    subCategoryTextController,
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return 'Enter Sub Category Price';
                                                  }
                                                  return null;
                                                },
                                                decoration:
                                                    const InputDecoration(
                                                  labelText: "Not Selected*",
                                                  labelStyle: TextStyle(
                                                      color: Colors.grey),
                                                  enabledBorder:
                                                      UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.grey),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return SubCategoryList();
                                                  }).whenComplete(() {
                                                setState(() {
                                                  subCategoryTextController
                                                          .text =
                                                      provider
                                                          .selectedSubCategory!;
                                                });
                                              });
                                            },
                                            icon: Icon(Icons.edit_outlined),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Enter Weight';
                                      }
                                      setState(() {
                                        weight = value;
                                      });
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                      labelText: "Weight Measuring Unit Ex- Kg,Gram,etc",
                                      labelStyle: TextStyle(color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Enter Tax %';
                                      }
                                      setState(() {
                                        tax = double.parse(value);
                                      });
                                      return null;
                                    },
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: "Tax %*",
                                      labelStyle: TextStyle(color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              SwitchListTile(
                                title: const Text("Track Inventory"),
                                subtitle:
                                    const Text("Switch on to track inventory"),
                                value: _track,
                                onChanged: (selected) {
                                  setState(() {
                                    _track = !_track;
                                  });
                                },
                              ),
                              Visibility(
                                visible: _track,
                                child: SizedBox(
                                  height: 300,
                                  width: double.infinity,
                                  child: Card(
                                    elevation: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        children: [
                                          TextFormField(
                                            controller: stockInventoryTextController,
                                            decoration: const InputDecoration(
                                              labelText: "Inventory Quantity*",
                                              labelStyle:
                                                  TextStyle(color: Colors.grey),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey),
                                              ),
                                            ),
                                          ),
                                          TextFormField(
                                            controller: lowStockTextController,
                                            decoration: const InputDecoration(
                                              labelText:
                                                  "Inventory Low Stock Quantity*",
                                              labelStyle:
                                                  TextStyle(color: Colors.grey),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
