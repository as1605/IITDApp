import 'package:flutter/material.dart';

import 'package:IITDAPP/modules/attendance/widgets/headings/attendanceListHeader.dart';
import 'package:IITDAPP/modules/attendance/data/attendanceModel.dart';
import 'package:IITDAPP/modules/attendance/widgets/cards/courseCard.dart';
import 'package:IITDAPP/values/colors/colors.dart';
import 'package:IITDAPP/modules/news/widgets/shimmers/sizedShimmer.dart';

class AttendanceList extends StatefulWidget {
  final entryNumber;
  const AttendanceList(
    this.entryNumber, {
    Key key,
  }) : super(key: key);

  @override
  _AttendanceListState createState() => _AttendanceListState();
}

class _AttendanceListState extends State<AttendanceList> {
  @override
  Widget build(BuildContext context) {
    // print('built AttendanceList');
    final loadingShimmer = SizedShimmer(
      baseColor: Colors.purple[900],
      highlightColor: Colors.purple[700],
      height: 80,
    );
    var _result = AttendanceModel.getAttendanceData(widget.entryNumber);
    return FutureBuilder(
      builder: (context, AsyncSnapshot<List<AttendanceModel>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AttendanceListHeader('Poor'),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0, bottom: 5),
                      child: loadingShimmer,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0, bottom: 5),
                      child: loadingShimmer,
                    ),
                    AttendanceListHeader('Regular'),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0, bottom: 5),
                      child: loadingShimmer,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0, bottom: 5),
                      child: loadingShimmer,
                    ),
                  ]),
            );
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.PRIMARY_COLOR_LIGHT),
                  ),
                  FlatButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: Text('REFRESH'),
                    textColor: AppColors.PRIMARY_COLOR_DARK,
                    color: AppColors.PRIMARY_COLOR,
                  )
                ],
              );
            }
            var children = <Widget>[];
            var regular = snapshot.data.where((f) =>
                (f.daysPresent) / (f.daysAbsent + f.daysPresent) >= 0.75);
            var poor = snapshot.data.where(
                (f) => (f.daysPresent) / (f.daysAbsent + f.daysPresent) < 0.75);
            if (poor.isNotEmpty) {
              children.add(AttendanceListHeader('Poor'));
              children.addAll(poor.map((i) => CourseCard(i)));
            }
            if (regular.isNotEmpty) {
              children.add(AttendanceListHeader('Regular'));
              children.addAll(regular.map((i) => CourseCard(i)));
            }
            return RefreshIndicator(
              color: AppColors.COURSE_CARD,
              onRefresh: () {
                print('refresh called');
                return _result =
                    AttendanceModel.getAttendanceData(widget.entryNumber);
              },
              child: ListView(
                children: children,
              ),
            );
          default:
            return null; // success - build whatever UI elements you need
        }
      },
      future: _result,
    );
  }
}
