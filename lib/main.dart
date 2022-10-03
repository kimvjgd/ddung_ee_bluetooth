import 'package:dongpakka_bluetooth_practice/chat_page1.dart';
import 'package:dongpakka_bluetooth_practice/connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/route_manager.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

Future<void> permission() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.bluetooth,
    Permission.bluetoothConnect,
    Permission.bluetoothScan,
  ].request();
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: FutureBuilder(
        future: FlutterBluetoothSerial.instance.requestEnable(),
        builder: (context, future){
          permission();
          if(future.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: Text('waiting'),),
            );
          }else {
            return Home();
          }
        },
      ),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Connection'),
          ),
          body: SelectBondedDevicePage(
            onChatPage: (device1) async {
              // await permission();

              BluetoothDevice device = device1;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return BluetoothPage(server: device);           // ChatPage1 이 바뀐 사진이다.
                  },
                ),
              );
            },
          ),
        ));
  }
}
