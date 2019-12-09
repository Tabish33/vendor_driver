import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vendor_driver/OrderCardUIHelper.dart';

class CompletedOrders extends StatefulWidget {
  CompletedOrders({Key key}) : super(key: key);

  @override
  _CompletedOrdersState createState() => _CompletedOrdersState();
}

class _CompletedOrdersState extends State<CompletedOrders> {
  Firestore storeDb = Firestore.instance;
  OrderCardUIHelper uiHelper = new OrderCardUIHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: storeDb.collection("vendor_orders").where("status",isEqualTo: "completed").getDocuments(),
        builder: (context,snap){
          List orders = [];
          if (snap.hasData) {
            snap.data.documents.forEach((DocumentSnapshot doc){
              orders.add(doc.data);
            });
            return Container(
                padding: EdgeInsets.all(10.0),
                child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: orders.length,
                itemBuilder: (context,index){
                  Map order = orders[index];
                  return buildOrderCard(order);
                },

              ),
            );
          }else{
            return Center( child: CircularProgressIndicator(), );
          }
        },
      )
    );
  }

   Widget buildOrderCard(Map order){
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0)
      ),
      elevation: 8.0,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            uiHelper.buildPrice(order),
            uiHelper.buildItems(order),
            uiHelper.buildAddress(order)
          ],
        ),
      ),
    );
  }

  
}