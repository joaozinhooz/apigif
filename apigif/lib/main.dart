import 'dart:convert';
import 'package:api_gif/src/models/gif.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart'; // Importando o pacote share

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: HomePage(),
      ),
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black, // Definindo o fundo preto para todo o aplicativo
      ),
    );
  }
}

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
    appBar: AppBar(
      title: Text(
        'Lista dos Gifs mais usados | -> Dev (oJoaozinhooz)',
        style: TextStyle(color: Colors.white), // Definir a cor do texto
      ),
      backgroundColor: Colors.black,
    ),
    body: FutureBuilder(
      future: _listGifs,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Gif> notNull = snapshot.data!;

            return GridView.count(
              crossAxisCount: 2,
              children: _listWidgetGifs(context, notNull),
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

  List<Widget> _listWidgetGifs(BuildContext context, List<Gif> data) {
    List<Widget> gifs = [];

    for (var gif in data) {
      gifs.add(
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GifPage(gifUrl: gif.url),
              ),
            );
          },
          child: Card(
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
        ),
      );
    }

    return gifs;
  }
}

class GifPage extends StatelessWidget {
  final String gifUrl;

  const GifPage({required this.gifUrl});

  // Função para compartilhar o GIF
  void _shareGif(BuildContext context) {
    Share.share(gifUrl);
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('GIF'),
      backgroundColor: Colors.black,
      iconTheme: IconThemeData(color: Colors.white), // Definir a cor do ícone de compartilhamento
      actions: [
        IconButton(
          icon: Icon(Icons.share),
          onPressed: () {
            _shareGif(context);
          },
        ),
      ],
    ),
    body: Center(
      child: Image.network(
        gifUrl,
        fit: BoxFit.contain,
      ),
    ),
  );
}
}