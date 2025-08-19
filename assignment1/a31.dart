Stream<int> numberStream(int count) async* {
  for (int i = 1; i <= count; i++) {
    await Future.delayed(Duration(seconds: 1));
    yield i;
  }
}

void main() async {
  await for (int num in numberStream(5)) {
    print("Received: $num");
  }
  print("Stream ended.");
}
