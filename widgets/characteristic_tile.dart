import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import "../utils/snackbar.dart";

import "descriptor_tile.dart";

class CharacteristicTile extends StatefulWidget {
  final BluetoothCharacteristic characteristic;
  final List<DescriptorTile> descriptorTiles;
  final String descName;

  const CharacteristicTile({Key? key, required this.characteristic, required this.descriptorTiles, required this.descName}) : super(key: key);

  @override
  State<CharacteristicTile> createState() => _CharacteristicTileState();
}

class _CharacteristicTileState extends State<CharacteristicTile> {
  List<int> _value = [0];

  late StreamSubscription<List<int>> _lastValueSubscription;

  @override
  void initState() {
    super.initState();

    widget.characteristic.read();

    var numDescriptores = widget.descriptorTiles.length;
    print("Descriptores: ${numDescriptores}\n");

    for (var value in widget.descriptorTiles) {
      print(value.descriptor.descriptorUuid.toString());
    }

    _lastValueSubscription = widget.characteristic.lastValueStream.listen((value) {
      if (value.isNotEmpty) {
        _value = value;
      }
      setState(() {});
    });

  }

  @override
  void dispose() {
    _lastValueSubscription.cancel();
    super.dispose();
  }

  BluetoothCharacteristic get c => widget.characteristic;

  List<int> _getRandomBytes() {
    final math = Random();
    return [math.nextInt(255), math.nextInt(255), math.nextInt(255), math.nextInt(255)];
  }

  Future onReadPressed() async {
    try {
      await c.read();
      Snackbar.show(ABC.c, "Read: Success", success: true);
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Read Error:", e), success: false);
    }
  }

  Future onWritePressed({int value = 0}) async {
    try {
      await c.write([value], withoutResponse: c.properties.writeWithoutResponse);
      Snackbar.show(ABC.c, "Write: Success", success: true);
      if (c.properties.read) {
        await c.read();
      }
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Write Error:", e), success: false);
    }
  }

  Future onSubscribePressed() async {
    try {
      String op = c.isNotifying == false ? "Subscribe" : "Unubscribe";
      await c.setNotifyValue(c.isNotifying == false);
      Snackbar.show(ABC.c, "$op : Success", success: true);
      if (c.properties.read) {
        await c.read();
      }
      setState(() {});
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Subscribe Error:", e), success: false);
    }
  }

  Widget buildUuid(BuildContext context) {
    String uuid = '0x${widget.characteristic.uuid.toString().toUpperCase()}';
    return Text(uuid, style: TextStyle(fontSize: 13));
  }

  Widget buildValue(BuildContext context) {
    String data = _value.toString();
    return Text(data, style: TextStyle(fontSize: 13, color: Colors.grey));
  }

  Widget buildReadButton(BuildContext context) {
    return TextButton(
        child: Text("Read"),
        onPressed: () async {
          await onReadPressed();
          setState(() {});
        });
  }

  Widget buildWriteButton(BuildContext context) {
    bool withoutResp = widget.characteristic.properties.writeWithoutResponse;
    return TextButton(
        child: Text(withoutResp ? "WriteNoResp" : "Write"),
        onPressed: () async {
          await onWritePressed();
          setState(() {});
        });
  }

  Widget buildSubscribeButton(BuildContext context) {
    bool isNotifying = widget.characteristic.isNotifying;
    return TextButton(
        child: Text(isNotifying ? "Unsubscribe" : "Subscribe"),
        onPressed: () async {
          await onSubscribePressed();
          setState(() {});
        });
  }

  Widget buildButtonRow(BuildContext context) {
    bool read = widget.characteristic.properties.read;
    bool write = widget.characteristic.properties.write;
    bool notify = widget.characteristic.properties.notify;
    bool indicate = widget.characteristic.properties.indicate;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (read) buildReadButton(context),
        if (write) buildWriteButton(context),
        if (notify || indicate) buildSubscribeButton(context),
      ],
    );
  }

  List<Widget> buildTrailing(int type)
  {
    type = widget.characteristic.uuid.toString().contains("00867914")? 1:0;
    if (type == 0) {
      return <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 100,
              child: const TextField(
                decoration: InputDecoration.collapsed(
                  border: OutlineInputBorder(),
                  hintText: 'Enter text',
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                print('Icon pressed');
              },
            ),
          ],
        ),
      ];
    }else{
      return [
        IconButton(
            onPressed: () { onWritePressed(value: 1); },
            //child: const Text('On')
            icon: Icon(
                Icons.play_arrow,
                color: _value[0] == 1? Colors.green : Colors.black

            )
        ),
        IconButton(
            onPressed: () { onWritePressed(value: 0); },
            //child: const Text('Off')
            icon: Icon(
                Icons.stop,
                color: _value[0] == 1? Colors.black : Colors.green
            )
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListTile(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //const Text('Characteristic'),
            //buildUuid(context),
            Text(widget.descName),
            buildValue(context),
          ],
        ),
        //subtitle: buildButtonRow(context),
        contentPadding: const EdgeInsets.all(1.0),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children:
            buildTrailing(0)
        )
      ),
      //children: widget.descriptorTiles,
    );
  }
}
