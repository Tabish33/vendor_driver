import 'package:flutter/material.dart';
import './PendingOrders.dart';
import './CompletedOrders.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
          length: 2,
          child: Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  backgroundColor: Color.fromRGBO(0, 133, 119, 1.0),
                  bottom: TabBar(
                    tabs: <Widget>[
                      Tab(icon: Icon(Icons.directions_car),),
                      Tab(icon: Icon(Icons.history),)
                    ],
                  ),
                  title: Text('Home'),
                ),
         body: TabBarView(
           children: <Widget>[
             PendingOrders(),
             CompletedOrders()
           ],
         ),
      ),
    );
  }
}