import 'package:buff_lisa/Files/restAPI.dart';
import 'package:flutter/material.dart';
import 'package:foldable_list/foldable_list.dart';
import 'package:foldable_list/resources/arrays.dart';
import 'package:buff_lisa/Files/pin.dart';
import '../Files/global.dart' as global;
import '../Files/io.dart';


class RankingPage extends StatefulWidget {
  final IO io;
  const RankingPage({super.key, required this.io});

  @override
  RankingPageState createState() => RankingPageState();
}

class RankingPageState extends State<RankingPage> {
  late List<Widget> simpleWidgetList = [];
  late List<Widget> expandedWidgetList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Ranking>>(
        future: widget.io.getRanking(),
        builder: (BuildContext context, AsyncSnapshot<List<Ranking>> snapshot) {
          if (snapshot.hasData) {
            initList(snapshot.data!);
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: const Text('Leaderboard',style: TextStyle(color: Colors.white)),
                backgroundColor: global.cThird,

              ),
              backgroundColor: Colors.white,
              body: ListView.separated(
                itemCount: snapshot.data!.length,
                padding: const EdgeInsets.all(8.0),
                separatorBuilder: (BuildContext context, int index) => const Divider(),
                itemBuilder: (BuildContext context, int index) {
                  if (snapshot.data![index].username == global.username) {
                    return  Card(shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                        color:  Colors.green[200],
                        child: ListTile(title: Text(snapshot.data![index].username, style: const TextStyle(color: global.cPrime)), leading: Text("${index+1}.", style: const TextStyle(color: global.cPrime)),trailing: Text("${snapshot.data![index].points} points", style: const TextStyle(color: global.cPrime)),));
                  }
                  return  Card(shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: ListTile(title: Text(snapshot.data![index].username, style: const TextStyle(color: global.cPrime)), leading: Text("${index+1}.", style: const TextStyle(color: global.cPrime),),trailing: Text("${snapshot.data![index].points} points", style: const TextStyle(color: global.cPrime))));
                  //return renderSimpleWidget(snapshot.data![index], index, me);
                },
            ));
          } else {
            return const Text("LOADING");
          }
        });

  }

  initList(List<Ranking> ranking) {
    for (var i = 0; i < ranking.length; i++) {
      bool me = false;
      if (ranking[i].username == global.username) {
        me = true;
      }
      simpleWidgetList.add(renderSimpleWidget(ranking[i], i, me));
      expandedWidgetList.add(renderExpandedWidget(ranking[i], i, me));
    }
  }


  Widget renderSimpleWidget(Ranking ranking, int number, bool me) {
    return Container(
          height: 50,
          decoration: BoxDecoration(
              color: (me ? Colors.green[200] :Colors.grey[200]), borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text((number+1).toString()),
                const SizedBox(width: 20,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ranking.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("${ranking.points} Points"),
                  ],
                )
              ],
            ),
          ),
    );
  }

  Widget renderExpandedWidget(Ranking ranking, int number, bool me) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
          color: (me ? Colors.green[200] :Colors.grey[200]), borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text((number+1).toString()),
            const SizedBox(width: 20,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ranking.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("${ranking.points} Points"),
                Text("Mona created:"),
                Text("Tornado created:"),

              ],
            )
          ],
        ),
      ),
    );
  }
}