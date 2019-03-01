import 'dart:async';
import 'dart:io';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:demise/utilityhelper/globalutility.dart' as globals;
// import 'package:device_info/device_info.dart';

// import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // final _userName = new TextEditingController();
  StreamSubscription<ConnectivityResult> subscription;
  Connectivity connectivity;
  bool _connectionStatus = false;
  bool _loadingInProgress = false;
// bool isAdmin = false;

  // List<int> arr = [];

  @override
  void initState() {
    // TODO: implement initState
    checkServer();
    connectivity = new Connectivity();
    subscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if ((result == ConnectivityResult.wifi ||
              result == ConnectivityResult.mobile) &&
          !_connectionStatus) {
        _connectionStatus = true;
        pingGoogle();
        // deviceInfo();
        // showToast(result.toString());
      } else {
        print(result);
        _connectionStatus = false;
        showToast(result.toString());
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: _buildBody(),
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
    );
  }

  Widget _buildBody() {
    if (_loadingInProgress) {
      return new Stack(
        children: [
          new Opacity(
            opacity: 0.3,
            child: const ModalBarrier(
                dismissible: false, color: Color(0xFFE0E0E0)),
          ),
          new Center(
            child: new CircularProgressIndicator(
              backgroundColor: Colors.green,
            ),
          ),
        ],
      );
    } else {
      return Center(
        child: Container(
          padding: EdgeInsets.all(25.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 62.0,
                  child: Image.asset('assets/logo/flutter-icon.png'),
                ),
                // ListTile(
                //   leading: const Icon(
                //     Icons.person,
                //     size: 30.0,
                //     color: Colors.white,
                //   ),
                //   title: new TextFormField(
                //     controller: _userName,
                //     style: TextStyle(
                //         color: Colors.white,
                //         fontSize: 16.0,
                //         fontWeight: FontWeight.w500),
                //     decoration: new InputDecoration(
                //       hintText: 'User Name',
                //     ),
                //     keyboardType: TextInputType.text,
                //     onEditingComplete: makeRequest,
                //     validator: (value) {
                //       if (value.isEmpty) {
                //         return 'User Name cannot be blank.';
                //       }
                //     },
                //   ),
                // ),
                // SizedBox(height: 15.0),
                // ListTile(
                //   leading: const Icon(
                //     Icons.lock,
                //     size: 30.0,
                //     color: Colors.white,
                //   ),
                //   title: new TextFormField(
                //     controller: _password,
                //     style: TextStyle(
                //         color: Colors.white,
                //         fontSize: 16.0,
                //         fontWeight: FontWeight.w500),
                //     decoration: new InputDecoration(
                //         hintText: 'Password', fillColor: Colors.white),
                //     keyboardType: TextInputType.text,
                //     obscureText: true,
                //     onEditingComplete: makeRequest,
                //     validator: (value) {
                //       if (value.isEmpty) {
                //         return 'Password cannot be blank.';
                //       }
                //     },
                //   ),
                // ),
                SizedBox(height: 20.0),
                _connectionStatus
                    ? RaisedButton(
                        child: Text('Set API Config'),
                        color: Color.fromRGBO(158, 166, 186, 0.4),
                        textColor: Colors.white,
                        elevation: 7.0,
                        onPressed: () {
                          // FirebaseAuth.instance
                          //     .signInWithEmailAndPassword(
                          //         email: _userName, password: _password)
                          //     .then((FirebaseUser user) {
                          //   Navigator.of(context).pushReplacementNamed('/homepage');
                          // }).catchError((e) {
                          //   print(e);
                          // });
                          callDialog(context);
                        },
                      )
                    : Text(''),
                SizedBox(height: 15.0),
                // FlatButton(
                //   child: Text(
                //     'Don\'t have an account?',
                //     style: TextStyle(
                //       color: Colors.white,
                //     ),
                //   ),
                //   onPressed: () {
                //     connectivity.checkConnectivity().then((res) => print(res));
                //     connectivity.getWifiName().then((res) => print(res));
                //     // checkWifi();
                //   },
                // ),
                // SizedBox(height: 10.0),
                RaisedButton.icon(
                  icon: Icon(
                    FontAwesomeIcons.google,
                    size: 30.0,
                    color: Color(0xFFDD4B39),
                  ),
                  onPressed: () {
                    // chckDwn();
                    showToast('Not Implemented');
                  },
                  color: Color.fromRGBO(158, 166, 186, 0.4),
                  label: Text(
                    'Sing in with Google',
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                RaisedButton.icon(
                  icon: Icon(
                    FontAwesomeIcons.facebookF,
                    size: 30.0,
                    color: Color(0xFF3B5998),
                  ),
                  onPressed: () {
                    // showToast('Not Implemented');
                    pingGoogle();
                    // Navigator.pushReplacementNamed(context, '/homepage');
                  },
                  color: Color.fromRGBO(158, 166, 186, 0.4),
                  label: Text(
                    'Sing in with facebook',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                // RaisedButton(
                //   child: Text('Sign Up'),
                //   color: Colors.blue,
                //   textColor: Colors.white,
                //   elevation: 7.0,
                //   onPressed: () {
                //     Navigator.of(context).pushNamed('/signup');
                //   },
                // ),
                // (arr.length != 0)
                //     ? Image.memory(arr)
                //     : Text(
                //         'Wait..',
                //         style: TextStyle(color: Colors.white),
                //       )
                // Image.network('http://192.168.3.126/FTPAPI/img/Hydrangeas.jpg')
              ],
            ),
          ),
        ),
      );
    }
  }

  Future pingGoogle() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('Internet Connected');
        _connectionStatus = true;
        await checkServiceConnectionAndLogin();
      }
    } on SocketException catch (_) {
      _connectionStatus = false;
      showToast('Internet Not Available');
      setState(() {});
    }
  }

  void callDialog(BuildContext context) async {
    openDialog(
      context,
      // dataSubList['@methodID'],
      await globals.Util.getShared('service-url', false),
      // await globals.Util.getShared('station-list', false),
    );
  }

  void openDialog(BuildContext context, String serviceName) {
    showDialog(
        context: context,
        // barrierDismissible: true,
        builder: (BuildContext context) {
          return new Theme(
            data: Theme.of(context).copyWith(
                dialogBackgroundColor: Color.fromRGBO(158, 166, 186, 0.4)),
            child: SimpleDialog(
              title: new Text(
                "API Config",
                style: TextStyle(color: Colors.white),
              ),
              children: <Widget>[ApiConfing(serviceName)],
            ),
          );
        });
  }

  // void deviceInfo() async {
  //   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //   AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  //   print('Running on ${androidInfo.model}');
  //   print('Running on ${androidInfo.androidId}');
  //   print('Running on ${androidInfo.product}');
  //   if (androidInfo.model == 'SM-G615F' &&
  //       androidInfo.product == 'j7maxlteins') {
  //     isAdmin = true;
  //     setState(() {});
  //   }
  //   // isAdmin = true;
  // }

  void checkServer() async {
    var serviceUrl = await globals.Util.getShared('service-url');

    serviceUrl ?? globals.Util.setShared('service-url', '192.168.0.69'); // per
    // serviceUrl ??
    //     globals.Util.setShared('service-url', '192.168.137.101:6161'); // temp
  }

  Future checkServiceConnectionAndLogin() async {
    var serviceUrl = await globals.Util.getShared('service-url');
    dynamic data;
    var args = {
      "ip": serviceUrl,
    };
    globals.getdata(args, 'FTPAPI/API/CheckServer', serviceUrl).then(
        (response) {
      data = json.decode(response.body)["data"];
      if (data.length > 0) {
        Navigator.pushReplacementNamed(context, '/homepage');
      } else {
        _loadingInProgress = false;
        setState(() {});
        print('Login Failed.Invalid Server. Please verify the address.');
        showToast('Login Failed.Invalid Server. Please verify the address.');
      }
    }, onError: (ex) {
      _loadingInProgress = false;
      setState(() {});
      print('Login Failed.Invalid Server. Please verify the address.');
      showToast('Login Failed.Invalid Server. Please verify the address.');
    }).catchError((ex) {
      _loadingInProgress = false;
      setState(() {});
      print('Login Failed.Invalid Server. Please verify the address.');
      showToast('Login Failed.Invalid Server. Please verify the address.');
    });
  }

  // void chckDwn() {
  //   var args = {
  //     // "URL": "",
  //     // "UserName": "neel",
  //     // "Password": "12345",
  //     // "FileName": "Indrnil_Paul.jpg",
  //     // "FolderName": "",
  //   };

  //   globals.getdata(args, 'FTPAPI/API/GetFiles').then((response) {
  //     print('dffffv d');
  //     print(response.body);
  //     var extractdata = json.decode(response.body)['data'];
  //     // print(extractdata);
  //     afterdata(extractdata);
  //   }, onError: (ex) {
  //     _loadingInProgress = false;
  //     setState(() {});
  //     showToast('Invalid Server. Please verify the address.');
  //   }).catchError((ex) {
  //     _loadingInProgress = false;
  //     setState(() {});
  //     showToast('Invalid Server. Please verify the address.');
  //   });
  // }

  // void afterdata(data) {
  //   // var s=json.decode(data);
  //   print(data[0]['Name']);
  //   print(base64Decode(Uri.decodeComponent(data[0]['Data'])));
  //   arr = base64Decode(Uri.decodeComponent(data[1]['Data']));
  //   setState(() {});
  //   // print(decoded);
  // }
}

