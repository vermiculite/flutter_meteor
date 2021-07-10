import 'package:flutter_meteor/src/ddp/connection.dart';

void main() {
  final connection = Connection('ws://localhost:3000/websocket');
  connection.connect();
}
