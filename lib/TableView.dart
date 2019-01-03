import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'dart:core';
import 'package:flutter_svg/flutter_svg.dart';

class TableView extends StatefulWidget {
  final String name, title;
  TableView(this.name, this.title);
  TableViewState createState() => TableViewState(name, title);
}

class TableViewState extends State<TableView> {
  String name, title;
  List<String> _columnNames = ["Position", "Team Name", "Points"];
  TableViewState(this.name, this.title);
  @override
  void initState() {
    super.initState();
    fetch(name);
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
                  Center(child: CircularProgressIndicator()),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Please wWait while the data loads..."),
                  )
                ],
              );
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return ListView(
                    children: <Widget>[createDataTable(context, snapshot)]);
              }
          }
        },
      ),
    );
  }

  Widget createDataTable(BuildContext context, AsyncSnapshot snapshot) {
    List<String> val = snapshot.data;
    return DataTable(
        columns: _columnNames
            .map((String col) => DataColumn(
                  label: Text(
                    col,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12
                    ),
                  ),
                ))
            .toList(),
        rows: val
            .map((String v) => DataRow(cells: [
                  DataCell(Text(v.split(",")[0],overflow: TextOverflow.ellipsis)),
                  DataCell(Text(v.split(",")[1],overflow: TextOverflow.ellipsis)),
                  DataCell(Text(v.split(",")[2],overflow: TextOverflow.ellipsis))
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
  final responseJson = json.decode(response.body);
  List c = responseJson["standings"][0]["table"];
  List<String> logoTeam = List();
  for (var i in c) {
    String v = "${i['position']},${i['team']['name']},${i["points"]}";
    logoTeam.add(v);
  }
  return logoTeam;
}
