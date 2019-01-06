import 'package:http/http.dart';
import 'dart:convert';
import 'dart:collection';
import 'package:dio/dio.dart';


Future<List<String>> fetch(String name) async {
  final response = await get(
    'http://api.football-data.org/v2/competitions/$name/standings',
    headers: {"X-Auth-Token": "6278cc4210794f96870c470c190b9c1a"},
  );
  final responseJson = json.decode(response.body);
  List c = responseJson["standings"][0]["table"];
  List<String> logoTeam = List();
  for (var i in c) {
    String v = "${i['team']['name']},${i['team']['id']}";
    logoTeam.add(v);
  }
  return logoTeam;
}

Future<HashMap<String, String>> fetch2(String name) async {
  final response = await get(
    'http://api.football-data.org/v2/competitions/$name/teams',
    headers: {"X-Auth-Token": "6278cc4210794f96870c470c190b9c1a"},
  );
  final responseJson = json.decode(response.body);
  List d = responseJson["teams"];
  HashMap<String, String> all = HashMap();
  for (var i in d) {
    if (i["crestUrl"] != null) {
      all[i['tla']] = i["crestUrl"];
    }
  }
  return all;
}

void main() {
  Future<HashMap> values = fetch2("PL");
  values.then((onValue) {
    var _dir="teams";
    Dio dio = Dio();
    for (var i in onValue.keys) {
      if (onValue[i].contains('svg')) {
        dio.download(onValue[i], "$_dir/PL/$i.svg");
      } else {
        dio.download(onValue[i], "$_dir/PL/$i.png");
      }
    }
  });
}
