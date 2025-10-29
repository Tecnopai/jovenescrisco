import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:flutter/gestures.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../core/theme/app_colors.dart';
import '../utils/responsive_helper.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = 'Cargando...';
  List<Widget> _aboutContent = [];
  bool _isLoadingContent = true;
  final analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    super.initState();
    analytics.logScreenView(screenName: 'about', screenClass: 'AboutScreen');
    _loadVersion();
    _loadAboutContent();
  }

  Future<void> _loadVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _version = packageInfo.version);
    } catch (_) {
      if (!mounted) return;
      setState(() => _version = '2.0.0');
    }
  }

  Future<void> _loadAboutContent() async {
    try {
      final response = await http
          .get(Uri.parse('https://jovenescristianos.co/quienes-somos/'))
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);
        final contentElement =
            document.querySelector('.entry-content') ??
            document.querySelector('article') ??
            document.querySelector('.post-content');

        final responsive = ResponsiveHelper(context);
        final widgets = <Widget>[];

        if (contentElement != null) {
          contentElement.querySelector('h1.entry-title')?.remove();

          for (var element in contentElement.children) {
            final tag = element.localName;
            final text = element.text.trim();
            if (text.isEmpty) continue;

            final header = tag == 'h2' || tag == 'h3' || tag == 'h4';
            if (header) {
              if (widgets.isNotEmpty) {
                widgets.add(SizedBox(height: responsive.spacing(20)));
              }
              widgets.add(
                Text(
                  text,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: responsive.h3,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              );
              widgets.add(SizedBox(height: responsive.spacing(8)));
            } else if (tag == 'p') {
              final spans = <InlineSpan>[];
              _processParagraph(element, spans);
              if (spans.isNotEmpty) {
                widgets.add(
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: responsive.bodyText,
                        color: AppColors.textMuted,
                        height: 1.6,
                        letterSpacing: 0.2,
                      ),
                      children: spans,
                    ),
                  ),
                );
                widgets.add(SizedBox(height: responsive.spacing(10)));
              }
            }
          }
        }

        setState(() {
          _aboutContent = widgets.isEmpty
              ? [const Text('No se pudo cargar el contenido.')]
              : widgets;
          _isLoadingContent = false;
        });
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (_) {
      if (!mounted) return;
      final responsive = ResponsiveHelper(context);
      setState(() {
        _aboutContent = [
          Text(
            'Nos caracterizamos por tener un corazón apasionado por la juventud y sus propósitos en esta tierra; creemos en la unidad del cuerpo de Cristo, es por eso que esta plataforma no solo hace difusión de eventos, noticias, lanzamientos y demás, sino que agrupa a un concilio de iglesias que bajo la sana doctrina propagan el evangelio de Dios.',
            style: TextStyle(
              fontSize: responsive.bodyText,
              color: AppColors.textMuted,
              height: 1.6,
            ),
          ),
        ];
        _isLoadingContent = false;
      });
    }
  }

  void _processParagraph(dom.Element paragraph, List<InlineSpan> spans) {
    for (var node in paragraph.nodes) {
      if (node.nodeType == dom.Node.TEXT_NODE) {
        final text = node.text ?? '';
        if (text.trim().isNotEmpty) spans.add(TextSpan(text: text));
      } else if (node.nodeType == dom.Node.ELEMENT_NODE) {
        final element = node as dom.Element;
        final text = element.text.trim();
        if (text.isEmpty) continue;

        if (element.localName == 'a') {
          final href = element.attributes['href'] ?? '';
          spans.add(
            TextSpan(
              text: text,
              style: const TextStyle(
                color: AppColors.primary,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => _launchUrl(href),
            ),
          );
        } else if (element.localName == 'strong' || element.localName == 'b') {
          spans.add(
            TextSpan(
              text: text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          );
        } else if (element.localName == 'em' || element.localName == 'i') {
          spans.add(
            TextSpan(
              text: text,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          );
        } else {
          _processParagraph(element, spans);
        }
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Nosotros')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(responsive.spacing(20)),
        child: Column(
          children: [
            _buildLogo(responsive),
            SizedBox(height: responsive.spacing(32)),
            _buildTitle(responsive),
            SizedBox(height: responsive.spacing(32)),
            _buildDescriptionCard(responsive),
            SizedBox(height: responsive.spacing(24)),
            _buildInfoCard(responsive, 'Versión', _version),
            SizedBox(height: responsive.spacing(14)),
            _buildWebsiteButton(responsive),
            SizedBox(height: responsive.spacing(14)),
            _buildSupportButton(responsive),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(ResponsiveHelper responsive) {
    final logoSize = responsive.getValue(
      smallPhone: 100.0,
      phone: 120.0,
      largePhone: 130.0,
      tablet: 140.0,
      desktop: 160.0,
      automotive: 130.0,
    );

    return Container(
      width: logoSize,
      height: logoSize,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.logo,
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(76, 247, 247, 248),
            blurRadius: 10,
            spreadRadius: 3,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/logo.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.radio, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildTitle(ResponsiveHelper responsive) => Text(
    'Jóvenes Cristianos Colombia',
    style: TextStyle(
      fontSize: responsive.h1,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
    textAlign: TextAlign.center,
  );

  Widget _buildDescriptionCard(ResponsiveHelper responsive) {
    return Container(
      padding: EdgeInsets.all(responsive.spacing(16)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: _isLoadingContent
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _aboutContent,
            ),
    );
  }

  Widget _buildInfoCard(
    ResponsiveHelper responsive,
    String title,
    String value,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.spacing(16)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF374151).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: responsive.caption,
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: responsive.spacing(4)),
          Text(
            value,
            style: TextStyle(
              fontSize: responsive.bodyText,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebsiteButton(ResponsiveHelper responsive) => _buildButton(
    responsive,
    'Sitio Web',
    Icons.web,
    () => _launchUrl('https://jovenescristianos.co/'),
  );

  Widget _buildSupportButton(ResponsiveHelper responsive) {
    final emailUri = Uri(
      scheme: 'mailto',
      path: 'contacto@jovenescristianos.co',
      query:
          'subject=${Uri.encodeComponent('Consulta desde la app Jóvenes Cristianos Colombia')}&body=${Uri.encodeComponent('Hola, quisiera más información sobre...')}',
    );
    return _buildButton(responsive, 'Soporte app', Icons.email, () async {
      if (await canLaunchUrl(emailUri)) await launchUrl(emailUri);
    });
  }

  Widget _buildButton(
    ResponsiveHelper responsive,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: responsive.bodyText),
      label: Text(label, style: TextStyle(fontSize: responsive.buttonText)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        padding: EdgeInsets.symmetric(
          horizontal: responsive.spacing(24),
          vertical: responsive.spacing(12),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
