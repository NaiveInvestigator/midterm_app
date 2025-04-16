import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Entity {
  final int id;
  final String title;
  final String lat;
  final String lon;
  final String image;

  Entity({
    required this.id,
    required this.title,
    required this.lat,
    required this.lon,
    required this.image,
  });

  factory Entity.fromJson(Map<String, dynamic> json) {
    return Entity(
      id: json['id'],
      title: json['title'],
      lat: json['lat'].toString(),
      lon: json['lon'].toString(),
      image: json['image'],
    );
  }
}

class EntityListScreen extends StatefulWidget {
  @override
  _EntityListScreenState createState() => _EntityListScreenState();
}

class _EntityListScreenState extends State<EntityListScreen> {
  late Future<List<Entity>> _entities;

  Future<List<Entity>> fetchEntities() async {
    final response = await http.get(
      Uri.parse('https://labs.anontech.info/cse489/t3/api.php'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Entity.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load entities');
    }
  }

  @override
  void initState() {
    super.initState();
    _entities = fetchEntities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Entity>>(
        future: _entities,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data found.'));
          }

          final entities = snapshot.data!;

          return ListView.builder(
            itemCount: entities.length,
            itemBuilder: (context, index) {
              final entity = entities[index];
              final imageUrl =
                  'https://labs.anontech.info/cse489/t3/${entity.image}';

              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/placeholder.jpg',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                title: Text("[ID: ${entity.id}] ${entity.title}"),
                subtitle: Text('Lat: ${entity.lat}\nLon: ${entity.lon}'),
              );
            },
          );
        },
      ),
    );
  }
}
