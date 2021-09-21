import 'package:acc/constants/font_family.dart';
import 'package:acc/models/authentication/otp_response.dart';
import 'package:acc/models/country/country.dart';
import 'package:acc/models/local_countries.dart';
import 'package:acc/services/country_service.dart';
import 'package:acc/utilites/hex_color.dart';
import 'package:acc/utils/code_utils.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:acc/screens/common/authentication/signin_verify_otp.dart';
import 'package:acc/services/OtpService.dart';
import 'package:acc/utilites/app_colors.dart';
import 'package:acc/utilites/app_strings.dart';
import 'package:acc/utilites/text_style.dart';
import 'package:provider/provider.dart';
import '../../../providers/country_provider.dart' as countryProvider;

import 'package:acc/utilites/ui_widgets.dart';
import 'package:ps_code_checking/ps_code_checking.dart';

class SignInOTP extends StatefulWidget {
  final List<Countries> _countriesList;

  SignInOTP({Key key, List<Countries> countriesList})
      : _countriesList = countriesList,
        super(key: key);

  @override
  _SignInOTPState createState() => _SignInOTPState();
}

class _SignInOTPState extends State<SignInOTP> {
  TextEditingController phoneController = new TextEditingController();
  final captchaController = CodeCheckController();
  final textConroller = TextEditingController();
  var progress;
  Map<String, dynamic> selectedCountryItem;
  List<Countries> countryList = [];
  // <Countries>[
  //   const Countries("India", "IN", 91, 10),
  //   const Countries("Singapore", "SG", 65, 12),
  //   const Countries("United States", "US", 1, 10),
  // ];
  Future _countries;
  var _isInit = true;
  bool _isDropdownVisible = true;

  bool showLabel = true;

  Countries selectedCountry;

  void showToast() {
    setState(() {
      _isDropdownVisible = true;
    });
  }

  void showTextLabel(bool value) {
    setState(() {
      showLabel = value;
    });
  }

