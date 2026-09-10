import 'package:flutter/material.dart';
import 'services/api.dart';
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
import 'screens/voice_room_screen.dart';
import 'screens/room_settings_screen.dart';
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
import 'screens/popular_rooms_screen.dart';
import 'screens/love_house_screen.dart';
import 'screens/cp_level_screen.dart';
import 'screens/svip_detail_screen.dart';
import 'screens/badges_screen.dart';
import 'screens/dm_chat_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/report_screen.dart';
import 'screens/room_theme_screen.dart';
import 'screens/tournament_bracket_screen.dart';
import 'screens/clan_war_screen.dart';
import 'screens/season_screen.dart';
import 'screens/live_stream_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/search_screen.dart';
import 'screens/leaderboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Api.init();
  runApp(const HayiDevApp());
}

class HayiDevApp extends StatelessWidget {
  const HayiDevApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HayiDev',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E27),
        primaryColor: const Color(0xFFFFC107),
      ),
      initialRoute: Api.hasToken() ? '/home' : '/',
      routes: {
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
        '/popular-rooms': (_) => const PopularRoomsScreen(),
        '/love-house': (_) => const LoveHouseScreen(),
        '/cp-level': (_) => const CpLevelScreen(),
        '/svip-detail': (_) => const SvipDetailScreen(),
        '/badges': (_) => const BadgesScreen(),
        '/shop': (_) => const ShopScreen(),
        '/search': (_) => const SearchScreen(),
        '/leaderboard': (_) => const LeaderboardScreen(),
      },
    );
  }
}
