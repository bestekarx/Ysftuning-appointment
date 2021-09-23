// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_mask/easy_mask.dart';
import 'package:dio/dio.dart';
import 'services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_launch/flutter_launch.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.black87),
          hintStyle: TextStyle(color: Colors.black87),
        ),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

Color buttonColor = Color(0X333333);

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

void urlOpen() async {
  const url = "https://www.ysftuning.com";
  if (await canLaunch(url))
    await launch(url);
  else
    // can't launch url, there is some error
    throw "Could not launch $url";
}

void whatsAppOpen() async {
  await FlutterLaunch.launchWhatsapp(phone: "+905537667909", message: "selam");
}

void instagramOpen() async {
  const url = "https://www.instagram.com/ysf.tuning/";
  if (await canLaunch(url))
    await launch(url);
  else
    // can't launch url, there is some error
    throw "Could not launch $url";
}

class _MyHomePageState extends State<MyHomePage> {
  var data;
  List<Services> serviceList = [];

  String nowDate = DateFormat("yyyy/MM/dd HH:mm").format(DateTime.now());

  TextEditingController name = new TextEditingController();
  TextEditingController phone = new TextEditingController();
  Services? dropdownValue;

  final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
    primary: HexColor("#333333"),
    onPrimary: HexColor("#333333"),
    textStyle: TextStyle(color: Colors.white),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(5)),
    ),
  );

  var alertStyle = AlertStyle(
    animationType: AnimationType.fromBottom,
    isCloseButton: true,
    isOverlayTapDismiss: false,
    descStyle: GoogleFonts.khand(fontWeight: FontWeight.w300),
    descTextAlign: TextAlign.start,
    animationDuration: Duration(milliseconds: 300),
    titleStyle: GoogleFonts.khand(fontWeight: FontWeight.bold),
    alertAlignment: Alignment.center,
  );

  bool isNullOrEmpty(Object val) => val == null || val == '';

  void setAppoiment() async {
    int? servicesId = this.dropdownValue?.id;
    var date = this.nowDate;

    if ((name.text == null || name.text == "") ||
        (phone.text == null || phone.text == "")) {
      Alert(
        context: context,
        type: AlertType.warning,
        style: alertStyle,
        desc: "Lütfen tüm alanları doldurun.",
        buttons: [
          DialogButton(
            child: Text("Tamam",
                style: GoogleFonts.khand(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            onPressed: () => Navigator.pop(context),
            color: Color.fromRGBO(0, 179, 134, 1.0),
          )
        ],
      ).show();

      return;
    }
    try {
      var a = {
        "apiUserName": 'admin',
        "apiUserPassword": 'admin',
        'name_surname': name.text,
        'phone': phone.text,
        'date': date,
        'ref_service': servicesId
      };

      var response = await Dio().post(
          'https://randevu.ysftuning.com/api/addAppointment',
          data: FormData.fromMap(a));

      data = response.data;

      Alert(
        context: context,
        type: AlertType.success,
        style: alertStyle,
        title: "Tebrikler..",
        desc:
            "Randevunuz işleme alınmıştır. En kısa sürede ilettiğiniz telefon numarası ile iletişime geçilecektir.",
        buttons: [
          DialogButton(
            child: Text("Tamam",
                style: GoogleFonts.khand(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            onPressed: () => Navigator.pop(context),
            color: Color.fromRGBO(0, 179, 134, 1.0),
          )
        ],
      ).show();

      setState(() {
        name.text = "";
        phone.text = "";
      });
      return;
    } catch (e) {
      print(e);
    }
  }

  void getHttp() async {
    try {
      var a = {"apiUserName": 'admin', "apiUserPassword": 'admin'};
      var response = await Dio().post(
          'https://randevu.ysftuning.com/api/getServices',
          data: FormData.fromMap(a));

      data = response.data;
      var test = jsonDecode(data).cast<Map<String, dynamic>>();

      setState(() {
        serviceList =
            test.map<Services>((data) => Services.fromJson(data)).toList();
        dropdownValue = serviceList[0];
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getHttp();
  }

  //sayfa
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        Container(
          // background image
          decoration: const BoxDecoration(
            // ignore: unnecessary_const
            image: const DecorationImage(
              image: AssetImage("bg.png"),
              fit: BoxFit.fill,
            ),
          ),
        ),
        Container(
            margin: const EdgeInsets.only(top: 50),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Image.asset('logo.png'),
                  ],
                ),
                Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(
                      top: 25, right: 25, left: 25, bottom: 25),
                  child: Column(
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 20),
                            child: TextField(
                              controller: name,
                              keyboardType: TextInputType.text,
                              style: GoogleFonts.khand(
                                  fontWeight: FontWeight.bold),
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                hintText: 'ad soyad',
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 20),
                            child: TextField(
                              controller: phone,
                              keyboardType: TextInputType.text,
                              style: GoogleFonts.khand(
                                  fontWeight: FontWeight.bold),
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                hintText: 'telefon',
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                              ),
                              inputFormatters: [
                                TextInputMask(
                                    mask: '\\ (999) 999 9999', reverse: false)
                              ],
                            ),
                          )
                        ],
                      ),
                      Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 20),
                          child: DropdownButton(
                            iconSize: 0.0,
                            icon: Icon(null),
                            isExpanded: true,
                            value: dropdownValue,
                            style: GoogleFonts.khand(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            items: serviceList.map((Services map) {
                              return new DropdownMenuItem<Services>(
                                value: map,
                                child: new Text(map.services_name ?? ""),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                dropdownValue = value as Services;
                              });
                            },
                          )),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 20, right: 20, top: 20),
                        child: TextFormField(
                          enableInteractiveSelection:
                              false, // will disable paste operation
                          focusNode: FocusNode(),
                          readOnly: true,
                          onTap: () {
                            DatePicker.showDateTimePicker(context,
                                showTitleActions: true,
                                minTime: DateTime.now(),
                                maxTime: DateTime(2030, 1, 1),
                                onChanged: (date) {
                              nowDate = DateFormat("yyyy-MM-dd HH:mm:ss")
                                  .format(date);
                            }, onConfirm: (date) {
                              setState(() {
                                print('confirm $date');
                                nowDate = DateFormat("yyyy-MM-dd HH:mm:ss")
                                    .format(date);
                              });
                            },
                                currentTime: DateTime.now(),
                                locale: LocaleType.tr);
                          },
                          keyboardType: TextInputType.text,
                          style: GoogleFonts.khand(fontWeight: FontWeight.bold),
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            labelText: '$nowDate',
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                              padding: EdgeInsets.only(
                                  right: 20, bottom: 10, top: 20),
                              child: ElevatedButton(
                                style: raisedButtonStyle,
                                onPressed: () {
                                  setAppoiment();
                                },
                                child: Text(
                                  'randevu al',
                                  style: GoogleFonts.khand(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ))),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 20, bottom: 10),
                            child: GestureDetector(
                              onTap: () {
                                whatsAppOpen();
                              }, // handle your image tap here
                              child: Image.asset(
                                'ig.png',
                                fit: BoxFit
                                    .cover, // this is the solution for border
                              ),
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: GestureDetector(
                                onTap: () {
                                  urlOpen();
                                }, // handle your image tap here
                                child: Text(
                                  'www.ysftuning.com',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.khand(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 20, bottom: 10),
                            child: GestureDetector(
                              onTap: () {
                                whatsAppOpen();
                              }, // handle your image tap here
                              child: Image.asset(
                                'wp.png',
                                fit: BoxFit
                                    .cover, // this is the solution for border
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            )),
      ],
    ));
  }
}
