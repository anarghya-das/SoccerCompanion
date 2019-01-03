import 'package:http/http.dart';
import 'dart:convert';

Future<List<String>> fetch(String name) async {
  final response = await get(
    'http://api.football-data.org/v2/competitions/$name/standings',
    headers: {"X-Auth-Token": "6278cc4210794f96870c470c190b9c1a"},
  );
  final responseJson = json.decode(response.body);
  List c = responseJson["standings"][0]["table"];
  List<String> logoTeam = List();
  for (var i in c) {
    String v = "${i['position']},${i['team']['name']}";
    logoTeam.add(v);
  }
  return logoTeam;
}

void fetch2(String name) async {
  final response = await get(
    'http://api.football-data.org/v2/competitions/$name/matches?matchday=21',
    headers: {"X-Auth-Token": "6278cc4210794f96870c470c190b9c1a"},
  );
  print(response.body);
}

void main() {
  // Future<List> values = fetch("PD");
  // values.then((onValue) {
  //   for (var i in onValue) {
  //     print(i);
  //   }
  // });
  fetch2("PL");
}
