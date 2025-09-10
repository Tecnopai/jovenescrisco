import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';

/// Elimina etiquetas HTML simples para mostrar títulos o resúmenes
String stripHtml(String? html) {
  if (html == null) return '';
  return html
      .replaceAll(RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false), '')
      .replaceAll('&nbsp;', ' ')
      .trim();
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 👇 Configuración de la barra superior (hora, señal, batería)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white, // Fondo blanco
      statusBarIconBrightness:
          Brightness.dark, // Iconos oscuros (hora, batería, señal)
    ),
  );

  runApp(MyApp());
}

const String siteBase = 'https://www.jovenescristianos.co';
const String postsEndpoint = '$siteBase/wp-json/wp/v2/posts';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jóvenes Cristianos',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // Mostramos el Splash primero
    );
  }
}

/// --- SPLASH SCREEN ---
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Esperamos 3 segundos antes de pasar a HomeChooser
    Timer(const Duration(seconds: 3), () {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => HomeChooser()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco o azul según tu diseño
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo de Jóvenes Cristianos
            Image.asset(
              "assets/logo.png", // asegúrate de tener este archivo en assets
              width: 180,
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(color: Colors.blue),
          ],
        ),
      ),
    );
  }
}

/// --- CHEQUEA DISPONIBILIDAD API ---
class HomeChooser extends StatefulWidget {
  @override
  _HomeChooserState createState() => _HomeChooserState();
}

class _HomeChooserState extends State<HomeChooser> {
  Future<bool>? _apiAvailable;

  @override
  void initState() {
    super.initState();
    _apiAvailable = _checkApi();
  }

  Future<bool> _checkApi() async {
    try {
      final resp = await http.get(Uri.parse('$postsEndpoint?per_page=1'));
      if (resp.statusCode == 200) return true;
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _apiAvailable,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final apiOn = snap.data ?? false;
        return MainTabs(apiAvailable: apiOn);
      },
    );
  }
}

/// --- PESTAÑAS PRINCIPALES ---
class MainTabs extends StatefulWidget {
  final bool apiAvailable;
  MainTabs({required this.apiAvailable});

  @override
  _MainTabsState createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = <Widget>[
      widget.apiAvailable ? PostsPage() : WebSitePage(),
      WebSitePage(),
    ];

    return Scaffold(
      body: tabs[_index],
      /*bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.article), label: "Noticias"),
          BottomNavigationBarItem(icon: Icon(Icons.web), label: "Web"),
        ],
        onTap: (i) => setState(() => _index = i),
      ),*/
    );
  }
}

/// --- EJEMPLO DE PÁGINA WEBVIEW ---
class WebSitePage extends StatelessWidget {
  const WebSitePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(siteBase));

    return Scaffold(
      body: SafeArea(
        // 👈 Esto evita que el WebView tape la hora/señal/batería
        child: WebViewWidget(controller: controller),
      ),
    );
  }
}

/// --- EJEMPLO DE POSTS ---
class PostsPage extends StatelessWidget {
  const PostsPage({Key? key}) : super(key: key);

  Future<List<dynamic>> _fetchPosts() async {
    final resp = await http.get(Uri.parse('$postsEndpoint?per_page=10'));
    if (resp.statusCode == 200) {
      return json.decode(resp.body);
    } else {
      throw Exception("Error al cargar posts");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _fetchPosts(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final posts = snap.data!;
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, i) {
            final title = stripHtml(posts[i]["title"]["rendered"]);
            final excerpt = stripHtml(posts[i]["excerpt"]["rendered"]);
            final imageUrl = posts[i]["jetpack_featured_media_url"] ?? "";

            return ListTile(
              leading: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 60,
                      placeholder: (c, _) =>
                          const CircularProgressIndicator(strokeWidth: 2),
                      errorWidget: (c, _, __) => const Icon(Icons.image),
                    )
                  : const Icon(Icons.article),
              title: Text(title),
              subtitle: Text(
                excerpt,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PostDetailPage(
                      title: title,
                      content: posts[i]["content"]["rendered"],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

/// --- DETALLE DE POST ---
class PostDetailPage extends StatelessWidget {
  final String title;
  final String content;

  const PostDetailPage({Key? key, required this.title, required this.content})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white, // 👈 Fondo blanco
        foregroundColor: Colors.black, // 👈 Texto e íconos en negro
        elevation: 1, // 👈 Borde sutil abajo
      ),
      body: SingleChildScrollView(child: Html(data: content)),
    );
  }
}
