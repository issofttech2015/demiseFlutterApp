import 'package:demise/model/lesson.dart';
// import 'package:demise/page/detailpage.dart';
import 'package:demise/page/imagegallery.dart';
import 'package:demise/utilityhelper/globalutility.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:demise/utilityhelper/globalutility.dart' as globals;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';

import 'package:path/path.dart' as p;
// import 'package:cached_network_image/cached_network_image.dart';

List<Lesson> lessons = [];

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loadingInProgress = true;
  List contentType = [];
  String _path = '...';
  String _fileName = '...';
  File _file;
  String serviceUrl = '';
  String serviceMode = '';
  String serviceMethod = '/';
  bool uploading = false;
  var progressString = "";
  String imagesView = 'list';
  BuildContext _customContext;
  @override
  void initState() {
    // lessons = getLessons();
    chckDwn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _customContext = context;
    ListTile makeListTile(Lesson _lesson, index) {
      return ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        leading: Container(
          padding: EdgeInsets.only(right: 12.0),
          decoration: new BoxDecoration(
            border: new Border(
              right: new BorderSide(width: 1.0, color: Colors.white24),
            ),
          ),
          // child: Icon(Icons.autorenew, color: Colors.white),
          child: new CircleAvatar(
            radius: 40.0,
            backgroundImage: NetworkImage(
                'http://' + serviceUrl + serviceMethod + _lesson.title),
            // CachedNetworkImage(
            //   imageUrl: 'http://' + serviceUrl + '/FTPAPI/img/' + _lesson.title,
            //   placeholder: (context, url) =>
            //       Image.asset('assets/logo/flutter-icon.png'),
            //   errorWidget: (context, url, error) => new Icon(Icons.error),
            //   useOldImageOnUrlChange: true,
            // ),
            // backgroundColor: Colors.transparent,
          ),
        ),
        title: Text(
          _lesson.title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

        subtitle: Row(
          children: <Widget>[
            Expanded(
                flex: 1,
                child: Container(
                  // tag: 'hero',
                  child: LinearProgressIndicator(
                      backgroundColor: Color.fromRGBO(209, 224, 224, 0.2),
                      value: _lesson.indicatorValue,
                      valueColor: AlwaysStoppedAnimation(Colors.green)),
                )),
            Expanded(
              flex: 4,
              child: Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text(_lesson.level,
                      style: TextStyle(color: Colors.white))),
            )
          ],
        ),
        trailing: Icon(Icons.favorite_border, color: Colors.white, size: 30.0),
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => DetailPage(
          //           lesson: _lesson,
          //           callback: deletedFile,
          //         ),
          //   ),
          // );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewImage(lessons, deletedFile, index),
            ),
          );
        },
      );
    }

    Card makeCard(Lesson lesson, index) {
      return Card(
        elevation: 8.0,
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Container(
          decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
          child: makeListTile(lesson, index),
        ),
      );
    }

    makeBody() {
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
        return Stack(children: <Widget>[
          Container(
            // decoration: BoxDecoration(color: Color.fromRGBO(58, 66, 86, 1.0)),
            child: imagesView == 'list'
                ? ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: lessons.length,
                    itemBuilder: (BuildContext context, int index) {
                      return makeCard(lessons[index], index);
                    },
                  )
                : GridView.builder(
                    itemCount: lessons.length,
                    gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisSpacing: 5.0,
                        crossAxisSpacing: 5.0,
                        childAspectRatio: 1.0,
                        crossAxisCount: 3),
                    itemBuilder: (BuildContext context, int index) {
                      return new GestureDetector(
                        child: GridTile(
                          child: new Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage('http://' +
                                    serviceUrl +
                                    serviceMethod +
                                    lessons[index].title),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          footer: SizedBox(
                            height: 40.0,
                            child: GridTileBar(
                              backgroundColor: Colors.black54,
                              title: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.bottomLeft,
                                child: Text(lessons[index].title),
                              ),
                              subtitle: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  lessons[index].level,
                                  style: TextStyle(fontSize: 11.0),
                                ),
                              ),
                              trailing: Icon(
                                Icons.favorite_border,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          // child: new Container(
                          //   alignment: Alignment.center,
                          //   decoration: BoxDecoration(
                          //     image: DecorationImage(
                          //       image: NetworkImage('http://' +
                          //           serviceUrl +
                          //           serviceMethod +
                          //           lessons[index].title),
                          //       fit: BoxFit.cover,
                          //     ),
                          //   ),
                          // child: Image(
                          //   height: 150.0,
                          //   image: NetworkImage('http://' +
                          //       serviceUrl +
                          //       '/FTPAPI/img/' +
                          //       lessons[index].title),
                          //   fit: BoxFit.cover,
                          // ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ViewImage(lessons, deletedFile, index),
                            ),
                          );
                        },
                      );
                    }),
          ),
          uploading
              ? Center(
                  child: Container(
                    height: 120.0,
                    width: 200.0,
                    child: Card(
                      color: Color.fromRGBO(58, 66, 86, .9),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(),
                          SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            "Uploading File: $progressString",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              : Text(''),
        ]);
      }
    }

    // final makeBottom = Container(
    //   height: 55.0,
    //   child: BottomAppBar(
    //     color: Color.fromRGBO(158, 166, 186, 0.4),
    //     child: Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //       children: <Widget>[
    //         IconButton(
    //           icon: Icon(Icons.home, color: Colors.white),
    //           onPressed: () {
    //             _loadingInProgress = true;
    //             setState(() {});
    //             chckDwn();
    //           },
    //         ),
    //         IconButton(
    //           icon: Icon(Icons.blur_on, color: Colors.white),
    //           onPressed: () {},
    //         ),
    //         IconButton(
    //           icon: Icon(Icons.image, color: Colors.white),
    //           onPressed: () {
    //             _openFileExplorer(FileType.IMAGE);
    //             loadContentType();
    //           },
    //         ),
    //         IconButton(
    //           icon: Icon(Icons.camera, color: Colors.white),
    //           onPressed: () {
    //             _openFileExplorer(FileType.CAPTURE);
    //             loadContentType();
    //           },
    //         )
    //       ],
    //     ),
    //   ),
    // );
    final topAppBar = AppBar(
      elevation: 0.1,
      backgroundColor: Color.fromRGBO(
          158, 166, 186, 0.4), // Color.fromRGBO(58, 66, 86, 1.0),
      title: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(aboutList[0]['value']),
          Text(
            'v' + aboutList[1]['value'],
            style: TextStyle(
              fontSize: 12.0,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            // _activeMeterIndex = 5; // becused menu item is fixed.
            // _scaffoldKey.currentState.openDrawer();
            callDialog(context);
          },
        ),
        IconButton(
          icon: imagesView == 'list'
              ? Icon(Icons.grid_on)
              : Icon(Icons.view_list),
          onPressed: () {
            toggleImgaeView();
          },
        )
      ],
    );

    return Scaffold(
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        appBar: topAppBar,
        body: makeBody(),
        floatingActionButton: makeActionButton()
        // bottomNavigationBar: makeBottom,
        );
  }

  void toggleImgaeView() {
    if (imagesView == 'list') {
      imagesView = 'grid';
    } else {
      imagesView = 'list';
    }
    globals.Util.setShared('image-view', imagesView);
    setState(() {});
  }

  Column makeActionButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(0.0, 0.0, .0, 0.0),
          child: FloatingActionButton(
            backgroundColor: Color.fromRGBO(158, 166, 186, 0.5),
            onPressed: () {
              aboutDialog(context);
            },
            tooltip: 'Aobut',
            child: new Icon(Icons.description),
            heroTag: null,
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0.0, 10.0, .0, 0.0),
          child: FloatingActionButton(
            backgroundColor: Color.fromRGBO(158, 166, 186, 0.5),
            onPressed: () {
              _loadingInProgress = true;
              setState(() {});
              chckDwn();
            },
            tooltip: '',
            child: new Icon(Icons.home),
            heroTag: null,
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0.0, 10.0, .0, 0.0),
          child: FloatingActionButton(
            backgroundColor: Color.fromRGBO(158, 166, 186, 0.5),
            onPressed: () {
              if (serviceMode != 'SERVER') {
                _openFileExplorer(FileType.IMAGE);
                loadContentType();
              }
            },
            tooltip: '',
            child: new Icon(Icons.cloud_upload),
            heroTag: null,
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
          child: FloatingActionButton(
            backgroundColor: Color.fromRGBO(158, 166, 186, 0.5),
            onPressed: () {
              if (serviceMode != 'SERVER') {
                _openFileExplorer(FileType.CAPTURE);
                loadContentType();
              }
            },
            tooltip: '',
            child: new Icon(Icons.camera_alt),
            heroTag: null,
          ),
        )
      ],
    );
  }

  void chckDwn() async {
    serviceMode = await globals.Util.getShared('service-mode');
    serviceUrl = await globals.Util.getShared('service-url');
    imagesView = await globals.Util.getShared('image-view');
    getMethod();
    if (serviceMode == 'SERVER') {
      var count = 0;
      lessons = [];
      while (count++ < 21) {
        lessons.add(Lesson(
            title: (600 + count).toString(),
            level: 'jpge',
            indicatorValue: 0.33,
            price: count,
            serverImage: [],
            content:
                "Start by taking a couple of minutes to read the info in this section. Launch your app and click on the Settings menu.  While on the settings page, click the Save button.  You should see a circular progress indicator display in the middle of the page and the user interface elements cannot be clicked due to the modal barrier that is constructed."));
      }
      _loadingInProgress = false;
      setState(() {});
    } else {
      var args = {};
      globals.getdata(args, 'FTPAPI/API/GetFiles').then((response) {
        afterGetServerData(json.decode(response.body)['data']);
      }, onError: (ex) {
        setState(() {});
        print('Invalid Server. Please verify the address.');
      }).catchError((ex) {
        setState(() {});
        print('Invalid Server. Please verify the address..');
      });
    }
  }

  afterGetServerData(List extractdata) {
    lessons = [];
    extractdata.forEach((f) {
      lessons.add(Lesson(
          title: f['Name'],
          level: f['ContentType'],
          indicatorValue: 0.33,
          price: f['TblFileID'],
          serverImage: [],
          content:
              "Start by taking a couple of minutes to read the info in this section. Launch your app and click on the Settings menu.  While on the settings page, click the Save button.  You should see a circular progress indicator display in the middle of the page and the user interface elements cannot be clicked due to the modal barrier that is constructed."));
    });
    _loadingInProgress = false;
    setState(() {});
  }

  void _openFileExplorer(FileType _pickingType) async {
    var data;
    try {
      _path = await FilePicker.getFilePath(type: _pickingType);
      _file = new File(_path);
      List<int> contents = await _file.readAsBytes();

      // data = Uri.encodeComponent(base64Encode(contents));
      data = contents;
    } on PlatformException catch (e) {
      print(e.toString());
    }

    if (!mounted) return;

    setState(() {
      _fileName = _path == null ? init : _path.split('/').last;
    });
    if (_file.existsSync()) {
      print(contentType
          .where((f) => f['extension'] == p.extension(_path))
          .toList()[0]['value']);
      var args = {
        "TblFileID": 0,
        "Name": _fileName,
        "ContentType": contentType
            .where((f) => f['extension'] == p.extension(_path))
            .toList()[0]['value'],
        "Data": data
      };
      // uploadFile(args);
      uploadFileByDio(args);
    }
  }

  void init() {
    _fileName = '...';
    _path = '...';
  }

  void loadContentType() async {
    if (contentType.length == 0) {
      String jsonContentType =
          await rootBundle.loadString('assets/contentType/contentType1.json');
      contentType = json.decode(jsonContentType);
    }
  }

  // void uploadFile(args) {
  //   globals.getdata(args, 'FTPAPI/API/UploadFiles').then((response) {
  //     afterGetServerData(json.decode(response.body)['data']);
  //   }, onError: (ex) {
  //     setState(() {});
  //     print('Invalid Server. Please verify the address.');
  //   }).catchError((ex) {
  //     setState(() {});
  //     print('Invalid Server. Please verify the address.');
  //   });
  // }

  void uploadFileByDio(args) async {
    Dio dio = Dio();
    try {
      await dio.post('http://' + serviceUrl + '/FTPAPI/API/UploadFiles',
          data: jsonEncode(args),
          options: Options(
            contentType: ContentType("application", "json", charset: "utf-8"),
            method: 'POST',
          ), onSendProgress: (rec, total) {
        print("SRec: $rec , STotal: $total");
        setState(() {
          uploading = true;
          progressString = ((rec / total) * 100).toStringAsFixed(0) + "%";
        });
      }, onReceiveProgress: (rec, total) {
        print("Rec: $rec , Total: $total");
        setState(() {
          uploading = true;
          progressString = ((rec / total) * 100).toStringAsFixed(0) + "%";
        });
      }).then((response) {
        afterGetServerData(response.data['data']);
      });
    } catch (e) {
      print(e);
    }
    setState(() {
      progressString = "Completed";
      uploading = false;
    });
    print("Upload completed");
  }

  void deletedFile(args) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      _loadingInProgress = true;
    }
    globals.getdata(args, 'FTPAPI/API/DeletedFiles').then((response) {
      afterGetServerData(json.decode(response.body)['data']);
      _loadingInProgress = false;
      setState(() {});
    }, onError: (ex) {
      setState(() {});
      print('Invalid Server. Please verify the address.');
    }).catchError((ex) {
      setState(() {});
      print('Invalid Server. Please verify the address.');
    });
  }

  void getMethod() {
    serviceMethod = serviceMode == "SERVER" ? '/' : '/FTPAPI/img/';
  }

  void callDialog(BuildContext context) async {
    openDialog(
        context,
        // dataSubList['@methodID'],
        await globals.Util.getShared('service-url'),
        customLogout);
  }

  void customLogout() {
    Navigator.pushNamedAndRemoveUntil(
        context, '/logout', ModalRoute.withName('/logout'));
  }
}

