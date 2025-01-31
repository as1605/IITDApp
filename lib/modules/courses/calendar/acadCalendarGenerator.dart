import 'dart:convert';

import 'package:IITDAPP/modules/calendar/calendar.dart';
import 'package:IITDAPP/values/Constants.dart';
import 'package:IITDAPP/widgets/course_class.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:validators/validators.dart';

Map<String, DayOfWeek> textToDayOfWeek = {
  'Mo': DayOfWeek.Monday,
  'Tu': DayOfWeek.Tuesday,
  'We': DayOfWeek.Wednesday,
  'Th': DayOfWeek.Thursday,
  'Fr': DayOfWeek.Friday,
  'Sa': DayOfWeek.Saturday,
  'Su': DayOfWeek.Sunday,
};

var textToDayofWeekInt = {
  'Mo': 1,
  'Tu': 2,
  'We': 3,
  'Th': 4,
  'Fr': 5,
  'Sa': 6,
  'Su': 7,
};

var intToTextDay = {
  1: 'Mo',
  2: 'Tu',
  3: 'We',
  4: 'Th',
  5: 'Fr',
  6: 'Sa',
  7: 'Su',
};

Future<String> getJson(fn) async {
  return rootBundle.loadString(fn);
}

createCalForSlot(
    holidays, times, DeviceCalendarPlugin dc, course_name, cal_id) async {
  for (var time in times) {
    List<DayOfWeek> daysOfWeek = [];
    for (var day in time[0]) {
      daysOfWeek.add(textToDayOfWeek[day]);
    }
    daysOfWeek.add(DayOfWeek.Saturday);
    var endDate = DateFormat("dd/MM/yyyy")
        .parse(holidays['endingDate'])
        .add(Duration(days: 1));
    var rrule = RecurrenceRule(RecurrenceFrequency.Weekly,
        interval: 1, endDate: endDate, daysOfWeek: daysOfWeek);

    // Define the start date as the date with first occurence of day occurs starting from now
    var startDate = DateTime.now()
            .isAfter(DateFormat("dd/MM/yyyy").parse(holidays['startingDate']))
        ? DateTime.now()
        : DateFormat("dd/MM/yyyy").parse(holidays['startingDate']);
    var startDateTime = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      int.parse(time[1][0].split(':')[0]),
      int.parse(time[1][0].split(':')[1]),
    ); // Extract Day from startDateTime
    for (int i = 0; i < 7; i++) {
      if (time[0].contains(intToTextDay[startDateTime.weekday])) {
        break;
      }
      startDateTime = startDateTime.add(Duration(days: 1));
    }
    var endDateTime = DateTime(
      startDateTime.year,
      startDateTime.month,
      startDateTime.day,
      int.parse(time[1][1].split(':')[0]),
      int.parse(time[1][1].split(':')[1]),
    );

    var event = Event(cal_id, // Google Calendar ID
        title: course_name, // Course Name
        description: '$course_name Class', // Course Name
        start: startDateTime,
        end: endDateTime,
        recurrenceRule: rrule);

    String exdate = "";
    // Construct the exdate from the holidays
    for (var holiday in holidays['excludedDates']) {
      var date = DateFormat("dd/MM/yyyy")
          .parse(holiday); //DateFormat("yyyyMMddThhmmssZ").parse(holiday);
      date = date.add(
          Duration(hours: startDateTime.hour, minutes: startDateTime.minute));
      exdate += date
              .toUtc()
              .toIso8601String()
              .replaceAll('-', '')
              .replaceAll(':', '')
              .replaceAll('.000', '') +
          ",";
    }
    // Now add non-working saturdays on exdate

    // First calc the first saturday date staring from startDateTime
    var saturdayDate = startDateTime;
    while (saturdayDate.weekday != 6) {
      saturdayDate = saturdayDate.add(Duration(days: 1));
    }

    // Now add all the saturdays except those in holidays['extraDays']
    while (saturdayDate.isBefore(endDate)) {
      var isclass = false;
      for (var day in holidays['extraDays']) {
        var date = DateFormat("dd/MM/yyyy")
            .parse(day[0]); //DateFormat("yyyyMMddThhmmssZ").parse(holiday);
        if (!(saturdayDate.year == date.year &&
            saturdayDate.month == date.month &&
            saturdayDate.day == date.day)) {
          continue;
        }
        if (time[0].contains(day[1])) {
          // Class is there
          isclass = true;
          break;
        }
      }
      if (!isclass) {
        exdate += saturdayDate
                .toUtc()
                .toIso8601String()
                .replaceAll('-', '')
                .replaceAll(':', '')
                .replaceAll('.000', '') +
            ",";
      }
      saturdayDate = saturdayDate.add(Duration(days: 7));
    }

    event.exdate = exdate.substring(0, exdate.length - 1);

    var createEventResult = await dc.createOrUpdateEvent(event);
    if (!createEventResult.isSuccess) return false;
    // ignore: unused_local_variable
    var eventId = createEventResult.data;
  }
  print('Done Exporting');
  return true;
}

