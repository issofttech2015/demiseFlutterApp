import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:async' show Future;
import "dart:convert";
import 'package:url_launcher/url_launcher.dart';

Future<dynamic> getdata(dynamic args, String callingMethod,
    [String serviceConnection = '']) async {
//String url = 'http://chisel.cloudjiffy.net/contacts/short';
  final body = jsonEncode(args);
  Future<dynamic> result;
  serviceConnection = serviceConnection == ''
      ? await Util.getShared('service-url')
      : serviceConnection;
  String url = 'http://' + serviceConnection + '/' + callingMethod;
  result = http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: body,
  );
  return (result);
}

void alertdialog(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return new Theme(
        data: Theme.of(context).copyWith(
            dialogBackgroundColor: Color.fromRGBO(158, 166, 186, 0.4)),
        child: AlertDialog(
          title: Text(''),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  message,
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            IconButton(
              iconSize: 40.0,
              icon: Icon(
                Icons.check_circle,
                color: Colors.white,
              ),
              color: Color.fromRGBO(58, 66, 86, 1.0),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}

class Util {
  static Future<SharedPreferences> getSharedPreferences() async {
    return SharedPreferences.getInstance();
  }

  static void setShared(String key, dynamic value,
      [bool isList = false]) async {
    SharedPreferences shared;
    shared = await getSharedPreferences();
    if (isList) {
      shared.setStringList(key, value);
    } else {
      shared.setString(key, value);
    }
  }

  static dynamic getShared(String key, [bool isList = false]) async {
    SharedPreferences shared;
    shared = await getSharedPreferences();
    if (isList) {
      return shared.getStringList(key) ?? null; //
    } else {
      return shared.getString(key) ?? null; //
    }
  }
}

void openDialog(BuildContext _context, String serviceName, Function callBack) {
  showDialog(
      context: _context,
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
            children: <Widget>[ApiConfing(serviceName, _context, callBack)],
          ),
        );
      });
}

List aboutList = [
  {
    'key': 'Name',
    'separeter': ':',
    'value': 'Demise',
    'textColorIsBlue': false,
    'isLink': false
  },
  {
    'key': 'Release',
    'separeter': ':',
    'value': '1.0.1.6',
    'textColorIsBlue': false,
    'isLink': false
  },
  // {
  //   'key': 'Base',
  //   'separeter': ':',
  //   'value': 'FusionERP™ 8',
  //   'textColorIsBlue': false
  // },
  // {
  //   'key': 'Release',
  //   'separeter': ':',
  //   'value': '2.835',
  //   'textColorIsBlue': false
  // },
  // {'key': '', 'separeter': '', 'value': '', 'textColorIsBlue': false},
  {
    'key': 'Support',
    'separeter': ':',
    'value': 'support@issofttech.com',
    'textColorIsBlue': true,
    'isLink': false
  },
  {
    'key': 'Website',
    'separeter': ':',
    'value': 'www.issofttech.com',
    'textColorIsBlue': true,
    'isLink': true
  }
];

void aboutDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true, // user must tap button!
    builder: (BuildContext context) {
      return new Theme(
        data: Theme.of(context).copyWith(
            dialogBackgroundColor: Color.fromRGBO(158, 166, 186, 0.4)),
        child: AlertDialog(
          title: Text(
            'About',
            style: TextStyle(color: Colors.white),
          ),
          content: new SizedBox(
            height: 100.0,
            width: 100.0,
            child: ListView.builder(
              itemCount: aboutList == null ? 0 : aboutList.length,
              itemBuilder: (BuildContext context, int i) {
                return Row(children: <Widget>[
                  new Expanded(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            aboutList[i]['key'],
                            style:
                                TextStyle(fontSize: 13.0, color: Colors.white),
                          ),
                          flex: 5,
                        ),
                        Expanded(
                          child: Text(
                            aboutList[i]['separeter'],
                            style:
                                TextStyle(fontSize: 13.0, color: Colors.white),
                          ),
                          flex: 1,
                        ),
                      ],
                    ),
                    flex: 2,
                  ),
                  new Expanded(
                    child: GestureDetector(
                      onTap: aboutList[i]['isLink']
                          ? () {
                              launchURL(aboutList[i]['value']);
                            }
                          : null,
                      child: Text(
                        aboutList[i]['value'],
                        style: TextStyle(
                            fontSize: 13.0,
                            color: aboutList[i]['textColorIsBlue'] == false
                                ? Colors.white
                                : Colors.blue),
                      ),
                    ),
                    flex: 5,
                  ),
                ]);
              },
            ),
          ),
        ),
      );
    },
  );
}

void launchURL(String url) async {
  url = 'https://' + url;
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

class ApiConfing extends StatefulWidget {
  final String _serviceName;
  final BuildContext _contextP;
  final _callBack;
  ApiConfing(this._serviceName, this._contextP, this._callBack);
  @override
  _ApiConfingState createState() => _ApiConfingState();
}

class _ApiConfingState extends State<ApiConfing> {
  final _serviceName = new TextEditingController();
  final _password = new TextEditingController();

  bool isNotShowPass = true;
  bool _loadingInProgress = false;
  String serviceMode = '';

  @override
  void initState() {
    // TODO: implement initState
    init();
    _serviceName.text = widget._serviceName;
    super.initState();
  }

  void init() async {
    serviceMode = await Util.getShared('service-mode');
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
                    enabled: serviceMode != 'SERVER',
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
                new Container(
                  margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                  child: new IconButton(
                      color: Colors.blueAccent,
                      icon: Icon(
                        serviceMode == 'SERVER' ? Icons.cloud : Icons.cloud_off,
                        color: Colors.white,
                      ),
                      tooltip: 'Change Service Mode',
                      onPressed: () {
                        changeMode();
                        setState(() {});
                      }),
                ),
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
            child: new IconButton(
                icon: Icon(
                  Icons.check_circle,
                  color: Colors.white,
                ),
                iconSize: 40.0,
                color: Color.fromRGBO(58, 66, 86, 1.0),
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
    if (serviceMode == 'SERVER') {
      updateData();
    } else {
      dynamic data;
      var args = {
        "ip": _serviceName.text,
      };

      getdata(args, 'FTPAPI/API/CheckServer', _serviceName.text).then(
          (response) {
        var extractdata = json.decode(response.body)["data"];
        print(extractdata);
        data = extractdata;
        if (data.length > 0) {
          updateData();
        } else {
          _loadingInProgress = false;
          setState(() {});
          alertdialog(context, 'Error.');
          // showToast('Error');
          // revertServiceConnection();
        }
      }, onError: (ex) {
        _loadingInProgress = false;
        setState(() {});
        alertdialog(context, 'Invalid Server. Please verify the address.');
        // showToast('Invalid Server. Please verify the address.');
      }).catchError((ex) {
        _loadingInProgress = false;
        setState(() {});
        alertdialog(context, 'Invalid Server. Please verify the address.');
        // showToast('Invalid Server. Please verify the address.');
      });
    }
  }

  void updateData() {
    Util.setShared('service-url', _serviceName.text);
    Util.setShared('service-mode', serviceMode);
    updateServiceUrl('Update API Config...', isLogout: true);
  }

  void updateServiceUrl(msg, {bool isLogout = false}) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      alertdialog(widget._contextP, msg);
      if (isLogout) widget._callBack();
    }
  }

  void changeMode() {
    if (serviceMode == 'SERVER') {
      serviceMode = 'LOCAL_SERVER';
      _serviceName.text = '192.168.0.69';
    } else {
      serviceMode = 'SERVER';
      _serviceName.text = 'i.pravatar.cc';
    }
  }
}
