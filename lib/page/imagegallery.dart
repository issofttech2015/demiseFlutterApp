import 'dart:io';

import 'package:demise/model/lesson.dart';
import 'package:dio/dio.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:flutter/material.dart';
// import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:demise/utilityhelper/globalutility.dart' as globals;
import 'package:flutter/services.dart';

class ViewImage extends StatefulWidget {
  final List<Lesson> lessonList;
  final Function callback;
  final int index;
  ViewImage(this.lessonList, this.callback, this.index);

  @override
  _ViewImageState createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
  Directory _downloadsDirectory;
  Permission permission;
  String serviceUrl = '';
  bool _loadingInProgress = true;
  bool downloading = false;
  var progressString = "";
  int currentIndex = 0;
  @override
  void initState() {
    // TODO: implement initState
    currentIndex = widget.index;
    initDownloadsDirectoryState();
    initPlatformState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // return
    //     // new Scaffold(
    //     //   body:
    //     Container(
    //   // child:
    //   // PhotoViewGallery(
    //   //   pageOptions: listOfImage(context),
    //   //   backgroundDecoration:
    //   //       BoxDecoration(color: Color.fromRGBO(58, 66, 86, .9)),
    //   // ),
    //   child: Text(
    //     'data',
    //     style: TextStyle(color: Colors.white),
    //   ),
    //   // ),
    //   // floatingActionButton: Column(
    //   //   crossAxisAlignment: CrossAxisAlignment.end,
    //   //   mainAxisAlignment: MainAxisAlignment.end,
    //   //   children: <Widget>[
    //   //     FloatingActionButton(
    //   //       onPressed: () {
    //   //         // Navigator.push(
    //   //         //   context,
    //   //         //   MaterialPageRoute(builder: (context) => ViewImage()),
    //   //         // );
    //   //       },
    //   //       tooltip: '',
    //   //       child: new Icon(Icons.image),
    //   //     ),
    //   //     Divider(),
    //   //     FloatingActionButton(
    //   //       onPressed: () {
    //   //         // Navigator.push(
    //   //         //   context,
    //   //         //   MaterialPageRoute(builder: (context) => ViewImage()),
    //   //         // );
    //   //       },
    //   //       tooltip: '',
    //   //       child: new Icon(Icons.image),
    //   //     ),
    //   //   ],
    //   // ),
    // );

    return Scaffold(
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        appBar: topAppBar,
        body: makeBody(),
        floatingActionButton: makeActionButton());
  }

  final topAppBar = AppBar(
    elevation: 0.1,
    backgroundColor:
        Color.fromRGBO(158, 166, 186, 0.4), // Color.fromRGBO(58, 66, 86, 1.0),
    title: Text('Demise'),
    // actions: <Widget>[
    //   IconButton(
    //     icon: Icon(Icons.power_settings_new),
    //     onPressed: () {
    //       Navigator.pushReplacementNamed(context, '/logout');
    //     },
    //   )
    // ],
  );

  List<PhotoViewGalleryPageOptions> listOfImage() {
    List<PhotoViewGalleryPageOptions> listPhotoViewGalleryPageOptions =
        List.generate(
      widget.lessonList.length,
      (int i) => new PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage('http://' +
                serviceUrl +
                '/FTPAPI/img/' +
                widget.lessonList[i].title),
            // maxScale: PhotoViewComputedScale.contained * 0.3,
            // minScale: PhotoViewComputedScale.contained * 0.9,
            heroTag: null,
          ),
    );
    return listPhotoViewGalleryPageOptions;
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
    // String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      // platformVersion = await SimplePermissions.platformVersion;
      await SimplePermissions.requestPermission(
          Permission.WriteExternalStorage);
      await SimplePermissions.requestPermission(Permission.ReadExternalStorage);
    } on PlatformException {
      // platformVersion = 'Failed to get platform version..';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      // _platformVersion = platformVersion;
    });
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
      return Stack(
        children: <Widget>[
          Container(
            child:
                // PhotoView(
                //   imageProvider: NetworkImage('http://' +
                //       serviceUrl +
                //       '/FTPAPI/img/' +
                //       widget.lessonList[0].title),
                // ),
                PhotoViewGallery(
              pageOptions: listOfImage(),
              onPageChanged: (val) => currentIndex = val,
              pageController: PageController(initialPage: widget.index),
              backgroundDecoration:
                  BoxDecoration(color: Color.fromRGBO(58, 66, 86, .9)),
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
  }

  Future<void> downloadFile() async {
    Dio dio = Dio();
    print(_downloadsDirectory);
    try {
      // Directory tempDir = await getTemporaryDirectory();
      // Directory dir = await getApplicationDocumentsDirectory();
      // var dir = await getExternalStorageDirectory();
      // final String dirPath = '${_downloadsDirectory.path}/demise';
      final String dirPath = _downloadsDirectory.path
          .replaceAll(new RegExp(r'Download'), 'Demise');
      await new Directory(dirPath).create(recursive: true);
      await dio.download(
          ('http://' +
              serviceUrl +
              '/FTPAPI/img/' +
              widget.lessonList[currentIndex].title),
          "$dirPath/" + widget.lessonList[currentIndex].title,
          onReceiveProgress: (rec, total) {
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
              downloadFile();
            },
            tooltip: '',
            heroTag: Hero(
              tag: 'cloud_download',
              child: Icon(Icons.cloud_download),
            ),
            child: Icon(Icons.cloud_download),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(0.0, 10.0, .0, 0.0),
          child: FloatingActionButton(
            backgroundColor: Color.fromRGBO(158, 166, 186, 0.5),
            onPressed: () {
              var args = {
                "TblFileID": widget.lessonList[currentIndex].price,
                "Name": widget.lessonList[currentIndex].title,
              };
              widget.callback(args);
            },
            tooltip: '',
            heroTag: Hero(
              tag: 'delete_forever',
              child: Icon(Icons.delete_forever),
            ),
            child: new Icon(Icons.delete_forever),
          ),
        ),
      ],
    );
  }
}
