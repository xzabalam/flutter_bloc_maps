import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_maps_app/models/models.dart';
import 'package:flutter_maps_app/services/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';

import '../../models/responses/places/places_model.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  TrafficService trafficService;

  SearchBloc({required this.trafficService}) : super(const SearchState()) {
    on<OnActivateManualMarkerEvent>(
        (event, emit) => emit(state.copyWith(displayManualMarker: true)));

    on<OnDeactivateManualMarkerEvent>(
        (event, emit) => emit(state.copyWith(displayManualMarker: false)));

    on<OnNewPlacesFoundEvent>(
        (event, emit) => emit(state.copyWith(places: event.places)));

    on<OnNewPlaceSelectedEvent>(_onNewPlaceSelected);
  }

  void _onNewPlaceSelected(
      OnNewPlaceSelectedEvent event, Emitter<SearchState> emit) {
    final existPlaceInHistory =
        state.history.indexWhere((element) => element.id == event.place.id);
    if (existPlaceInHistory == -1) {
      emit(state.copyWith(history: [event.place, ...state.history]));
    }
  }

  Future<RouteDestination> getCoorsStartToEnd(LatLng start, LatLng end) async {
    final trafficResponse =
        await trafficService.getCoordinatesStartToEnd(start, end);

    final endPlaceInformation =
        await trafficService.getInformationByCoordinates(end);

    final geometry = trafficResponse.routes[0].geometry;
    final distance = trafficResponse.routes[0].distance;
    final duration = trafficResponse.routes[0].duration;

    final points = decodePolyline(geometry, accuracyExponent: 6);
    final latLngList = points
        .map((cords) => LatLng(cords[0].toDouble(), cords[1].toDouble()))
        .toList();

    return RouteDestination(
        points: latLngList,
        duration: duration,
        distance: distance,
        endPlaceInformation: endPlaceInformation);
  }

  Future getPlacesByQuery(LatLng proximity, String query) async {
    final newPlaces = await trafficService.getResultsByQuery(proximity, query);
    add(OnNewPlacesFoundEvent(newPlaces));
  }
}
