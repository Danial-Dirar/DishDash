import 'package:dish_dash/screens/signup_choice_screen.dart';
import 'package:dish_dash/screens/register_user_screen.dart';
import 'package:dish_dash/screens/register_company_screen.dart';
import 'package:dish_dash/screens/user/user_dashboard_screen.dart';
import 'package:dish_dash/screens/user/offer_list_screen.dart';
import 'package:dish_dash/screens/user/offer_detail_screen.dart';
import 'package:dish_dash/screens/user/restaurant_detail_screen.dart';
import 'package:dish_dash/screens/company/company_dashboard_screen.dart';
import 'package:dish_dash/screens/company/post_offer_screen.dart';
import 'package:dish_dash/screens/company/edit_company_info_screen.dart';
import 'package:dish_dash/screens/company/my_posts_screen.dart';
import 'package:dish_dash/screens/company/menu_screen.dart';
import 'package:dish_dash/screens/forgot_password_screen.dart';
import 'package:dish_dash/screens/coming_soon_screen.dart';
import 'package:dish_dash/screens/auth_gate.dart';
import 'package:dish_dash/services/theme_notifier.dart';
import 'package:dish_dash/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dish_dash/screens/signin_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dish_dash/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const DishDashApp());
}

class DishDashApp extends StatelessWidget {
  const DishDashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'DishDash',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                primary: AppColors.primary,
              ),
              scaffoldBackgroundColor: const Color(0xFFF6F7F9),
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                brightness: Brightness.dark,
              ),
              scaffoldBackgroundColor: const Color(0xFF121212),
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
            themeMode: themeNotifier.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const AuthGate(),
            routes: {
              // Authentication routes
              '/signin': (context) => const SigninScreen(),
              '/signupchoice': (context) => const SignupChoiceScreen(),
              '/registeruser': (context) => const RegisterUserScreen(),
              '/registercompany': (context) => const RegisterCompanyScreen(),
              '/forgot-password': (context) => const ForgotPasswordScreen(),

              // User routes
              '/user-dashboard': (context) => const UserDashboardScreen(),
              '/guest': (context) => const UserDashboardScreen(),
              '/offers': (context) => const OfferListScreen(),
              '/saved-offers': (context) => const OfferListScreen(),
              '/restaurant-detail': (context) => const RestaurantDetailScreen(),
              '/offer-detail': (context) => const OfferDetailScreen(),

              // Company routes
              '/company-dashboard': (context) =>
                  const CompanyDashboardScreen(),
              '/post-offer': (context) => const PostOfferScreen(),
              '/my-posts': (context) => const MyPostsScreen(),
              '/edit-company-info': (context) => const EditCompanyInfoScreen(),
              '/menu': (context) => const MenuScreen(),

              // Aliases used by the app drawer / other screens (kept so their
              // navigation targets resolve to the correct existing screens).
              '/savedoffers': (context) => const OfferListScreen(),
              '/postoffer': (context) => const PostOfferScreen(),
              '/myposts': (context) => const MyPostsScreen(),
              '/editcompanyinfo': (context) => const EditCompanyInfoScreen(),
            },
            // Any route that is referenced but not yet implemented (Settings,
            // Help, Analytics, Search, Profile, etc.) resolves to a friendly
            // "Coming soon" screen instead of crashing the app.
            onUnknownRoute: (settings) => MaterialPageRoute(
              builder: (_) => ComingSoonScreen(
                title: ComingSoonScreen.titleFromRoute(settings.name),
              ),
            ),
          );
        },
      ),
    );
  }
}
