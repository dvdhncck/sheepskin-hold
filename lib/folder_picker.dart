// @dart=2.9

import 'package:flutter/material.dart';

import 'sheepskin.dart';

class FolderPickingTab extends StatefulWidget {
  final SheepSkin sheepSkin;

  const FolderPickingTab(this.sheepSkin);

  @override
  State<FolderPickingTab> createState() {
    return _FolderPickingTabState(sheepSkin);
    // sheepSkin.folderPickingWidgetState = _FolderPickingTabState(sheepSkin);
    // return sheepSkin.folderPickingWidgetState;
  }
}

class _FolderPickingTabState extends State<FolderPickingTab> {
  final SheepSkin sheepSkin;

  _FolderPickingTabState(this.sheepSkin);

  @override
  Widget build(BuildContext context) {
    print("build() starts.");

    var imageInformationLabel = Row(children: [
      Expanded(
          child: Center(
              child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(sheepSkin.imageCount)))),
    ]);

    var pathRows = <Widget>[];
    for (final String path in sheepSkin.paths) {
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
                sheepSkin.removePath(path);
              });
            })
      ]));
    }

    var upper = Column(children:[imageInformationLabel, ListView(shrinkWrap:true, children: pathRows,)]);

    var buttonBar = Row(children: [
      Expanded(
          child: Padding(
              padding: EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    sheepSkin.displayFilePickerForFolderSelection();
                  },
                  child: Text('Add image folder')))),
    ]);

    return Column(mainAxisAlignment:MainAxisAlignment.spaceBetween,children: [upper, buttonBar]);
  }
}