class ApiConfing extends StatefulWidget {
  final String _serviceName;
  ApiConfing(this._serviceName);
  @override
  _ApiConfingState createState() => _ApiConfingState();
}

class _ApiConfingState extends State<ApiConfing> {
  final _serviceName = new TextEditingController();
  final _password = new TextEditingController();
  bool isNotShowPass = true;
  bool _loadingInProgress = false;

  @override
  void initState() {
    // TODO: implement initState
    _serviceName.text = widget._serviceName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingInProgress) {
      return new Column(
        children: [
          new Center(
            child: new CircularProgressIndicator(
              backgroundColor: Colors.white,
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: <Widget>[
          new Padding(
            padding: EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 0.0),
            child: new Row(
              children: [
                new Expanded(
                  child: new TextField(
                    onEditingComplete: () {
                      _loadingInProgress = true;
                      setState(() {});
                      checkServiceConnection();
                    },
                    controller: _serviceName,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500),
                    autofocus: false,
                    decoration: InputDecoration(
                        counterStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                        hintText: 'Service Address'),
                  ),
                ),
                // new Container(
                //   margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                //   child: new IconButton(
                //       color: Colors.blueAccent,
                //       icon: Icon(
                //         Icons.network_check,
                //         color: Colors.white,
                //       ),
                //       tooltip: 'Check Service Connection',
                //       onPressed: () {
                //         _loadingInProgress = true;
                //         setState(() {});
                //         checkServiceConnection();
                //       }),
                // ),
              ],
            ),
          ),
          new Padding(
            padding: EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 0.0),
            child: new Row(
              children: [
                new Expanded(
                  child: new TextField(
                    controller: _password,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500),
                    autofocus: true,
                    obscureText: isNotShowPass,
                    decoration: InputDecoration(
                        counterStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                        hintText: 'Password'),
                  ),
                ),
                new Container(
                  margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                  child: new IconButton(
                      color: Colors.blueAccent,
                      icon: Icon(
                        isNotShowPass ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white,
                      ),
                      tooltip: 'Show Password',
                      onPressed: () {
                        isNotShowPass = !isNotShowPass;
                        setState(() {});
                      }),
                ),
              ],
            ),
          ),
          new Container(
            margin: EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 0.0),
            child: new MaterialButton(
                height: 40.0,
                color: Color.fromRGBO(58, 66, 86, 1.0),
                textColor: Colors.white,
                child: new Text("Submit"),
                onPressed: () {
                  if (_password.text == 'Neel10') {
                    _loadingInProgress = true;
                    setState(() {});
                    checkServiceConnection();
                  } else {
                    updateServiceUrl('You are not Admin');
                  }
                }),
          )
        ],
      );
    }
  }

  void checkServiceConnection() async {
    dynamic data;
    var args = {
      "ip": _serviceName.text,
    };

    globals.getdata(args, 'FTPAPI/API/CheckServer', _serviceName.text).then(
        (response) {
      var extractdata = json.decode(response.body)["data"];
      print(extractdata);
      data = extractdata;
      if (data.length > 0) {
        globals.Util.setShared('service-url', _serviceName.text, false);
        updateServiceUrl('Update API Config...');
      } else {
        _loadingInProgress = false;
        setState(() {});
        showToast('Error');
        // revertServiceConnection();
      }
    }, onError: (ex) {
      _loadingInProgress = false;
      setState(() {});
      showToast('Invalid Server. Please verify the address.');
    }).catchError((ex) {
      _loadingInProgress = false;
      setState(() {});
      showToast('Invalid Server. Please verify the address.');
    });
  }

  void updateServiceUrl(msg) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      showToast(msg);
    }
  }
}

showToast(String _msg) {
  Fluttertoast.showToast(
      msg: _msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 3,
      textColor: Colors.white);
}
