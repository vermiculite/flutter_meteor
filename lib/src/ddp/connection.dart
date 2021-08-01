import 'dart:async';
import 'dart:convert';
import 'package:flutter_meteor/src/data/subscription.dart';

import 'package:web_socket_channel/web_socket_channel.dart';

class Connection {

  final List<String> _queue = [];
  final _response = jsonEncode({
    "msg": "connect",
    "version": "1",
    "support": ["1", "pre2", "pre1"]
  });

  final String url;

  var _connected = false;

  var _serverId;

  var _lastPing;

  String _sessionId;
  SubscriptionController subController;

  WebSocketChannel channel;

  Connection({this.url, this.subController});

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
      _serverId = message['server_id'];
      channel.sink.add(_response);
    }
    if (message.keys.contains('msg')) {
      _handleMessage(message);
    }
  }

  void _handleMessage(Map<String, dynamic> message) {
    String key = message['msg'];
    switch (key) {
      case 'connected':
        _connected = true;
        _sessionId = message['session'];
        _emptyQueue();
        return;
      case 'ping':
        channel.sink.add(jsonEncode({'msg': 'pong'}));
        return;
      case 'pong':
        _lastPing = DateTime.now();
        Future.delayed(Duration(minutes: 1), () {
          _pingTheServer();
        });
        return;
      case 'ready':
        List subs = message['subs'];
        subController.ready(subs);
        return;
      case 'added':
        print(message);
    }
  }

  void _error(err, stackTrace) {
    print('Handling the exception');
    print(err);
    print(stackTrace);
  }

  void _pingTheServer() {
    _sendMessage(jsonEncode({'msg': 'ping'}));
  }

  unsubscribe(String subscriptionId) {
    _sendMessage(jsonEncode({'msg': 'unsub', 'id': subscriptionId}));
  }

  subscribe({String id, String name, List<dynamic> params = const []}) {
    _sendMessage(jsonEncode({'msg': 'sub', 'id': id, 'name': name, 'params': params}));
  }

  _sendMessage(String message) {
    if(_connected) {
      channel.sink.add(message);
    } else {
      _queue.add(message);
    }
  }

  void _emptyQueue() {
    _queue.forEach((element) {
      _sendMessage(element);
    });
  }
}
