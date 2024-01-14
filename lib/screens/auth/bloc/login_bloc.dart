import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';

import 'login_event.dart';
import 'login_state.dart';
import '../../../../repositories/user_repository.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository userRepository;

  final _emailController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();

  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;

  Stream<String> get email => _emailController.stream.transform(
        validateEmail,
      );
  Stream<String> get password => _passwordController.stream.transform(
        validatePassword,
      );

  Stream<bool> get submitValid => Rx.combineLatest2(
        email,
        password,
        (u, p) => true,
      );

  LoginBloc({required this.userRepository}) : super(LoginInitial()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
  }

  Future<void> _onLoginButtonPressed(
    LoginButtonPressed event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      await userRepository.authenticate(
        username: _emailController.value,
        password: _passwordController.value,
      );
      emit(LoginSuccess());
    } catch (error) {
      emit(LoginFailure(error: 'Unable to log in'));
    }
  }

  final validateEmail = StreamTransformer<String, String>.fromHandlers(
    handleData: (email, sink) {
      if (email.isEmpty) {
        sink.addError('Email cannot be empty');
      } else {
        sink.add(email);
      }
    },
  );

  final validatePassword = StreamTransformer<String, String>.fromHandlers(
    handleData: (password, sink) {
      if (password.isEmpty) {
        sink.addError('Password cannot be empty');
      } else {
        sink.add(password);
      }
    },
  );

  @override
  Future<void> close() {
    _emailController.close();
    _passwordController.close();
    return super.close();
  }
}
