import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_agram/app/app.dart';
import 'package:stream_feed_flutter_core/stream_feed_flutter_core.dart';

import '../components/login/login.dart';

/// {@template app}
/// Main entry point to the Stream-agram application.
/// {@endtemplate}
class StreamagramApp extends StatefulWidget {
  /// {@macro app}
  const StreamagramApp({
    Key? key,
    required this.appTheme,
  }) : super(key: key);

  /// App's theme data.
  final AppTheme appTheme;

  @override
  State<StreamagramApp> createState() => _StreamagramAppState();
}

class _StreamagramAppState extends State<StreamagramApp> {
  final _client =
      StreamFeedClient('eyssk29az2kj'); // TODO: Add Stream API Token
  late final appState = AppState(client: _client);

  // Important to only initialize this once.
  // Unless you want to update the bloc state
  late final feedBloc = FeedBloc(client: _client);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: appState,
      child: MaterialApp(
        title: 'Stream-agram',
        theme: widget.appTheme.lightTheme,
        darkTheme: widget.appTheme.darkTheme,
        themeMode: ThemeMode.dark,
        builder: (context, child) {
          // Stream Feeds provider to give access to [FeedBloc]
          // This class comes from Stream Feeds.
          return FeedProvider(
            bloc: feedBloc,
            child: child!,
          );
        },
        home: const LoginScreen(),
      ),
    );
  }
}
