import 'dart:async';
import 'dart:io';

class WebSocketMock implements WebSocket {
  bool isConnected = false;
  final StreamController streamController = StreamController();
  final StreamController incommingStreamController = StreamController();

  @override
  Duration? pingInterval;

  @override
  void add(data) {
    if (isConnected) {
      incommingStreamController.add(data);
    } else {
      throw StateError('WebSocket is not connected');
    }
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future addStream(Stream stream) {
    throw UnimplementedError();
  }

  @override
  void addUtf8Text(List<int> bytes) {}

  @override
  Future<bool> any(bool Function(dynamic element) test) {
    throw UnimplementedError();
  }

  @override
  Stream asBroadcastStream(
      {void Function(StreamSubscription subscription)? onListen,
      void Function(StreamSubscription subscription)? onCancel}) {
    throw UnimplementedError();
  }

  @override
  Stream<E> asyncExpand<E>(Stream<E>? Function(dynamic event) convert) {
    throw UnimplementedError();
  }

  @override
  Stream<E> asyncMap<E>(FutureOr<E> Function(dynamic event) convert) {
    throw UnimplementedError();
  }

  @override
  Stream<R> cast<R>() {
    throw UnimplementedError();
  }

  @override
  Future close([int? code, String? reason]) async {
    isConnected = false;
    await streamController.close();
    return null;
  }

  @override
  int? get closeCode => throw UnimplementedError();

  @override
  String? get closeReason => throw UnimplementedError();

  @override
  Future<bool> contains(Object? needle) {
    throw UnimplementedError();
  }

  @override
  Stream distinct([bool Function(dynamic previous, dynamic next)? equals]) {
    throw UnimplementedError();
  }

  @override
  Future get done => throw UnimplementedError();

  @override
  Future<E> drain<E>([E? futureValue]) {
    throw UnimplementedError();
  }

  @override
  Future elementAt(int index) {
    throw UnimplementedError();
  }

  @override
  Future<bool> every(bool Function(dynamic element) test) {
    throw UnimplementedError();
  }

  @override
  Stream<S> expand<S>(Iterable<S> Function(dynamic element) convert) {
    throw UnimplementedError();
  }

  @override
  String get extensions => throw UnimplementedError();

  @override
  Future get first => throw UnimplementedError();

  @override
  Future firstWhere(bool Function(dynamic element) test, {Function()? orElse}) {
    throw UnimplementedError();
  }

  @override
  Future<S> fold<S>(
      S initialValue, S Function(S previous, dynamic element) combine) {
    throw UnimplementedError();
  }

  @override
  Future<void> forEach(void Function(dynamic element) action) {
    throw UnimplementedError();
  }

  @override
  Stream handleError(Function onError, {bool Function(dynamic error)? test}) {
    throw UnimplementedError();
  }

  @override
  bool get isBroadcast => throw UnimplementedError();

  @override
  Future<bool> get isEmpty => throw UnimplementedError();

  @override
  Future<String> join([String separator = ""]) {
    throw UnimplementedError();
  }

  @override
  Future get last => throw UnimplementedError();

  @override
  Future lastWhere(bool Function(dynamic element) test, {Function()? orElse}) {
    throw UnimplementedError();
  }

  @override
  Future<int> get length => throw UnimplementedError();

  @override
  StreamSubscription listen(void Function(dynamic event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    isConnected = true;
    return streamController.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  Stream<S> map<S>(S Function(dynamic event) convert) {
    throw UnimplementedError();
  }

  @override
  Future pipe(StreamConsumer streamConsumer) {
    throw UnimplementedError();
  }

  @override
  String? get protocol => throw UnimplementedError();

  @override
  int get readyState => throw UnimplementedError();

  @override
  Future reduce(Function(dynamic previous, dynamic element) combine) {
    throw UnimplementedError();
  }

  @override
  Future get single => throw UnimplementedError();

  @override
  Future singleWhere(bool Function(dynamic element) test,
      {Function()? orElse}) {
    throw UnimplementedError();
  }

  @override
  Stream skip(int count) {
    throw UnimplementedError();
  }

  @override
  Stream skipWhile(bool Function(dynamic element) test) {
    throw UnimplementedError();
  }

  @override
  Stream take(int count) {
    throw UnimplementedError();
  }

  @override
  Stream takeWhile(bool Function(dynamic element) test) {
    throw UnimplementedError();
  }

  @override
  Stream timeout(Duration timeLimit,
      {void Function(EventSink sink)? onTimeout}) {
    throw UnimplementedError();
  }

  @override
  Future<List> toList() {
    throw UnimplementedError();
  }

  @override
  Future<Set> toSet() {
    throw UnimplementedError();
  }

  @override
  Stream<S> transform<S>(StreamTransformer<dynamic, S> streamTransformer) {
    throw UnimplementedError();
  }

  @override
  Stream where(bool Function(dynamic event) test) {
    throw UnimplementedError();
  }
}
