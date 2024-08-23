import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'homeassistant_provider.dart';

class HomeAssistantBuilder extends StatelessWidget {
  final String host;
  final int port;
  final List<String> entities;

  final String? accessToken;

  final Widget? loadingWidget;
  final Widget child;

  HomeAssistantBuilder(
      {super.key,
      required this.host,
      required this.port,
      required this.entities,
      this.accessToken,
      this.loadingWidget,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeAssistantProvider>(
      create: (context) => HomeAssistantProvider(host: host, port: port, entities: entities, accessToken: accessToken),
      child: Builder(
        builder: (context) => FutureBuilder(
          future: Provider.of<HomeAssistantProvider>(context, listen: false).connect(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(
                    child: Text(
                  'Failed to connect: ${snapshot.error}',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ));
              }
              return child;
            } else {
              if (loadingWidget != null) {
                return loadingWidget!;
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }
          },
        ),
      ),
    );
  }
}
