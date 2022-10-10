import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps_app/blocs/blocs.dart';
import 'package:flutter_maps_app/helpers/helpers.dart';
import 'package:flutter_maps_app/widgets/widgets.dart';

class ManualMarker extends StatelessWidget {
  const ManualMarker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) => state.displayManualMarker
            ? const _ManualMarkerBody()
            : const SizedBox());
  }
}

class _ManualMarkerBody extends StatelessWidget {
  const _ManualMarkerBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mapBloc = BlocProvider.of<MapBloc>(context);
    final searchBloc = BlocProvider.of<SearchBloc>(context);
    final locationBloc = BlocProvider.of<LocationBloc>(context);

    final size = MediaQuery.of(context).size;
    return SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            const Positioned(top: 70, left: 20, child: BtnBack()),
            Center(
              child: Transform.translate(
                offset: const Offset(0, -22),
                child: BounceInDown(
                  from: 100,
                  child: const Icon(
                    Icons.location_on_rounded,
                    size: 50,
                  ),
                ),
              ),
            ),
            Positioned(
                bottom: 70,
                left: 40,
                child: FadeInUp(
                  duration: const Duration(milliseconds: 300),
                  child: MaterialButton(
                    minWidth: size.width - 120,
                    color: Colors.black,
                    elevation: 0,
                    height: 50,
                    shape: const StadiumBorder(),
                    child: const Text(
                      'Confirmar destino',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w300),
                    ),
                    onPressed: () async {
                      final start = locationBloc.state.lastKnownLocation;
                      if (start == null) return;

                      final end = mapBloc.mapCenter;
                      if (end == null) return;

                      showLoadingMessage(context);

                      final destination =
                          await searchBloc.getCoorsStartToEnd(start, end);

                      await mapBloc.drawRoutePolyline(destination);

                      // Desactivamos la barra para la seleccion manual del destino
                      searchBloc.add(OnDeactivateManualMarkerEvent());

                      Navigator.pop(context);
                    },
                  ),
                ))
          ],
        ));
  }
}
