import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:intl/intl.dart';
import 'package:vendor_app_for_grocery/services/firebase_services.dart';
import 'package:vendor_app_for_grocery/services/order_services.dart';
import 'package:vendor_app_for_grocery/widgets/delivery_boys_list.dart';

class OrderSummaryCard extends StatefulWidget {
  const OrderSummaryCard({Key? key, required this.documentSnapshot})
      : super(key: key);
  final DocumentSnapshot documentSnapshot;

  @override
  State<OrderSummaryCard> createState() => _OrderSummaryCardState();
}

class _OrderSummaryCardState extends State<OrderSummaryCard> {
  final OrderService _orderService = OrderService();
  final FirebaseService _services = FirebaseService();
  DocumentSnapshot? customer;

  Color statusColor(DocumentSnapshot documentSnapshot) {
    if (documentSnapshot['orderStatus'] == "Accepted") {
      return Colors.blueGrey;
    }
    if (documentSnapshot['orderStatus'] == "Rejected") {
      return Colors.red;
    }
    if (documentSnapshot['orderStatus'] == "Picked-Up") {
      return Colors.pink;
    }
    if (documentSnapshot['orderStatus'] == "On the Way") {
      return Colors.purple;
    }
    if (documentSnapshot['orderStatus'] == "Delivered") {
      return Colors.green;
    }
    return Colors.orange;
  }

  @override
  void initState() {
    _services
        .getCustomerDetails(widget.documentSnapshot['userId'])
        .then((value) {
      if (value != null) {
        setState(() {
          customer = value;
        });
      } else {
        print("No Data Found");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 14,
                child: _orderService.statusIcon(widget.documentSnapshot),
              ),
              title: Text(
                widget.documentSnapshot['orderStatus'],
                style: TextStyle(
                  fontSize: 15,
                  color: statusColor(widget.documentSnapshot),
                ),
              ),
              subtitle: Text(
                "On ${DateFormat.yMMMd().format(
                  DateTime.parse(widget.documentSnapshot['timestamp']),
                )}",
                style: const TextStyle(fontSize: 1),
              ),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Payment Type : ${widget.documentSnapshot['cod'] == true ? "Cash On Delivery" : "Paid Online"}",
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Amount : Rs ${widget.documentSnapshot['total'].toStringAsFixed(0)}",
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            //TODO: Customer Name, contact number
            customer != null
                ? ListTile(
                    title: Row(
                      children: [
                        const Text(
                          "Customer : ",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${customer?['firstName']} ${customer?['lastName']}",
                          style: TextStyle(fontSize: 12),
                        )
                      ],
                    ),
                    subtitle: Text(
                      customer?['address'],
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.phone),
                      onPressed: () {
                        FlutterPhoneDirectCaller.callNumber(
                            customer?['number']);
                      },
                    ),
                  )
                : Container(),
            ExpansionTile(
              title: const Text(
                "Order Details",
                style: TextStyle(fontSize: 12, color: Colors.black),
              ),
              subtitle: const Text(
                "View order details",
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              children: [
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.documentSnapshot['products'].length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Image.network(widget.documentSnapshot['products']
                            [index]['productImage']),
                      ),
                      title: Text(widget.documentSnapshot['products'][index]
                          ['productName']),
                      subtitle: Text(
                          "${widget.documentSnapshot['products'][index]['qty']} x Rs ${widget.documentSnapshot['products'][index]['price']} = Rs ${widget.documentSnapshot['products'][index]['total'].toStringAsFixed(0)}"),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 12, right: 12, top: 8, bottom: 8),
                  child: Card(
                    elevation: 8,
                    color: Colors.green,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Seller : ',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                widget.documentSnapshot['seller']['shopName'],
                                style: const TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          (int.parse(widget.documentSnapshot['discount']) > 0)
                              ? Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          'Discount : ',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "${widget.documentSnapshot['discount']}",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          'Discount Code: ',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "${widget.documentSnapshot['discountCode']}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                )
                              : Container(),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              const Text(
                                'Delivery Fee: ',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "${widget.documentSnapshot['deliveryFee']}",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
            const Divider(
              height: 3,
              color: Colors.grey,
            ),
            // const Divider(
            //   height: 3,
            //   color: Colors.grey,
            // ),
            statusContainer(widget.documentSnapshot),
            // const Divider(
            //   height: 3,
            //   color: Colors.grey,
            // ),
          ],
        ),
      ),
    );
  }

  showDialogBox(title, status, documentId) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.INFO,
      animType: AnimType.BOTTOMSLIDE,
      title: title,
      desc: 'Are you sure',
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        EasyLoading.show(status: "Updating Status");
        status == "Accepted"
            ? _orderService.updateOrderStatus(documentId, status).then((value) {
                EasyLoading.showSuccess("Updated Successfully");
              })
            : _orderService.updateOrderStatus(documentId, status).then((value) {
                EasyLoading.showSuccess("Updated Successfully");
              });
      },
    ).show();
  }

  Widget statusContainer(DocumentSnapshot documentSnapshot) {
    if (documentSnapshot['deliveryBoy']['name'].length > 1) {
      return documentSnapshot['deliveryBoy']['image'] == null
          ? Container()
          : ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                child: SizedBox(
                    width: 40,
                    child: Image.network(
                      documentSnapshot['deliveryBoy']['image'],
                      fit: BoxFit.fill,
                    )),
              ),
              title: Text(documentSnapshot['deliveryBoy']['name']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      GeoPoint location =
                          documentSnapshot['deliveryBoy']['location'];
                      _orderService.launchMap(location, "Hello");
                    },
                    icon: const Icon(Icons.map),
                  ),
                  IconButton(
                    onPressed: () {
                      FlutterPhoneDirectCaller.callNumber(
                          documentSnapshot['deliveryBoy']['phone']);
                    },
                    icon: const Icon(Icons.phone),
                  ),
                ],
              ),
            );
    }

    if (documentSnapshot['orderStatus'] == "Accepted") {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: 50,
        color: Colors.grey[300],
        child: Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                //Delivery Boys List
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return DeliveryBoysList(
                        documentSnapshot: documentSnapshot,
                      );
                    });
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Theme.of(context).primaryColor),
              ),
              child: const Text("Select Delivery Boy"),
            ),
          ),
        ),
      );
    }
    return Container(
      color: Colors.grey[300],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  showDialogBox(
                      "Accept Order", "Accepted", documentSnapshot.id);
                },
                child: const Text("Accept"),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: AbsorbPointer(
                absorbing: documentSnapshot['orderStatus'] == "Rejected"
                    ? true
                    : false,
                child: ElevatedButton(
                  onPressed: () {
                    showDialogBox(
                        "Cancel Order", "Rejected", documentSnapshot.id);
                  },
                  child: const Text("Reject"),
                  style: ButtonStyle(
                    backgroundColor:
                        documentSnapshot['orderStatus'] == "Rejected"
                            ? MaterialStateProperty.all(Colors.grey)
                            : MaterialStateProperty.all(Colors.red),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
