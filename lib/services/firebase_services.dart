import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  User? user = FirebaseAuth.instance.currentUser;

  CollectionReference category =
      FirebaseFirestore.instance.collection('category');

  CollectionReference products =
      FirebaseFirestore.instance.collection('products');

  CollectionReference vendorBanner =
      FirebaseFirestore.instance.collection('vendorBanner');

  CollectionReference coupons =
      FirebaseFirestore.instance.collection('coupons');

  Future<void> publishProduct({id}) {
    return products.doc(id).update({
      'published': true,
    });
  }

  Future<void> unPublishProduct({id}) {
    return products.doc(id).update({
      'published': false,
    });
  }

  Future<void> deleteProduct({id}) {
    return products.doc(id).delete();
  }

  Future<void> saveBannerVendor(url) {
    return vendorBanner.add({
      'imageUrl': url,
      'sellerUid': user?.uid,
    });
  }

  Future<void> deleteBannerVendor({id}) {
    return vendorBanner.doc(id).delete();
  }

  Future<void> saveCoupon(document,title, discountRate, expiry, details, active) {
    if(document==null){
      return coupons.doc(title).set({
        'title': title,
        'discountRate': discountRate,
        'expiry': expiry,
        'details': details,
        'active': active,
        'sellerId': user?.uid,
      });
    }
    return coupons.doc(title).update({
      'title': title,
      'discountRate': discountRate,
      'expiry': expiry,
      'details': details,
      'active': active,
      'sellerId': user?.uid,
    });
  }
}
