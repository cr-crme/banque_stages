import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class SocketMock implements Socket {
  final subscription = StreamController<Uint8List>();

  @override
  Encoding get encoding => throw UnimplementedError();

  @override
  void add(List<int> data) {}

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future addStream(Stream<List<int>> stream) {
    throw UnimplementedError();
  }

  @override
  InternetAddress get address => throw UnimplementedError();

  @override
  Future<bool> any(bool Function(Uint8List element) test) {
    throw UnimplementedError();
  }

  @override
  Stream<Uint8List> asBroadcastStream(
      {void Function(StreamSubscription<Uint8List> subscription)? onListen,
      void Function(StreamSubscription<Uint8List> subscription)? onCancel}) {
    throw UnimplementedError();
  }

  @override
  Stream<E> asyncExpand<E>(Stream<E>? Function(Uint8List event) convert) {
    throw UnimplementedError();
  }

  @override
  Stream<E> asyncMap<E>(FutureOr<E> Function(Uint8List event) convert) {
    throw UnimplementedError();
  }

  @override
  Stream<R> cast<R>() {
    throw UnimplementedError();
  }

  @override
  Future close() {
    throw UnimplementedError();
  }

  @override
  Future<bool> contains(Object? needle) {
    throw UnimplementedError();
  }

  @override
  void destroy() {}

  @override
  Stream<Uint8List> distinct(
      [bool Function(Uint8List previous, Uint8List next)? equals]) {
    throw UnimplementedError();
  }

  @override
  Future get done => throw UnimplementedError();

  @override
  Future<E> drain<E>([E? futureValue]) {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> elementAt(int index) {
    throw UnimplementedError();
  }

  @override
  Future<bool> every(bool Function(Uint8List element) test) {
    throw UnimplementedError();
  }

  @override
  Stream<S> expand<S>(Iterable<S> Function(Uint8List element) convert) {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> get first => throw UnimplementedError();

  @override
  Future<Uint8List> firstWhere(bool Function(Uint8List element) test,
      {Uint8List Function()? orElse}) {
    throw UnimplementedError();
  }

  @override
  Future flush() {
    throw UnimplementedError();
  }

  @override
  Future<S> fold<S>(
      S initialValue, S Function(S previous, Uint8List element) combine) {
    throw UnimplementedError();
  }

  @override
  Future<void> forEach(void Function(Uint8List element) action) {
    throw UnimplementedError();
  }

  @override
  Uint8List getRawOption(RawSocketOption option) {
    throw UnimplementedError();
  }

  @override
  Stream<Uint8List> handleError(Function onError,
      {bool Function(dynamic error)? test}) {
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
  Future<Uint8List> get last => throw UnimplementedError();

  @override
  Future<Uint8List> lastWhere(bool Function(Uint8List element) test,
      {Uint8List Function()? orElse}) {
    throw UnimplementedError();
  }

  @override
  Future<int> get length => throw UnimplementedError();

  @override
  StreamSubscription<Uint8List> listen(void Function(Uint8List event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return subscription.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  Stream<S> map<S>(S Function(Uint8List event) convert) {
    throw UnimplementedError();
  }

  @override
  Future pipe(StreamConsumer<Uint8List> streamConsumer) {
    throw UnimplementedError();
  }

  @override
  int get port => throw UnimplementedError();

  @override
  Future<Uint8List> reduce(
      Uint8List Function(Uint8List previous, Uint8List element) combine) {
    throw UnimplementedError();
  }

  @override
  InternetAddress get remoteAddress => throw UnimplementedError();

  @override
  int get remotePort => throw UnimplementedError();

  @override
  bool setOption(SocketOption option, bool enabled) {
    throw UnimplementedError();
  }

  @override
  void setRawOption(RawSocketOption option) {}

  @override
  Future<Uint8List> get single => throw UnimplementedError();

  @override
  Future<Uint8List> singleWhere(bool Function(Uint8List element) test,
      {Uint8List Function()? orElse}) {
    throw UnimplementedError();
  }

  @override
  Stream<Uint8List> skip(int count) {
    throw UnimplementedError();
  }

  @override
  Stream<Uint8List> skipWhile(bool Function(Uint8List element) test) {
    throw UnimplementedError();
  }

  @override
  Stream<Uint8List> take(int count) {
    throw UnimplementedError();
  }

  @override
  Stream<Uint8List> takeWhile(bool Function(Uint8List element) test) {
    throw UnimplementedError();
  }

  @override
  Stream<Uint8List> timeout(Duration timeLimit,
      {void Function(EventSink<Uint8List> sink)? onTimeout}) {
    throw UnimplementedError();
  }

  @override
  Future<List<Uint8List>> toList() {
    throw UnimplementedError();
  }

  @override
  Future<Set<Uint8List>> toSet() {
    throw UnimplementedError();
  }

  @override
  Stream<S> transform<S>(StreamTransformer<Uint8List, S> streamTransformer) {
    throw UnimplementedError();
  }

  @override
  Stream<Uint8List> where(bool Function(Uint8List event) test) {
    throw UnimplementedError();
  }

  @override
  void write(Object? object) {}

  @override
  void writeAll(Iterable objects, [String separator = ""]) {}

  @override
  void writeCharCode(int charCode) {}

  @override
  void writeln([Object? object = ""]) {}

  @override
  set encoding(Encoding encoding) {}
}

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
