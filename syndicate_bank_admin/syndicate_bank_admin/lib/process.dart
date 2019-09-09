import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class Process extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Process> {

  String uid,service;
  var c=0;
  getSharedPreferences(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    service= prefs.getString("service");

  }
  void _loginapi_validate() async {
    var count=null,countt=null;
    await Firestore.instance
        .collection('bookings').document(service)
        .get()
        .then((DocumentSnapshot doc) {
      if(doc.data!=null)
        count = doc["count"];
      else
        count=0;
    });

    if(c<count) {
      setState(() {
        c++;
      });

      Firestore.instance.collection('tokens')
          .document(service)
          .setData({'uid': uid, 'count': c, 'service': service});

    }
    else{

      Firestore.instance.collection('tokens')
          .document(service).delete();
      Fluttertoast.showToast(
          msg: "Tokens finished....",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          textColor: Colors.white,
          backgroundColor: Colors.red
      );
      Navigator.of(context).pushReplacementNamed('/home');


    }
  }
  @override
  void initState() {
    Future _getdata() async {
      final FirebaseUser user = await auth.currentUser();
      uid = user.uid;
      await Firestore.instance
          .collection('tokens').document(service)
          .get()
          .then((DocumentSnapshot doc) {
        if(doc.data!=null)
          c = doc["count"];
        else
          c=0;
        setState(() {

        });
      });
    }
    _getdata();
  }

  getExpenseItems(AsyncSnapshot<QuerySnapshot> snapshot) {
    initState();
    return snapshot.data.documents
        .map((doc) => ((doc['count']==c)&&(doc['service']==service))?new ListTile(title: Center(child:new Text(doc["uname"],style: TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),)),):new ListTile())
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
        stream: Firestore.instance.collection('userstat').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(child:Text("jis"));
          } else {

            return Center(child:Column(children: <Widget>[Padding(
              padding: const EdgeInsets.only(top:140.0),
              child: Text("Current Token",style: TextStyle(
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
                child:Text("USER'S NAME: ")),
              Padding(
                padding: const EdgeInsets.only(top:10.0),

                child: ListView(shrinkWrap:true,children: getExpenseItems(snapshot)),
              ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                new RaisedButton(
                  onPressed: _loginapi_validate,
                  color: Colors.green,
                  child: new Text("NEXT !",  style: new TextStyle(color: Colors.white)),
                  padding: EdgeInsets.only(left:63.0,right:63,top:23,bottom: 23),

                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                  ),
                )
              ],
            ),],)
            );
            }
        },
      ),
    );
  }

}
