import 'package:flutter/material.dart';
import 'TableView.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> {
  List<String> _leagues = [
    'Premier League',
    'La Liga',
    'Serie A',
    'Ligue 1',
    'Bundesliga',
    'Primeira Liga',
    'Eredivise',
  ];

  List<String> _codes = [
    'PL',
    'PD',
    'SA',
    'FL1',
    'BL1',
    'PPL',
    'DED',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: _leagues.length,
      separatorBuilder: (context, i) => Divider(),
      itemBuilder: (context, i) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading:
                Image.asset("logos/${_codes[i]}.png", width: 70, height: 70),
            title: Text(_leagues[i]),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TableView(_codes[i],_leagues[i])));
            },
          ),
        );
      },
    );
  }
}
