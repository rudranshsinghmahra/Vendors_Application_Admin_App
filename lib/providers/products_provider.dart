import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vendor_app_for_grocery/constants.dart';

class ProductProvider with ChangeNotifier {
  String? selectedCategory;
  String? selectedSubCategory;
  String? categoryImage;
  File? image;
  bool isPictureAvailable = false;
  String? shopName;
  String? productUrl;

  selectCategory(mainCategory, categoryImage) {
    selectedCategory = mainCategory;
    this.categoryImage = categoryImage;
    notifyListeners();
  }

  selectSubCategory(selected) {
    selectedSubCategory = selected;
    notifyListeners();
  }

  resetProvider(){
    //remove all existing data before uploading new data
    selectedCategory = null;
    selectedSubCategory = null;
    categoryImage = null;
    image = null;
    shopName = null;
    productUrl = null;
    notifyListeners();
  }

  Future<String> uploadProductImage(String filePath, productName) async {
    File file = File(filePath);
    FirebaseStorage _storage = FirebaseStorage.instance;
    var timeStamp = Timestamp.now().microsecondsSinceEpoch;
    try {
      await _storage
          .ref('productImage/$shopName/$productName/$timeStamp')
          .putFile(file);
    } on FirebaseException catch (e) {
      print(e.code);
    }
    String downloadUrl = await _storage
        .ref('productImage/$shopName/$productName/$timeStamp')
        .getDownloadURL();
    productUrl = downloadUrl;
    notifyListeners();
    return downloadUrl;
  }

  getShopName(shopName) {
    this.shopName = shopName;
    notifyListeners();
  }

  Future<File?> getProductImage() async {
    final ImagePicker _picker = ImagePicker();
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      image = File(pickedImage.path);
      isPictureAvailable = true;
      notifyListeners();
    } else {
      print("No Image Selected");
    }
    return image;
  }

  Future<void> saveProductDetailToDatabase(
      {productName,
      description,
      price,
      comparedPrice,
      collection,
      brand,
      sku,
      weight,
      tax,
      stockQty,
      lowStockQty,
      context}) async {
    var timeStamp = Timestamp.now().microsecondsSinceEpoch.toString();
    CollectionReference _products =
        FirebaseFirestore.instance.collection('products');
    User? user = FirebaseAuth.instance.currentUser;
    try{
      _products.doc(timeStamp.toString()).set({
        'seller': {'shopName': shopName, 'sellerUid': user?.uid},
        'productName': productName,
        'description': description,
        'price': price,
        'comparedPrice': comparedPrice,
        'collection': collection,
        'brand': brand,
        'sku': sku,
        'categoryName': {
          'mainCategory': selectedCategory,
          'subCategory': selectedSubCategory,
          'categoryImage': categoryImage
        },
        'weight': weight,
        'tax': tax,
        'stockQty' : stockQty,
        'lowStockQty' : lowStockQty,
        'published' : false,
        'productId' : timeStamp,
        'productImage' : productUrl,
      });
      showAlert("Product Details Saved Successfully");
    }catch(e){
      print(e.toString());
    }
  }

  Future<void> updateProductDetailToDatabase(
      {productName,
        description,
        price,
        comparedPrice,
        collection,
        brand,
        sku,
        weight,
        tax,
        stockQty,
        lowStockQty,
        productId,
        image,
        category,
        subCategory,
        categoryImage,
        context}) async {
    CollectionReference _products =
    FirebaseFirestore.instance.collection('products');
    try{
      _products.doc(productId).update({
        'productName': productName,
        'description': description,
        'price': price,
        'comparedPrice': comparedPrice,
        'collection': collection,
        'brand': brand,
        'sku': sku,
        'categoryName': {
          'mainCategory': category,
          'subCategory': subCategory,
          'categoryImage': categoryImage,
        },
        'weight': weight,
        'tax': tax,
        'stockQty' : stockQty,
        'lowStockQty' : lowStockQty,
        'published' : false,
        'productImage' : productUrl == null ? image : productUrl,
      });
      showAlert("Product Details Saved Successfully");
    }catch(e){
      print(e.toString());
    }
  }

}
