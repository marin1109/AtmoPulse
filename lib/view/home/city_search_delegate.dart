import 'package:flutter/material.dart';

// Importez WeatherService et tout ce dont vous avez besoin
import '../../../services/weather_service.dart';
import '../../../types/common/vs.dart';

class CitySearchDelegate extends SearchDelegate<String> {
  final WeatherService weatherService;

  CitySearchDelegate({required this.weatherService});

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text("Tapez le nom d'une ville..."));
    }
    return FutureBuilder<List<VS>>(
      future: weatherService.fetchCitySuggestions(query),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final suggestions = snapshot.data!;
        if (suggestions.isEmpty) {
          return Center(child: Text("Aucune ville trouvée pour '$query'"));
        }
        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final city = suggestions[index];
            return ListTile(
              title: Text(city.city.value),
              subtitle: Text('${city.region.value}, ${city.country.value}'),
              onTap: () {
                close(context, city.url);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      close(context, query);
    });
    return Container();
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }
}