  Future<void> _fetchAllCountries(BuildContext context) async {
    // await Provider.of<countryProvider.Countries>(context, listen: false)
    //     .fetchAndSetCountries();

    final Country extractedData = await CountryService.fetchCountries();
    if (extractedData.type == "success") {
      if (extractedData.data.options.length != 0) {
        countryList.clear();
        for (int i = 0; i < extractedData.data.options.length; i++) {
          var value = extractedData.data.options[i];
          countryList.add(Countries(
              value.countryName,
              value.countryAbbr,
              int.parse(
                  value.countryPhCode.replaceAll(new RegExp(r'[^0-9]'), '')),
              10));
        }
        if (countryList.isNotEmpty) {
          selectedCountry = countryList[0];
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      // _countries = _fetchAllCountries(context);
      // _fetchAllCountries(context);
    }

    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    print("Signin -> ${widget._countriesList.length}");
    countryList = widget._countriesList;
    // _fetchAllCountries(context);
    //  selectedCountry = countryList[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.dark.copyWith(statusBarColor: Color(0xffffffff)));
    return MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: Scaffold(
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
                                width: 60,
                                height: 60,
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
                                      child: Text(loginHeader,
                                          style: textBold26(headingBlack)),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(
                                          top: 5.0, left: 25.0, right: 25.0),
                                      child: Text(loginVia,
                                          style: textNormal16(textGrey)),
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    _createMobileFields(),
                                    //CAPTCHA
                                    _createCaptcha(context),

                                    //SIGN IN BUTTON
                                    Container(
                                        margin: const EdgeInsets.only(
                                            top: 5.0,
                                            left: 25.0,
                                            bottom: 20,
                                            right: 25.0),
                                        child: ElevatedButton(
                                            onPressed: () {
                                              FocusScope.of(context)
                                                  .requestFocus(FocusNode());

                                              if (phoneController
                                                  .text.isEmpty) {
                                                showSnackBar(context,
                                                    correctEmailMobile);
                                                return;
                                              }

                                              if (!captchaController.verify(
                                                  textConroller.value.text)) {
                                                showSnackBar(
                                                    context, correctCaptcha);
                                                textConroller.clear();
                                                captchaController.refresh();
                                                return;
                                              }
                                              if (CodeUtils.emailValid(
                                                  phoneController.text)) {
                                                progress =
                                                    ProgressHUD.of(context);

                                                progress
                                                    ?.showWithText(sendingOtp);

                                                sendOTPServer(
                                                    phoneController.text,
                                                    "twilio",
                                                    "email");
                                              } else if (!CodeUtils.isPhone(
                                                  phoneController.text)) {
                                                print(
                                                    "selectedCountry- ${selectedCountry.name}\n maxLength = ${selectedCountry.maxLength}");
                                                if (selectedCountry == null) {
                                                  showSnackBar(context,
                                                      errorCountryCode);
                                                  return;
                                                }

                                                if (selectedCountry.maxLength !=
                                                    phoneController
                                                        .text.length) {
                                                  showSnackBar(context,
                                                      "Phone number should be of ${selectedCountry.maxLength} digits.");
                                                  return;
                                                }

                                                print("mobile");
                                                progress =
                                                    ProgressHUD.of(context);
                                                progress
                                                    ?.showWithText(sendingOtp);

                                                sendOTPServer(
                                                    phoneController.text,
                                                    "twilio",
                                                    "mobile");
                                              } else {
                                                showSnackBar(context,
                                                    warningEmailMobile);
                                                return;
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                                padding: EdgeInsets.all(0.0),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            18))),
                                            child: Ink(
                                                decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                        colors: [
                                                          Theme.of(context)
                                                              .primaryColor,
                                                          Theme.of(context)
                                                              .primaryColor
                                                        ]),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: 60,
                                                  alignment: Alignment.center,
                                                  child: Text(sendOtp,
                                                      style: textWhiteBold18()),
                                                ))))
                                  ]),
                            ])),
                      )),
            )));
  }

  Row _createMobileFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Visibility(
          visible: _isDropdownVisible,
          child: Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.only(
                    top: 5.0, left: 25.0, bottom: 20, right: 5.0),
                width: MediaQuery.of(context).size.width,
                height: 80,
                decoration: customDecoration(),
                child: _buildCodeDropDown(countryList
                    .map((info) => {
                          'text': info.name,
                          'value': info.dialCode,
                        })
                    .toList()),
              )),
        ),
        Visibility(
          visible: !_isDropdownVisible,
          child: SizedBox(
            width: 20,
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.only(top: 5.0, bottom: 20, right: 25.0),
            decoration: customDecoration(),
            child: inputTextField(mobileEmailLabel, phoneController),
          ),
        ),
      ],
    );
  }
  // Widget _createMobileFields() {
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     children: [
  //       Visibility(
  //         visible: _isDropdownVisible,
  //         child: Flexible(
  //             child:
  //                 // Container(
  //                 //   margin: const EdgeInsets.only(
  //                 //       top: 5.0, left: 25.0, bottom: 20, right: 5.0),
  //                 //   decoration: customDecoration(),
  //                 //   child: _buildCodeDropDown(),
  //                 // )

  //                 // InkWell(
  //                 //     highlightColor: Colors.transparent,
  //                 //     splashColor: Colors.transparent,
  //                 //     onTap: () {
  //                 //       openInvestmentList();
  //                 //     },
  //                 //     child: Container(
  //                 //       margin: const EdgeInsets.only(
  //                 //           top: 5.0, left: 25.0, bottom: 20, right: 5.0),
  //                 //       decoration: customDecoration(),
  //                 //       child: Column(
  //                 //         children: [
  //                 //           Visibility(
  //                 //               visible: !showLabel,
  //                 //               child: Container(
  //                 //                 margin: EdgeInsets.only(top: 5),
  //                 //                 child: Text(
  //                 //                   "Country Code",
  //                 //                   style: textNormal12(Colors.grey[600]),
  //                 //                 ),
  //                 //               )),
  //                 //           Row(
  //                 //             children: [
  //                 //               Visibility(
  //                 //                 visible: showLabel,
  //                 //                 child: Container(
  //                 //                   child: Padding(
  //                 //                     padding: EdgeInsets.only(
  //                 //                         left: 10.0,
  //                 //                         right: 10.0,
  //                 //                         top: 25.0,
  //                 //                         bottom: 25.0),
  //                 //                     child: Text("Code",
  //                 //                         style: textNormal14(Colors.grey[600])),
  //                 //                   ),
  //                 //                 ),
  //                 //               ),
  //                 //               Visibility(
  //                 //                   visible: !showLabel,
  //                 //                   child: Container(
  //                 //                       child: Padding(
  //                 //                     padding: EdgeInsets.only(
  //                 //                       left: 10.0,
  //                 //                       right: 10.0,
  //                 //                     ),
  //                 //                     child: selectedCountryItem != null
  //                 //                         ? Align(
  //                 //                             alignment: Alignment.center,
  //                 //                             child: Text(
  //                 //                               selectedCountryItem.phoneCode
  //                 //                                   .toString(),
  //                 //                               style: textNormal14(Colors.black),
  //                 //                             ),
  //                 //                           )
  //                 //                         : Text(
  //                 //                             "Country Code",
  //                 //                             style:
  //                 //                                 textNormal14(Colors.grey[600]),
  //                 //                           ),
  //                 //                   ))),
  //                 //               Spacer(),
  //                 //               IconButton(
  //                 //                   onPressed: () {
  //                 //                     openInvestmentList();
  //                 //                   },
  //                 //                   splashColor: Colors.transparent,
  //                 //                   highlightColor: Colors.transparent,
  //                 //                   icon: Icon(Icons.arrow_drop_down))
  //                 //             ],
  //                 //           )
  //                 //         ],
  //                 //       ),
  //                 //     )),
  //                 Container(
  //           margin: const EdgeInsets.only(top: 5.0, bottom: 20, left: 25.0),
  //           width: MediaQuery.of(context).size.width,
  //           height: 80,
  //           decoration: customDecoration(),
  //           child: Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 10.0),
  //             child: _buildCodeDropDown(countryList
  //                 .map((info) => {
  //                       'text': info.code,
  //                       'value': info.dialCode,
  //                       'value1': info.name
  //                     })
  //                 .toList()),
  //           ),
  //           // FutureBuilder(
  //           //     future: _countries,
  //           //     builder: (ctx, dataSnapshot) {
  //           //       if (dataSnapshot.connectionState ==
  //           //           ConnectionState.waiting) {
  //           //         return Center(
  //           //             child: CircularProgressIndicator(
  //           //           color: Theme.of(context).primaryColor,
  //           //         ));
  //           //       } else {
  //           //         if (dataSnapshot.error != null) {
  //           //           return Center(child: Text("An error occurred!"));
  //           //         } else {
  //           //           return Consumer<countryProvider.Countries>(
  //           //             builder: (ctx, countryData, child) => Padding(
  //           //               padding:
  //           //                   const EdgeInsets.symmetric(horizontal: 8.0),
  //           //               child: _buildCodeDropDown(countryData.countries
  //           //                   .map((info) => {
  //           //                         'text': info.abbreviation,
  //           //                         'value': info.phoneCode,
  //           //                       })
  //           //                   .toList()),
  //           //             ),
  //           //           );
  //           //         }
  //           //       }
  //           //     }),
  //         )),
  //       ),
  //       Visibility(
  //           visible: _isDropdownVisible,
  //           child: Container(
  //             width: 10,
  //           )),
  //       Visibility(
  //           visible: !_isDropdownVisible,
  //           child: Container(
  //             width: 20,
  //           )),
  //       Expanded(
  //         flex: 2,
  //         child: Container(
  //           margin: const EdgeInsets.only(top: 5.0, bottom: 20, right: 25.0),
  //           decoration: customDecoration(),
  //           child: inputTextField(mobileEmailLabel, phoneController),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  TextEditingController searchController = new TextEditingController();
  List<countryProvider.CountryInfo> tempList = [];

  void openInvestmentList() {
    showModalBottomSheet(
        isDismissible: false,
        enableDrag: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: Scaffold(
                    body: SingleChildScrollView(
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Row(children: [
                                      Text(
                                        "Choose your country",
                                        textAlign: TextAlign.start,
                                        style: textBold16(headingBlack),
                                      ),
                                      Spacer(),
                                      InkWell(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            "Done",
                                            style: textNormal16(headingBlack),
                                          ))
                                    ])),
                                Container(
                                  margin: EdgeInsets.all(10.0),
                                  child: TextField(
                                    controller: searchController,
                                    decoration: new InputDecoration(
                                        hintText: 'Search',
                                        border: InputBorder.none),
                                    onChanged: (text) {
                                      print("SEARCH:- ${text}");
                                    },
                                  ),
                                ),
                                Container(
                                  child: FutureBuilder(
                                      future: _countries,
                                      builder: (ctx, dataSnapshot) {
                                        if (dataSnapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                              child: CircularProgressIndicator(
                                            color:
                                                Theme.of(context).primaryColor,
                                          ));
                                        } else {
                                          if (dataSnapshot.error != null) {
                                            return Center(
                                                child:
                                                    Text("An error occurred!"));
                                          } else {
                                            return Consumer<
                                                countryProvider.Countries>(
                                              builder: (ctx, data, child) =>
                                                  ListView.builder(
                                                itemBuilder: (ctx, index) {
                                                  if (searchController
                                                          .text.isNotEmpty &&
                                                      data.countries[index].name
                                                          .toLowerCase()
                                                          .contains(
                                                              searchController
                                                                  .text
                                                                  .toLowerCase()
                                                                  .toString())) {
                                                    print(
                                                        "search:- ${data.countries[index].name}");
                                                    tempList.add(
                                                        data.countries[index]);
                                                    print(
                                                        "tempList:- ${tempList.length}");
                                                    return Container(
                                                        child: _createItemCell(
                                                            data.countries[
                                                                index]));
                                                  }
                                                  return Container(
                                                      child: _createItemCell(
                                                          data.countries[
                                                              index]));
                                                },
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                itemCount:
                                                    data.countries.length,
                                                shrinkWrap: true,
                                              ),
                                            );
                                          }
                                        }
                                      }),
                                ),
                              ],
                            )))));
          });
        });
  }

  Widget _createItemCell(countryProvider.CountryInfo countri) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: InkWell(
        onTap: () {
          // selectedCountryItem = countri;
          print(countri.phoneCode);
          showTextLabel(false);
          Navigator.pop(context);
        },
        child: Row(
          children: [
            Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    countri.name,
                    style: textNormal18(Colors.black),
                    maxLines: 2,
                  ),
                )),
            Spacer(),
            Text(
              "+${countri.phoneCode}",
              style: textNormal14(Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Container _createCaptcha(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 25.0,
          bottom: 20.0,
          right: 25.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              captchaText,
              style: textNormal16(textGrey),
            ),
            SizedBox(
              height: 20.0,
            ),
            Row(children: [
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.only(right: 10.0),
                  height: 60,
                  decoration: BoxDecoration(
                      color: HexColor('E5E5E5'),
                      borderRadius: BorderRadius.all(
                        const Radius.circular(20.0),
                      )),
                  child: Container(
                    margin:
                        EdgeInsets.only(right: 10.0, left: 10.0, bottom: 5.0),
                    alignment: Alignment.center,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() {}),
                      child: Row(children: [
                        Expanded(
                          child: PSCodeCheckingWidget(
                            lineWidth: 1,
                            maxFontSize: 24,
                            dotMaxSize: 8,
                            lineColorGenerator:
                                SingleColorGenerator(Colors.transparent),
                            textColorGenerator:
                                SingleColorGenerator(Colors.black),
                            dotColorGenerator:
                                SingleColorGenerator(Colors.black),
                            controller: captchaController,
                            codeGenerator: SizedCodeGenerator(size: 6),
                          ),
                        ),
                        Expanded(
                            child: Container(
                                margin: EdgeInsets.only(left: 40, bottom: 20),
                                child: IconButton(
                                    icon: Icon(
                                      Icons.refresh,
                                    ),
                                    iconSize: 30,
                                    highlightColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    color: Theme.of(context).primaryColor,
                                    onPressed: () {
                                      captchaController.refresh();
                                    })))
                      ]),
                    ),
                  ),
                ),
              ),
              Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.only(left: 10.0),
                    width: MediaQuery.of(context).size.width,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        const Radius.circular(20.0),
                      ),
                      shape: BoxShape.rectangle,
                      border: Border.all(
                        color: HexColor('E5E5E5'),
                        width: 2,
                      ),
                    ),
                    child: otpTextField(),
                  ))
            ])
          ],
        ),
      ),
    );
  }

  BoxDecoration customDecoration() {
    return BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.all(const Radius.circular(10.0)),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 2),
            color: Colors.grey[200],
          )
        ]);
  }

  Widget _buildCodeDropDown(List<Map<String, dynamic>> list) {
    return Padding(
        padding: EdgeInsets.only(left: 10.0, right: 5.0),
        child: DropdownSearch<Map<String, dynamic>>(
          mode: Mode.BOTTOM_SHEET,
          showSearchBox: true,
          emptyBuilder: (ctx, search) => Center(
            child: Text('No Data Found',
                style: TextStyle(
                    decoration: TextDecoration.none,
                    fontFamily: FontFamilyMontserrat.bold,
                    fontSize: 26,
                    color: Colors.black)),
          ),
          showSelectedItem: false,
          items: list,
          itemAsString: (Map<String, dynamic> country) =>
              "+${country['value']} ${country['text']} ",
          hint: "",
          selectedItem: selectedCountryItem,
          // label: selectedCountry != "" ? selectedCountry : 91,
          onChanged: (map) {
            setState(() {
              final index = countryList
                  .indexWhere((element) => element.name == map['text']);
              if (index >= 0) {
                selectedCountry = countryList[index];
                print('Using indexWhere: ${countryList[index].maxLength}');
              }
              selectedCountryItem = map;
            });
          },
          dropdownSearchDecoration: InputDecoration(
            border: InputBorder.none,
            labelText: selectedCountryItem == null ? 'Code' : 'Country Code',
            labelStyle: textNormal14(Colors.grey[600]),
            enabledBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.all(const Radius.circular(10.0)),
                borderSide: BorderSide(color: Colors.transparent)),
          ),
          maxHeight: 500,
        ));
  }

  // Widget _buildCodeDropDown() {
  //   return Padding(
  //       padding: EdgeInsets.only(left: 10.0, right: 5.0),
  //       child: DropdownButtonFormField<Countries>(
  //         decoration: InputDecoration(
  //             labelText: 'Country Code',
  //             labelStyle: new TextStyle(color: Colors.grey[600]),
  //             enabledBorder: UnderlineInputBorder(
  //                 borderRadius: BorderRadius.all(const Radius.circular(10.0)),
  //                 borderSide: BorderSide(color: Colors.transparent))),
  //         value: selectedCountry,
  //         onChanged: (Countries countries) {
  //           setState(() {
  //             print("selectedItemValue3 => ${countries.maxLength}");

  //             selectedCountry = countries;
  //           });
  //         },
  //         items: countryList.map((Countries countries) {
  //           return DropdownMenuItem<Countries>(
  //             value: countries,
  //             child: Row(
  //               children: <Widget>[
  //                 Text(
  //                   "+${countries.dialCode}",
  //                   style: TextStyle(color: Colors.black),
  //                 ),
  //               ],
  //             ),
  //           );
  //         }).toList(),
  //       ));
  // }

  TextField otpTextField() {
    return TextField(
      controller: textConroller,
      style: textBlackNormal18(),
      decoration: new InputDecoration(
        contentPadding: EdgeInsets.all(15.0),
        border: InputBorder.none,
        focusedBorder: UnderlineInputBorder(
          borderSide: const BorderSide(color: Colors.transparent, width: 2.0),
          borderRadius: BorderRadius.all(
            const Radius.circular(10.0),
          ),
        ),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
    );
  }

  TextField inputTextField(text, _controller) {
    return TextField(
        onChanged: (text) {
          if (CodeUtils.emailValid(text)) {
            setState(() {
              _isDropdownVisible = false;
            });
          } else if (text == null) {
            setState(() {
              _isDropdownVisible = true;
            });
          } else {
            setState(() {
              _isDropdownVisible = true;
            });
          }
        },
        style: textBlackNormal14(),
        controller: _controller,
        decoration: new InputDecoration(
            contentPadding: EdgeInsets.all(22.0),
            labelText: text,
            labelStyle: textNormal14(Colors.grey[600]),
            border: InputBorder.none,
            focusedBorder: UnderlineInputBorder(
                borderSide:
                    const BorderSide(color: Colors.transparent, width: 2.0),
                borderRadius: BorderRadius.all(
                  const Radius.circular(10.0),
                ))));
  }

  Future<void> sendOTPServer(
      String text, String requesterType, String osType) async {
    String getOtpPlatform = "";
    print("osType => $osType");
    if (osType == "email") {
      getOtpPlatform = text.toString().trim();
    } else {
      // getOtpPlatform = "+${selectedCountry.dialCode}" + text.toString().trim();
      getOtpPlatform = "+${selectedCountryItem['value'].toString()}" +
          text.toString().trim();
    }
    print("number;- $getOtpPlatform");
    VerificationIdSignIn verificationIdSignIn =
        await OtpService.getVerificationFromTwillio(
            getOtpPlatform, osType, requesterType);

    progress.dismiss();
    if (verificationIdSignIn.type == "success") {
      openSignInVerifyOTP(verificationIdSignIn.data.verificationId,
          getOtpPlatform, osType, requesterType);
    } else {
      showSnackBar(context, verificationIdSignIn.message);
    }
  }

  void openSignInVerifyOTP(String verificationId, String phoneNumber,
      String otpType, String requesterType) {
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, anotherAnimation) {
          return SignInVerifyOTP(
            verificationId: verificationId,
            phoneNumber: phoneNumber,
            otpType: otpType,
          );
        },
        transitionDuration: Duration(milliseconds: 2000),
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
}