// List getLessons() {
//   return [
//     Lesson(
//         title: "Introduction to Driving",
//         level: "Beginner",
//         indicatorValue: 0.33,
//         price: 20,
//         content:
//             "Start by taking a couple of minutes to read the info in this section. Launch your app and click on the Settings menu.  While on the settings page, click the Save button.  You should see a circular progress indicator display in the middle of the page and the user interface elements cannot be clicked due to the modal barrier that is constructed."),
//     Lesson(
//         title: "Observation at Junctions",
//         level: "Beginner",
//         indicatorValue: 0.33,
//         price: 50,
//         content:
//             "Start by taking a couple of minutes to read the info in this section. Launch your app and click on the Settings menu.  While on the settings page, click the Save button.  You should see a circular progress indicator display in the middle of the page and the user interface elements cannot be clicked due to the modal barrier that is constructed."),
//     Lesson(
//         title: "Reverse parallel Parking",
//         level: "Intermidiate",
//         indicatorValue: 0.66,
//         price: 30,
//         content:
//             "Start by taking a couple of minutes to read the info in this section. Launch your app and click on the Settings menu.  While on the settings page, click the Save button.  You should see a circular progress indicator display in the middle of the page and the user interface elements cannot be clicked due to the modal barrier that is constructed."),
//     Lesson(
//         title: "Reversing around the corner",
//         level: "Intermidiate",
//         indicatorValue: 0.66,
//         price: 30,
//         content:
//             "Start by taking a couple of minutes to read the info in this section. Launch your app and click on the Settings menu.  While on the settings page, click the Save button.  You should see a circular progress indicator display in the middle of the page and the user interface elements cannot be clicked due to the modal barrier that is constructed."),
//     Lesson(
//         title: "Incorrect Use of Signal",
//         level: "Advanced",
//         indicatorValue: 1.0,
//         price: 50,
//         content:
//             "Start by taking a couple of minutes to read the info in this section. Launch your app and click on the Settings menu.  While on the settings page, click the Save button.  You should see a circular progress indicator display in the middle of the page and the user interface elements cannot be clicked due to the modal barrier that is constructed."),
//     Lesson(
//         title: "Engine Challenges",
//         level: "Advanced",
//         indicatorValue: 1.0,
//         price: 50,
//         content:
//             "Start by taking a couple of minutes to read the info in this section. Launch your app and click on the Settings menu.  While on the settings page, click the Save button.  You should see a circular progress indicator display in the middle of the page and the user interface elements cannot be clicked due to the modal barrier that is constructed."),
//     Lesson(
//         title: "Self Driving Car",
//         level: "Advanced",
//         indicatorValue: 1.0,
//         price: 50,
//         content:
//             "Start by taking a couple of minutes to read the info in this section. Launch your app and click on the Settings menu.  While on the settings page, click the Save button.  You should see a circular progress indicator display in the middle of the page and the user interface elements cannot be clicked due to the modal barrier that is constructed.  ")
//   ];
// }
