import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../map/map.dart';
import '../bloc/register_bloc.dart';
import '../bloc/register_event.dart';
import '../bloc/register_state.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  RegisterFormState createState() => RegisterFormState();
}

class RegisterFormState extends State<RegisterForm> {
  @override
  Widget build(BuildContext context) {
    final registerBloc = BlocProvider.of<RegisterBloc>(context);

    onRegisterButtonPressed() {
      registerBloc.add(RegisterButtonPressed());
    }

    return BlocListener<RegisterBloc, RegisterState>(
      listener: (contaxt, state) {
        if (state is RegisterFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
            ),
          );
        }

        if (state is RegisterSuccess) {
          Navigator.of(context).pushNamed(MapScreen.routeName);
        }
      },
      child: BlocBuilder<RegisterBloc, RegisterState>(
        builder: (context, state) {
          return Form(
            child: Column(
              children: [
                StreamBuilder<String>(
                  stream: registerBloc.name,
                  builder: (context, snapshot) {
                    return TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Name',
                        errorText: snapshot.error?.toString(),
                      ),
                      onChanged: registerBloc.changeName,
                    );
                  },
                ),
                StreamBuilder<String>(
                  stream: registerBloc.email,
                  builder: (context, snapshot) {
                    return TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        errorText: snapshot.error?.toString(),
                      ),
                      onChanged: registerBloc.changeEmail,
                    );
                  },
                ),
                StreamBuilder<String>(
                  stream: registerBloc.password,
                  builder: (context, snapshot) {
                    return TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        errorText: snapshot.error?.toString(),
                      ),
                      obscureText: true,
                      onChanged: registerBloc.changePassword,
                    );
                  },
                ),
                const SizedBox(height: 32),
                StreamBuilder<bool>(
                  stream: registerBloc.submitValid,
                  builder: (context, snapshot) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      onPressed:
                          snapshot.hasData ? onRegisterButtonPressed : null,
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                if (state is RegisterLoading) const CircularProgressIndicator(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Have an account?'),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Login'),
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
