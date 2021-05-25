// @dart=2.9

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'sheepskin.dart';

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
      widget.sheepSkin.removePath(path);
    });
  }

  @override
  Widget build(BuildContext context) {
    var imageInformationLabel = Row(children: [
      Expanded(
          child: Center(
              child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(widget.sheepSkin.imagesLabelText)))),
    ]);

    var pathRows = <Widget>[];
    if (widget.sheepSkin.getPaths() != null &&
        widget.sheepSkin.getPaths().length > 0) {
      for (final String path in widget.sheepSkin.getPaths()) {
        pathRows.add(PathLabel(
            path,
            () => {
                  setState(() {
                    print('repaint from $path');
                    widget.sheepSkin.removePath(path);
                  })
                }));
      }
    }

    var upper = Column(children: [
      imageInformationLabel,
      ListView(
        shrinkWrap: true,
        children: pathRows,
      )
    ]);

    var buttonBar = Row(children: [
      Expanded(
          child: Padding(
              padding: EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () async {
                    try {
                      String path =
                          await FilePicker.platform.getDirectoryPath();
                      widget.sheepSkin.addPath(path);
                    } on PlatformException catch (e) {
                      print("Unsupported operation" + e.toString());
                    } catch (ex) {
                      print(ex);
                    }
                  },
                  child: Text('Add image folder')))),
    ]);

    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
