import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:forjob/pages/howtoplay.dart';

class PlayerList extends StatefulWidget {
  const PlayerList({super.key});

  @override
  State<PlayerList> createState() => _PlayerListState();
}

class _PlayerListState extends State<PlayerList> {
  final CollectionReference<Map<String, dynamic>> usersCollection = FirebaseFirestore.instance.collection('users');
  List<List<String>> myListTile = List<List<String>>.generate(1, (index) => []);
  bool mylistbreaker = true; 
  Color isMyTile = Colors.white;
  String currentusername = '';
  
  @override
  void initState() {
    super.initState();
    //findnickname();
    mylistbreaker = true;
  }
  //void findnickname()async{
  //  SharedPreferences prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //    currentusername =  prefs.getString('nickname')!;
  //  });
  //}
 // void nameFinder(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot)async{
 //   SharedPreferences prefs = await SharedPreferences.getInstance();
 //   var email = prefs.getString('nick');
 //   snapshot.data!.docs.forEach((doc) { 
 //     if(doc.data()['email'] == email){
 //       setState(() {
 //           currentusername = doc.data()['nickname'];
 //       });
 //     }
 //     
 //   });
 // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            
            backgroundColor: Colors.black,
            actions: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: GestureDetector(
                  child: const Icon(Icons.question_mark),
                  onTap: ()async{
                    await Navigator.push(context,
                                MaterialPageRoute(builder: (context) => const HowToPlay()));
                  },
                  ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: GestureDetector(
                  child: const Icon(Icons.settings),
                  onTap: ()async{
                  //  await Navigator.push(context,
                  //              MaterialPageRoute(builder: (context) => HowToPlay()));
                  },
                  ),
              ),
            ],
            title: const Padding(
              padding: EdgeInsets.only(left:70),
              child: Text('Zelix Pac'),
            ),
          ),
          body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: usersCollection.snapshots(),
            builder: (context, snapshot) {
              print('times : $mylistbreaker');
              if(!snapshot.hasData){const CircularProgressIndicator(strokeWidth: 10,color: Colors.blue,);}

              else if(mylistbreaker){
                 List<String> temp = [];
                 List<int> times = [];
                 int ttime(QueryDocumentSnapshot<Map<String, dynamic>> element) => jsonDecode(element.data()['time'].toString());
                 myListTile[0]=['NO','NAME','TIME','SCORE'];
                 for (var element in snapshot.data!.docs) {
                   times.add(ttime(element));
                 }
                 print('times : $times');
                 times.sort((a, b) => a.compareTo(b));
                 
                     for (var i = 0; i < times.length; i++) {
                      for (var element in snapshot.data!.docs) { 
                        if(ttime(element) == times[i]){
                            temp = [];
                            temp.add(element.data()['nickname'].toString());
                            temp.add(element.data()['time'].toString());
                            temp.add(element.data()['score'].toString());
                            myListTile.add(temp);
                            //print(myListTile);
                          }
                     }    
                 }
                 mylistbreaker = false;
              }
              //nameFinder(snapshot);
              return SingleChildScrollView(
                child: SizedBox(
                  height: 10000,
                  child: Column(
                    children: myListTile.map((tile) { 
                       print('currentusername : $currentusername');
                       if(currentusername == tile[0]){
                          isMyTile = Colors.yellow;
                        
                       }
                       else{
                          isMyTile = Colors.white;
                       }
                       return Card(
                         elevation: 30,
                         margin: const EdgeInsets.all(1),
                         child: ListTile(
                          tileColor: isMyTile,
                           leading: Padding(
                             padding: const EdgeInsets.all(8.0),
                             child: Text(myListTile.indexOf(tile) == 0 ? 'NO' : myListTile.indexOf(tile).toString(),style: const TextStyle(fontSize: 23,color: Colors.blue),),
                           ),
                           title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                             children: [
                               Padding(
                                 padding: const EdgeInsets.all(15.0),
                                 child: Text(myListTile.indexOf(tile) == 0 ?  'NAME' : tile[0],style: const TextStyle(fontSize: 23,color: Colors.blue),),
                               ),
                               Padding(
                                 padding: const EdgeInsets.all(1.0),
                                 child: Text(myListTile.indexOf(tile) == 0 ? 'TIME': tile[1],style: const TextStyle(fontSize: 23,color: Colors.blue),),
                               ),
                             ],
                           ),
                           trailing: Padding(
                             padding: const EdgeInsets.all(0.0),
                             child: Text(myListTile.indexOf(tile) == 0 ?  'SCORE' : tile[2],style: const TextStyle(fontSize: 23,color: Colors.blue),),
                           ),
                         ),
                     );
                  }).toList(),
                  ),
                ),
              );
            }
          ),
        );
  }
}