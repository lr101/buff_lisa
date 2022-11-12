import 'package:buff_lisa/5_Ranking/ranking_ui.dart';
import 'package:buff_lisa/Files/restAPI.dart';
import 'package:flutter/material.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';

import '../Files/DTOClasses/ranking.dart';


class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  RankingPageState createState() => RankingPageState();
}

class RankingPageState extends State<RankingPage> with AutomaticKeepAliveClientMixin<RankingPage>{
  late List<Ranking> rankings = [];

  /// loads ranking data on initialization of page
  @override
  void initState() {
    pullRefresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RankingUI(state: this);
  }

  /// gets the ranking list from the server and replaces the ranking list in widget
  Future<List<Ranking>> pullRefresh() async {
    List<Ranking> freshRanking = await RestAPI.fetchRanking();
    setState(() {
      rankings = freshRanking;
    });
    return freshRanking;
  }

  @override
  bool get wantKeepAlive => true;
}