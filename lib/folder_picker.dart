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
  @override
  Widget build(BuildContext context) {
    print("_FolderPickingTabState.build()");

    var imageInformationLabel = Row(children: [
      Expanded(
          child: Center(
              child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(widget.sheepSkin.imageCount)))),
    ]);

    var pathRows = <Widget>[];
    // TODO: get immutable copy of paths
    if(widget.sheepSkin.getPaths() != null && widget.sheepSkin.getPaths().length > 0) {
      for (final String path in widget.sheepSkin.getPaths()) {
        //rows.add(getLabel(path, (p) => sheepSkin.removePath(p)));
        pathRows.add(Flex(direction: Axis.horizontal, children: [
          Expanded(
              child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Container(
                      decoration: BoxDecoration(color: Colors.grey),
                      padding: EdgeInsets.all(8.0),
                      child: Text(path)))),
          IconButton(
              icon: const Icon(Icons.remove_circle_outline_rounded),
              tooltip: 'Remove',
              onPressed: () {
                setState(() {
                  widget.sheepSkin.removePath(path);
                });
              })
        ]));
      }
    }

    var upper = Column(children:[imageInformationLabel, ListView(shrinkWrap:true, children: pathRows,)]);

    var buttonBar = Row(children: [
      Expanded(
          child: Padding(
              padding: EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () async {
                      try {
                        String path = await FilePicker.platform.getDirectoryPath();
                        widget.sheepSkin.addPath(path);
                      } on PlatformException catch (e) {
                        print("Unsupported operation" + e.toString());
                      } catch (ex) {
                        print(ex);
                      }
                  },
                  child: Text('Add image folder')))),
    ]);

    return Column(mainAxisAlignment:MainAxisAlignment.spaceBetween,children: [upper, buttonBar]);
  }
}


/*
class PathLabel extends StatefulWidget {
  final String path;
  final _FolderPickingTabState optionsWidgetState;

  PathLabel(this.optionsWidgetState, this.path) {
    print('make PathLabel for ' + path);
  }

  void removePath() {
    sheepSkin.removePath(path);
  }

  @override
  State<StatefulWidget> createState() => _PathLabelState();
}

class _PathLabelState extends State<PathLabel> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    print('build() for ' + widget.path + ' vis=' + _visible.toString());

    return AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.5,
        duration: Duration(seconds: 1),
        onEnd: () {
          print('fade ended for ' + widget.path);
          widget.removePath();
        },
        child: Flex(direction: Axis.horizontal, children: [
          Expanded(
              child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Container(
                      decoration: BoxDecoration(color: Colors.grey),
                      padding: EdgeInsets.all(8.0),
                      child: Text(widget.path)))),
          IconButton(
              icon: const Icon(Icons.remove_circle_outline_rounded),
              tooltip: 'Remove',
              onPressed: () {
                setState(() {
                  _visible = false;
                });
              })
        ]));
  }
}
*/
