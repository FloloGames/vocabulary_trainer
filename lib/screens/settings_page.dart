import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ExpansionTileController _expansionTileController =
      ExpansionTileController();
  bool _openAppAfterUnlocks = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            onTap: () {
              //set unlock count
            },
            title: const Text(
              "Open app after {n} unlocks",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            trailing: Switch(
              value: _openAppAfterUnlocks,
              onChanged: (value) {
                _openAppAfterUnlocks = value;
                if (!value) {
                  _expansionTileController.collapse();
                }
                setState(() {});
              },
            ),
          ),
          IgnorePointer(
            ignoring: !_openAppAfterUnlocks,
            child: ExpansionTile(
              controller: _expansionTileController,
              title: Text(
                "Selected Topics to learn:",
                style: TextStyle(
                  fontSize: 18,
                  color: _openAppAfterUnlocks ? Colors.white : Colors.grey,
                ),
              ),
              children: [
                for (int index = 0; index < 2; index++)
                  ListTile(
                    title: const Text("Subject/Topic"),
                    trailing: IconButton(
                      onPressed: () {
                        // Remove from list
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  ),
                // Button as a child of ExpansionTile
                IconButton(
                  onPressed: () {
                    // Handle button click
                  },
                  icon: const Icon(
                    Icons.add_outlined,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              "Example Screen",
              style: TextStyle(
                fontSize: 18,
                color: _openAppAfterUnlocks ? Colors.blue : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
