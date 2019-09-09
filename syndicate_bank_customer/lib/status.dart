import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class Status extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Status> {
  String dropdownValue = 'Select Service';

  String uid,service;
  var c=0;
  getSharedPreferences(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    service= prefs.getString("service");

  }
  @override
  void initState() {
    Future _getdata() async {
      final FirebaseUser user = await auth.currentUser();
      uid = user.uid;
      await Firestore.instance
          .collection('userstat').document(uid)
          .get()
          .then((DocumentSnapshot doc) {
        if(doc.data!=null) {

          setState(() {
            c = doc["count"];
          });
        }
        else
          c=0;

      });
    }
    _getdata();
  }

  getExpenseItems(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.documents
        .map((doc) => (doc['service']==service)?new ListTile(title: Center(child:new Text("Service Requested: "+doc["service"],style: TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),)), subtitle: Center(child:new Text(doc["count"].toString(),style: TextStyle(
      fontSize: 60,
      fontWeight: FontWeight.bold,
      color: Colors.red,
    ),))):new ListTile())
        .toList();
  }




  @override
  Widget build(BuildContext context) {
getSharedPreferences(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: <Widget>[],
        elevation: 0.0,
        title: Text("STATUS"),
      ),
      body:
            StreamBuilder(
              stream: Firestore.instance.collection('tokens').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                } else {

                 return Center(child: Column(children: <Widget>[Padding(
                 padding: const EdgeInsets.only(top:140.0),
                   child: Text("My Token",style: TextStyle(
                     color: Colors.grey,
                     fontSize: 20,
                   ),),
                 ),Padding(
                padding: const EdgeInsets.only(top:20.0),
                child: Text(c.toString(),style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.red,
                )),
                ),

                Padding(
                padding: const EdgeInsets.only(top:80.0),
                child:Text("Current Token",style: TextStyle(
                  color: Colors.grey,
                  fontSize: 20,))),Padding(
                   padding: const EdgeInsets.only(top:1.0),
                   child: ListView(shrinkWrap:true,children: getExpenseItems(snapshot)),
                 )]));

                }
              },
            ),
    );
  }

}
