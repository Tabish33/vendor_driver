import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:path_provider/path_provider.dart';
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

       File pdf = await createPdf(order);
       String url = await uploadPdf(pdf, order['id']);
       await storeDb.collection("vendor_orders").document(order_id).updateData({"status":"completed", 'invoice_url': url});

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

  createPdf(Map order)async{
    final pdfLib.Document pdf = pdfLib.Document();

    pdf.addPage(
      pdfLib.Page(
        pageFormat: PdfPageFormat.a5,
        build: (context) {
          return pdfLib.Container(
            child: pdfLib.Column(
              crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
              children: [
                pdfLib.Text("relllo",style: pdfLib.TextStyle( fontSize: 20.0, fontWeight: pdfLib.FontWeight.bold)),
                pdfLib.Padding(padding: pdfLib.EdgeInsets.only(bottom: 5.0)),
                pdfLib.Text("Purchase Order", style: pdfLib.TextStyle( fontSize: 30.0, fontWeight: pdfLib.FontWeight.bold)),
                pdfLib.Padding(padding: pdfLib.EdgeInsets.only(top: 5.0)),
                pdfLib.Row(
                  children: [
                    pdfLib.Text("Ship Date",style: pdfLib.TextStyle( fontSize: 13.0, fontWeight: pdfLib.FontWeight.bold)),
                    pdfLib.Padding(padding: pdfLib.EdgeInsets.only(left: 15.0)),
                    pdfLib.Text("Ship Via",style: pdfLib.TextStyle( fontSize: 13.0, fontWeight: pdfLib.FontWeight.bold)),
                    pdfLib.Padding(padding: pdfLib.EdgeInsets.only(left: 35.0 )),
                    pdfLib.Text("Terms",style: pdfLib.TextStyle( fontSize: 13.0, fontWeight: pdfLib.FontWeight.bold)),
                  ]
                ),
                pdfLib.Padding(padding: pdfLib.EdgeInsets.only(top: 3.0)),
                pdfLib.Row(
                  children: [
                    pdfLib.Text("${order['date']}",style: pdfLib.TextStyle( fontSize: 11.0, fontWeight: pdfLib.FontWeight.bold)),
                    pdfLib.Padding(padding: pdfLib.EdgeInsets.only(left: 20.0)),
                    pdfLib.Text("relllo",style: pdfLib.TextStyle( fontSize: 11.0, fontWeight: pdfLib.FontWeight.bold)),
                    pdfLib.Padding(padding: pdfLib.EdgeInsets.only(left: 60.0 )),
                    pdfLib.Text("Shippin and Payment Terms",style: pdfLib.TextStyle( fontSize: 11.0, fontWeight: pdfLib.FontWeight.bold)),
                  ]
                ),
                pdfLib.Padding(padding: pdfLib.EdgeInsets.only(top: 10.0 , bottom: 15.0)),
                pdfLib.Table.fromTextArray(context: context, data: <List<String>>[
                <String>['Item', 'Qty', 'Unit Price', 'Total Price'],
                ...order['items'].map(
                    (item) => ["${item['data']['name']}", "${item['quantity']} ${item['data']['unit']}","${item['data']['price_per_qty']}" , "${item['data']['price_per_qty']*item['quantity']}" ]),
                ["","","Subtotal","${order['bill'] - 30}" ],
                ["","","Shipping","30" ],
                ["","","Total","${order['bill']}" ]
              ]),
              ]
            )
          );
        }
      )
    );

    final String dir = (await getApplicationDocumentsDirectory()).path;
    final String path = '$dir/example.pdf';
    final File file = File(path);
    return await file.writeAsBytes(pdf.save());
  }

  uploadPdf(File file,id)async{
    StorageReference storageReference = FirebaseStorage.instance.ref().child("vendor_invoices/${id}");    
    StorageUploadTask uploadTask = storageReference.putFile(file);    
    await uploadTask.onComplete;   
    print('File Uploaded');    
    String url = await storageReference.getDownloadURL();  
    return url;
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