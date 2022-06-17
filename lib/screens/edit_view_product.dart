import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app_for_grocery/constants.dart';
import 'package:vendor_app_for_grocery/providers/products_provider.dart';
import 'package:vendor_app_for_grocery/services/firebase_services.dart';
import '../widgets/category_list.dart';

class EditViewProduct extends StatefulWidget {
  const EditViewProduct({Key? key, required this.productId}) : super(key: key);
  final String productId;
  @override
  State<EditViewProduct> createState() => _EditViewProductState();
}

class _EditViewProductState extends State<EditViewProduct> {
  final FirebaseService _service = FirebaseService();
  final TextEditingController _brandText = TextEditingController();
  final TextEditingController _skuText = TextEditingController();
  final TextEditingController _productNameText = TextEditingController();
  final TextEditingController _weightText = TextEditingController();
  final TextEditingController _priceText = TextEditingController();
  final TextEditingController _comparedPriceText = TextEditingController();
  final TextEditingController _descriptionText = TextEditingController();
  final TextEditingController categoryTextController = TextEditingController();
  final TextEditingController subCategoryTextController =
      TextEditingController();
  final TextEditingController _stockText = TextEditingController();
  final TextEditingController _lowStockText = TextEditingController();
  final TextEditingController _taxTextController = TextEditingController();

  DocumentSnapshot? doc;
  double? discount;
  String? dropdownValue;
  bool _showEdit = true;
  String? _image;
  String? categoryImage;
  bool _isVisible = false;
  bool _cannotEdit = true;
  File? image;

  Future _pickImageFromGallery() async{
    try{
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if(image == null){
        return;
      }
      final imageTemporary = File(image.path);
      setState(() {
        this.image = imageTemporary;
      });
    }on PlatformException catch(e){
      print("Failed to Pick Imaeg $e");
    }
  }

  List<String> collection = [
    'Featured Products',
    'Best Selling',
    'Recently Added',
  ];

  final _formKey = GlobalKey<FormState>();

  Future<void> getProductDetails() async {
    _service.products
        .doc(widget.productId)
        .get()
        .then((DocumentSnapshot document) {
      if (document.exists) {
        setState(() {
          doc = document;
          _brandText.text = document['brand'];
          _skuText.text = document['sku'];
          _productNameText.text = document['productName'];
          _weightText.text = document['weight'];
          _image = document['productImage'];
          _descriptionText.text = document['description'];
          _priceText.text = document['price'].toString();
          _comparedPriceText.text = document['comparedPrice'].toString();
          discount = (((double.parse(_comparedPriceText.text)) -
                  (double.parse(_priceText.text))) /
              (double.parse(_comparedPriceText.text)) *
              100);
          categoryTextController.text =
              document['categoryName']['mainCategory'];
          subCategoryTextController.text =
              document['categoryName']['subCategory'];
          dropdownValue = document['collection'];
          _stockText.text = document['stockQty'].toString();
          _lowStockText.text = document['lowStockQty'].toString();
          _taxTextController.text = document['tax'].toString();
          categoryImage = document['categoryName']['categoryImage'];
        });
      }
    });
  }

