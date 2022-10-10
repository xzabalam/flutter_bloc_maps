import 'package:dio/dio.dart';
import 'package:flutter_maps_app/config/env/env.dart';

class PlacesInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.queryParameters.addAll(
        {'country': 'ec', 'language': 'es', 'access_token': Env.mapBoxApiKey});

    super.onRequest(options, handler);
  }
}
