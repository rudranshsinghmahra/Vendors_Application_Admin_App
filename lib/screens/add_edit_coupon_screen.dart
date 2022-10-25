import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:vendor_app_for_grocery/services/firebase_services.dart';

class AddEditCoupon extends StatefulWidget {
  const AddEditCoupon({Key? key, this.documentSnapshot}) : super(key: key);
  final DocumentSnapshot? documentSnapshot;
  static const String id = 'add-coupon';

  @override
  State<AddEditCoupon> createState() => _AddEditCouponState();
}

class _AddEditCouponState extends State<AddEditCoupon> {
  final formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  TextEditingController dateText = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController couponDetailsController = TextEditingController();
  TextEditingController discountRateController = TextEditingController();
  bool active = false;
  final FirebaseService _service = FirebaseService();

  _selectDate(context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2050));
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        String formattedText = DateFormat('dd-MM-yyyy').format(_selectedDate);
        dateText.text = formattedText;
      });
    }
  }

  @override
  void initState() {
    if (widget.documentSnapshot != null) {
      setState(() {
        titleController.text = widget.documentSnapshot?['title'];
        discountRateController.text =
            "${widget.documentSnapshot?['discountRate']}";
        couponDetailsController.text = "${widget.documentSnapshot?['details']}";
        dateText.text = "${widget.documentSnapshot?['expiry'].toDate()}";
        active = widget.documentSnapshot?['active'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ADD / EDIT COUPON"),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                TextFormField(
                  controller: titleController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter Coupon Title";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      labelText: "Coupon Title",
                      labelStyle: TextStyle(color: Colors.grey)),
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: discountRateController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter Discount %";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      labelText: "Discount %",
                      labelStyle: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(
                  height: 4,
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: dateText,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Apply Coupon Expiry Date";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      labelText: "Coupon Expiry Date",
                      labelStyle: const TextStyle(color: Colors.grey),
                      suffixIcon: InkWell(
                        onTap: () {
                          _selectDate(context);
                        },
                        child: const Icon(Icons.date_range_outlined),
                      )),
                ),
                const SizedBox(
                  height: 4,
                ),
                TextFormField(
                  controller: couponDetailsController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Enter Coupon Details";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    labelText: "Coupon Details",
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: Theme.of(context).primaryColor,
                  value: active,
                  onChanged: (bool newValue) {
                    setState(() {
                      active = !active;
                    });
                  },
                  title: const Text("Activate Coupon"),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        EasyLoading.show(status: "Please Wait...");
                        _service
                            .saveCoupon(
                                widget.documentSnapshot,
                                titleController.text.toUpperCase(),
                                int.parse(discountRateController.text),
                                _selectedDate,
                                couponDetailsController.text,
                                active)
                            .then((value) {
                          setState(() {
                            titleController.clear();
                            discountRateController.clear();
                            couponDetailsController.clear();
                            active = false;
                          });
                        });
                        EasyLoading.showSuccess("Coupon Saved Successfully");
                      }
                    },
                    child: const Text(
                      "Submit",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
