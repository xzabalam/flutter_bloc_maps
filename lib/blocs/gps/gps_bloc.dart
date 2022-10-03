import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart';

part 'gps_event.dart';
part 'gps_state.dart';

class GpsBloc extends Bloc<GpsEvent, GpsState> {
  StreamSubscription? gpsServiceSubscription;

  GpsBloc()
      : super(const GpsState(
            isGpsEnabled: false, isGpsPermissionGranted: false)) {
    on<GpsAndPermissionEvent>((event, emit) => emit(state.copyWith(
        isGpsEnabled: event.isGpsEnabled,
        isGpsPermissionGranted: event.isGpsPermissionGranted)));
    _init();
  }

  Future<void> _init() async {
    final gpsInitStatus =
        await Future.wait([_checkGpsStatus(), _isPermissionGranted()]);

    print('gpsInitStatus: $gpsInitStatus');

    add(GpsAndPermissionEvent(
        isGpsEnabled: gpsInitStatus[0],
        isGpsPermissionGranted: gpsInitStatus[1]));
  }

  Future<bool> _checkGpsStatus() async {
    final isEnable = await geo.Geolocator.isLocationServiceEnabled();

    gpsServiceSubscription =
        geo.Geolocator.getServiceStatusStream().listen((status) {
      final isEnabled = status == geo.ServiceStatus.enabled;
      add(GpsAndPermissionEvent(
          isGpsEnabled: isEnabled,
          isGpsPermissionGranted: state.isGpsPermissionGranted));
    });

    return isEnable;
  }

  Future<void> askGpsAccess() async {
    final status = await Permission.location.request();

    switch (status) {
      case PermissionStatus.granted:
        add(GpsAndPermissionEvent(
            isGpsEnabled: state.isGpsEnabled, isGpsPermissionGranted: true));
        break;
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
      case PermissionStatus.permanentlyDenied:
        add(GpsAndPermissionEvent(
            isGpsEnabled: state.isGpsEnabled, isGpsPermissionGranted: false));
        openAppSettings();
        break;
    }
  }

  Future<bool> _isPermissionGranted() async {
    return await Permission.location.isGranted;
  }

  @override
  Future<void> close() {
    gpsServiceSubscription?.cancel();
    return super.close();
  }
}
