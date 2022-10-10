import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'
    show BitmapDescriptor;

Future<BitmapDescriptor> getAssetImageMarker(String markerPath) async {
  late BitmapDescriptor iconMarker;
  await getBytesFromAsset(markerPath)
      .then((value) => {iconMarker = BitmapDescriptor.fromBytes(value!)});
  return iconMarker;
}

Future<Uint8List?> getBytesFromAsset(String markerPath) async {
  ByteData data = await rootBundle.load(markerPath);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
      targetHeight: 150, targetWidth: 150);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
      ?.buffer
      .asUint8List();
}
