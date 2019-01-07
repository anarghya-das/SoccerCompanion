import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'dart:core';
import 'dart:collection';
import 'team.dart';

class TableView extends StatefulWidget {
  final String name, title;
  TableView(this.name, this.title);
  TableViewState createState() => TableViewState(name, title);
}

class TableViewState extends State<TableView> {
  String name, title;
  List<String> _columnNames = [
    "Pos",
    "    ",
    "Club",
    "P",
    "W",
    "L",
    "D",
    "GD",
    "Pts"
  ];
  TableViewState(this.name, this.title);
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                "logos/$name.png",
                fit: BoxFit.fill,
              ),
            ),
          )
        ];
      },
      body: _tableFutureBuilder(context),
    ));
  }

  Widget _tableFutureBuilder(BuildContext context) {
    return FutureBuilder(
      future: fetch(name),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                    child: Image.asset("logos/football.gif",
                        width: 100, height: 100)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Please wait while the data loads..."),
                )
              ],
            );
          case ConnectionState.done:
            if (snapshot.hasError) {
              print(snapshot.error);
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                      child: Icon(
                    Icons.face,
                    size: 100,
                  )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "An error Occured!",
                      style: TextStyle(fontSize: 30),
                    ),
                  )
                ],
              );
            } else {
              return createListTable(context, snapshot);
            }
        }
      },
    );
  }

  Widget createListTable(BuildContext context, AsyncSnapshot snapshot) {
    List<Team> val = snapshot.data;
    return ListView.separated(
      itemCount: val.length + 1,
      separatorBuilder: (con, i) => Divider(),
      itemBuilder: (con, idx) {
        if (idx == 0) {
          return ListTile(
            title: _getTableHeader(_columnNames),
          );
        } else {
          return ListTile(
              title: Row(
            children: _getTableRows(val, idx),
          ));
        }
      },
    );
  }

  List<Widget> _getTableRows(List<Team> val, int idx) {
    List<Widget> list = new List<Widget>();
    List<String> data = val[idx - 1].getTableData();
    for (var i = 0; i < data.length; i++) {
      if (i == 1) {
        list.add(Expanded(child: Image.asset(data[i], width: 30,height: 30,)));
      } else {
        list.add(Expanded(child: Text(data[i])));
      }
    }
    return list;
  }

  Widget _getTableHeader(List<String> strings) {
    List<Widget> list = new List<Widget>();
    for (var i = 0; i < strings.length; i++) {
      list.add(Expanded(
          child: Text(
        strings[i],
        style: TextStyle(fontWeight: FontWeight.bold),
      )));
    }
    return Row(children: list);
  }

  Future<List<Team>> fetch(String name) async {
    final response = await get(
      'http://api.football-data.org/v2/competitions/$name/standings',
      headers: {"X-Auth-Token": "6278cc4210794f96870c470c190b9c1a"},
    );
    final response2 = await get(
      'http://api.football-data.org/v2/competitions/$name/teams',
      headers: {"X-Auth-Token": "6278cc4210794f96870c470c190b9c1a"},
    );
    final responseJson = json.decode(response.body);
    final responseJson2 = json.decode(response2.body);
    List c = responseJson["standings"][0]["table"];
    List d = responseJson2["teams"];
    HashMap<String, String> nameTLA = HashMap();
    for (var i in d) {
      nameTLA[i["name"]] = i["tla"];
    }
    List<Team> logoTeam = List();
    for (var i in c) {
      Team newTeam = Team(
          int.parse(i['position'].toString()),
          i['team']['name'].toString(),
          nameTLA[i['team']['name'].toString()],
          int.parse(i["playedGames"].toString()),
          int.parse(i["won"].toString()),
          int.parse(i["lost"].toString()),
          int.parse(i["draw"].toString()),
          int.parse(i["goalDifference"].toString()),
          int.parse(i["points"].toString()));
      logoTeam.add(newTeam);
    }
    return logoTeam;
  }
}
