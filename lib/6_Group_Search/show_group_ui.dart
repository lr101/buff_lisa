import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../Files/global.dart' as global;
import '../Files/DTOClasses/group.dart';


class ShowGroupUI {

  static Widget build(BuildContext context, Size size, Group group) {
    return AlertDialog(
        content: SizedBox(
          height: size.height - 300,
          width: size.width - 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text("Logo: "),
                        SizedBox(
                          height: 40,
                          child: group.getProfileImageWidget()
                        )
                      ],
                    ),
                    Row(
                      children: [
                        const Text("Group name: "),
                        Text(group.name),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    SizedBox(
                      height: 50,
                      child: SingleChildScrollView(
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           const Text("Description:"),
                           group.getDescriptionWidget()
                         ],
                       ),
                      )
                    ),
                    const SizedBox(height: 10,),
                    FutureBuilder<Set<String>>(
                        future: group.getMembers(),
                        builder: (context, snapshot) => snapshot.hasData ? _buildList(snapshot.requireData) : const CircularProgressIndicator()
                    )
                  ],
                ),
              ]
          ),
        )
    );
  }


  static Widget _buildList(Set<String> members) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Members: "),
        ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: members.length,
          itemBuilder: (_, index) => Card(
            child:  ListTile(
              tileColor: (members.elementAt(index) == global.username ? Colors.green : null),
              leading: Text("${index+1}. "),
              title: Text(members.elementAt(index)),
            )
          )
        )
      ],
    );
  }
}