import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  StreamSubscription<Position>? _positionStreamSubscription;

  LocationBloc() : super(const LocationState()) {
    on<OnNewUserLocationEvent>((event, emit) {
      print('state: ${state.myLocationHistory.length}');
      emit(state.copyWith(
          lastKnownLocation: event.newLocation,
          myLocationHistory: [...state.myLocationHistory, event.newLocation]));
    });

    on<OnStartFollowingUserEvent>(
        (event, emit) => emit(state.copyWith(followingUser: true)));

    on<OnStopFollowingUserEvent>(
        (event, emit) => emit(state.copyWith(followingUser: false)));
  }

  Future getCurrentPosition() async {
    final position = await Geolocator.getCurrentPosition();
    add(OnNewUserLocationEvent(LatLng(position.latitude, position.longitude)));
  }

  void startFollowingUser() {
    add(OnStartFollowingUserEvent());

    _positionStreamSubscription =
        Geolocator.getPositionStream().listen((event) {
      final position = event;

      print('position: $position');

      add(OnNewUserLocationEvent(
          LatLng(position.latitude, position.longitude)));
    });
  }

  void stopFollowingUser() {
    _positionStreamSubscription?.cancel();
    add(OnStopFollowingUserEvent());
  }

  @override
  Future<void> close() {
    stopFollowingUser();
    return super.close();
  }
}
