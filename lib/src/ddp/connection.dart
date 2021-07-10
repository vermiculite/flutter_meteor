import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class Connection {
  final response = jsonEncode({
    "msg": "connect",
    "version": "1",
    "support": ["1", "pre2", "pre1"]
  });

  final String url;

  var connected = false;

  var serverId;

  String sessionId;

  WebSocketChannel channel;

  Connection(this.url);

  connect() {
    channel = WebSocketChannel.connect(
      Uri.parse(url),
    );
    channel.stream.listen(_listen);
    channel.stream.handleError(_error);
  }

  void _listen(dynamic rawMessage) {
    Map<String, dynamic> message = jsonDecode(rawMessage);
    print(message);

    if (message.keys.contains('server_id')) {
      serverId = message['server_id'];
      channel.sink.add(response);
    }
    if (message.keys.contains('msg')) {
      _handleMessage(message);
    }
  }

  void _handleMessage(Map<String, dynamic> message) {
    String key = message['msg'];
    switch (key) {
      case 'connected':
        connected = true;
        sessionId = message['session'];
        return;
      case 'ping':
        channel.sink.add(jsonEncode({'msg': 'pong'}));
        return;
    }
  }

  void _error(err, stackTrace) {
    print('Handling the exception');
    print(err);
    print(stackTrace);
  }
}
