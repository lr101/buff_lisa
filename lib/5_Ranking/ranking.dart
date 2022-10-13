import 'package:buff_lisa/Files/restAPI.dart';
import 'package:flutter/material.dart';
import 'package:buff_lisa/Files/pin.dart';
import '../Files/global.dart' as global;
import '../Files/io.dart';


class RankingPage extends StatefulWidget {
  final IO io;
  const RankingPage({super.key, required this.io});

  @override
  RankingPageState createState() => RankingPageState();
}

class RankingPageState extends State<RankingPage> with AutomaticKeepAliveClientMixin<RankingPage>{
  late List<Ranking> rankings = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Leaderboard',style: TextStyle(color: Colors.white)),
            backgroundColor: global.cThird,

          ),
          backgroundColor: Colors.white,
          body: RefreshIndicator(
            onRefresh: _pullRefresh,
            child:FutureBuilder<List<Ranking>>(
              future: RestAPI.fetchRanking(),
              builder: (BuildContext context, AsyncSnapshot<List<Ranking>> snapshot) {
                if (snapshot.hasData) {
                rankings = snapshot.data!;
                return  ListView.separated(
                    itemCount: rankings.length,
                    padding: const EdgeInsets.all(8.0),
                    separatorBuilder: (BuildContext context, int index) => const Divider(),
                    itemBuilder: (BuildContext context, int index) {
                      if (rankings[index].username == global.username) {
                        return  Card(shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                            color:  Colors.green[200],
                            child: ListTile(title: Text(rankings[index].username, style: const TextStyle(color: global.cPrime)), leading: Text("${index+1}.", style: const TextStyle(color: global.cPrime)),trailing: Text("${rankings[index].points} points", style: const TextStyle(color: global.cPrime)),));
                      }
                      return  Card(shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: ListTile(title: Text(rankings[index].username, style: const TextStyle(color: global.cPrime)), leading: Text("${index+1}.", style: const TextStyle(color: global.cPrime),),trailing: Text("${rankings[index].points} points", style: const TextStyle(color: global.cPrime))));
                      //return renderSimpleWidget(snapshot.data![index], index, me);
                    },
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            })
          )
    );

  }

  Future<void> _pullRefresh() async {
    List<Ranking> freshRanking = await RestAPI.fetchRanking();
    setState(() {
      rankings = freshRanking;
    });
  }

  @override
  bool get wantKeepAlive => true;
}