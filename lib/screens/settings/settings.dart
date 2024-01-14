import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          SwitchListTile(
            title: Text('Enable Notifications'),
            value: notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                notificationsEnabled = value;
              });
              // Add logic to handle setting change
            },
          ),
          ListTile(
            title: Text('Account'),
            onTap: () {
              // Navigate to account settings
            },
          ),
          ListTile(
            title: Text('Privacy'),
            onTap: () {
              // Navigate to privacy settings
            },
          ),
          ListTile(
            title: Text('About'),
            onTap: () {
              // Navigate to about page
            },
          ),
          // Add more settings options here
        ],
      ),
    );
  }
}
