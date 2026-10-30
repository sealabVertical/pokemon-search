import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokémon Finder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const PokemonDetailScreen(),
    );
  }
}

class PokemonDetail {
  final int id;
  final String name;
  final int height;
  final int weight;
  final List<String> abilities;
  final List<String> types;
  final String imageUrl;

  PokemonDetail({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.abilities,
    required this.types,
    required this.imageUrl,
  });

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    return PokemonDetail(
      id: json['id'] as int,
      name: json['name'] as String,
      height: json['height'] as int,
      weight: json['weight'] as int,

      abilities: (json['abilities'] as List)
          .map((item) => item['ability']['name'].toString())
          .toList(),

      types: (json['types'] as List)
          .map((item) => item['type']['name'].toString())
          .toList(),

      imageUrl:
          json['sprites']?['other']?['official-artwork']?['front_default'] ??
          json['sprites']?['front_default'] ??
          '',
    );
  }
}

class PokemonService {
  Future<PokemonDetail> fetchPokemon(String name) async {
    final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/$name');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      return PokemonDetail.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('Pokemon not found!');
    } else {
      throw Exception('Failed to load Pokemon. Please try again.');
    }
  }
}

class PokemonDetailScreen extends StatefulWidget {
  const PokemonDetailScreen({super.key});

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  final TextEditingController _searchController = TextEditingController();

  final PokemonService _pokemonService = PokemonService();

  PokemonDetail? _pokemon;

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _searchPokemon() async {
    final pokemonName = _searchController.text.trim().toLowerCase();

    if (pokemonName.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a Pokémon name.';
        _pokemon = null;
      });
      return;
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _pokemon = null;
    });

    try {
      final result = await _pokemonService.fetchPokemon(pokemonName);

      if (!mounted) return;

      setState(() {
        _pokemon = result;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokémon Search'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Pokémon Name',
                hintText: 'Example: pikachu',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (_) {
                if (!_isLoading) {
                  _searchPokemon();
                }
              },
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _isLoading ? null : _searchPokemon,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Search Pokémon'),
            ),

            const SizedBox(height: 24),

            if (_errorMessage != null)
              Center(
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),

            if (_pokemon != null) _buildPokemonDetails(_pokemon!),
          ],
        ),
      ),
    );
  }

  Widget _buildPokemonDetails(PokemonDetail pokemon) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (pokemon.imageUrl.isNotEmpty)
              Image.network(
                pokemon.imageUrl,
                height: 180,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image_not_supported, size: 100);
                },
              )
            else
              const Icon(Icons.image_not_supported, size: 100),

            const SizedBox(height: 12),

            Text(
              pokemon.name.toUpperCase(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            Text(
              'Pokémon ID: ${pokemon.id}',
              style: const TextStyle(fontSize: 16),
            ),

            const Divider(height: 30),

            _buildInfoRow('Height', '${pokemon.height / 10} m'),

            _buildInfoRow('Weight', '${pokemon.weight / 10} kg'),

            _buildInfoRow('Types', pokemon.types.join(', ')),

            _buildInfoRow('Abilities', pokemon.abilities.join(', ')),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
