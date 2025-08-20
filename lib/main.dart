import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/voting_screen.dart';
import 'screens/vote_confirmation_screen.dart';
import 'screens/results_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/election_provider.dart';

void main() {
  runApp(const EVotingApp());
}

class EVotingApp extends StatelessWidget {
  const EVotingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ElectionProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp.router(
            title: 'E-Voting App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 2,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            routerConfig: _createRouter(authProvider),
          );
        },
      ),
    );
  }

  GoRouter _createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final isLoggedIn = authProvider.isLoggedIn;
        final isAdminLoggedIn = authProvider.isAdminLoggedIn;
        final path = state.matchedLocation;

        // Admin routes
        if (path.startsWith('/admin')) {
          if (!isAdminLoggedIn && path != '/admin/login') {
            return '/admin/login';
          }
          if (isAdminLoggedIn && path == '/admin/login') {
            return '/admin/dashboard';
          }
          return null;
        }

        // User routes
        if (path == '/') {
          return '/splash';
        }

        if (isLoggedIn && (path == '/login' || path == '/register')) {
          return '/home';
        }

        if (!isLoggedIn && !['/login', '/register', '/splash', '/admin/login'].contains(path)) {
          return '/login';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/voting/:electionId',
          builder: (context, state) {
            final electionId = int.parse(state.pathParameters['electionId']!);
            return VotingScreen(electionId: electionId);
          },
        ),
        GoRoute(
          path: '/vote-confirmation',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return VoteConfirmationScreen(
              electionId: extra['electionId'],
              partyId: extra['partyId'],
              partyName: extra['partyName'],
              candidateName: extra['candidateName'],
            );
          },
        ),
        GoRoute(
          path: '/results/:electionId',
          builder: (context, state) {
            final electionId = int.parse(state.pathParameters['electionId']!);
            return ResultsScreen(electionId: electionId);
          },
        ),
        GoRoute(
          path: '/admin/login',
          builder: (context, state) => const AdminLoginScreen(),
        ),
        GoRoute(
          path: '/admin/dashboard',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
      ],
    );
  }
}