int getCalendarScore(cal) {
  if (cal.accountName == 'IITDAPP' && cal.name == 'Academic Calendar') {
    return -1;
  }
  if (cal.accountType == 'com.google' &&
      cal.accountName.contains('@gmail.com')) {
    if (cal.isDefault) {
      return -3;
    }
    return -2;
  }
  return 0;
}

Future<List> getCalendars() async {
  List<Calendar> calendars = [];
  var calendarsResult = await DeviceCalendarPlugin().retrieveCalendars();
  if (calendarsResult.isSuccess) {
    calendars = List.from(calendarsResult.data);
  }
  calendars.sort((a, b) => getCalendarScore(a).compareTo(getCalendarScore(b)));
  // Google Calendars and Academic Calendars get the highest priorities

  // Convert to list of strings
  List<String> calendarNames = [];
  Map<String, String> calendarNameToId = {};
  for (var cal in calendars) {
    calendarNames.add(cal.name.trim());
    calendarNameToId[cal.name.trim()] = cal.id;
    // calendarNames.add(cal.name + ' (' + cal.accountName + ')');
  }
  return [calendarNames, calendarNameToId];
}

Future<String> getCalendarId(DeviceCalendarPlugin dc) async {
  var calendars = await dc.retrieveCalendars();
  for (var cal in calendars.data) {
    if (cal.accountType == 'com.google' &&
        cal.accountName.contains('@gmail.com') &&
        cal.isDefault) {
      return cal.id;
    }
  }
  // Cannot find the google calendar, try to find create/academic calendar
  for (var cal in calendars.data) {
    if (cal.accountName == 'IITDAPP' && cal.name == 'Academic Calendar') {
      return cal.id;
    }
  }
  // Academic Calendar Doesnt exist, create all the calendars
  return await createCalendar(calNames[0], accountName);
}

String getSem() {
  var sem = '';
  if (currentUser.email.length > 5) {
    if (currentUser.email.substring(3, 5) == "21" &&
        isNumeric(currentUser.email.substring(2, 3))) {
      sem = "1";
    } else {
      sem = "2";
    }
  }
  return sem;
}

generate_calendar_(List<Course> courses, String cal_id) async {
  // Given Courses Map, iterate over the map and create new recurrence event for each course
  // This will be followed by removing the holiday dates
  // This will be followed by adding the extra timetable days
  // We are all set.
  DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
  // var cal_id = await getCalendarId(_deviceCalendarPlugin);

  var slotting =
      json.decode(await getJson('assets/courses/slotting_pattern.jsonc'));
  var holidays;
  if (getSem() == '1') {
    holidays = json.decode(await getJson('assets/courses/holidays_sem1.jsonc'));
  } else {
    holidays = json.decode(await getJson('assets/courses/holidays.jsonc'));
  }
  for (var course in courses) {
    var slot = course.slot;
    // Check if slot is in the slotting dict
    if (slotting.containsKey(slot)) {
      // If it is, then add the course to the slotting dict
      await createCalForSlot(holidays, slotting[slot], _deviceCalendarPlugin,
          course.name.toUpperCase(), cal_id);
    } else {
      continue;
    }
  }
  return true;
}
