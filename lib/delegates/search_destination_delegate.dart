import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps_app/blocs/blocs.dart';
import 'package:flutter_maps_app/models/responses/places/feature.dart';
import 'package:flutter_maps_app/models/responses/places/places_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/models.dart';

class SearchDestinationDelegate extends SearchDelegate<SearchResult> {
  SearchDestinationDelegate() : super(searchFieldLabel: "Buscar");

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          })
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () {
          final result = SearchResult(cancel: true);
          close(context, result);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    final searchBloc = BlocProvider.of<SearchBloc>(context);
    final locationBloc = BlocProvider.of<LocationBloc>(context);

    final proximity = locationBloc.state.lastKnownLocation!;
    final queryString = Uri.encodeComponent(query);
    searchBloc.getPlacesByQuery(proximity, queryString);

    return BlocBuilder<SearchBloc, SearchState>(builder: (context, state) {
      final places = state.places;
      return placesList(places, searchBloc);
    });
  }

  ListView placesList(List<Feature> places, SearchBloc searchBloc) {
    return ListView.separated(
        itemBuilder: (context, position) {
          final place = places[position];
          return ListTile(
            title: Text(place.text),
            subtitle: Text(place.placeName),
            leading: const Icon(Icons.place_outlined, color: Colors.black),
            onTap: () {
              final result = SearchResult(
                  cancel: false,
                  manual: false,
                  position: LatLng(place.center[1], place.center[0]),
                  name: place.text,
                  description: place.placeName);

              searchBloc.add(OnNewPlaceSelectedEvent(place));

              close(context, result);
            },
          );
        },
        separatorBuilder: (context, position) => const Divider(),
        itemCount: places.length);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final history = BlocProvider.of<SearchBloc>(context).state.history;

    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.place_outlined, color: Colors.black),
          title: const Text('Colocar la ubicación manualmente.'),
          onTap: () {
            final result = SearchResult(cancel: false, manual: true);
            close(context, result);
          },
        ),
        ...history.map((place) => ListTile(
              title: Text(place.text),
              subtitle: Text(place.placeName),
              leading: const Icon(Icons.history, color: Colors.black),
              onTap: () {
                final result = SearchResult(
                    cancel: false,
                    manual: false,
                    position: LatLng(place.center[1], place.center[0]),
                    name: place.text,
                    description: place.placeName);

                close(context, result);
              },
            ))
      ],
    );
  }
}
