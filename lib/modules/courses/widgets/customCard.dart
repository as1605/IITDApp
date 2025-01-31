// import 'package:IITDAPP/ThemeModel.dart';
import 'package:IITDAPP/ThemeModel.dart';
import 'package:IITDAPP/modules/courses/calendar/acadCalendarGenerator.dart';
import 'package:IITDAPP/modules/courses/courses.dart';
import 'package:IITDAPP/utility/analytics_manager.dart';
import 'package:IITDAPP/values/Constants.dart';
import 'package:IITDAPP/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pedantic/pedantic.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:validators/validators.dart';
import 'package:flutter/cupertino.dart';
// import 'package:IITDAPP/routes/Routes.dart';
// import 'package:provider/provider.dart';

// ignore: must_be_immutable
class CustomCard extends StatefulWidget {
  CustomCard(this.callback);
  var callback;

  List<String> list_of_calendars = [
    'My Calendar',
    'Academic Calendar',
    'IITD App',
  ];
  String curr_calendar = 'Academic Calendar';

  Map<String, String> cal_to_id = {
    'My Calendar': '1',
    'Academic Calendar': '2',
    'IITD App': '3',
  };

  @override
  _CustomCardState createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  // Check if xx is a digit

  // Init State
  @override
  initState() {
    super.initState();
    getCalendars().then((value) {
      setState(() {
        // Remove duplicates
        widget.cal_to_id = value[1];
        var cals = value[0].toSet().toList();
        widget.curr_calendar = cals[0]; //.substring(0, value[0].indexOf('('));
        print('curr calendar' + widget.curr_calendar);
        print(value);
        widget.list_of_calendars = cals;
      });
    });
    // widget.curr_calendar = widget.list_of_calendars[0];
  }

  @override
  Widget build(BuildContext context) {
    var sem = '';
    if (currentUser.email.length > 5) {
      if (currentUser.email.substring(3, 5) == "21" &&
          isNumeric(currentUser.email.substring(2, 3))) {
        sem = "1";
      } else {
        sem = "2";
      }
    }

    const height = 600.0;
    return Scaffold(
        backgroundColor: Colors.transparent,
        // Provider.of<ThemeModel>(context).theme.SCAFFOLD_BACKGROUND,
        floatingActionButton: FloatingActionButton(
          heroTag: null,
          onPressed: () async {},
          backgroundColor: Colors.deepPurpleAccent[100],
          child: IconButton(
            onPressed: () async {
              print(widget.toString());
              unawaited(showLoading(context, message: 'Generating Calendar'));
              await generate_calendar_(currentUser.tocalender,
                  widget.cal_to_id[widget.curr_calendar]);
              Navigator.pop(context);

              logEvent(AnalyticsEvent.EXPORT_CALENDAR_SUCCESS,
                  value: currentUser.tocalender.length);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Calendar Generated'),
                duration: Duration(seconds: 3),
              ));
              widget.callback();
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            icon: FaIcon(
              FontAwesomeIcons.fileExport,
              // Icons.share,
              size: 25,
            ),
          ),
        ),
        body: Container(
          height: height, // change this
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(height / 20)),
            color: Provider.of<ThemeModel>(context)
                .theme
                .COURSE_CARD
                .withOpacity(1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(height: 10),
              Text(
                'Courses',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w600),
              ),
              Container(height: 10),
              Text(
                '2021-22 Sem $sem',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
              ),
              Container(height: 8),
              Divider(
                color: Colors.grey,
              ),
              Container(
                  height: 360,
                  child: NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (overscroll) {
                      overscroll.disallowGlow();
                      return;
                    },
                    child: SingleChildScrollView(
                        physics: ClampingScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            ...currentUser.tocalender
                                .map((e) => UserCourse(e))
                                .toList(),
                          ],
                        )),
                  )),
              Divider(
                height: 5,
              ),
              if (widget.list_of_calendars != null)
                Container(
                  margin: EdgeInsets.fromLTRB(20, 10, 100, 0),
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: Text(
                        widget.curr_calendar,
                        style: TextStyle(
                            color: Colors.deepPurpleAccent[100],
                            fontWeight: FontWeight.w500),
                      ),
                      value: widget.curr_calendar,
                      style: TextStyle(
                          color: Colors.deepPurpleAccent[100],
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                      // alignment: Alignment.bottomCenter,
                      icon: Icon(
                        CupertinoIcons.calendar_badge_plus,
                        size: 30,
                        color: Colors.deepPurpleAccent[100],
                      ),
                      items: widget.list_of_calendars.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(fontSize: 16)),
                        );
                      }).toList(),
                      onChanged: (_) {
                        widget.curr_calendar = _;
                        setState(() {});
                      },
                    ),
                  ),
                )
            ],
          ),
        ));
  }
}

// Container(
//   margin: EdgeInsets.fromLTRB(10, 10, 0, 0),
//   child: TextButton(
//       style: ButtonStyle(
//         overlayColor: MaterialStateColor.resolveWith(
//             (states) => Colors.transparent),
//       ),
//       onPressed: () => {
//             Navigator.pop(context),
//             // Navigator.pushNamed(context, Routes.coursesPage),
//             Navigator.push(
//                 context,
//                 PageRouteBuilder(
//                     pageBuilder: (_, __, ___) =>
//                         CoursesScreen()))
//           },
//       child: Text("Back")),
// ),
