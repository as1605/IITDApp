import 'package:IITDAPP/values/Constants.dart';

import 'package:IITDAPP/ThemeModel.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
//import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

import '../event_class.dart';
import './event_info_card.dart';
import './event_about.dart';
import './event_updates_list.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';
// import 'package:IITDAPP/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
// import 'dart:math';

Future<Event> getEvent(String eventid) async {
  final response = await http.get('$uri/api/events/$eventid',
      headers: {'authorization': 'Bearer $token'});
  if (response.statusCode == 200) {
    var parsedJson = json.decode(response.body);
    var event = Event.fromJson(parsedJson['event']);

    // final http.Response responseData =
    //     await http.get("$uri/{$parsedJson['event']['image']}");
    // var uint8list = responseData.bodyBytes;
    // var buffer = uint8list.buffer;
    // ByteData byteData = ByteData.view(buffer);
    // var tempDir = await getTemporaryDirectory();
    // File file = await File('${tempDir.path}/img.png').writeAsBytes(
    //     buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    // var img = Image.network("$uri/{$parsedJson['event']['image']}");
    // var bytes = await rootBundle.load();

    var imgurl = "${parsedJson['event']['image']}";
    var tptp = "$uri/$imgurl";
    // var rng = Random();
    // String temp = (await getTemporaryDirectory()).path;
    // File file = File('$temp/' + rng.nextInt(100000).toString() + '.png');
    // http.Response response2 = await http.get(tptp);
    // await file.writeAsBytes(response2.bodyBytes);
    // event.eventImage = file;
    // tempo.add(file.path);
    event.imageLink = tptp;

    return event;
  } else {
    throw Exception('Failed to load Event');
  }
}

class EventInfo extends StatefulWidget {
  final String id;
  // final Function _reorderLists;
  final bool showButton;

  const EventInfo(this.id, {this.showButton = true});

  @override
  State<StatefulWidget> createState() {
    return EventInfoState();
  }
}

class EventInfoState extends State<EventInfo> {
  String id;

  @override
  void initState() {
    super.initState();
    id = widget.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Provider.of<ThemeModel>(context).theme.SCAFFOLD_BACKGROUND,
      appBar: AppBar(
        backgroundColor: Provider.of<ThemeModel>(context).theme.APP_BAR_START,
        //backgroundColorEnd: Provider.of<ThemeModel>(context).theme.APP_BAR_END,
        title: Text('Event'),
        centerTitle: true,
        // actions: <Widget>[ProfileIcon()],
      ),
      body: FutureBuilder(
        future: getEvent(id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView(
              children: <Widget>[
                EventInfoCard(
                  snapshot.data,
                  showButton: widget.showButton,
                ),
                EventAbout(snapshot.data),
                EventUpdatesList(snapshot.data.eventid)
              ],
            );
          } else if (snapshot.hasError) {
            print(snapshot);
            return Center(
              child: Text(
                'Some Error Occurred',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w300,
                ),
              ),
            );
          }

          return Center(
            child: CircularProgressIndicator(
                // valueColor: AlwaysStoppedAnimation<Color>(
                //     Provider.of<ThemeModel>(context,listen:false).theme.PRIMARY_TEXT_COLOR),
                ),
          );
        },
      ),
    );
  }
}
