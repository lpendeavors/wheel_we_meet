import 'package:flutter/material.dart';

import '../../utils.dart';
import 'bloc/friends_enum.dart';

class FriendOptions extends StatelessWidget {
  const FriendOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.25,
      minChildSize: 0.25,
      maxChildSize: 0.25,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              ListTile(
                leading: const Icon(Icons.chat),
                title: const Text('Send Message'),
                onTap: () => Navigator.of(context).pop(
                  FriendOptionType.message,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Share Location'),
                onTap: () => Navigator.of(context).pop(
                  FriendOptionType.shareLocation,
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                title: const Text('Delete Friend',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  showConfirmation(
                    context: context,
                    title: 'Delete Friend',
                    content: 'Are you sure you want to delete this friend?',
                    confirmButtonText: 'Delete',
                    confirmButtonTextColor: Colors.red,
                  ).then(
                    (confirmed) {
                      if (confirmed == true) {
                        Navigator.of(context).pop(
                          FriendOptionType.delete,
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
