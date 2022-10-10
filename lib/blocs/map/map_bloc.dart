import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps_app/enumerations/enumerations.dart';
import 'package:flutter_maps_app/helpers/helpers.dart';
import 'package:flutter_maps_app/theme/themes.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/models.dart';
import '../blocs.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final LocationBloc locationBloc;
  GoogleMapController? _mapController;
  LatLng? mapCenter;
  StreamSubscription<LocationState>? locationStateSubscription;

  /**
   * Permite convertir un Duration al formato HH:mm:ss
   */
  formatDurationToString(Duration d) =>
      d.toString().split('.').first.padLeft(8, "0");

  MapBloc({required this.locationBloc}) : super(const MapState()) {
    on<OnMapInitializedEvent>(_onInitMap);

    on<OnStartFollowingUserMapEvent>(_onStartFollowingUser);

    on<OnStopFollowingUserMapEvent>(
        (event, emit) => emit(state.copyWith(isFollowingUser: false)));

    on<UpdateUserPolylineEvent>(_onUpdateUserPolylineEvent);

    on<OnToggleUserShowRouteEvent>(
        (event, emit) => emit(state.copyWith(showMyRoute: !state.showMyRoute)));

    on<DisplayPolylinesEvent>((event, emit) => emit(
        state.copyWith(polylines: event.polylines, markers: event.markers)));

    _moveCameraWhenFollowignUser();
  }

  void _moveCameraWhenFollowignUser() {
    locationStateSubscription = locationBloc.stream.listen((locationState) {
      if (locationState.lastKnownLocation != null) {
        add(UpdateUserPolylineEvent(locationState.myLocationHistory));
      }

      if (!state.isFollowingUser) return;
      if (locationState.lastKnownLocation == null) required;

      moveCamera(locationState.lastKnownLocation!);
    });
  }

  void _onInitMap(OnMapInitializedEvent event, Emitter<MapState> emit) {
    _mapController = event.controller;
    _mapController!.setMapStyle(jsonEncode(uberMapTheme));
    emit(state.copyWith(isMapInitialized: true));
  }

  void _onStartFollowingUser(
      OnStartFollowingUserMapEvent event, Emitter<MapState> emmit) {
    emit(state.copyWith(isFollowingUser: true));

    if (locationBloc.state.lastKnownLocation == null) required;
    moveCamera(locationBloc.state.lastKnownLocation!);
  }

  void _onUpdateUserPolylineEvent(
      UpdateUserPolylineEvent event, Emitter<MapState> emmit) {
    final myRoute = Polyline(
        polylineId: const PolylineId("myRoute"),
        color: Colors.black,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        points: event.userLocations);

    final currentPolylines = Map<String, Polyline>.from(state.polylines);
    currentPolylines['myRoute'] = myRoute;

    emit(state.copyWith(polylines: currentPolylines));
  }

  Future drawRoutePolyline(RouteDestination destination) async {
    final myRoute = Polyline(
      polylineId: const PolylineId('route'),
      color: Colors.black,
      width: 5,
      points: destination.points,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );

    double kms = ((destination.distance / 10).floorToDouble()) / 100;
    String tripDuration =
        formatDurationToString(Duration(seconds: destination.duration.toInt()));

    final initCustomMarker =
        await getAssetImageMarker(AssetsMarkersEnum.inicialMarker.value);

    final startMarker = Marker(
        markerId: const MarkerId('start'),
        position: destination.points.first,
        icon: initCustomMarker,
        infoWindow: InfoWindow(
            title: 'Inicio',
            snippet: 'Distancia: $kms Km, Duración: $tripDuration.'));

    final finalCustomMarker =
        await getAssetImageMarker(AssetsMarkersEnum.finalMarker.value);

    final endMarker = Marker(
        markerId: const MarkerId('end'),
        position: destination.points.last,
        icon: finalCustomMarker,
        infoWindow: InfoWindow(
            title: '${destination.endPlaceInformation.text}',
            snippet: '${destination.endPlaceInformation.placeName}'));

    final currentPolylines = Map<String, Polyline>.from(state.polylines);
    currentPolylines['route'] = myRoute;

    final currentMarkers = Map<String, Marker>.from(state.markers);
    currentMarkers['start'] = startMarker;
    currentMarkers['end'] = endMarker;

    add(DisplayPolylinesEvent(currentPolylines, currentMarkers));

    await Future.delayed(const Duration(milliseconds: 300));
    _mapController?.showMarkerInfoWindow(const MarkerId('start'));
  }

  void moveCamera(LatLng newLocation) {
    final CameraUpdate cameraUpdate = CameraUpdate.newLatLng(newLocation);
    _mapController?.animateCamera(cameraUpdate);
  }

  @override
  Future<void> close() {
    locationStateSubscription?.cancel();
    return super.close();
  }
}
