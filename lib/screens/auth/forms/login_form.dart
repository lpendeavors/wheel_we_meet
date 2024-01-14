import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';
import '../../map/map.dart';
import '../forgot_password.dart';
import '../register.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  @override
  Widget build(BuildContext context) {
    final loginBloc = BlocProvider.of<LoginBloc>(context);

    onLoginButtonPressed() {
      loginBloc.add(LoginButtonPressed());
    }

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is LoginSuccess) {
          Navigator.of(context).pushReplacementNamed(
            MapScreen.routeName,
          );
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return Form(
            child: Column(
              children: [
                StreamBuilder<String>(
                  stream: loginBloc.email,
                  builder: (context, snapshot) {
                    return TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        errorText: snapshot.error?.toString(),
                      ),
                      onChanged: loginBloc.changeEmail,
                    );
                  },
                ),
                StreamBuilder<String>(
                  stream: loginBloc.password,
                  builder: (context, snapshot) {
                    return TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        errorText: snapshot.error?.toString(),
                      ),
                      obscureText: true,
                      onChanged: loginBloc.changePassword,
                    );
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        ForgotPasswordScreen.routeName,
                      );
                    },
                    child: Text('Forgot Password?'),
                  ),
                ),
                StreamBuilder<bool>(
                  stream: loginBloc.submitValid,
                  builder: (context, snapshot) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      onPressed:
                          snapshot.data == true ? onLoginButtonPressed : null,
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                if (state is LoginLoading) const CircularProgressIndicator(),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Need an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            RegisterScreen.routeName,
                          );
                        },
                        child: Text('Sign Up'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
