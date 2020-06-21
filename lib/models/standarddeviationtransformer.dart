import 'dart:async';

extension StandardDeviation<T> on Stream<T> {
  static StreamController _controller;
  Stream<T> standardDeviation() {
    return this;
  }
}

class StandardDeviationTransformer<S, T> implements StreamTransformer<S, T> {
  StreamController _controller;

  StreamSubscription _subscription;

  bool cancelOnError;

  // Original Stream
  Stream<S> _stream;

  StandardDeviationTransformer({bool sync: false, this.cancelOnError}) {
    _controller = new StreamController<T>(onListen: _onListen, onCancel: _onCancel, onPause: () {
      _subscription.pause();
    }, onResume: () {
      _subscription.resume();
    }, sync: sync);
  }

  StandardDeviationTransformer.broadcast({bool sync: false, bool this.cancelOnError}) {
    _controller = new StreamController<T>.broadcast(onListen: _onListen, onCancel: _onCancel, sync: sync);
  }

  void _onListen() {
    _subscription = _stream.listen(onData,
      onError: _controller.addError,
      onDone: _controller.close,
      cancelOnError: cancelOnError);
  }

  void _onCancel() {
    _subscription.cancel();
    _subscription = null;
  }

  /**
   * Transformation
   */

  void onData(S data) {
    _controller.add(data);
  }

  /**
   * Bind
   */

  Stream<T> bind(Stream<S> stream) {
    this._stream = stream;
    return _controller.stream;
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() {
    // TODO: implement cast
    throw UnimplementedError();
  }
}