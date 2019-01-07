import 'dart:core';


class Team{
  int _position;
  String _teamName;
  String _tla;
  int _played;
  int _won;
  int _lost;
  int _draw;
  int _goalDiff;
  int _points;

  Team(this._position,this._teamName,this._tla,this._played,this._won,this._lost,this._draw,this._goalDiff,this._points);

 List<String> getTableData(){
   String fileID="teams/$_tla.png";
   List<String> data=[
     _position.toString(),
     fileID,
     _tla,
     _played.toString(),
     _won.toString(),
     _lost.toString(),
     _draw.toString(),
     _goalDiff.toString(),
     _points.toString()
   ];
   return data;
 }

}