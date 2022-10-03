import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/route_manager.dart';

import 'package:syncfusion_flutter_charts/charts.dart';

class BluetoothPage extends StatefulWidget {
  final BluetoothDevice server;

  const BluetoothPage({this.server});

  @override
  _BluetoothPage createState() => _BluetoothPage();
}

class _BluetoothPage extends State<BluetoothPage> {
  // LocalNotificationService service; // 이게 왜 들어가있는거야?

  static const clientID = 0;
  BluetoothConnection connection;

  String _messageBuffer = '';
  String dataString = '';

  bool isConnecting = true;

  bool get isConnected => connection != null && connection.isConnected;
  bool isDisconnecting = false;
  TextEditingController _messageEditingController = TextEditingController();
  @override
  void initState() {
    super.initState();


    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });


      connection.input.listen(_onDataReceived).onDone(() {
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }
    _messageEditingController.dispose();
    super.dispose();

  }

  final double _value = 90.0;

  @override
  Widget build(BuildContext context) {


    return Scaffold(
        body: Column(
          children: [
            Expanded(child: Container(child:Center(child: Text(dataString)),color: Colors.lightGreen,)),
            SizedBox(
              height: 100,
              width: Get.width,
              child: Row(
                children: [
                  Expanded(child: TextField(controller: _messageEditingController,)),
                  TextButton(onPressed: (){
                    connection.output.add(utf8.encode(_messageEditingController.text) as Uint8List);
                  }, child: Text('Send'))
                ],
              ),
            )
          ],
        )        // Container(
        );
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    for (var byte in data) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    }
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }
    // Create message if there is new line character
    dataString = String.fromCharCodes(buffer);


    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        _messageBuffer = dataString.substring(index);
      });
    } else {
      // _messageBuffer = (backspacesCounter > 0
      //     ? int.parse(_messageBuffer.substring(
      //         0, _messageBuffer.length - backspacesCounter))
      //     : (_messageBuffer + dataString));
      _messageBuffer =
          (backspacesCounter > 0 ? 123 : (_messageBuffer + dataString));
    }
    print(dataString);
  }

  // 넘으면....
  // void listenToNotification() =>
  //     service.onNotificationClick.stream.listen(onNotificationListener);

  void onNotificationListener(String payload) {
    if (payload != null && payload.isNotEmpty) {
      // Navigator.push(context, MaterialPageRoute(builder: (context)=>SecondScreen(payload: payload)));
    }
  }
}
