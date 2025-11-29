import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'auth/controller/auth_controller.dart';
import 'auth/view/splash_screen.dart';
import 'auth/view/auth_view.dart';
import 'auth/view/signup_view.dart';
import 'views/dashboard_screen.dart';
import 'utils/constants.dart';
import 'RAN/controller/ran_controller.dart';
import 'RAN/controller/ran_profile_controller.dart';
import 'RAN/controller/ran_bot_contoller.dart';
import 'RAN/view/ran_dashboard_screen.dart';
import 'RAN/view/ran_map_screen.dart';
import 'RAN/view/ran_analytics_screen.dart';
import 'RAN/view/ran_bts_list_screen.dart';
import 'RAN/view/ran_bts_detail_screen.dart';
import 'RAN/view/ran_alerts_screen.dart';
import 'RAN/view/ran_profile_screen.dart';
import 'RAN/view/ran_bot_view.dart';
import 'CORE/controller/core_controller.dart';
import 'CORE/controller/core_profile_controller.dart';
import 'CORE/controller/core_bot_controller.dart';
import 'CORE/view/core_dashboard_screen.dart';
import 'CORE/view/core_topology_screen.dart';
import 'CORE/view/core_elements_list_screen.dart';
import 'CORE/view/core_element_detail_screen.dart';
import 'CORE/view/core_analytics_screen.dart';
import 'CORE/view/core_services_screen.dart';
import 'CORE/view/core_profile_screen.dart';
import 'CORE/view/core_bot_screen.dart';
import 'IP/controller/ip_controller.dart';
import 'IP/controller/ip_bot_controller.dart';
import 'IP/view/ip_dashboard_screen.dart';
import 'IP/view/ip_topology_screen.dart';
import 'IP/view/ip_links_screen.dart';
import 'IP/view/ip_monitoring_screen.dart';
import 'IP/view/ip_alerts_screen.dart';
import 'IP/view/ip_bot_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => RANController()),
        ChangeNotifierProvider(create: (_) => RANProfileController()),
        ChangeNotifierProvider(create: (_) => RANBotController()),
        ChangeNotifierProvider(create: (_) => CoreController()),
        ChangeNotifierProvider(create: (_) => CoreProfileController()),
        ChangeNotifierProvider(create: (_) => CoreBotController()),
        ChangeNotifierProvider(create: (_) => IPController()),
        ChangeNotifierProvider(create: (_) => IPBotController()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: DarkThemeColors.background,
          colorScheme: ColorScheme.dark(
            primary: DarkThemeColors.primary,
            secondary: DarkThemeColors.accent,
            surface: DarkThemeColors.cardBackground,
            error: DarkThemeColors.error,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: DarkThemeColors.textPrimary,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(
            ThemeData.dark().textTheme.copyWith(
              bodyLarge: TextStyle(color: DarkThemeColors.textPrimary),
              bodyMedium: TextStyle(color: DarkThemeColors.textPrimary),
              bodySmall: TextStyle(color: DarkThemeColors.textSecondary),
              titleLarge: TextStyle(
                color: DarkThemeColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              titleMedium: TextStyle(
                color: DarkThemeColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              titleSmall: TextStyle(color: DarkThemeColors.textSecondary),
            ),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: DarkThemeColors.cardBackground,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: DarkThemeColors.textPrimary,
            ),
            iconTheme: IconThemeData(color: DarkThemeColors.textPrimary),
          ),
          cardTheme: CardThemeData(
            color: DarkThemeColors.cardBackground,
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: DarkThemeColors.border, width: 1),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: DarkThemeColors.primary,
              foregroundColor: Colors.white,
              elevation: 5,
              shadowColor: DarkThemeColors.primary.withOpacity(0.4),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: DarkThemeColors.surfaceElevated,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: DarkThemeColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: DarkThemeColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: DarkThemeColors.primary, width: 2),
            ),
          ),
          dividerTheme: DividerThemeData(
            color: DarkThemeColors.divider,
            thickness: 1,
          ),
        ),
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (context) => const SplashScreen(),
          AppRoutes.login: (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          AppRoutes.adminDashboard: (context) => const DashboardScreen(
            title: 'Admin Dashboard',
            icon: Icons.admin_panel_settings,
            color: DarkThemeColors.errorBright,
          ),
          AppRoutes.ranDashboard: (context) => const RANDashboardScreen(),
          '/ran-map': (context) => const RANMapScreen(),
          '/ran-analytics': (context) => const RANAnalyticsScreen(),
          '/ran-bts-list': (context) => const RANBTSListScreen(),
          '/ran-bts-detail': (context) => const RANBTSDetailScreen(),
          '/ran-alerts': (context) => const RANAlertsScreen(),
          '/ran-profile': (context) => const RANProfileScreen(),
          '/ran-bot': (context) => const RANBotView(),
          AppRoutes.coreDashboard: (context) => const CoreDashboardScreen(),
          '/core-topology': (context) => const CoreTopologyScreen(),
          '/core-elements-list': (context) => const CoreElementsListScreen(),
          '/core-element-detail': (context) => const CoreElementDetailScreen(),
          '/core-analytics': (context) => const CoreAnalyticsScreen(),
          '/core-services': (context) => const CoreServicesScreen(),
          '/core-profile': (context) => const CoreProfileScreen(),
          '/core-bot': (context) => const CoreBotScreen(),
          AppRoutes.ipDashboard: (context) => const IPDashboardScreen(),
          '/ip-topology': (context) => const IPTopologyScreen(),
          '/ip-links': (context) => const IPLinksScreen(),
          '/ip-monitoring': (context) => const IPMonitoringScreen(),
          '/ip-alerts': (context) => const IPAlertsScreen(),
          '/ip-bot': (context) => const IPBotScreen(),
          AppRoutes.nocDashboard: (context) => const DashboardScreen(
            title: 'NOC Dashboard',
            icon: Icons.monitor_heart,
            color: DarkThemeColors.chartPink,
          ),
          AppRoutes.analystDashboard: (context) => const DashboardScreen(
            title: 'Network Analyst Dashboard',
            icon: Icons.analytics,
            color: DarkThemeColors.accentLight,
          ),
        },
      ),
    );
  }
}
