import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/user_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;

  AuthenticationBloc({required this.userRepository})
      : super(AuthenticationInitial()) {
    // Handle AppStarted event
    on<AppStarted>((event, emit) async {
      try {
        final isSignedIn = await userRepository.isSignedIn();
        if (isSignedIn) {
          emit(AuthenticationAuthenticated());
        } else {
          emit(AuthenticationUnauthenticated());
        }
      } catch (_) {
        emit(AuthenticationFailure(message: 'An unknown error occurred'));
      }
    });

    // Handle LoggedIn event
    on<LoggedIn>((event, emit) {
      emit(AuthenticationAuthenticated());
    });

    // Handle LoggedOut event
    on<LoggedOut>((event, emit) {
      emit(AuthenticationUnauthenticated());
    });
  }
}
