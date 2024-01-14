import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../repositories/user_repository.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final UserRepository userRepository;

  final _nameController = BehaviorSubject<String>();
  final _emailController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();

  Function(String) get changeName => _nameController.sink.add;
  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;

  Stream<String> get name => _nameController.stream;
  Stream<String> get email => _emailController.stream;
  Stream<String> get password => _passwordController.stream;

  Stream<bool> get submitValid => Rx.combineLatest3(
        name,
        email,
        password,
        (n, e, p) => true,
      );

  RegisterBloc({required this.userRepository}) : super(RegisterInitial()) {
    on<RegisterButtonPressed>(_onRegisterButtonPressed);
  }

  void _onRegisterButtonPressed(
    RegisterButtonPressed event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterLoading());
    try {
      await userRepository.register(
        name: _nameController.value,
        email: _emailController.value,
        password: _passwordController.value,
      );
      emit(RegisterSuccess());
    } catch (e) {
      emit(RegisterFailure(error: e.toString()));
    }
  }

  final validateName = StreamTransformer<String, String>.fromHandlers(
    handleData: (name, sink) {
      final nameRegex = RegExp(r'^[A-Za-z]+(?:\s[A-Za-z]+)+$');
      if (name.isEmpty) {
        sink.addError('Name cannot be empty');
      } else if (nameRegex.hasMatch(name) == false) {
        sink.addError('Name must include first and last');
      } else {
        sink.add(name);
      }
    },
  );

  final validateEmail = StreamTransformer<String, String>.fromHandlers(
    handleData: (email, sink) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (email.isEmpty) {
        sink.addError('Email cannot be empty');
      } else if (emailRegex.hasMatch(email) == false) {
        sink.addError('Email must be valid');
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
    _nameController.close();
    _emailController.close();
    _passwordController.close();
    return super.close();
  }
}
