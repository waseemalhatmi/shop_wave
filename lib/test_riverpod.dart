import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyState {}

class MyNotifier extends AsyncNotifier<MyState> {
  @override
  Future<MyState> build() async {
    return MyState();
  }

  void test() {
    state = const AsyncLoading();
    ref.read(Provider((ref) => 1));
  }
}

final myNotifierProvider = AsyncNotifierProvider.autoDispose<MyNotifier, MyState>(MyNotifier.new);
