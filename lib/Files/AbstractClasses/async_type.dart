import 'dart:isolate';
import 'package:mutex/mutex.dart';

class AsyncType<T>  {
    T? _value;
    bool isLoaded = false;
    final m = Mutex();
    final Future<T> Function() callback;

    AsyncType({T? value, required this.callback}) {
        if (value != null) {
            _value = value;
            isLoaded = true;
        }
    }

    bool get isEmpty => _value != null;

    Future<void> setValue(T value) async {
        await m.acquire();
        try {
            _value = value;
            isLoaded = true;
        } finally {
            m.release();
        }
    }

    Future<T> asyncValue () async {

        if (!isLoaded) {
            print("ACQUIRE LOCK of a ${T.runtimeType}");
            await m.acquire();
            try {
                if (!isLoaded) {
                    _value = await callback();
                    isLoaded = true;
                }
            } finally {
                m.release();
            }
        }
        return _value!;
    }

    T? get syncValue => _value;

}
