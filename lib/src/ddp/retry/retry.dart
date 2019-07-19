import 'dart:async';
import 'dart:math';

class Retry {

  final int baseTimeOut;
  final double exponent;
  final int maxTimeOut;
  final int minTimeOut;
  final int minCount;
  final double fuzz;
  Timer timer;

  Retry({
    this.baseTimeOut = 1000,
    this.exponent = 2.2,
    this.maxTimeOut = 5 * 60 * 1000,
    this.minTimeOut = 10,
    this.minCount = 2,
    this.fuzz = 0.5,
  });

  void clear() {
    if(timer != null) {
      timer.cancel();
      timer = null;
    }
  }

  Duration _timeOut(int count) {
    if (count < minCount) {
      return Duration(milliseconds: minTimeOut);
    }
    // fuzz the timeout randomly, to avoid reconnect storms when a
    // server goes down.
    Random rnd = Random();
    var timeout = min(
        maxTimeOut,
        baseTimeOut * pow(exponent, count)
    ) * (
        rnd.nextDouble() * fuzz + (1 - fuzz / 2)
    );

    return Duration(milliseconds: timeout);
  }

  Duration retryLater(int count, Function fn) {
    Duration timeout = _timeOut(count);
    if (timer != null) {
      clear();
    }
    timer = Timer(timeout, fn);
    return timeout;
  }
}