import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'homeassistant_provider.dart';

mixin RefreshableWidget<T extends StatefulWidget> on State<T> {
  Timer? _timer;

  Duration get refreshRate;

  @override
  void initState() {
    super.initState();
    refresh();

    _timer = Timer.periodic(refreshRate, (Timer timer) async {
      if (mounted) {
        await refresh();
      }
    });
  }

  Future<void> refresh();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class HomeAssistantBuilder extends StatefulWidget {
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
  _HomeAssistantBuilderState createState() => _HomeAssistantBuilderState();
}

class _HomeAssistantBuilderState extends State<HomeAssistantBuilder> with RefreshableWidget<HomeAssistantBuilder> {
  late HomeAssistantProvider _provider;
  late Future<void> _connectFuture;

  @override
  void initState() {
    super.initState();
    _provider = HomeAssistantProvider(
      host: widget.host,
      port: widget.port,
      entities: widget.entities,
      accessToken: widget.accessToken,
    );
    _connectFuture = _provider.connect();
  }

  @override
  Duration get refreshRate => Duration(minutes: 1);

  @override
  Future<void> refresh() async {
    print("Refreshing Home Assistant connection...");
    await _provider.connect();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeAssistantProvider>(
      create: (context) => _provider,
      child: Builder(
        builder: (context) => FutureBuilder(
          future: _connectFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(
                    child: Text(
                  'Failed to connect: ${snapshot.error}',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ));
              }
              return widget.child;
            } else {
              if (widget.loadingWidget != null) {
                return widget.loadingWidget!;
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
