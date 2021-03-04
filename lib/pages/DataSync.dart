import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:personal_dictionary_with_sync/database/DatabaseHelper.dart';
import 'package:personal_dictionary_with_sync/model/Words.dart';
import 'package:personal_dictionary_with_sync/network/ApiClient.dart';
import 'package:personal_dictionary_with_sync/pages/Welcome.dart';
import 'package:personal_dictionary_with_sync/utils/Colors.dart';

class DataSync extends StatefulWidget {
  @override
  _DataSyncState createState() => _DataSyncState();
}

class _DataSyncState extends State<DataSync>
    with TickerProviderStateMixin {

  var status = 'Processing..';
  List<Words> _wordModel = List();

  DatabaseHelper databaseHelper = DatabaseHelper.instance;

  double progress = 0.0;

  AnimationController _animationController;
  AnimationController _rotatAnimationController;
  Animation _animation;
  StreamController<double> _streamController;
  Stream _stream;

  var icon = 'assets/images/sync.png';
  var sync_status = 'Syncing in progress..';
  var sync_txt_color = t1_colorPrimary;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController =
        AnimationController(duration: Duration(seconds: 4), vsync: this);

    _rotatAnimationController =
        AnimationController(duration: Duration(seconds: 2), vsync: this);

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController)
      ..addListener(() {
        // update like setState
        _streamController.sink.add(_animation.value);
      });

    _rotatAnimationController.repeat();
    // start our animation
    // Once 4s is completed go to the next page
    _animationController.forward().whenComplete(() {
      _redirectToLogin();
    });

    _streamController = StreamController();
    _stream = _streamController.stream;

    _getAllAgents();
  }

  _redirectToLogin() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Welcome()));
  }

  _getAllAgents() async {
    status = 'Initializing database..';
    await databaseHelper.deleteAll();

    status = 'Configuring database..';
    final wordsList = await ApiClient().getAllAgentsData();

    status = 'Processing..';
    databaseHelper.insertAll(wordsList.toList());

   /* databaseHelper.getAll().then((rows) {
      setState(() {
        rows.forEach((row) {
          _wordModel.add(Words.fromJson(row));
        });
      });
    });*/

    _rotatAnimationController.reset();
    setState(() {
      sync_txt_color = Colors.green.shade700;
      sync_status = 'Sync complete';
      icon = 'assets/images/sync_complete.png';
    });

    status = 'Redirecting to login';
    await Future.delayed(Duration(seconds: 1));
    _streamController.sink.add(1.0);

    //TODO : Total user not print

    int total = await databaseHelper.getTotalCount();
    print("Total User : "+total.toString());

    Fluttertoast.showToast(
        msg: "Total User : "+total.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );

  }

  @override
  void dispose() {
    // TODO: implement dispose

    _animationController.dispose();
    _rotatAnimationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Stack(children: <Widget>[
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '$sync_status',
                      style: TextStyle(
                          color: sync_txt_color,
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  AnimatedBuilder(
                      animation: _rotatAnimationController.view,
                      builder: (context, child) {
                        return Transform.rotate(
                            angle: _rotatAnimationController.value * 2 * pi,
                            child: Image.asset(
                              '$icon',
                              fit: BoxFit.fill,
                            ));
                      }),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: StreamBuilder<double>(
                  initialData: progress,
                  stream: _stream,
                  builder: (context, snapshot) {
                    final value = snapshot.data;
                    print(value);
                    return SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(50.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '$status',
                                style: TextStyle(
                                    color: t1_colorPrimary, fontSize: 16.0),
                              ),
                            ),
                            Container(
                                width: double.infinity,
                                height: 10,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: t1_colorPrimary, width: 3),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Stack(
                                  children: [
                                    // LayoutBuilder provide us the available space for the conatiner
                                    // constraints.maxWidth needed for our animation
                                    LayoutBuilder(
                                      builder: (context, constraints) =>
                                          Container(
                                            // from 0 to 1 it takes 60s
                                            width: constraints.maxWidth * value,
                                            decoration: BoxDecoration(
                                              color: Colors.blue[900],
                                              borderRadius:
                                              BorderRadius.circular(50),
                                            ),
                                          ),
                                    ),
                                  ],
                                )),
                          /*  Expanded(
                              child: ListView.builder(
                                  itemCount: _wordModel.length,
                                  itemBuilder: (context, index) {
                                    var word = _wordModel[index];
                                    return ListTile(
                                        title: Text('${word.english}'),
                                        subtitle: Text('${word.bangla}'));
                                  }),
                            ),*/
                          ],
                        ),
                      ),
                    );
                  }),
            ),
          ]),
        ),
      ),
    );
  }
}
