import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:vendor_driver/OTPBottomSheet.dart';
import 'package:flutter/material.dart';
import 'OrderCardUIHelper.dart';
import 'ConfigureFcm.dart';

class PendingOrders extends StatefulWidget {
  PendingOrders({Key key}) : super(key: key);

  @override
  _PendingOrdersState createState() => _PendingOrdersState();
}

class _PendingOrdersState extends State<PendingOrders> {
  Firestore storeDb = Firestore.instance;
  OrderCardUIHelper uiHelper = new OrderCardUIHelper();
  ConfigureFcm fcm = new ConfigureFcm();

  @override

  @override
  void initState() { 
    super.initState();
    fcm.saveDeviceToken();
    fcm.configureFcm();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: storeDb.collection("vendor_orders").where("status",isEqualTo: "out_for_delivery").snapshots(),
        builder: (context,snap){
          List orders = [];
          if (snap.hasData) {
            snap.data.documents.forEach((DocumentSnapshot doc){
              orders.add(doc.data);
            });
            return Container(
                // margin: EdgeInsets.all(10.0),
                child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: orders.length,
                itemBuilder: (context,index){
                  Map order = orders[index];
                  return Padding(
                    padding: const EdgeInsets.only(left:8.0, right: 8.0, top: 10.0 ),
                    child: buildOrderCard(order),
                  );
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
            uiHelper.buildPhoneNumber(order),
            uiHelper.buildAddress(order),
            uiHelper.buildItems(order),
            buildDirectionButton(order),
            buildConfirmOrderButton(order)
          ],
        ),
      ),
    );
  }

  Widget buildDirectionButton(Map order){
     return  SizedBox(
              width: double.maxFinite,
                  child: FlatButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                color: Color.fromRGBO(0, 133, 119, 1.0),
                onPressed: ()=> openMaps(order) ,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child: Icon(
                            Icons.directions,
                            size: 17,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Get Directions",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0),
                        ),
                      ],
                    ),
                  
              ),
            );
  }

  openMaps(Map order)async{

    final availableMaps = await MapLauncher.installedMaps;
    print(order); // [AvailableMap { mapName: Google Maps, mapType: google }, ...]
    // print( order['delivery_location']['long']); // [AvailableMap { mapName: Google Maps, mapType: google }, ...]

    await availableMaps.first.showMarker(
      coords: Coords(order['delivery_location']['lat'], order['delivery_location']['long']),
      title: "Shanghai Tower",
      description: "Asia's tallest building",
    );

  }

  Widget buildConfirmOrderButton(Map order){
     return  SizedBox(
              width: double.maxFinite,
                  child: FlatButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                color: Colors.amber,
                onPressed: ()=> openOTPBottomSheet(order) ,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child: Icon(
                            Icons.directions,
                            size: 17,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Confirm Delivery",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0),
                        ),
                      ],
                    ),
                  
              ),
            );
  }

  openOTPBottomSheet(order)async{
    await showModalBottomSheet(
        context: context,
        builder: (context) {
          return OTPBottomSheet(order);
        });

  }
}