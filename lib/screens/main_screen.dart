import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'news_screen.dart';
import 'about_screen.dart';
import '../utils/responsive_helper.dart';
import '../core/theme/app_colors.dart';
import '../utils/version_checker.dart';

enum NavigationType { bottom, rail }

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  late List<Widget> _screens;
  late List<NavigationItem> _navigationItems;

  final analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    super.initState();
    // Verificar versión después de que la pantalla esté lista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          VersionChecker.checkVersion();
        }
      });
    });
    analytics.logScreenView(screenName: 'main', screenClass: 'MainScreen');

    _screens = const [NewsScreen(), AboutScreen()];

    _navigationItems = [
      NavigationItem(
        icon: Icons.article_outlined,
        selectedIcon: Icons.article,
        label: 'Noticias',
        tooltip: 'Últimas noticias',
      ),
      NavigationItem(
        icon: Icons.info_outline,
        selectedIcon: Icons.info,
        label: 'Nosotros',
        tooltip: 'Información de la app',
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) => setState(() => _currentIndex = index);

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final useNavigationRail = responsive.useNavigationRail;

    return Scaffold(
      backgroundColor: AppColors.background, // ✅ Fondo unificado
      body: Row(
        children: [
          if (useNavigationRail) _buildNavigationRail(responsive),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: responsive.isAutomotive
                  ? const NeverScrollableScrollPhysics()
                  : const AlwaysScrollableScrollPhysics(),
              children: _screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: useNavigationRail
          ? null
          : _buildBottomNavigationBar(responsive),
    );
  }

  /// -------------------------------------------
  /// NAVIGATION RAIL (Tablet / Desktop)
  /// -------------------------------------------
  Widget _buildNavigationRail(ResponsiveHelper responsive) {
    final railWidth = responsive.getValue(
      phone: 72.0,
      tablet: 200.0,
      desktop: 240.0,
      automotive: 180.0,
    );

    final iconSize = responsive.getValue(
      phone: 24.0,
      largePhone: 26.0,
      tablet: 28.0,
      desktop: 32.0,
      automotive: 32.0,
    );

    final labelTextSize = responsive.getValue(
      phone: 12.0,
      largePhone: 13.0,
      tablet: 14.0,
      desktop: 16.0,
      automotive: 16.0,
    );

    final isExtended =
        responsive.isAutomotive ||
        responsive.isLargeTablet ||
        responsive.isDesktop;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface, // ✅ Usa el color de superficie
        border: Border(
          right: BorderSide(
            color: AppColors.textSecondary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        boxShadow: responsive.isAutomotive
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(2, 0),
                ),
              ]
            : null,
      ),
      child: NavigationRail(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabTapped,
        extended: isExtended,
        minExtendedWidth: railWidth,
        minWidth: responsive.getValue(
          phone: 72.0,
          tablet: 80.0,
          automotive: 90.0,
        ),
        labelType: isExtended ? null : NavigationRailLabelType.none,
        backgroundColor: Colors.transparent,
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
        selectedIconTheme: IconThemeData(
          size: iconSize,
          color: AppColors.primary, // ✅ Color principal marca
        ),
        unselectedIconTheme: IconThemeData(
          size: iconSize * 0.9,
          color: AppColors.textSecondary, // ✅ Color texto secundario
        ),
        selectedLabelTextStyle: TextStyle(
          fontSize: labelTextSize,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
        unselectedLabelTextStyle: TextStyle(
          fontSize: labelTextSize * 0.9,
          fontWeight: FontWeight.normal,
          color: AppColors.textSecondary,
        ),
        destinations: _navigationItems.map((item) {
          return NavigationRailDestination(
            icon: Tooltip(message: item.tooltip, child: Icon(item.icon)),
            selectedIcon: Tooltip(
              message: item.tooltip,
              child: Icon(item.selectedIcon),
            ),
            label: Text(item.label),
            padding: EdgeInsets.symmetric(
              vertical: responsive.getValue(
                phone: 8.0,
                tablet: 12.0,
                automotive: 16.0,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// -------------------------------------------
  /// BOTTOM NAVIGATION BAR (Móvil / Vertical)
  /// -------------------------------------------
  Widget _buildBottomNavigationBar(ResponsiveHelper responsive) {
    final iconSize = responsive.getValue(
      smallPhone: 22.0,
      phone: 24.0,
      largePhone: 26.0,
      tablet: 28.0,
    );

    final fontSize = responsive.getValue(
      smallPhone: 11.0,
      phone: 12.0,
      largePhone: 13.0,
      tablet: 14.0,
    );

    final elevation = responsive.getValue(phone: 8.0, tablet: 12.0);

    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _onTabTapped,
      type: BottomNavigationBarType.fixed,
      enableFeedback: true,
      elevation: elevation,
      iconSize: iconSize,
      backgroundColor: AppColors.surface, // ✅ usa surface
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      selectedIconTheme: IconThemeData(size: iconSize),
      unselectedIconTheme: IconThemeData(size: iconSize * 0.9),
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: fontSize,
        color: AppColors.primary,
      ),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: fontSize * 0.85,
        color: AppColors.textSecondary,
      ),
      items: _navigationItems.map((item) {
        return BottomNavigationBarItem(
          icon: Tooltip(
            message: item.tooltip,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: responsive.getValue(
                  phone: 4.0,
                  largePhone: 6.0,
                  tablet: 8.0,
                ),
              ),
              child: Icon(item.icon),
            ),
          ),
          activeIcon: Tooltip(
            message: item.tooltip,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: responsive.getValue(
                  phone: 4.0,
                  largePhone: 6.0,
                  tablet: 8.0,
                ),
              ),
              child: Icon(item.selectedIcon),
            ),
          ),
          label: item.label,
          tooltip: '',
        );
      }).toList(),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String tooltip;

  NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.tooltip,
  });
}
