import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:flutter_meteor/src/ddp/connection.dart';

class SubscriptionController {
  Map<String, StreamController> _subscriptions = {};

  SubscriptionController();

  ready(List subs) {
    subs.forEach((subId) {
      StreamController<Subscription> subscription = _subscriptions[subId];
      if (subscription != null) {
        subscription.add(
            Subscription(ready: true, subscriptionId: subId, controller: this));
      }
    });
  }

  unsubscribe({String subId, Connection connection}) {
    connection.unsubscribe(subId);
  }

  Stream<Subscription> subscribe({String name, params = const [], Connection connection}) {
    var uuid = Uuid();
    String id = uuid.v1();
    var controller = StreamController<Subscription>();
    _subscriptions[id] = controller;
    controller
        .add(Subscription(ready: false, subscriptionId: id, controller: this));
    connection.subscribe(id: id, name: name, params: params);
    return controller.stream;
  }
}

class Subscription {
  final bool ready;
  final String subscriptionId;
  final SubscriptionController controller;

  Subscription({this.ready, this.subscriptionId, this.controller});

  void stop() {
    controller.unsubscribe();
  }

  String toString() {
    return "ready: $ready, id: $subscriptionId";
  }
}
