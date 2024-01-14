import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';

class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  AuthenticationWrapperState createState() => AuthenticationWrapperState();
}

class AuthenticationWrapperState extends State<AuthenticationWrapper> {
  @override
  void initState() {
    super.initState();
    context.read<AuthenticationBloc>().add(AppStarted());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        Future.delayed(const Duration(seconds: 3), () {
          if (state is AuthenticationAuthenticated) {
            Navigator.of(context).pushReplacementNamed('/map');
          } else {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        });
        return const SplashScreen();
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Welcome to the App!'),
      ),
    );
  }
}
