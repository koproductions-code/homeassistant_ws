<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

# homeassistant_ws
This package provides an interface to communicate with HomeAssistant using the websocket protocol. In addition, it provides a way to integrate this interface into flutter applications using [provider](https://pub.dev/packages/provider)

## Features
 - Listen for state changes for specific HomeAssistant entities.
 - Integrate into flutter widgets using the provider package.

## Getting started

### Dependencies:
```dart
provider: ^6.1.2
```

## Usage

### Usage with Flutter
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homeassistant_ws/flutter/homeassistant_ws_flutter.dart'; // <-- If you want to use the flutter functionality, you need to import this subpackage.

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeAssistantBuilder(
            host: "homeassistant.koproductions.dev",
            port: 443,
            entities: ["[Your Entity IDs]"],
            child: EntityWidget(
              entityId: "[EntityID]",
            )));
  }
}

class EntityWidget extends StatefulWidget {
  final String entityId;

  const EntityWidget({super.key, required this.entityId});

  @override
  EntityWidgetState createState() => EntityWidgetState();
}

class EntityWidgetState extends State<EntityWidget> {
  String state = "unknown";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<HomeAssistantProvider>(context);

    provider.socket?.subscribe(widget.entityId, update);
  }

  void update(HAEntityState data) {
    setState(() {
      state = data.state;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(state);
  }
}

```

## Credits
Thanks to 

## Additional information

TODO: Tell users more about the package: where to find more information, how to 
contribute to the package, how to file issues, what response they can expect 
from the package authors, and more.