  @override
  void initState() {
    getProductDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ProductProvider>(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          AbsorbPointer(
            absorbing: _showEdit ? false : true,
            child: ElevatedButton(
              child: _showEdit
                  ? const Text(
                      "Edit Content",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    )
                  : const Text(
                      "",
                      style: TextStyle(color: Colors.white),
                    ),
              onPressed: () {
                showAlert("Editing Content Enabled");
                setState(
                  () {
                    _showEdit = false;
                    _cannotEdit = false;
                  },
                );
              },
            ),
          )
        ],
      ),
      bottomSheet: Container(
        height: 60,
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  color: Colors.black87,
                  child: const Center(
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: AbsorbPointer(
                absorbing: _cannotEdit,
                child: InkWell(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      EasyLoading.show(status: "Saving");
                      if (image != null) {
                        //upload new details if image is changed
                        provider
                            .uploadProductImage(
                                image!.path, _productNameText.text)
                            .then(
                          (value) {
                            if (value != null) {
                              EasyLoading.dismiss();
                              provider.updateProductDetailToDatabase(
                                context: context,
                                productName: _productNameText.text,
                                weight: _weightText.text,
                                tax: double.parse(_taxTextController.text),
                                stockQty: int.parse(_stockText.text),
                                sku: _skuText.text,
                                price: double.parse(_priceText.text),
                                lowStockQty: int.parse(_lowStockText.text),
                                description: _descriptionText.text,
                                collection: dropdownValue,
                                brand: _brandText.text,
                                comparedPrice:
                                    int.parse(_comparedPriceText.text),
                                productId: widget.productId,
                                image: _image,
                                category: categoryTextController.text,
                                subCategory: subCategoryTextController.text,
                                categoryImage: categoryImage,
                              );
                            }
                          },
                        );
                      } else {
                        //upload new details if image is not changed
                        provider.updateProductDetailToDatabase(
                          context: context,
                          productName: _productNameText.text,
                          weight: _weightText.text,
                          tax: double.parse(_taxTextController.text),
                          stockQty: int.parse(_stockText.text),
                          sku: _skuText.text,
                          price: double.parse(_priceText.text),
                          lowStockQty: int.parse(_lowStockText.text),
                          description: _descriptionText.text,
                          collection: dropdownValue,
                          brand: _brandText.text,
                          comparedPrice: int.parse(_comparedPriceText.text),
                          productId: widget.productId,
                          image: _image,
                          category: categoryTextController.text,
                          subCategory: subCategoryTextController.text,
                          categoryImage: categoryImage,
                        );
                        EasyLoading.dismiss();
                      }
                      provider.resetProvider();
                    }
                  },
                  child: Container(
                    color: Colors.deepPurpleAccent,
                    child: const Center(
                      child: Text(
                        "Save",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: doc == null
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: ListView(
                  children: [
                    AbsorbPointer(
                      absorbing: _cannotEdit,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 80,
                                height: 40,
                                child: TextFormField(
                                  controller: _brandText,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.only(left: 10, right: 10),
                                      hintText: "Brand",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: OutlineInputBorder(),
                                      filled: true,
                                      fillColor: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(.1)),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("SKU : "),
                                  Container(
                                    width: 70,
                                    child: TextFormField(
                                      controller: _skuText,
                                      style: const TextStyle(fontSize: 12),
                                      decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                            child: TextFormField(
                              controller: _productNameText,
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none),
                              style: TextStyle(fontSize: 30),
                            ),
                          ),
                          SizedBox(
                            height: 25,
                            child: TextFormField(
                              controller: _weightText,
                              decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none),
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 80,
                                child: TextFormField(
                                  controller: _priceText,
                                  decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.zero,
                                      prefix: Text("Rs. "),
                                      border: InputBorder.none),
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                              Container(
                                width: 80,
                                child: TextFormField(
                                  controller: _comparedPriceText,
                                  decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.zero,
                                      prefix: Text("Rs. "),
                                      border: InputBorder.none),
                                  style: TextStyle(
                                      fontSize: 18,
                                      decoration: TextDecoration.lineThrough),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    color: Colors.red),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20),
                                  child: Text(
                                      "${discount?.toStringAsFixed(0)} % OFF"),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "Inclusive Of All Taxes",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Center(
                            child: InkWell(
                              onTap: () {
                                _pickImageFromGallery().then((value){
                                  setState(() {
                                    _image = image!.path;
                                  });
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: image != null
                                    ? Image.file(
                                        image!,
                                        height: 300,
                                      )
                                    : Image.network(
                                        _image!,
                                        height: 300,
                                      ),
                              ),
                            ),
                          ),
                          Text(
                            "About this product",
                            style: TextStyle(fontSize: 20),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: TextFormField(
                              maxLines: null,
                              controller: _descriptionText,
                              keyboardType: TextInputType.multiline,
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                              decoration:
                                  InputDecoration(border: InputBorder.none),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 10),
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
                                      controller: categoryTextController,
                                      decoration: const InputDecoration(
                                        hintText: "Not Selected*",
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: _cannotEdit ? false : true,
                                  child: IconButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
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
                                  ),
                                )
                              ],
                            ),
                          ),
                          Visibility(
                            visible: _isVisible,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 10),
                              child: Row(
                                children: [
                                  Text(
                                    'Sub Category',
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
                                        controller: subCategoryTextController,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Enter Sub Category Price';
                                          }
                                          return null;
                                        },
                                        decoration: const InputDecoration(
                                          labelText: "Not Selected*",
                                          labelStyle:
                                              TextStyle(color: Colors.grey),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return SubCategoryList();
                                          }).whenComplete(() {
                                        setState(() {
                                          subCategoryTextController.text =
                                              provider.selectedSubCategory!;
                                        });
                                      });
                                    },
                                    icon: Icon(Icons.edit_outlined),
                                  )
                                ],
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
                                  icon: const Icon(Icons.arrow_drop_down),
                                )
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                "Stock : ",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: _stockText,
                                  decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.zero,
                                      border: InputBorder.none),
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "Low Stock : ",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: _lowStockText,
                                  decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.zero,
                                      border: InputBorder.none),
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "Tax %: ",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: _taxTextController,
                                  decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.zero,
                                      border: InputBorder.none),
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 60,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
