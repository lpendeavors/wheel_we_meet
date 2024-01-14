import 'package:flutter/material.dart';

class AddFriend extends StatefulWidget {
  const AddFriend({super.key});

  @override
  AddFriendState createState() => AddFriendState();
}

class AddFriendState extends State<AddFriend> {
  final TextEditingController _emailController = TextEditingController();
  bool _isEmailValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
  }

  void _validateEmail() {
    setState(() {
      _isEmailValid = RegExp(r'^\S+@\S+\.\S+$').hasMatch(_emailController.text);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Friend'),
      backgroundColor: Colors.white,
      content: TextField(
        controller: _emailController,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Enter email',
        ),
        keyboardType: TextInputType.emailAddress,
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          onPressed: _isEmailValid
              ? () => Navigator.of(context).pop(_emailController.value.text)
              : null,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
