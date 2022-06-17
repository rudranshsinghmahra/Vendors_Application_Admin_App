import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app_for_grocery/constants.dart';
import 'package:vendor_app_for_grocery/providers/auth_provider.dart';
import 'package:vendor_app_for_grocery/screens/home_screen.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _emailTextEditingController =
      TextEditingController();
  final TextEditingController _phoneTextEditingController =
      TextEditingController();
  final TextEditingController _passwordTextEditingController =
      TextEditingController();
  final TextEditingController _confirmTextEditingController =
      TextEditingController();
  final TextEditingController _addressTextEditingController =
      TextEditingController();
  final TextEditingController _nameTextEditingController =
      TextEditingController();
  final TextEditingController _taglineTextEditingController =
      TextEditingController();
  String email = "";
  String password = "";
  String shopName = "";
  String mobile = "0000000000";
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final _authData = Provider.of<AuthProvider>(context);

    Future<String> uploadFile(String filePath) async {
      File file = File(filePath);
      FirebaseStorage _storage = FirebaseStorage.instance;
      try {
        await _storage
            .ref(
                'uploads/shopProfilePicture/${_nameTextEditingController.text}')
            .putFile(file);
      } on FirebaseException catch (e) {
        print(e.code);
      }
      String downloadUrl = await _storage
          .ref('uploads/shopProfilePicture/${_nameTextEditingController.text}')
          .getDownloadURL();
      return downloadUrl;
    }

    return isLoading
        ? Center(
            child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
          )
        : Form(
            key: formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter Shop Type";
                      }
                      setState(() {
                        _nameTextEditingController.text = value;
                      });
                      setState(() {
                        shopName = value;
                      });
                      return null;
                    },
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.add_business),
                        labelText: "Business/Shop Name",
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2, color: Theme.of(context).primaryColor),
                        ),
                        focusColor: Theme.of(context).primaryColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    controller: _phoneTextEditingController,
                    maxLength: 10,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter Mobile Number";
                      }
                      setState(() {
                        mobile = value;
                      });
                      return null;
                    },
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.phone),
                        labelText: "Mobile Number",
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2, color: Theme.of(context).primaryColor),
                        ),
                        focusColor: Theme.of(context).primaryColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    controller: _emailTextEditingController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter Email Address";
                      }
                      final bool _isValid = EmailValidator.validate(
                          _emailTextEditingController.text);
                      if (!_isValid) {
                        return "Email is Invalid";
                      }
                      setState(() {
                        email = value;
                      });
                      return null;
                    },
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email),
                        labelText: "Email Address",
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2, color: Theme.of(context).primaryColor),
                        ),
                        focusColor: Theme.of(context).primaryColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    controller: _passwordTextEditingController,
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Enter Password";
                      }
                      if (value.length < 6) {
                        return "Minimum 6 Characters";
                      }
                      setState(() {
                        password = value;
                      });
                      return null;
                    },
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.vpn_key_outlined),
                        labelText: "Password",
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2, color: Theme.of(context).primaryColor),
                        ),
                        focusColor: Theme.of(context).primaryColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    controller: _confirmTextEditingController,
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Re-Enter Password";
                      }
                      if (_confirmTextEditingController.text !=
                          _passwordTextEditingController.text) {
                        return "Password Mis-Match";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.vpn_key_outlined),
                        labelText: "Confirm Password",
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2, color: Theme.of(context).primaryColor),
                        ),
                        focusColor: Theme.of(context).primaryColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    maxLines: 6,
                    controller: _addressTextEditingController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Press Navigator Button";
                      }
                      if (_authData.shopLatitude == null) {
                        return "Press Navigator Button";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: () {
                            _addressTextEditingController.text =
                                "Locating... Please wait";
                            _authData.getCurrentAddress().then((value) {
                              if (value != null) {
                                setState(() {
                                  _addressTextEditingController.text =
                                      "${_authData.placeName}\n${_authData.shopAddress}";
                                });
                              } else {
                                showAlert(
                                    "Couldn't find your location. Try Again Later");
                              }
                            });
                          },
                          icon: const Icon(Icons.location_searching),
                        ),
                        prefixIcon: const Icon(Icons.contact_mail_outlined),
                        labelText: "Business Address",
                        enabledBorder: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2, color: Theme.of(context).primaryColor),
                        ),
                        focusColor: Theme.of(context).primaryColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: TextFormField(
                    onChanged: (value) {
                      _taglineTextEditingController.text = value;
                    },
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.comment),
                        labelText: "Business/Shop Tagline",
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 2, color: Theme.of(context).primaryColor),
                        ),
                        focusColor: Theme.of(context).primaryColor),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                        child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).primaryColor)),
                      onPressed: () {
                        if (_authData.isPictureAvailable == true) {
                          if (formKey.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });
                            _authData
                                .registerVendor(
                                    _emailTextEditingController.text,
                                    _passwordTextEditingController.text,
                            _phoneTextEditingController.text)
                                .then((value) {
                              if (value?.user?.uid != null) {
                                //Vendor is registered Successfully. Now upload Profile Pic to Firestore.
                                uploadFile(_authData.image!.path).then((value) {
                                  if (value != null) {
                                    //Save vendor details to database
                                    _authData
                                        .saveVendorDataToDatabase(
                                            url: value,
                                            shopName: shopName,
                                            mobile: mobile,
                                            dialog:
                                                _taglineTextEditingController
                                                    .text)
                                        .then((value) {
                                      setState(() {
                                        formKey.currentState?.reset();
                                        isLoading = false;
                                      });
                                      Navigator.pushReplacementNamed(
                                          context, HomeScreen.id);
                                    });
                                  } else {
                                    showAlert(
                                        "Failed to upload Shop Profile Picture");
                                  }
                                });
                              } else {
                                //Registration Failed
                              }
                            });
                          }
                        } else {
                          showAlert("Shop Picture is Mandatory");
                        }
                      },
                      child: const Text(
                        "Register",
                        style: TextStyle(color: Colors.white),
                      ),
                    ))
                  ],
                )
              ],
            ),
          );
  }
}
