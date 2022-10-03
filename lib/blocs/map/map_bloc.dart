import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_maps_app/theme/themes.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../blocs.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final LocationBloc locationBloc;
  GoogleMapController? _mapController;

  MapBloc({required this.locationBloc}) : super(const MapState()) {
    on<OnMapInitializedEvent>(_onInitMap);

    _moveCameraWhenFollowignUser();
  }

  void _moveCameraWhenFollowignUser() {
    locationBloc.stream.listen((locationState) {
      if (!state.followUser) return;
      if (locationState.lastKnownLocation == null) required;

      moveCamera(locationState.lastKnownLocation!);
    });
  }

  void _onInitMap(OnMapInitializedEvent event, Emitter<MapState> emit) {
    _mapController = event.controller;
    _mapController!.setMapStyle(jsonEncode(uberMapTheme));
    emit(state.copyWith(isMapInitialized: true));
  }

  void moveCamera(LatLng newLocation) {
    final CameraUpdate cameraUpdate = CameraUpdate.newLatLng(newLocation);
    _mapController?.animateCamera(cameraUpdate);
  }
}
