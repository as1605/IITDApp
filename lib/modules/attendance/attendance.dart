import 'package:flutter/material.dart';

import 'package:IITDAPP/modules/attendance/screens/attendanceList.dart';
import 'package:IITDAPP/widgets/CustomAppBar.dart';
import 'package:IITDAPP/widgets/Drawer.dart';
import 'package:IITDAPP/ThemeModel.dart';
import 'package:provider/provider.dart';

class Attendance extends StatelessWidget {
  static const String routeName = '/attendance';
  final entryNumber = '2019CS11111';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Provider.of<ThemeModel>(context).theme.SCAFFOLD_BACKGROUND,
      appBar: CustomAppBar(
        title: Text('Attendance'),
      ),
      drawer: AppDrawer(
        tag: 'Attendance',
      ),
      body: AttendanceList(entryNumber),
    );
  }
}
