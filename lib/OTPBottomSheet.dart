import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OTPBottomSheet extends StatefulWidget {
  Map order;

  OTPBottomSheet(ordr) {
    order = ordr;
  }

  @override
  _OTPBottomSheetState createState() => _OTPBottomSheetState();
}

class _OTPBottomSheetState extends State<OTPBottomSheet> {
  Firestore storeDb = Firestore.instance;
  TextEditingController otp_controller = new TextEditingController(); 

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(17.0),
      child: Container(
        height: 180.0,
         child: Column(
           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
           children: <Widget>[
             TextField(
               controller: otp_controller,
               keyboardType: TextInputType.number,
               decoration: InputDecoration(
                 labelText: "Enter OTP",
               ),
             ),

             buildConfirmDeliveryButton()
           ],
         )
      ),
    );
  }

  Widget buildConfirmDeliveryButton(){
     return  SizedBox(
              width: double.maxFinite,
              height: 50.0,
                  child: FlatButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                color: Colors.amber,
                onPressed: ()=> confirmOTP() ,
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

  confirmOTP()async{
    Map  order = widget.order;
    String order_id =  order['id'].toString();
    String otp = order_id.substring(9,13);

    if(otp_controller.text == otp) {
       showCupertinoModalPopup(
         context: context,
         builder: (context) {
            return Container(
              width: 200.0,
              height: 200.0,
              child: Center(
                child: Card(
                  
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  )
                ),
              ),
            );
          }
       ); 

       await storeDb.collection("vendor_orders").document(order_id).updateData({"status":"completed"});
       CloudFunctions.instance.getHttpsCallable(
         functionName: "sendVendorDeliveryMail",
       ).call(
          <String, Map>{
            "order": order
          },
        );
                  
       Navigator.of(context).pop();

       showSuccessDialog(); 

       Future.delayed(const Duration(seconds: 2), () { 
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        });
       
    }
    else print("wrong");
  }

  showSuccessDialog(){
    showCupertinoModalPopup(
         context: context,
         builder: (context) {
            return Container(
              width: 250.0,
              height: 200.0,
              child: Center(
                child: Card( 
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text("Delivery Complete", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),),
                        Icon(Icons.check,color: Colors.green, size: 30.0,)
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
       ); 
  }
}