import 'package:flutter/material.dart';

// Mapowanie kluczy na ikony Fluttera:
final Map<String, IconData> iconMap = {
  'watering': Icons.water_drop,
  'sunlight': Icons.wb_sunny,
  'fertilizing': Icons.eco,
  'soil': Icons.grass,
  'temperature': Icons.thermostat,
  'humidity': Icons.water,
  'ph': Icons.science,
};

final Map<String, String> nameMap = {
  "commonNames": "Also Known As",
  "family": "Botanical Family",
  "description": "Description",
  "care": "Care Instructions",
  "watering": "Watering Needs",
  "sunlight": "Light Requirements",
  "fertilizing": "Fertilization Schedule",
  "soil": "Soil Type",
  "growth": "Growth Conditions",
  "temperature": "Temperature Range",
  "humidity": "Humidity Requirements",
  "ph": "Soil pH Level",
  "locations": "Native Regions",
};

class PlantDetailsWidget extends StatelessWidget {
  final Map<String, dynamic> plant;

  const PlantDetailsWidget({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    final plantName = plant['name'] ?? 'Unknown Plant';
    final filteredPlant =
        Map.of(plant)
          ..remove('id')
          ..remove('name');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _capitalize(plantName),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),

          ...filteredPlant.entries.map<Widget>((entry) {
            final key = entry.key;
            final value = entry.value;
            if (value is Map<String, dynamic>) {
              // Podmapa - pokaż jako lista z ikonami
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _capitalize(nameMap[key] ?? key) + ':',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...value.entries.map((subEntry) {
                      final icon = iconMap[subEntry.key];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (icon != null)
                              Icon(icon, size: 20, color: Colors.green),
                            if (icon != null) const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: [
                                    TextSpan(
                                      text:
                                          '${_capitalize(nameMap[subEntry.key] ?? subEntry.key)}: ',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(text: subEntry.value.toString()),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            } else if (value is List) {
              // Lista - pokaż jako tekst rozdzielony przecinkami
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: _capitalize(nameMap[key] ?? key) + ': ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(text: value.join(', ')),
                    ],
                  ),
                ),
              );
            } else {
              // Prosta wartość
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: _capitalize(nameMap[key] ?? key) + ': ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(text: value.toString()),
                    ],
                  ),
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
