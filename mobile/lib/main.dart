import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/api.dart';
import 'services/socket.dart';
import 'services/offline_cache.dart';

import 'widgets/app_theme.dart';
import 'widgets/theme_provider.dart';
import 'widgets/feedback_service.dart';

import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/social_login_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/games_screen.dart';
import 'screens/gifts_screen.dart';
import 'screens/vip_screen.dart';
import 'screens/invite_screen.dart';
import 'screens/clans_screen.dart';
import 'screens/wheel_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/friends_screen.dart';
import 'screens/posts_screen.dart';
import 'screens/tournaments_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/svip_screen.dart';
import 'screens/jackaroo_screen.dart';
import 'screens/rocket_game_screen.dart';
import 'screens/events_screen.dart';
import 'screens/umo_screen.dart';
import 'screens/domino_screen.dart';
import 'screens/ludo_screen.dart';
import 'screens/carrom_screen.dart';
import 'screens/roulette_screen.dart';
import 'screens/slot_screen.dart';
import 'screens/dragon_tiger_screen.dart';
import 'screens/teen_patti_screen.dart';
import 'screens/collection_screen.dart';
import 'screens/nameplate_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/live_stream_screen.dart';
import 'screens/season_screen.dart';
import 'screens/bingo_screen.dart';
import 'screens/football_king_screen.dart';
import 'screens/profile_visitors_screen.dart';
import 'screens/group_chat_screen.dart';
import 'screens/story_screen.dart';
import 'screens/svip_tiers_screen.dart';
import 'screens/gift_box_screen.dart';
import 'screens/flash_sale_screen.dart';
import 'screens/daily_rewards_screen.dart';
import 'screens/coupon_screen.dart';
import 'screens/search_users_screen.dart';
import 'screens/forgot_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Api.init();
  await OfflineCache.init();
  await FeedbackService.init();

  final themeProvider = ThemeProvider();
  await themeProvider.init();

  try {
    final token = await Api.getToken();
    if (token != null) {
      SocketService.connect(token);
    }
  } catch (_) {}

  runApp(
    ChangeNotifierProvider<ThemeProvider>.value(
      value: themeProvider,
      child: const HayiDevApp(),
    ),
  );
}

class HayiDevApp extends StatelessWidget {
  const HayiDevApp({super.key});

  @override
  Widget build(BuildContext context) {
    final tp = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Hayi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: tp.mode,
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/onboarding': (_) => OnboardingScreen(
              onComplete: () => Navigator.pushReplacementNamed(context, '/'),
            ),
        '/': (_) => const SocialLoginScreen(),
        '/email-login': (_) => const LoginScreen(),
        '/home': (_) => const HomeScreen(),
        '/games': (_) => const GamesScreen(),
        '/gifts': (_) => const GiftsScreen(),
        '/vip': (_) => const VipScreen(),
        '/invite': (_) => const InviteScreen(),
        '/clans': (_) => const ClansScreen(),
        '/wheel': (_) => const WheelScreen(),
        '/notifications': (_) => const NotificationsScreen(),
        '/friends': (_) => const FriendsScreen(),
        '/posts': (_) => const PostsScreen(),
        '/tournaments': (_) => const TournamentsScreen(),
        '/edit-profile': (_) => const EditProfileScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/wallet': (_) => const WalletScreen(),
        '/svip': (_) => const SvipScreen(),
        '/jackaroo': (_) => const JackarooScreen(),
        '/rocket': (_) => const RocketGameScreen(),
        '/events': (_) => const EventsScreen(),
        '/umo': (_) => const UmoScreen(),
        '/domino': (_) => const DominoScreen(),
        '/ludo': (_) => const LudoScreen(),
        '/carrom': (_) => const CarromScreen(),
        '/roulette': (_) => const RouletteScreen(),
        '/slot': (_) => const SlotScreen(),
        '/dragon-tiger': (_) => const DragonTigerScreen(),
        '/teen-patti': (_) => const TeenPattiScreen(),
        '/collection': (_) => const CollectionScreen(),
        '/nameplate': (_) => const NameplateScreen(),
        '/shop': (_) => const ShopScreen(),
        '/live': (_) => const LiveStreamScreen(),
        '/season': (_) => const SeasonScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/search-users': (_) => const SearchUsersScreen(),
        '/coupon': (_) => const CouponScreen(),
        '/daily-rewards': (_) => const DailyRewardsScreen(),
        '/flash-sale': (_) => const FlashSaleScreen(),
        '/gift-box': (_) => const GiftBoxScreen(),
        '/svip-tiers': (_) => const SvipTiersScreen(),
        '/story': (_) => const StoryScreen(),
        '/groups': (_) => const GroupChatScreen(),
        '/profile-visitors': (_) => const ProfileVisitorsScreen(),
      },
    );
  }
}
