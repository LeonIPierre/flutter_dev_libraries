import 'dart:async';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:admob_flutter/src/admob_event_handler.dart';

class AdmobInterstitialFuture extends AdmobEventHandler {
  static const MethodChannel _channel =
      MethodChannel('admob_flutter/interstitial');

  int id;
  MethodChannel _adChannel;
  final String adUnitId;
  final void Function(AdmobAdEvent, Map<String, dynamic>) listener;

  AdmobInterstitialFuture({
    @required this.adUnitId,
    this.listener,
  }) : super(listener) {
    id = hashCode;
    if (listener != null) {
      _adChannel = MethodChannel('admob_flutter/interstitial_$id');
      _adChannel.setMethodCallHandler(handleEvent);
    }
  }

  Future<bool> get isLoaded async {
    final bool result =
        await _channel.invokeMethod('isLoaded', <String, dynamic>{
      'id': id,
    });
    return result;
  }

  Future<dynamic> load() async {
    return await _channel.invokeMethod('load', <String, dynamic>{
      'id': id,
      'adUnitId': adUnitId,
    }).then((value) async {
      if(listener == null)
        return Future.value();
      else 
        return await _channel.invokeMethod('setListener', <String, dynamic>{
        'id': id,
        });
    });
  }

  void show() async {
    if (await isLoaded == true) {
      await _channel.invokeMethod('show', <String, dynamic>{
        'id': id,
      });
    }
  }

  void dispose() async {
    await _channel.invokeMethod('dispose', <String, dynamic>{
      'id': id,
    });
  }
}
