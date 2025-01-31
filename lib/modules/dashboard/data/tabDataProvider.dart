import 'package:IITDAPP/modules/dashboard/data/dashboardAlerts.dart';
import 'package:IITDAPP/modules/news/data/newsData.dart';
// import 'package:IITDAPP/modules/news/news.dart';
import 'package:IITDAPP/utility/apiResponse.dart';
import 'package:IITDAPP/values/Constants.dart';

import 'package:flutter/foundation.dart';
import 'package:localstorage/localstorage.dart';

class TabDataProvider<T> with ChangeNotifier {
  ApiResponse data;
  List<int> alerts = [];
  // ignore: prefer_typing_uninitialized_variables
  var cnp;
  DashboardAlerts da;
  Function getCacheData;
  Function filter;
  int limit;
  LocalStorage ls = LocalStorage('newsClickHistory${currentUser.id}');

  @override
  void dispose() {
    cnp.removeListener(listenerAttachment);
    super.dispose();
  }

  void listenerAttachment() {
    update(getCacheData(cnp));
  }

  void update(ApiResponse newData) async {
    // print('updating ${limit??0}');
    if (newData.status != Status.COMPLETED) {
      data = newData;
      notifyListeners();
    } else {
      // print('completed');
      var filteredData = filter(newData.data.sublist(
          0, newData.data.length > limit ? limit : newData.data.length));
      // print('data $filteredData');
      var newsViewed = (await ls.getItem('newsID') ?? []) as List;
      // Sort based on if it is viewed or not
      // if newsViweded then give them low preference
      // else give them high preference

      int funCompare(var a, var b) {
        var a1 = newsViewed.contains(a.id);
        var b1 = newsViewed.contains(b.id);
        return a1
            ? b1
                ? b.createdAt.isAfter(a.createdAt)
                    ? 1
                    : -1
                : 1
            : b1
                ? -1
                : b.createdAt.isAfter(a.createdAt)
                    ? 1
                    : -1;
      }

      if (filteredData.length > 0) {
        if (filteredData[0] is NewsModel) {
          filteredData.sort(funCompare);
        }
      }
      alerts = await da.getAlerts(filteredData);
      // print('alerts $alerts');
      data = ApiResponse.completed(filteredData);
      notifyListeners();
    }
  }

  void viewed() {
    da.setAlerts(data.data);
    // print('set alerts $alerts');
  }

  void refreshAlerts() async {
    if (data.status == Status.COMPLETED) {
      // print('refresh ${data.data.length}');
      alerts = await da.getAlerts(data.data);
    }
    notifyListeners();
  }

  TabDataProvider(
      {this.cnp,
      this.getCacheData,
      this.da,
      @required this.limit,
      this.filter}) {
    // print('new tab');
    filter ??= (i) => i;
    data = getCacheData(cnp);
    update(getCacheData(cnp));
    cnp.addListener(listenerAttachment);
  }
}
