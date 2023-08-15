import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mutex/mutex.dart';

class AsyncType<T>  {
    T? _value;
    bool _isLoaded = false;
    bool _retry = true;
    final _m = Mutex();
    final Future<T> Function() callback;
    final Future<T> Function()? callbackDefault;
    final Widget Function(T)? builder;
    final Future<void> Function()? save;

    AsyncType({T? value, required this.callback, this.callbackDefault, this.builder, this.save, retry = true}) {
        if (value != null) {
            _value = value;
            _isLoaded = true;
        }
        _retry = retry;
    }

    bool get isEmpty => _value == null;
    bool get isLoaded => _isLoaded;

    Future<void> setValue(T value) async {
        if (kDebugMode) print("ACQUIRE LOCK of a ${T.toString()}");
        await _m.acquire();
        try {
            _value = value;
            _isLoaded = true;
            if (save != null) save!();
        } finally {
            _m.release();
        }
    }

    Future<void> setValueButNotLoaded(T value) async {
        if (kDebugMode) print("ACQUIRE LOCK of a ${T.toString()}");
        await _m.acquire();
        try {
            _value = value;
        } finally {
            _m.release();
        }
    }

    Future<T> asyncValue () async {

        if (!_isLoaded) {
            if (kDebugMode) print("ACQUIRE LOCK of a ${T.toString()}");
            await _m.acquire();
            try {
                if (!_isLoaded) {
                    _value = await callback();
                    if (save != null) save!();
                    _isLoaded = true;
                }
            } catch(e) {
                if (!_retry) _isLoaded = true;
                if (callbackDefault != null) {
                    _value = await callbackDefault!();
                } else {
                    throw Exception("could not be loaded");
                }
            } finally {
                _m.release();
            }
        }
        return _value as T;
    }

    Future<T> asyncValueMerge(T Function(bool isLoaded, T? current, T asyncVal) func) async {
        _value = func(_isLoaded, syncValue, await asyncValue(), );
        return _value!;
    }

    T? get syncValue => _value;

    Widget getWidget() {
        if (builder != null) {
            if (_value != null && _isLoaded) return builder!(_value as T);
            return FutureBuilder<T>(
                future: asyncValue(),
                builder: (context, snapshot) {
                    if (snapshot.hasData) {
                        return builder!(snapshot.requireData);
                    } else if (callbackDefault != null) {
                        return FutureBuilder<T>(
                            future: callbackDefault!(),
                            builder: (context, snapshot) =>
                            snapshot.hasData
                                ? builder!(snapshot.requireData)
                                : const CircularProgressIndicator(),
                        );
                    } else {
                        return const CircularProgressIndicator();
                    }
                }
            );
        } else {
            return const CircularProgressIndicator();
        }
    }

    Widget customWidget({required Widget Function(T) callback, required Widget Function() elseFunc}) {
        return FutureBuilder<T>(
            future: asyncValue(),
            builder: (context, snapshot) {
                if (snapshot.hasData) {
                    return callback(snapshot.requireData);
                } else {
                    return elseFunc();
                }
            },
        );
    }

    Future<T> refresh () async {
        await _m.acquire();
        try {
            _value = await callback();
            if (save != null) save!();
            _isLoaded = true;
        } catch(e) {
            if (callbackDefault != null) {
                _value = await callbackDefault!();
            } else {
                throw Exception("could not be loaded");
            }
        } finally {
            _m.release();
        }
        return _value!;
    }

}
