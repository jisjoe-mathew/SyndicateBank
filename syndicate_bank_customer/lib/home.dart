import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String dropdownValue = 'Select Service';

  String uid,uname;

  @override
  void initState() {
    Future _getdata() async {
      final FirebaseUser user = await auth.currentUser();
      uid = user.uid;
      uname = user.displayName;

    }
    _getdata();
  }

  Future _loginapi_validate() async {
    if (dropdownValue == "Select Service") {
      Fluttertoast.showToast(
          msg: "Please select a service to do a booking..",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          textColor: Colors.white,
          backgroundColor: Colors.red
      );
      setState(() {


      });
    }
    else {
      var count=null;
      await Firestore.instance
          .collection('bookings').document(dropdownValue)
          .get()
          .then((DocumentSnapshot doc) {
            if(doc.data!=null)
        count = doc["count"];
      });

      if (count == null){
        Firestore.instance.collection('bookings')
            .document(dropdownValue)
            .setData({'count': 1});
        Firestore.instance.collection('userstat')
            .document(uid)
            .setData({'uid':uid,'count':1,'service':dropdownValue,'uname':uname});

      }
      else {
        count++;
        Firestore.instance.collection('bookings')
            .document(dropdownValue)
            .setData({'count': count});
        Firestore.instance.collection('userstat')
            .document(uid)
            .setData({'uid':uid,'count':count,'service':dropdownValue,'uname':uname});

      }
      final prefs = await SharedPreferences.getInstance();
      prefs.clear();
      prefs.setString("service", dropdownValue);
      Navigator.of(context).pushReplacementNamed('/status');

    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: <Widget>[],
        elevation: 0.0,
        title: Text("HOME"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            FutureBuilder(
              future: FirebaseAuth.instance.currentUser(),
              builder: (BuildContext context, AsyncSnapshot user) {
                if (user.connectionState == ConnectionState.waiting) {
                  return Container();
                } else {
                  return Column(children: <Widget>[Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Welcome ",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        user.data.displayName.toString() + "!",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          fontSize: 20,
                        ),
                      )
                    ],
                  )
                    ,Padding(
                    padding: const EdgeInsets.only(top:80.0),
                    child: Text(
                      "Create Booking",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  )
                  ,Padding(
                    padding: const EdgeInsets.only(top:10.0),
                    child: new Theme(
                data: Theme.of(context).copyWith(
                canvasColor: Colors.blue.shade200,
                ),
                child: DropdownButton<String>(
                      value: dropdownValue,
                      onChanged: (String newValue) {
                        setState(() {
                          dropdownValue = newValue;
                        });
                      },
                      items: <String>['Select Service','Current or Savings Account','Term Deposit','Retail Loan','Agricultural Loan','Priority Sector Loan','SME Loan','Corporate Finance']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    )),
                  ),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        new RaisedButton(
                          onPressed: _loginapi_validate,
                          color: Colors.green,
                          child: new Text("Book Now!",  style: new TextStyle(color: Colors.white)),
                          padding: EdgeInsets.only(left:63.0,right:63,top:23,bottom: 23),

                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                          ),
                        )
                      ],
                    ),],);
                }
              },
            ),
            FlatButton(
              splashColor: Colors.white,
              highlightColor: Theme.of(context).hintColor,
              child: Text(
                "Logout",
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              onPressed: () {
                auth.signOut().then((onValue) {
                  Navigator.of(context).pushReplacementNamed('/login');
                });
              },
            )
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }
}
