import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderCardUIHelper extends StatelessWidget {
  const OrderCardUIHelper({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Widget buildPrice(Map order){
    return Text("₹${order['bill']}", style: TextStyle(
      fontSize: 20.0, fontWeight: FontWeight.bold

    ),);
  }

  Widget buildItems(Map order){
    List items = order['items'];
    return Container(
        height: 50.0,
          child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  itemBuilder: (context,index){
                    Map item = items[index];
                    return Container(
                        margin: EdgeInsets.only(right: 4.0),
                        child: Chip(
                        backgroundColor: Colors.blue,
                        label:  Text("${item['data']['name']} ${item['quantity']} ${item['data']['unit']}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold ),),
                      ),
                    );
        },
      ),
    );
  }

  Widget buildPhoneNumber(Map order){
    return Container(
      margin: EdgeInsets.only(top: 10.0, bottom: 3.0,),
      child: InkWell(
          onTap: ()=> launchDialer(order) ,
          child: Row(
          children: <Widget>[
            Icon(Icons.phone, color: Colors.blue,),
            Container(
              width: 305,
              padding: const EdgeInsets.only(left:8.0),
              child: RichText(text: TextSpan(
                text: order['delivery_location']['phone'] != null ? order['delivery_location']['phone']: "No address available",
                      style: TextStyle(color: Colors.grey[600] )
              ),
              textAlign: TextAlign.left,
              softWrap: true,
              )
            )
            
          ],
        ),
      ),
    );
  }

  launchDialer(Map order){
    launch("tel:${order['delivery_location']['phone'] }");
  }

  Widget buildAddress(Map order){
    return Container(
      margin: EdgeInsets.only(top: 10.0, bottom: 3.0,),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.pin_drop, color: Colors.red,),
          Container(
            width: 305,
            padding: const EdgeInsets.only(left:8.0),
            child: RichText(text: TextSpan(
              text: order['delivery_location']['address'] != null ? order['delivery_location']['address']: "No address available",
                    style: TextStyle(color: Colors.grey[600])
            ),
            textAlign: TextAlign.left,
            softWrap: true,
            )
          )
          
        ],
      ),
    );
  }
}