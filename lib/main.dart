import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  // We need to call it manually,
  // because we going to call setPreferredOrientations()
  // before the runApp() call
  WidgetsFlutterBinding.ensureInitialized();

  // Than we setup preferred orientations,
  // and only after it finished we run our app
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft])
      .then((value) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        backgroundColor: Colors.black,
        textTheme: Typography.material2021().white,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class CitibikeData {
  String numBikes;
  String numEbikes;
  String stationName;
  CitibikeData(this.numBikes, this.numEbikes, this.stationName);
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<dynamic> data;
  late int numBikes;

  @override
  void initState() {
    super.initState();
  }

  num textOffset(text) {
    return 61 - text.length * 4;
  }

  Future<dynamic> fetchData() async {
    var response = await http.get(
        Uri.parse("https://gbfs.citibikenyc.com/gbfs/es/station_status.json"));

    if (response.statusCode != 200) {
      throw Exception('Failed to load data');
    }

    var list = jsonDecode(response.body)["data"]["stations"] as List;

    final stationStatus =
        list.firstWhereOrNull((item) => item["station_id"] == "432");

    final numBikes = stationStatus["num_bikes_available"] as String;
    final numEbikes = stationStatus["num_ebikes_available"] as String;

    response = await http.get(
        Uri.parse("https://gbfs.citibikenyc.com/gbfs/es/station_status.json"));

    if (response.statusCode != 200) {
      throw Exception('Failed to load data');
    }

    list = jsonDecode(response.body)["data"]["stations"] as List;

    final stationInfo =
        list.firstWhereOrNull((item) => item["station_id"] == "432");

    final stationName =
        (stationInfo["name"] as String).replaceAll("Avenue", "Ave");

    return CitibikeData(numBikes, numEbikes, stationName);
  }

  @override
  Widget build(BuildContext context) {
    const logicalWidth = 64;
    const logicalHeight = 32;
    const aspectRatio = logicalWidth / logicalHeight;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.white)),
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: LayoutBuilder(builder: (context, constraints) {
              var scale = constraints.maxWidth / logicalWidth;
              return Stack(
                // fit: StackFit.expand,
                children: <Widget>[
                  Positioned(
                    top: 3 * scale,
                    left: 10 * scale,
                    child: Image.asset(
                      'assets/images/bike.png',
                      scale: 1 / scale,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.none,
                    ),
                  ),
                  Positioned(
                    top: 23 * scale,
                    left: (textOffset("hi") - 5) * scale,
                    child: Image.asset(
                      "assets/images/ebike.png",
                      scale: 1 / scale,
                      filterQuality: FilterQuality.none,
                    ),
                  ),
                  Positioned(
                      top: 7 * scale, left: 2 * scale, child: Text("hey"))
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
