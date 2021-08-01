import 'package:flutter_meteor/flutter_meteor.dart';
import 'package:flutter_meteor/src/data/subscription.dart';

void main() {
  init();
  Stream<Subscription> subStream = subscribe(name: 'links.all');
  subStream.forEach((element) {
    print(element);
  });
}
