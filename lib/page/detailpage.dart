import 'dart:io';
import 'package:flutter/services.dart';

import 'package:demise/model/lesson.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:demise/utilityhelper/globalutility.dart' as globals;
import 'package:cached_network_image/cached_network_image.dart';

class DetailPage extends StatefulWidget {
  final Lesson lesson;
  final Function callback;
  DetailPage({Key key, this.lesson, this.callback}) : super(key: key);
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Directory _downloadsDirectory;
  String _platformVersion = 'Unknown';
  Permission permission;
  String serviceUrl = '';
  bool _loadingInProgress = true;
  bool downloading = false;
  var progressString = "";

  @override
  void initState() {
    // TODO: implement initState
    initDownloadsDirectoryState();
    initPlatformState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final levelIndicator =

    // final coursePrice = Container(
    //   padding: const EdgeInsets.all(7.0),
    //   decoration: new BoxDecoration(
    //       border: new Border.all(color: Colors.white),
    //       borderRadius: BorderRadius.circular(5.0)),
    //   child: new Text(
    //     "ID : " + lesson.price.toString(),
    //     style: TextStyle(color: Colors.white),
    //   ),
    // );

    // final coursePrice =

    // final topContentText =

    // final topContent =

    // final bottomContentText = Text(
    //   lesson.content,
    //   style: TextStyle(fontSize: 18.0),
    // );
    // final readButton = Container(
    //     padding: EdgeInsets.symmetric(vertical: 16.0),
    //     width: MediaQuery.of(context).size.width,
    //     child: RaisedButton(
    //       onPressed: () => {},
    //       color: Color.fromRGBO(58, 66, 86, 1.0),
    //       child:
    //           Text("TAKE THIS LESSON", style: TextStyle(color: Colors.white)),
    //     ));
    // final bottomContent = Container(
    //   width: MediaQuery.of(context).size.width,
    //   padding: EdgeInsets.all(40.0),
    //   child: Center(
    //     child: Column(
    //       children: <Widget>[bottomContentText, readButton],
    //     ),
    //   ),
    // );

    return Scaffold(body: makeBody());
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
      return Column(
        children: <Widget>[
          Expanded(
            child: topContent(),
          ),
        ],
      );
    }
  }

  topContent() {
    return Stack(
      children: <Widget>[
        Container(
          padding:
              EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.4),
          child: CachedNetworkImage(
            imageUrl:
                'http://' + serviceUrl + '/FTPAPI/img/' + widget.lesson.title,
            placeholder: (context, url) =>
                Image.asset('assets/logo/flutter-icon.png'),
            errorWidget: (context, url, error) => new Icon(Icons.error),
            useOldImageOnUrlChange: true,
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.4,
          padding: EdgeInsets.all(40.0),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(color: Color.fromRGBO(58, 66, 86, .9)),
          child: Center(
            child: topContentText(),
          ),
        ),
        Positioned(
          left: 3.0,
          top: 46.0,
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 25.0,
            ),
          ),
        ),
        downloading
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
                          "Downloading File: $progressString",
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
      ],
    );
  }

  topContentText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // SizedBox(height: 15.0),
        Icon(
          Icons.image,
          color: Colors.white,
          size: 25.0,
        ),
        Container(
          width: 90.0,
          child: new Divider(color: Colors.green),
        ),
        SizedBox(height: 10.0),
        Text(
          widget.lesson.title,
          style: TextStyle(color: Colors.white, fontSize: 16.0),
        ),
        // SizedBox(height: 1.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(flex: 2, child: levelIndicator()),
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Text(
                  widget.lesson.level,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Expanded(flex: 2, child: coursePrice())
          ],
        ),
      ],
    );
  }

  levelIndicator() {
    return Container(
      child: Container(
        child: LinearProgressIndicator(
            backgroundColor: Color.fromRGBO(209, 224, 224, 0.2),
            value: widget.lesson.indicatorValue,
            valueColor: AlwaysStoppedAnimation(Colors.green)),
      ),
    );
  }

  coursePrice() {
    return Row(
      children: <Widget>[
        Expanded(
          child: IconButton(
            icon: Icon(
              Icons.cloud_download,
              color: Colors.white,
              size: 25.0,
            ),
            onPressed: () {
              downloadFile();
            },
          ),
        ),
        SizedBox(width: 5.0),
        Expanded(
          child: IconButton(
            icon: Icon(
              Icons.delete_forever,
              color: Colors.white,
              size: 25.0,
            ),
            onPressed: () {
              var args = {
                "TblFileID": widget.lesson.price,
                "Name": widget.lesson.title,
              };
              widget.callback(args);
            },
          ),
        ),
      ],
    );
  }

  void downloadFile1() async {
    // final Directory extDir = await getExternalStorageDirectory();
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${_downloadsDirectory.path}/demise';
    await new Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${widget.lesson.title}';
    final File file = new File(filePath);
    try {
      file.writeAsBytes(widget.lesson.serverImage);
      print(file);
    } catch (e) {
      print(e);
    }
  }

  Future<void> downloadFile() async {
    Dio dio = Dio();
    print(_downloadsDirectory);
    try {
      Directory tempDir = await getTemporaryDirectory();
      Directory dir = await getApplicationDocumentsDirectory();
      // var dir = await getExternalStorageDirectory();
      // final String dirPath = '${_downloadsDirectory.path}/demise';
      final String dirPath = _downloadsDirectory.path
          .replaceAll(new RegExp(r'Download'), 'Demise');
      await new Directory(dirPath).create(recursive: true);
      await dio.download(
          ('http://' + serviceUrl + '/FTPAPI/img/' + widget.lesson.title),
          "$dirPath/" + widget.lesson.title, onReceiveProgress: (rec, total) {
        print("Rec: $rec , Total: $total");

        setState(() {
          downloading = true;
          progressString = ((rec / total) * 100).toStringAsFixed(0) + "%";
        });
      });
    } catch (e) {
      print(e);
    }

    setState(() {
      downloading = false;
      progressString = "Completed";
    });
    print("Download completed");
  }

  Future<void> initDownloadsDirectoryState() async {
    serviceUrl = await globals.Util.getShared('service-url');

    Directory downloadsDirectory;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      downloadsDirectory = await DownloadsPathProvider.downloadsDirectory;
    } on PlatformException {
      print('Could not get the downloads directory');
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _downloadsDirectory = downloadsDirectory;
      _loadingInProgress = false;
    });
  }

  initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await SimplePermissions.platformVersion;
      var ex = await SimplePermissions.requestPermission(
          Permission.WriteExternalStorage);
      var ex1 = await SimplePermissions.requestPermission(
          Permission.ReadExternalStorage);
    } on PlatformException {
      platformVersion = 'Failed to get platform version..';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }
}
