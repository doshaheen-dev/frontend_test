import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:acc/screens/requests/request_recieved.dart';
import 'package:acc/screens/requests/request_sent.dart';

class Requests extends StatefulWidget {
  @override
  _RequestState createState() => new _RequestState();
}

class _RequestState extends State<Requests>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.dark.copyWith(statusBarColor: Color(0xff00A699)));
    return new Scaffold(
      body: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => {},
              ),
              backgroundColor: Color(0xff00A699),
              title: Text(
                "Requests",
              ),
              centerTitle: false,
              bottom: TabBar(
                indicator: UnderlineTabIndicator(
                    insets: EdgeInsets.symmetric(horizontal: 16.0)),
                controller: _tabController,
                indicatorColor: Colors.white,
                unselectedLabelColor: Colors.grey[600],
                tabs: [
                  Tab(
                    child: Text(
                      "Request Received",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "Request Sent",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                RequestRecieved(),
                RequestSent(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
