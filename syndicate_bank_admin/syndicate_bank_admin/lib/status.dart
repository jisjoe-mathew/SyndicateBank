import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'main.dart';

class Status extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Status> {
  String dropdownValue = 'Select Service';

  String uid;
  
  @override
  void initState() {
    Future _getdata() async {
      final FirebaseUser user = await auth.currentUser();
      uid = user.uid;
    }
    _getdata();
  }

  getExpenseItems(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.documents
        .map((doc) => (doc['uid']==uid)?new ListTile(title: Center(child:new Text(doc["service"],style: TextStyle(
      color: Colors.grey,
      fontSize: 20,
    ),)), subtitle: Center(child:new Text(doc["count"].toString(),style: TextStyle(
      fontSize: 80,
      fontWeight: FontWeight.bold,
      color: Colors.red,
    ),))):new ListTile())
        .toList();
  }




  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: <Widget>[],
        elevation: 0.0,
        title: Text("STATUS"),
      ),
      body:
            StreamBuilder(
              stream: Firestore.instance.collection('userstat').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                } else {

                 return Center(child: Padding(
                   padding: const EdgeInsets.only(top:280.0),
                   child: ListView(children: getExpenseItems(snapshot)),
                 ));

                }
              },
            ),
    );
  }

}
