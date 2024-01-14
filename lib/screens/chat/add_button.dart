import 'package:flutter/material.dart';

import '../friends/friend_select.dart';
import '../group/search_groups.dart';
import 'conversation.dart';

class AddButton extends StatefulWidget {
  const AddButton({Key? key}) : super(key: key);

  @override
  AddButtonState createState() => AddButtonState();
}

class AddButtonState extends State<AddButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _translateButton;
  bool isOpened = false;

  @override
  initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(() {
        setState(() {});
      });
    _translateButton = Tween<double>(
      begin: 56.0,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget add() {
    return const FloatingActionButton(
      heroTag: 'addChat',
      elevation: 0,
      backgroundColor: Colors.blue,
      onPressed: null,
      tooltip: 'Add',
      child: Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }

  Widget chatWithFriend() {
    return FloatingActionButton(
      heroTag: 'chatCreate',
      backgroundColor: Colors.blue[100],
      elevation: 0,
      onPressed: () async {
        setState(() {
          isOpened = false;
          _animationController.reverse();
        });
        await showModalBottomSheet<String>(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return FriendSelect(
              onSelected: (id) => Navigator.of(context).pushReplacementNamed(
                ConversationScreen.routeName,
                arguments: {
                  'friendId': id,
                },
              ),
            );
          },
        );
      },
      tooltip: 'Chat with Friend',
      child: const Icon(Icons.person_add),
    );
  }

  Widget createGroup() {
    return FloatingActionButton(
      heroTag: 'groupCreate',
      backgroundColor: Colors.blue[100],
      elevation: 0,
      onPressed: () {
        setState(() {
          isOpened = false;
          _animationController.reverse();
        });
        Navigator.of(context).pushNamed(
          SearchGroupsScreen.routeName,
        );
      },
      tooltip: 'Create Group',
      child: const Icon(Icons.group_add),
    );
  }

  Widget toggle() {
    return FloatingActionButton(
      heroTag: 'toggleAdd',
      backgroundColor: Colors.blue,
      onPressed: animate,
      tooltip: 'Add',
      child: Icon(
        isOpened ? Icons.close : Icons.add,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 2.0,
            0.0,
          ),
          child: chatWithFriend(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value,
            0.0,
          ),
          child: createGroup(),
        ),
        toggle(),
      ],
    );
  }
}
