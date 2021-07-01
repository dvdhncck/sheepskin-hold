import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//import 'package:path_provider/path_provider.dart';
//import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

//import 'package:filesystem_picker/filesystem_picker.dart';
//import 'package:path_provider_ex/path_provider_ex.dart';

import 'sheepskin.dart';
import 'gui_parts.dart';

class FolderPickingTab extends StatefulWidget {
  final SheepSkin sheepSkin;

  const FolderPickingTab(this.sheepSkin);

  @override
  State<FolderPickingTab> createState() {
    return _FolderPickingTabState();
  }
}

class _FolderPickingTabState extends State<FolderPickingTab> {
  void removePath(String path) {
    setState(() {
      widget.sheepSkin.sheepState.removePath(path);
    });
  }

  Widget build(BuildContext context) {
    var columnWidth = MediaQuery
        .of(context)
        .size
        .width;

    var folders =
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: EdgeInsets.all(4), child: makeLabel('Folders Scanned')),
      Padding(
          padding: EdgeInsets.all(4),
          child: makeValue(widget.sheepSkin.sheepState.paths.length.toString()))
    ]);

    var images = Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Padding(padding: EdgeInsets.all(4), child: makeLabel('Images Found')),
      Padding(
          padding: EdgeInsets.all(4),
          child: makeValue(widget.sheepSkin.getImageCount().toString())),
    ]);

    var countContainer = Padding(
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        child: Row(children: [folders, Spacer(), images]));

    // ---------

    var pathsContainer = widget.sheepSkin.sheepState.paths.length == 0
        ? Spacer()
        : Container(
        child: Column(children: [
          Padding(
              padding: EdgeInsets.all(10.0),
              child: makeHeading('Search where?')),
          Padding(
              padding: EdgeInsets.all(4.0),
              child: makeListGrid(
                  widget.sheepSkin.sheepState.paths,
                  columnWidth,
                      (path) =>
                      setState(() =>
                      {widget.sheepSkin.sheepState.removePath(path)})))
        ]),
        constraints:
        BoxConstraints(maxWidth: columnWidth, minWidth: columnWidth));

    var buttonBar = Row(children: [
      Expanded(
          child: Padding(
              padding: EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () async {
                    try {
                      //var failFn = () => widget.sheepSkin.sheepState.log('Folder fail', 'Whilst picking');
                      //
                      // await FilePicker.platform.getDirectoryPath().then((path) {

                      //List<StorageInfo> storageInfo = await PathProviderEx.getStorageInfo();
                      //var root = storageInfo[0].rootDir; //storageInfo[1] for SD card, geting the root directory

                      //String? root = await PathProviderPlatform.instance.getExternalStoragePath();
                     // Directory? root = await getTemporaryDirectory();
                      Directory? root = Directory('/storage');

                      //var list = await getExternalStorageDirectories();

                      var onSuccess = (path) {
                        // TODO: update image counts here
                        setState(() =>
                            widget.sheepSkin.sheepState.addPath(path));
                      };

                      var onFailure = (error) {
                        setState(() =>
                            widget.sheepSkin.sheepState
                                .log("Add path failed", error.toString()));
                      };

                      await FilePicker.platform.getDirectoryPath().
                      then(onSuccess, onError: onFailure);

                      // await FilesystemPicker.open(
                      //   title: 'Save to folder',
                      //   context: context,
                      //   rootDirectory: root,
                      //   fsType: FilesystemType.folder,
                      //   pickText: 'Pick a folder with images in it',
                      //   folderIconColor: Colors.teal,
                      // ).then(onSuccess, onError: onFailure);

                    } on PlatformException catch (e) {
                      print("Unsupported operation" + e.toString());
                    } catch (ex) {
                      print(ex);
                    }
                  },
                  child: Text('Add another folder')))),
    ]);

    var upper = Expanded(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              countContainer,
              pathsContainer,
            ]));

    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [upper, buttonBar]);
  }
}

class PathLabel extends StatefulWidget {
  final String path;
  final Function onRemove;

  PathLabel(this.path, this.onRemove);

  @override
  State<StatefulWidget> createState() => _PathLabelState();
}

class _PathLabelState extends State<PathLabel> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    //print('build() for ' + widget.path + ' vis=' + _visible.toString());

    return AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.5,
        duration: Duration(seconds: 1),
        onEnd: () {
          widget.onRemove();
        },
        child: Padding(
            padding: EdgeInsets.fromLTRB(5, 2, 5, 2),
            child: Container(
                decoration: makeBorder(Color.fromARGB(200, 240, 240, 240),
                    Color.fromARGB(200, 220, 220, 220)),
                child: Flex(direction: Axis.horizontal, children: [
                  Expanded(
                      child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(widget.path))),
                  IconButton(
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                      tooltip: 'Remove',
                      onPressed: () {
                        setState(() {
                          print('planning to remove ${widget.path}');
                          _visible = false;
                        });
                      })
                ]))));
  }

  BoxDecoration makeBorder(Color fill, Color edges) {
    return BoxDecoration(
      color: fill,
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
      // border: Border(
      //   top: BorderSide(width: 1.0, color: edges),
      //   left: BorderSide(width: 1.0, color: edges),
      //   right: BorderSide(width: 1.0, color: edges),
      //   bottom: BorderSide(width: 1.0, color: edges),
      //),
    );
  }
}
