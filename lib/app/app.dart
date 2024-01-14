import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../repositories/repositories.dart';
import '../screens/auth/bloc/login_bloc.dart';
import '../screens/auth/bloc/register_bloc.dart';
import '../screens/auth/forgot_password.dart';
import '../screens/auth/login.dart';
import '../screens/auth/register.dart';
import '../screens/chat/bloc/conversation_cubit.dart';
import '../screens/chat/conversation_list.dart';
import '../screens/chat/conversation.dart';
import '../screens/friends/bloc/friends_cubit.dart';
import '../screens/friends/friends.dart';
import '../screens/group/bloc/group_cubit.dart';
import '../screens/group/create_group.dart';
import '../screens/group/search_groups.dart';
import '../screens/map/bloc/map_cubit.dart';
import '../screens/map/map.dart';
import '../screens/search/bloc/search_cubit.dart';
import '../screens/search/search.dart';
import '../screens/places/places.dart';
import '../screens/settings/settings.dart';
import 'auth_wrapper.dart';
import 'bloc/auth_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => AuthenticationBloc(
          userRepository: GetIt.I.get<UserRepository>(),
        ),
        child: const AuthenticationWrapper(),
      ),
      routes: {
        LoginScreen.routeName: (context) => BlocProvider(
              create: (context) => LoginBloc(
                userRepository: GetIt.I.get<UserRepository>(),
              ),
              child: const LoginScreen(),
            ),
        RegisterScreen.routeName: (context) => BlocProvider(
              create: (context) => RegisterBloc(
                userRepository: GetIt.I.get<UserRepository>(),
              ),
              child: const RegisterScreen(),
            ),
        ForgotPasswordScreen.routeName: (context) =>
            const ForgotPasswordScreen(),
        MapScreen.routeName: (context) => BlocProvider(
              create: (context) => MapCubit(
                routeRepository: GetIt.I.get<RouteRepository>(),
                userRepository: GetIt.I.get<UserRepository>(),
                geoRepository: GetIt.I.get<GeoRepository>(),
              ),
              child: const MapScreen(),
            ),
        SettingsScreen.routeName: (context) => const SettingsScreen(),
        FriendsScreen.routeName: (context) => BlocProvider(
              create: (context) => FriendsCubit(
                userRepository: GetIt.I.get<UserRepository>(),
              ),
              child: const FriendsScreen(),
            ),
        ChatScreen.routeName: (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final friendId = args?['friendId'] as String?;
          final conversationId = args?['conversationId'] as String?;

          return BlocProvider(
            create: (context) => ConversationCubit(
              friendId: friendId,
              conversationId: conversationId,
              conversationRepository: GetIt.I.get<ConversationRepository>(),
            ),
            child: const ChatScreen(),
          );
        },
        SearchScreen.routeName: (context) => BlocProvider(
              create: (context) => SearchCubit(
                addressRepository: GetIt.I.get<AddressRepository>(),
              ),
              child: const SearchScreen(),
            ),
        PlacesScreen.routeName: (context) => const PlacesScreen(),
        ConversationScreen.routeName: (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final friendId = args?['friendId'] as String?;
          final conversationId = args?['conversationId'] as String?;

          return BlocProvider(
            create: (context) => ConversationCubit(
              friendId: friendId,
              conversationId: conversationId,
              conversationRepository: GetIt.I.get<ConversationRepository>(),
            ),
            child: const ConversationScreen(),
          );
        },
        CreateGroupScreen.routeName: (context) => BlocProvider<GroupCubit>(
              create: (context) => GroupCubit(
                userRepository: GetIt.I.get<UserRepository>(),
                conversationRepository: GetIt.I.get<ConversationRepository>(),
              ),
              child: const CreateGroupScreen(),
            ),
        SearchGroupsScreen.routeName: (context) => BlocProvider<GroupCubit>(
              create: (context) => GroupCubit(
                userRepository: GetIt.I.get<UserRepository>(),
                conversationRepository: GetIt.I.get<ConversationRepository>(),
              ),
              child: const SearchGroupsScreen(),
            ),
      },
    );
  }
}
