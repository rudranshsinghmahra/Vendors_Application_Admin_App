import 'package:chips_choice_null_safety/chips_choice_null_safety.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app_for_grocery/services/order_services.dart';
import 'package:vendor_app_for_grocery/widgets/order_summary_card.dart';
import '../providers/orders_provider.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);
  static const String id = "order-screen";
  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final OrderService _orderServices = OrderService();
  User? user = FirebaseAuth.instance.currentUser;
  int tag = 0;
  List<String> options = [
    "All Orders",
    "Ordered",
    "Accepted",
    "Rejected",
    "Picked-Up",
    "On the Way",
    "Delivered",
  ];

  @override
  Widget build(BuildContext context) {
    var _orderProvider = Provider.of<OrderProvider>(context);
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text("Orders Received"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            width: MediaQuery.of(context).size.width,
            child: ChipsChoice<int>.single(
                choiceStyle: const C2ChoiceStyle(
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                    color: Colors.grey),
                value: tag,
                onChanged: (val) {
                  if (val == 0) {
                    setState(() {
                      _orderProvider.status == null;
                    });
                  }
                  setState(() {
                    tag = val;
                    _orderProvider.status = options[val];
                  });
                },
                choiceItems: C2Choice.listFrom<int, String>(
                    source: options, value: (i, v) => i, label: (i, v) => v)),
          ),
          Container(
            child: StreamBuilder<QuerySnapshot>(
              stream: _orderServices.orders
                  .where('seller.sellerId', isEqualTo: user?.uid)
                  .where('orderStatus',
                      isEqualTo: tag > 0 ? _orderProvider.status : null)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data?.size == 0) {
                  //TODO: No orders screen
                  return Center(
                    child: Text(tag > 0
                        ? "No ${options[tag]} orders"
                        : "No Orders. Continue Shopping"),
                  );
                }
                return Expanded(
                  child: ListView(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      return OrderSummaryCard(
                        documentSnapshot: document,
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
