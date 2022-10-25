import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app_for_grocery/constants.dart';
import 'package:vendor_app_for_grocery/providers/products_provider.dart';
import 'package:vendor_app_for_grocery/services/firebase_services.dart';
import 'package:vendor_app_for_grocery/widgets/banner_card.dart';

class BannerScreen extends StatefulWidget {
  const BannerScreen({Key? key}) : super(key: key);
  static const String id = 'banner-screen';

  @override
  State<BannerScreen> createState() => _BannerScreenState();
}

class _BannerScreenState extends State<BannerScreen> {
  bool _isVisible = false;
  File? image;
  final TextEditingController _imagePathText = TextEditingController();
  FirebaseService _service = FirebaseService();

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ProductProvider>(context);
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          BannerCard(),
          SizedBox(
            height: 10,
          ),
          Container(
            child: Center(
              child: Text(
                "ADD NEW BANNER",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 150,
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    color: Colors.grey[200],
                    child: image != null
                        ? Image.file(
                            image!,
                            fit: BoxFit.fill,
                          )
                        : Center(
                            child: Text("No Image Selected"),
                          ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _imagePathText,
                  enabled: false,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                        child: Visibility(
                      visible: _isVisible ? false : true,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isVisible = true;
                          });
                        },
                        child: const Text("Add New Banner"),
                      ),
                    )),
                  ],
                ),
                Visibility(
                  visible: _isVisible,
                  child: Container(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: ElevatedButton(
                              onPressed: () {
                                getBannerImage().then((value) {
                                  if (image != null) {
                                    setState(() {
                                      _imagePathText.text = image!.path;
                                    });
                                  }
                                });
                              },
                              child: const Text("Upload Image"),
                            )),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: AbsorbPointer(
                              absorbing: image != null ? false : true,
                              child: ElevatedButton(
                                onPressed: () {
                                  EasyLoading.show(status: "Saving..");
                                  uploadBannerImage(
                                          image!.path, provider.shopName)
                                      .then((value) {
                                    if (value != null) {
                                      _service.saveBannerVendor(value);
                                      setState(() {
                                        _imagePathText.clear();
                                        image = null;
                                      });
                                      EasyLoading.dismiss();
                                      showAlert(
                                          "Banner Image Uploaded Successfully");
                                    } else {
                                      showAlert("Banner Upload Failed");
                                    }
                                  });
                                },
                                child: const Text("Save"),
                                style: ButtonStyle(
                                    backgroundColor: image != null
                                        ? MaterialStateProperty.all(
                                            Colors.deepPurple)
                                        : MaterialStateProperty.all(
                                            Colors.grey)),
                              ),
                            )),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _isVisible = false;
                                    setState(() {
                                      _imagePathText.clear();
                                      image = null;
                                    });
                                  });
                                },
                                child: const Text("Cancel"),
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.black45)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<File?> getBannerImage() async {
    final ImagePicker _picker = ImagePicker();
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        image = File(pickedImage.path);
      });
    } else {
      print("No Image Selected");
    }
    return image;
  }

  Future<String> uploadBannerImage(filePath, shopName) async {
    File file = File(filePath);
    FirebaseStorage _storage = FirebaseStorage.instance;
    var timeStamp = Timestamp.now().microsecondsSinceEpoch;
    try {
      await _storage.ref('vendorBanner/$shopName/$timeStamp').putFile(file);
    } on FirebaseException catch (e) {
      print(e.code);
    }
    String downloadUrl = await _storage
        .ref('vendorBanner/$shopName/$timeStamp')
        .getDownloadURL();
    return downloadUrl;
  }
}
