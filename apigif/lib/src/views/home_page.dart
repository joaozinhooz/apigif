import 'dart:convert';

import 'package:api_gif/src/models/gif.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var uri = Uri.https('api.giphy.com', '/v1/gifs/trending', {
    'api_key': '8pKaUjc63tCIpLowIrnIVT7GnmBbzqSC',
    'limit': '20',
    'rating': 'g'
  });

  Future<List<Gif>>? _listGifs;

  Future<List<Gif>> _getGifs() async {
    print(uri);
    final response = await http.get(uri);

    List<Gif> gifs = [];

    if (response.statusCode == 200) {
      String body = utf8.decoder.convert(response.bodyBytes);
      final jsonData = jsonDecode(body);

      for (var item in jsonData['data']) {
        gifs.add(
          Gif(item['title'], item['images']['downsized']['url']),
        );
      }

      return gifs;
    } else {
      throw Exception('Fallo la conexion');
    }
  }

  @override
  void initState() {
    super.initState();
    _listGifs = _getGifs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Top Gifs'), backgroundColor: Colors.black,),
      body: FutureBuilder(
        
        future: _listGifs,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Gif> notNull = snapshot.data!;

            return GridView.count(
              crossAxisCount: 2,
              children: _listWidgetGifs(notNull),
            );
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return Text('Error');
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  List<Widget> _listWidgetGifs(List<Gif> data) {
    List<Widget> gifs = [];

    for (var gif in data) {
      gifs.add(
        Card(
          child: Column(
            children: [
              Expanded(
                child: Image.network(
                  gif.url,
                  fit: BoxFit.fill,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return gifs;
  }
}
