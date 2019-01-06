import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'dart:core';
import 'dart:collection';
import 'package:flutter_svg/flutter_svg.dart';

class TableView extends StatefulWidget {
  final String name, title;
  TableView(this.name, this.title);
  TableViewState createState() => TableViewState(name, title);
}

class TableViewState extends State<TableView> {
  String name, title;
  List<String> _columnNames = ["Pos", "Club", "P", "W", "L", "D", "GD", "Pts"];
  TableViewState(this.name, this.title);
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: FutureBuilder(
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
      ),
    );
  }

  Widget createListTable(BuildContext context, AsyncSnapshot snapshot) {
    List<String> val = snapshot.data;
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

  List<Widget> _getTableRows(List<String> val, int idx) {
    List<Widget> list = new List<Widget>();
    var length = val[0].split(",").length;
    for (var i = 0; i < length; i++) {
      list.add(Expanded(child: Text(val[idx - 1].split(",")[i])));
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

  Widget createDataTable(BuildContext context, AsyncSnapshot snapshot) {
    List<String> val = snapshot.data;
    return DataTable(
        columns: _columnNames
            .map((String col) => DataColumn(
                  label: Text(
                    col,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ))
            .toList(),
        rows: val
            .map((String v) => DataRow(cells: [
                  DataCell(Text(v.split(",")[0])),
                  DataCell(Text(v.split(",")[1])),
                  DataCell(Text(v.split(",")[2])),
                  DataCell(Text(v.split(",")[3])),
                  DataCell(Text(v.split(",")[4])),
                  DataCell(Text(v.split(",")[5])),
                  DataCell(Text(v.split(",")[6])),
                  DataCell(Text(v.split(",")[7]))
                ]))
            .toList());
  }

  Widget createList(BuildContext context, AsyncSnapshot snapshot) {
    List<String> val = snapshot.data;
    return ListView.separated(
      itemCount: val.length,
      separatorBuilder: (context, i) => Divider(),
      itemBuilder: (context, index) {
        String v = val[index];
        List sub = v.split(",");
        return choice(sub);
      },
    );
  }

  Widget choice(List l) {
    if (l[0].contains("svg")) {
      return ListTile(
          leading: SvgPicture.network(
            l[0],
            width: 50,
            height: 50,
          ),
          title: Text(l[1]));
    } else {
      return ListTile(
          leading: Image.network(
            l[0],
            width: 50,
            height: 50,
          ),
          title: Text(l[1]));
    }
  }
}

Future<List<String>> fetch(String name) async {
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
  List<String> logoTeam = List();
  for (var i in c) {
    String v =
        "${i['position']},${nameTLA[i['team']['name']]},${i["playedGames"]},${i["won"]},${i["lost"]},${i["draw"]},${i["goalDifference"]},${i["points"]}";
    logoTeam.add(v);
  }
  return logoTeam;
}
