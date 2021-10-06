import 'package:acc/models/country/country.dart';
import 'package:acc/services/country_service.dart';
import 'package:acc/utilites/app_strings.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:acc/screens/common/authentication/signin_otp.dart';
import 'package:acc/screens/common/user_type.dart';
import 'package:acc/utilites/app_colors.dart';
import 'package:acc/utilites/text_style.dart';
import 'package:acc/utilites/ui_widgets.dart';
import 'package:acc/models/local_countries.dart' as localCountry;

class OnBoarding extends StatefulWidget {
  @override
  _OnBoardingState createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  int currentPageValue = 0;
  int previousPageValue = 0;
  PageController controller;
  double _moveBar = 0.0;

  Color statusBarColor;

  double scale;
  List<localCountry.Countries> countryList = [];

  @override
  void initState() {
    super.initState();
    getAllCountries();
    _init();
  }

  void _init() async {
    controller = PageController(initialPage: currentPageValue);
  }

  @override
  Widget build(BuildContext context) {
    scale = MediaQuery.of(context).textScaleFactor;

    if (currentPageValue == 0) {
      statusBarColor = statusGrey;
      SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle.dark.copyWith(statusBarColor: statusGrey));
    } else if (currentPageValue == 1) {
      statusBarColor = statusGrey1;
      SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle.dark.copyWith(statusBarColor: statusGrey1));
    } else if (currentPageValue == 2) {
      statusBarColor = statusGrey2;
      SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle.dark.copyWith(statusBarColor: statusGrey2));
    } else {
      statusBarColor = statusGrey;
      SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle.dark.copyWith(statusBarColor: statusGrey));
    }

    final List<Widget> introWidgetsList = <Widget>[
      Stack(children: [
        Container(
            child: Stack(children: [
          Image.asset(
            'assets/images/onboarding/onboarding_first.png',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.fill,
          ),
          _addLogo(),
        ])),
        Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.all(25.0),
            child: Text(
              onBoardingScreen1,
              //  textScaleFactor: 1.0,
              textAlign: TextAlign.center,
              style: textWhiteBold20(),
            ))
      ]),
      Stack(children: [
        Container(
            child: Stack(children: [
          Image.asset(
            'assets/images/onboarding/onboarding_second.png',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.fill,
          ),
          _addLogo(),
        ])),
        Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.all(25.0),
            child: Text(
              onBoardingScreen2,
              //  textScaleFactor: 1.0,
              textAlign: TextAlign.center,
              style: textWhiteBold20(),
            ))
      ]),
      Stack(children: [
        Container(
            child: Stack(children: [
          Image.asset(
            'assets/images/onboarding/onboarding_third.png',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.fill,
          ),
          _addLogo(),
        ])),
        Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.all(25.0),
            child: Text(
              onBoardingScreen3,
              //   textScaleFactor: 1.0,
              textAlign: TextAlign.center,
              style: textWhiteBold20(),
            ))
      ])
    ];

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(backgroundColor: Colors.white),
        home: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: Scaffold(
                appBar: AppBar(
                  toolbarHeight: 0,
                  elevation: 0.0,
                  backgroundColor: (statusBarColor),
                ),
                bottomNavigationBar: BottomAppBar(),
                body: SafeArea(
                    child: Column(children: [
                  // Slider View
                  Expanded(
                      child: Container(
                          child: Stack(
                              alignment: AlignmentDirectional.bottomCenter,
                              children: <Widget>[
                        PageView.builder(
                            physics: BouncingScrollPhysics(),
                            itemCount: introWidgetsList.length,
                            onPageChanged: (int page) {
                              getChangedPageAndMoveBar(page);
                            },
                            controller: controller,
                            itemBuilder: (context, index) {
                              return introWidgetsList[index];
                            }),
                        Stack(
                            alignment: AlignmentDirectional.topCenter,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(top: 5),
                                child: Divider(color: Colors.white70),
                              ),
                              Container(
                                  margin: EdgeInsets.only(bottom: 100),
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        for (int i = 0;
                                            i < introWidgetsList.length;
                                            i++)
                                          if (i == currentPageValue) ...[
                                            circleBar(true, i)
                                          ] else
                                            circleBar(false, i),
                                      ]))
                            ])
                      ]))),
                  // Bottom view
                  Container(
                      color: kDarkGrey,
                      height: 150,
                      child: Column(children: [
                        InkWell(
                            borderRadius: BorderRadius.circular(40),
                            onTap: () {
                              
                              // Open  view
                              Navigator.of(context).push(PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation, anotherAnimation) {
                                    return UserType();
                                  },
                                  transitionDuration:
                                      Duration(milliseconds: 2000),
                                  transitionsBuilder: (context, animation,
                                      anotherAnimation, child) {
                                    animation = CurvedAnimation(
                                        curve: Curves.fastLinearToSlowEaseIn,
                                        parent: animation);
                                    return SlideTransition(
                                      position: Tween(
                                              begin: Offset(1.0, 0.0),
                                              end: Offset(0.0, 0.0))
                                          .animate(animation),
                                      child: child,
                                    );
                                  }));
                            },
                            child: Container(
                                margin: const EdgeInsets.only(
                                    top: 20.0, left: 25.0, right: 25.0),
                                height: 60,
                                decoration: appColorButton(context),
                                child: Center(
                                    child: Text(
                                  "Join our community",
                                  //  textScaleFactor: 1.0,
                                  style: textWhiteBold18(),
                                )))),
                        Container(
                            margin: const EdgeInsets.only(top: 20.0),
                            alignment: Alignment.center,
                            child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                    text: "Already a member? ",
                                    style: textNormal16(textDarkOrange),
                                    children: [
                                      TextSpan(
                                          text: 'Sign In',
                                          style: textNormal16(
                                              Theme.of(context).primaryColor),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              openSignIn(context);
                                            })
                                    ])))
                      ]))
                ])))));
  }

  void openSignIn(BuildContext context) {
    print("size onboarding countryList:-${countryList.length}");
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, anotherAnimation) {
          return SignInOTP(countriesList: countryList);
        },
        transitionDuration: Duration(milliseconds: 1000),
        transitionsBuilder: (context, animation, anotherAnimation, child) {
          animation = CurvedAnimation(
              curve: Curves.fastLinearToSlowEaseIn, parent: animation);
          return SlideTransition(
            position: Tween(begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0))
                .animate(animation),
            child: child,
          );
        }));
  }

  Widget circleBar(bool isActive, int currentPageValue) {
    return Row(
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 2),
          margin: EdgeInsets.symmetric(horizontal: 8),
          height: 30.0,
          width: 30.0,
          child: Container(
            alignment: Alignment.center,
            child: Text(
              (currentPageValue + 1).toString(),
              textAlign: TextAlign.center,
              //  textScaleFactor: 1.0,
              style: textBold14(Colors.black),
            ),
          ),
          decoration: BoxDecoration(
              color: isActive ? kwhiteGrey : kIndicatorInactive,
              borderRadius: BorderRadius.all(Radius.circular(20))),
        )
      ],
    );
  }

  void getChangedPageAndMoveBar(int page) {
    currentPageValue = page;

    if (previousPageValue == 0) {
      previousPageValue = currentPageValue;
      _moveBar = _moveBar + 0.14;
    } else {
      if (previousPageValue < currentPageValue) {
        previousPageValue = currentPageValue;
        _moveBar = _moveBar + 0.14;
      } else {
        previousPageValue = currentPageValue;
        _moveBar = _moveBar - 0.14;
      }
    }
    setState(() {});
  }

  Widget _addLogo() {
    return Container(
      margin: const EdgeInsets.only(left: 15.0),
      child: Image.asset(
        'assets/images/app_logo.png',
        width: 160,
        height: 100,
      ),
    );
  }

  Future<void> getAllCountries() async {
    final Country extractedData = await CountryService.fetchCountries();
    if (extractedData.type == "success") {
      if (extractedData.data.options.length != 0) {
        countryList.clear();
        for (int i = 0; i < extractedData.data.options.length; i++) {
          var value = extractedData.data.options[i];
          countryList.add(localCountry.Countries(
              value.countryName,
              value.countryAbbr,
              int.parse(
                  value.countryPhCode.replaceAll(new RegExp(r'[^0-9]'), '')),
              value.maxLength));
        }
      }
    }
  }
}
