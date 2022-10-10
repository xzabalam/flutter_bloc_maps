import 'package:dio/dio.dart';
import 'package:flutter_maps_app/config/env/env.dart';
import 'package:flutter_maps_app/models/models.dart';
import 'package:flutter_maps_app/services/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/responses/places/places_model.dart';

class TrafficService {
  final Dio _dioTraffic;
  final Dio _dioPlaces;

  TrafficService()
      : _dioTraffic = Dio()..interceptors.add(TrafficInterceptor()),
        _dioPlaces = Dio()..interceptors.add(PlacesInterceptor());

  /**
   * Obtener las coordenadas para dibujar las polylines dadas las coordenadas
   * de origen y fin.
   *
   * En los interceptores @{link: TrafficInterceptor} se agregan las queryParams
   * que se necesitan para realizar la llamada al api de mapBox.
   */
  Future<TrafficResponse> getCoordinatesStartToEnd(
      LatLng start, LatLng end) async {
    final coordinatesString =
        '${start.longitude},${start.latitude};${end.longitude},${end.latitude}';
    final url = '${Env.urlMapBoxApi}/driving/$coordinatesString';
    final response = await _dioTraffic.get(url);

    return TrafficResponse.fromMap(response.data);
  }

  /**
   * Obtener los lugares buscados que se encuentran próximos al lugar actual.
   *
   * En los interceptores @{link: PlacesInterceptor} se agregan las queryParams
   * que se necesitan para realizar la llamada al api de mapBox.
   */
  Future<List<Feature>> getResultsByQuery(
      LatLng proximity, String query) async {
    if (query.isEmpty) return [];

    final url = '${Env.searchMapBoxApi}/$query.json';

    final resp = await _dioPlaces.get(url, queryParameters: {
      'proximity': '${proximity.longitude},${proximity.latitude}',
      'limit': 20,
    });

    final placesResponse = PlacesResponse.fromMap(resp.data);

    return placesResponse.features;
  }

  /**
   * Permite obtener la informaci[on de una ubicaci[on.
   */
  Future<Feature> getInformationByCoordinates(LatLng coordinates) async {
    final url =
        '${Env.searchMapBoxApi}/${coordinates.longitude},${coordinates.latitude}.json';

    final resp = await _dioPlaces.get(url, queryParameters: {'limit': 1});

    final placesResponse = PlacesResponse.fromMap(resp.data);

    return placesResponse.features[0];
  }
}
