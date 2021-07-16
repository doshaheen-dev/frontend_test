import 'dart:math';

import 'package:acc/screens/investor/dashboard/investor_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:acc/models/authentication/verify_phone_signin.dart';
import 'package:acc/screens/fundraiser/dashboard/fundraiser_dashboard.dart';
import 'package:acc/services/OtpService.dart';
import 'package:acc/utilites/app_colors.dart';
import 'package:acc/utilites/app_strings.dart';
import 'package:acc/utilites/text_style.dart';

import 'package:acc/utilites/ui_widgets.dart';

class SignInVerifyOTP extends StatefulWidget {
  final String _verificationId;
  final String _phoneNumber;
  final String _otpType;

  const SignInVerifyOTP(
      {Key key, String verificationId, String phoneNumber, String otpType})
      : _verificationId = verificationId,
        _phoneNumber = phoneNumber,
        _otpType = otpType,
        super(key: key);

  @override
  _SignInVerifyOTPState createState() => _SignInVerifyOTPState();
}

class _SignInVerifyOTPState extends State<SignInVerifyOTP> {
  String currentText = "";
  bool hasError = false;

  String _verificationId;
  String _phoneNumber;
  String _otpType;

  TextEditingController otpController = new TextEditingController();
  var progress;

  @override
  void initState() {
    _verificationId = widget._verificationId;
    _phoneNumber = widget._phoneNumber;
    _otpType = widget._otpType;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.dark.copyWith(statusBarColor: Color(0xffffffff)));
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          elevation: 0.0,
          backgroundColor: Color(0xffffffff),
        ),
        bottomNavigationBar: BottomAppBar(),
        backgroundColor: Colors.white,
        body: ProgressHUD(
            child: Builder(
                builder: (context) => SafeArea(
                        child: SingleChildScrollView(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                          Container(
                            child: IconButton(
                              icon: Icon(Icons.arrow_back, size: 30),
                              onPressed: () => {Navigator.pop(context)},
                            ),
                          ),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 10.0, left: 25.0),
                                  child: Text(otpLabel,
                                      style: textBold28(headingBlack)),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 5.0, left: 25.0, right: 25.0),
                                  child: Text(otpSentTo,
                                      style: textNormal16(textGrey)),
                                ),
                                SizedBox(
                                  height: 25,
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: const EdgeInsets.only(
                                      top: 5.0,
                                      left: 40.0,
                                      bottom: 20,
                                      right: 40.0),
                                  child: PinCodeTextField(
                                    controller: otpController,
                                    appContext: context,
                                    pastedTextStyle: textNormal16(textGrey),
                                    length: 6,
                                    animationType: AnimationType.none,
                                    pinTheme: PinTheme(
                                      shape: PinCodeFieldShape.underline,
                                      selectedColor: Colors.grey,
                                      inactiveColor: Colors.grey,
                                      activeColor: Colors.orange,
                                      activeFillColor: Colors.orange,
                                    ),
                                    cursorColor: Colors.black,
                                    enableActiveFill: false,
                                    keyboardType: TextInputType.number,
                                    onCompleted: (v) {},
                                    onChanged: (value) {
                                      setState(() {
                                        currentText = value;
                                      });
                                    },
                                    beforeTextPaste: (text) {
                                      return false;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 40,
                                ),
                                //Verify BUTTON
                                Container(
                                    margin: const EdgeInsets.only(
                                        top: 5.0,
                                        left: 25.0,
                                        bottom: 20,
                                        right: 25.0),
                                    child: ElevatedButton(
                                        onPressed: () {
                                          if (otpController.text.isEmpty) {
                                            showSnackBar(context, warningOTP);
                                            return;
                                          }
                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());
                                          signIn(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.all(0.0),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18))),
                                        child: Ink(
                                            decoration: BoxDecoration(
                                                gradient: LinearGradient(colors: [
                                                  kDarkOrange,
                                                  kLightOrange
                                                ]),
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            child: Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: 60,
                                                alignment: Alignment.center,
                                                child: Text(verifyOtp,
                                                    style:
                                                        textWhiteBold18())))))
                              ])
                        ]))))));
  }

  void signIn(BuildContext context) {
    progress = ProgressHUD.of(context);
    progress?.showWithText(verifyingOtp);

    verifyPhoneUser("", _phoneNumber, _otpType,
        otpController.text.trim().toString(), _verificationId);
  }

  void openHome(String userType) {
    if (userType == "Investor" || userType == "investor" || userType == "") {
      Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
              pageBuilder: (context, animation, anotherAnimation) {
                return InvestorDashboard();
              },
              transitionDuration: Duration(milliseconds: 2000),
              transitionsBuilder:
                  (context, animation, anotherAnimation, child) {
                animation = CurvedAnimation(
                    curve: Curves.fastLinearToSlowEaseIn, parent: animation);
                return SlideTransition(
                  position:
                      Tween(begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0))
                          .animate(animation),
                  child: child,
                );
              }),
          (Route<dynamic> route) => false);
    } else if (userType == "Fundraiser" || userType == "fundraiser") {
      Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
              pageBuilder: (context, animation, anotherAnimation) {
                return FundraiserDashboard();
              },
              transitionDuration: Duration(milliseconds: 2000),
              transitionsBuilder:
                  (context, animation, anotherAnimation, child) {
                animation = CurvedAnimation(
                    curve: Curves.fastLinearToSlowEaseIn, parent: animation);
                return SlideTransition(
                  position:
                      Tween(begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0))
                          .animate(animation),
                  child: child,
                );
              }),
          (Route<dynamic> route) => false);
    }
  }

  Future<void> verifyPhoneUser(String token, String phoneNumber, String otpType,
      String smsCode, String verificationId) async {
    UserSignIn verifyPhoneNumber = await OtpService.verifyUserByServer(
        token, phoneNumber, verificationId, smsCode, otpType);
    progress.dismiss();

    if (verifyPhoneNumber.type == "success") {
      showSnackBarWithoutButton(context, verifyPhoneNumber.message);
      openHome(verifyPhoneNumber.data.userType);
    } else {
      _openDialog(context, verifyPhoneNumber.message);
    }
  }

  _openDialog(BuildContext context, String message) {
    // set up the buttons
    Widget positiveButton = TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(
          "Ok",
          style: textNormal16(Color(0xff00A699)),
        ));

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: Text(message),
      actions: [
        positiveButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}