import 'package:flutter/material.dart';
import 'package:tfg_project/view/examples/examples.dart';
import 'package:tfg_project/view/feed/explore.dart';
import 'package:tfg_project/view/profile/account.dart';
import 'package:tfg_project/view/profile/edit_profile.dart';
import 'package:tfg_project/view/profile/profile.dart';

import 'authentication/log_out_button.dart';
import 'editor/editor_home.dart';
import 'feed/feed.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int _selectedIndex = 0;
  bool _isFirstTime = true;
  final scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  List<Widget> _widgetOptions() => <Widget>[
    FeedPage(scaffoldKey: scaffoldKey),
    const ExamplesPage(),
    EditorHomePage(scaffoldKey: scaffoldKey,),
    ProfilePage(userId: null, homeScaffoldKey: scaffoldKey,)
  ];

  static final List<String> _widgetTitles = <String>[
    'Feed',
    'Ejemplos',
    'Editor',
    'Perfil'
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isFirstTime) {
      final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      setState(() {
        _selectedIndex = args?['selectedIndex'] ?? _selectedIndex;
        _isFirstTime = false;
      });
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_widgetTitles[_selectedIndex]),
        leading: LogOutButton(scaffoldKey: scaffoldKey),
        actions: [
          if (_selectedIndex == 3)
            PopupMenuButton(
              icon: const Icon(Icons.settings),
              onSelected: (value) {
                if (value == 'editProfile') {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const EditProfilePage()),
                  );
                } else if (value == 'account') {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AccountPage()),
                  );
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'editProfile',
                  child: Text('Editar Perfil'),
                ),
                const PopupMenuItem(
                  value: 'account',
                  child: Text('Cuenta'),
                ),
              ],
            ),
          if (_selectedIndex == 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: IconButton(
                icon: const Icon(Icons.search, size: 32, color: Colors.white,),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const Explore()),
                  ).then((value) {
                    setState(() {
                      _selectedIndex = 0;
                    });
                  });
                },
              ),
            )
        ],
      ),
      body: Center(
          child: _widgetOptions().elementAt(_selectedIndex)
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dynamic_feed),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_album_outlined),
            label: 'Ejemplos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo),
            label: 'Editor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}