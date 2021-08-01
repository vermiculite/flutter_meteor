library flutter_meteor;

import 'package:flutter_meteor/src/data/subscription.dart';
import 'package:flutter_meteor/src/ddp/connection.dart';

String url = 'ws://localhost:3000/websocket';
var subController = SubscriptionController();
Connection  connection = Connection(url: url, subController: subController);

init() {
  connection.connect();
}

subscribe({String name, List params = const []}) {
  return subController.subscribe(name: name, params: params, connection: connection);
}