import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forjob/pages/intro.dart';
import 'package:forjob/main.dart';
import 'package:forjob/models/monster.dart';
import 'package:forjob/models/path.dart';
import 'package:forjob/models/pixel.dart';
import 'package:forjob/models/player.dart';
import 'package:forjob/services/database.dart';

class Game extends StatefulWidget {
  final int? enteredLevel;
  const Game({super.key, this.enteredLevel});
  @override
  State<Game> createState() => _GameState();
}
class _GameState extends State<Game> {
  double width = 0.0;
  double height = 0.0;
  static int numberInRow = 13;
  int numberOfSquares = numberInRow * 15;
  int player = numberInRow + 1;
  int monster = numberInRow * 13 + 1;
  List<int> monsterpath = [];
  List<int> food = [];
  int time = 0;
  Timer timetimer = Timer(const Duration(), () { });
  Timer playertimer = Timer(const Duration(), () { });
  Timer monstertimer= Timer(const Duration(), () { });
  static List<int> levelBarriers = [148,158,159,160,162,164,165,167,130,131,133,135,136,137,139,140,115,114,113,112,110,109,107,106,120,127,
    80,82,83,84,85,87,88,89,54,55,68,57,58,59,60,61,63,27,29,30,31,32,34,35,36,48 ];
  static List<int> sidebarriers = [ //Kaenarlar : 
    0,1,2,3,4,5,6,7,8,9,10,11,12,13,26,39,52,65,78,91,104,117,130,143,156,169,182,183,184,185,186,187,188,189,190,191,192,193,194,
    181,168,155,142,129,116,103,90,77,64,51,38,25, 
  ];
  List<int> barriers = sidebarriers + levelBarriers;
  String direction = "";
  String ghostdirection = "right";
  List<bool> finished = List.generate(17, (index) => false);
  bool lose = false;
  bool win = false;
  bool playing = false;
  int score = 0;
  String myPlayerColor = 'yellow';
  int powerlevel = -1;
  String currentuserid = '';
  List<int> currentpath = List<int>.generate(2, (index) => 0); 
  List<int> allgaps = [];
  List<int> monsterToPlayerGaps = [];
  List<int> possibleuppath = [];
  int currentgap = 0;

  int removableBarrier = 14;
  //SharedPreferences? prefs;
  Random randimize = Random();
  DatabaseService dbs = DatabaseService();
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
  List<int> finishedLevelsDB = [];

  @override
  void initState() {
    super.initState();
    dbs = DatabaseService();
    findAllGaps();
    //findnickname();
  }
 //void findnickname()async{
 //  SharedPreferences prefs = await SharedPreferences.getInstance();
 //  currentuserid = prefs.getString('nickname')!;
 //}
void findAllGaps(){
  for (var i = 0; i < numberOfSquares; i++) {
          if(!barriers.contains(i) && 
               (!barriers.contains(i + numberInRow) && 
               !barriers.contains(i - numberInRow) && 
               (barriers.contains(i + 1) && 
               barriers.contains(i - 1))) &&
               ((!barriers.contains(i+numberInRow+1) ||
               !barriers.contains(i+numberInRow-1)) &&
               (!barriers.contains(i-numberInRow+1) ||
               !barriers.contains(i-numberInRow-1)))){
            setState(() {
               allgaps.add(i);
            });
          }
    }
}
void monsterToPlayerGapsFN(){ //Monsterdan Playera gidilebilen delikler
  if((player/numberInRow).ceil() > (monster/numberInRow).ceil()){ //Player monsterdan aşağıda
    setState(() {
       monsterToPlayerGaps.clear();
     });
      for (var i = 0; i < allgaps.length; i++) {
          if((allgaps[i]/numberInRow).ceil() > (monster/numberInRow).ceil()  &&  (allgaps[i]/numberInRow).ceil() < (player/numberInRow).ceil()){
              setState(() {
                monsterToPlayerGaps.add(allgaps[i]);
              });
          }
        }
  }
  else if((player/numberInRow).ceil() < (monster/numberInRow).ceil()){//Monster playerdan aşağıda
     setState(() {
       monsterToPlayerGaps.clear();
     });
      for (var i = 0; i < allgaps.length; i++) {
          if((allgaps[i]/numberInRow).ceil() < (monster/numberInRow).ceil()  &&  (allgaps[i]/numberInRow).ceil() > (player/numberInRow).ceil()){
              setState(() {
                monsterToPlayerGaps.add(allgaps[i]);
              });
          }
        }
  }
  
}
void possibleupordownpathFN(){
  List<bool> barrFinder = [];
  if((player/numberInRow).ceil() > (monster/numberInRow).ceil()){
       setState(() {
         possibleuppath = [];
       });
       for (var upgap in monsterToPlayerGaps) {
          if((upgap/numberInRow).ceil() + 1 == (player/numberInRow).ceil()){//Playerin 1 üstündeki gapler
            barrFinder = [];
            if(upgap+numberInRow > player){ //upgap sağdaysa
              for (var i = player; i < upgap+numberInRow; i++) {//Playera gisen yol bos mu
                barriers.contains(i) ? barrFinder.add(true) : true;
              }
              if(barrFinder.isEmpty){//Playera gisen yol bossa
                  if(!possibleuppath.contains(upgap) || possibleuppath.isEmpty){
                      setState(() {
                    possibleuppath.add(upgap);
                    possibleuppath.toSet().toList();
                  });
                  }
                }
            }
            else if(upgap+numberInRow < player){ // upgap soldaysa
              barrFinder = [];
              for (var i = upgap+numberInRow; i < player; i++) {//Playera gisen yol bos mu
                barriers.contains(i) ? barrFinder.add(true) : true;
              }
              if(barrFinder.isEmpty){//Playera gisen yol bossa
                  if(!possibleuppath.contains(upgap) || possibleuppath.isEmpty){
                      setState(() {
                        possibleuppath.add(upgap);
                        possibleuppath.toSet().toList();
                     });
                  }
              }
            }
            else if(upgap+numberInRow == player){ // upgap üstteyse
                  if(!possibleuppath.contains(upgap) || possibleuppath.isEmpty){
                      setState(() {
                        possibleuppath.add(upgap);
                        possibleuppath.toSet().toList();
                      });
                  }
            }
         } 
    } 
  }
  else if((player/numberInRow).ceil() < (monster/numberInRow).ceil()){
      setState(() {
         possibleuppath = [];
       });
      for (var downgap in monsterToPlayerGaps) {
          if((downgap/numberInRow).ceil() - 1 == (player/numberInRow).ceil()){//Playerin 1 altındaki gapler
            barrFinder = [];
            if(downgap-numberInRow > player){ //upgap sağdaysa
              for (var i = player; i < downgap-numberInRow; i++) {//Playera gisen yol bos mu
                barriers.contains(i) ? barrFinder.add(true) : true;
              }
              if(barrFinder.isEmpty){//Playera gisen yol bossa
                  if(!possibleuppath.contains(downgap) || possibleuppath.isEmpty){
                      setState(() {
                    possibleuppath.add(downgap);
                    possibleuppath.toSet().toList();
                  });
                  }
                }
            }
            else if(downgap-numberInRow < player){ // upgap soldaysa
              barrFinder = [];
              for (var i = downgap-numberInRow; i < player; i++) {//Playera gisen yol bos mu
                barriers.contains(i) ? barrFinder.add(true) : true;
              }
              if(barrFinder.isEmpty){//Playera gisen yol bossa
                  if(!possibleuppath.contains(downgap) || possibleuppath.isEmpty){
                      setState(() {
                        possibleuppath.add(downgap);
                        possibleuppath.toSet().toList();
                     });
                  }
              }
            }
            else if(downgap-numberInRow == player){ // upgap üstteyse
                  if(!possibleuppath.contains(downgap) || possibleuppath.isEmpty){
                      setState(() {
                        possibleuppath.add(downgap);
                        possibleuppath.toSet().toList();
                      });
                  }
            }
         } 
    }
    
  }
}
void possibleupordownpathHelperFN(){
  List<bool> barrFinder = [];
  List<bool> toMonster = [];
  possibleupordownpathFN();
  if((player/numberInRow).ceil() > (monster/numberInRow).ceil()){
       for (var upgap in monsterToPlayerGaps) {
         for (var k = 0; k < possibleuppath.length; k++) {
            if((upgap/numberInRow).ceil() + 2 == (possibleuppath[k]/numberInRow).ceil()){//İki gap arasında iki kat varsa
                  barrFinder = [];
                  if(upgap+numberInRow > possibleuppath[k] - numberInRow){ //upgap sağdaysa
                          for (var i = possibleuppath[k] - numberInRow; i < upgap+numberInRow; i++) {//Playera gisen yol bos mu
                            barriers.contains(i) ? barrFinder.add(true) : true;
                          }
                          if(monster > upgap - numberInRow && (monster/numberInRow).ceil() + 1 == (upgap/numberInRow).ceil()){
                              toMonster = [];
                              for (var i = upgap - numberInRow; i < monster; i++) {
                                  barriers.contains(i) ? toMonster.add(true) : true;
                               }
                          }
                          else if(monster < upgap - numberInRow && (monster/numberInRow).ceil() + 1 == (upgap/numberInRow).ceil()){
                              toMonster = [];
                              for (var i = monster; i < upgap - numberInRow; i++) {
                                  barriers.contains(i) ? toMonster.add(true) : true;
                               }
                          }
                          else if(monster == upgap - numberInRow && (monster/numberInRow).ceil() + 1 == (upgap/numberInRow).ceil()){
                              toMonster = [];
                          }
                          
                          if(barrFinder.isEmpty){//Playera gisen yol bossa
                              if(!possibleuppath.contains(upgap) || possibleuppath.isEmpty){
                                 if(!toMonster.contains(true)){
                                    setState(() {
                                    possibleuppath.add(upgap);
                                    possibleuppath.toSet().toList();
                                  });
                                 }
                                  
                              }
                            }
                 }
                 else if(upgap+numberInRow < possibleuppath[k] - numberInRow){ // upgap soldaysa
                   barrFinder = [];
                   for (var i = upgap+numberInRow; i < possibleuppath[k] - numberInRow; i++) {//Playera gisen yol bos mu
                     barriers.contains(i) ? barrFinder.add(true) : true;
                   }
                   if(barrFinder.isEmpty){//Playera gisen yol bossa
                       if(!possibleuppath.contains(upgap) || possibleuppath.isEmpty){
                           setState(() {
                             possibleuppath.add(upgap);
                             possibleuppath.toSet().toList();
                          });
                       }
                   }
                 }
                 else if(upgap+numberInRow == possibleuppath[k] - numberInRow){ // upgap üstteyse
                       if(!possibleuppath.contains(upgap) || possibleuppath.isEmpty){
                           setState(() {
                             possibleuppath.add(upgap);
                             possibleuppath.toSet().toList();
                           });
                       }
                 }
               }
            }
        }
  }
  else if((player/numberInRow).ceil() < (monster/numberInRow).ceil()){
        for (var downgap in monsterToPlayerGaps) {
         for (var k = 0; k < possibleuppath.length; k++) {
            if((downgap/numberInRow).ceil() - 2 == (possibleuppath[k]/numberInRow).ceil()){//İki gap arasında iki kat varsa
                  barrFinder = [];
                  if(downgap-numberInRow > possibleuppath[k] + numberInRow){ //downgap sağdaysa
                          for (var i = possibleuppath[k] + numberInRow; i < downgap-numberInRow; i++) {//Playera gisen yol bos mu
                            barriers.contains(i) ? barrFinder.add(true) : true;
                          }
                          if(monster > downgap + numberInRow && (monster/numberInRow).ceil() - 1 == (downgap/numberInRow).ceil()){
                              toMonster = [];
                              for (var i = downgap + numberInRow; i < monster; i++) {
                                  barriers.contains(i) ? toMonster.add(true) : true;
                               }
                          }
                          else if(monster < downgap + numberInRow && (monster/numberInRow).ceil() - 1 == (downgap/numberInRow).ceil()){
                              toMonster = [];
                              for (var i = monster; i < downgap + numberInRow; i++) {
                                  barriers.contains(i) ? toMonster.add(true) : true;
                               }
                          }
                          else if(monster == downgap + numberInRow && (monster/numberInRow).ceil() - 1 == (downgap/numberInRow).ceil()){
                              toMonster = [];
                          }
                          
                          if(barrFinder.isEmpty){//Playera gisen yol bossa
                              if(!possibleuppath.contains(downgap) || possibleuppath.isEmpty){
                                 if(!toMonster.contains(true)){
                                    setState(() {
                                    possibleuppath.add(downgap);
                                    possibleuppath.toSet().toList();
                                  });
                                 }
                                  
                              }
                            }
                 }
                 else if(downgap-numberInRow < possibleuppath[k] + numberInRow){ // upgap soldaysa
                   barrFinder = [];
                   for (var i = downgap-numberInRow; i < possibleuppath[k] + numberInRow; i++) {//Playera gisen yol bos mu
                     barriers.contains(i) ? barrFinder.add(true) : true;
                   }
                   if(barrFinder.isEmpty){//Playera gisen yol bossa
                       if(!possibleuppath.contains(downgap) || possibleuppath.isEmpty){
                           setState(() {
                             possibleuppath.add(downgap);
                             possibleuppath.toSet().toList();
                          });
                       }
                   }
                 }
                 else if(downgap-numberInRow == possibleuppath[k] + numberInRow){ // upgap üstteyse
                       if(!possibleuppath.contains(downgap) || possibleuppath.isEmpty){
                           setState(() {
                             possibleuppath.add(downgap);
                             possibleuppath.toSet().toList();
                           });
                       }
                 }
               }
            }
        }
  }
}
void playerUpOrDownMovementGapModifierFN(){
  if((player/numberInRow).ceil() > (monster/numberInRow).ceil()){
      for (var i = 0; i < possibleuppath.length; i++) {
         if((possibleuppath[i]/numberInRow).ceil() > (player/numberInRow).ceil()){
          setState(() {
            possibleuppath.remove(possibleuppath[i]);
          });
        }
      }
  }
  else if((player/numberInRow).ceil() < (monster/numberInRow).ceil()){
     for (var i = 0; i < possibleuppath.length; i++) {
       if((possibleuppath[i]/numberInRow).ceil() < (player/numberInRow).ceil()){
        setState(() {
          possibleuppath.remove(possibleuppath[i]);
        });
       }
      }
  }
}
void toPlayerGapModifierFN(){//Playerla üst gap arasında bariyer varsa gapi siler
  List<bool> barrFinder = [];
  if((player/numberInRow).ceil() > (monster/numberInRow).ceil()){
         for (var i = 0; i < possibleuppath.length; i++) {
            if((possibleuppath[i]/numberInRow).ceil() + 1 == (player/numberInRow).ceil()){
                  if(player > possibleuppath[i]+numberInRow){
                     
                     for (var j = possibleuppath[i]+numberInRow; j < player; j++) {
                       barriers.contains(j) ? barrFinder.add(true) : true;
                     }
                     if(barrFinder.contains(true)){
                      setState(() {
                        possibleuppath.remove(possibleuppath[i]);
                        barrFinder = [];
                      });
                     }
                  }
                  else if(player < possibleuppath[i]+numberInRow){
                     barrFinder = [];
                     for (var j = player; j < possibleuppath[i]+numberInRow; j++) {
                       barriers.contains(j) ? barrFinder.add(true) : true;
                     }
                     if(barrFinder.contains(true)){
                      setState(() {
                        possibleuppath.remove(possibleuppath[i]);
                        barrFinder = [];
                      });
                     }
                  }
             }
         }
  } 
  else if((player/numberInRow).ceil() < (monster/numberInRow).ceil()){
      for (var i = 0; i < possibleuppath.length; i++) {
         if((possibleuppath[i]/numberInRow).ceil() - 1 == (player/numberInRow).ceil()){
              if(player > possibleuppath[i]-numberInRow){    
                  for (var j = possibleuppath[i]-numberInRow; j < player; j++) {
                    barriers.contains(j) ? barrFinder.add(true) : true;
                  }
                  if(barrFinder.contains(true)){
                   setState(() {
                     possibleuppath.remove(possibleuppath[i]);
                     barrFinder = [];
                   });
                  }
               }
               else if(player < possibleuppath[i]-numberInRow){
                  barrFinder = [];
                  for (var j = player; j < possibleuppath[i]-numberInRow; j++) {
                    barriers.contains(j) ? barrFinder.add(true) : true;
                  }
                  if(barrFinder.contains(true)){
                   setState(() {
                     possibleuppath.remove(possibleuppath[i]);
                     barrFinder = [];
                   });
                  }
               }
          }
      }
  }
}
void monsterCurrentGapFN(){
  List<bool> stomonsterbarrFinder = [];
  List<bool> btomonsterbarrFinder = [];
  if((player/numberInRow).ceil() > (monster/numberInRow).ceil()){
        if(possibleuppath.length>=2){
           for (var i = 0; i < possibleuppath.length; i++) {
            for (var k = 0; k < possibleuppath.length; k++) { 
              if(possibleuppath[k] < possibleuppath[i]){
                  if((monster/numberInRow).ceil() + 1 == (possibleuppath[k]/numberInRow).ceil() && (monster/numberInRow).ceil() < (possibleuppath[i]/numberInRow).ceil() - 1){
                    //print('1');
                     setState(() {
                       currentgap = possibleuppath[k];
                     });
                  }
                  else if((possibleuppath[i]/numberInRow).ceil() > (possibleuppath[k]/numberInRow).ceil()){
                     //print('3');
                     setState(() {
                       currentgap = possibleuppath[k];
                     });
                  }
                  else if((possibleuppath[i]/numberInRow).ceil() == (possibleuppath[k]/numberInRow).ceil()){
                    if(possibleuppath[k]-numberInRow < monster){
                      for (var j = possibleuppath[k]-numberInRow; j < monster; j++) {
                         barriers.contains(j) ? stomonsterbarrFinder.add(true) : true;
                      }
                    }
                    else if(possibleuppath[k]-numberInRow > monster){
                      for (var j = monster; j < possibleuppath[k]-numberInRow; j++) {
                         barriers.contains(j) ? stomonsterbarrFinder.add(true) : true;
                      }
                    }
                    if(possibleuppath[i]-numberInRow < monster){
                      for (var j = possibleuppath[i]-numberInRow; j < monster; j++) {
                         barriers.contains(j) ? btomonsterbarrFinder.add(true) : true;
                      }
                    }
                    else if(possibleuppath[i]-numberInRow > monster){
                      for (var j = monster; j < possibleuppath[i]-numberInRow; j++) {
                         barriers.contains(j) ? btomonsterbarrFinder.add(true) : true;
                      }
                    }
                    
                     if((monster - (possibleuppath[k] - numberInRow)).abs() >= (monster - (possibleuppath[i] - numberInRow)).abs()){
                        if(!btomonsterbarrFinder.contains(true)){
                          setState(() {
                            currentgap = possibleuppath[i];
                          });
                        }
                     }
                     else if((monster - (possibleuppath[k] - numberInRow)).abs() < (monster - (possibleuppath[i] - numberInRow)).abs()){
                        if(!stomonsterbarrFinder.contains(true)){
                          setState(() {
                            currentgap = possibleuppath[k];
                          });
                        }
                     }
                  }
              }
            }
          }
        }
        else if(possibleuppath.length==1){
         setState(() {
           currentgap = possibleuppath[0];
         });
        }
  }
  else if((player/numberInRow).ceil() < (monster/numberInRow).ceil()){//Monster playerdan aşağıda
        if(possibleuppath.length>=2){
           for (var i = 0; i < possibleuppath.length; i++) {
            for (var k = 0; k < possibleuppath.length; k++) { 
              if(possibleuppath[k] < possibleuppath[i]){
                  if((monster/numberInRow).ceil() - 1 == (possibleuppath[i]/numberInRow).ceil() && (monster/numberInRow).ceil() > (possibleuppath[k]/numberInRow).ceil() + 1){
                    print('1');
                     setState(() {
                       currentgap = possibleuppath[i];
                     });
                  }
                  else if((possibleuppath[i]/numberInRow).ceil() > (possibleuppath[k]/numberInRow).ceil()){
                     print('3');
                     setState(() {
                       currentgap = possibleuppath[i];
                     });
                  }
                  else if((possibleuppath[i]/numberInRow).ceil() == (possibleuppath[k]/numberInRow).ceil() && (possibleuppath[k]/numberInRow).ceil() == (monster/numberInRow).ceil() - 1){
                   
                     if(possibleuppath[k]+numberInRow < monster){
                      for (var j = possibleuppath[k]+numberInRow; j < monster; j++) {
                         barriers.contains(j) ? stomonsterbarrFinder.add(true) : true;
                      }
                    }
                    else if(possibleuppath[k]+numberInRow > monster){
                      for (var j = monster; j < possibleuppath[k]+numberInRow; j++) {
                         barriers.contains(j) ? stomonsterbarrFinder.add(true) : true;
                      }
                    }
                    if(possibleuppath[i]+numberInRow < monster){
                      for (var j = possibleuppath[i]+numberInRow; j < monster; j++) {
                         barriers.contains(j) ? btomonsterbarrFinder.add(true) : true;
                      }
                    }
                    else if(possibleuppath[i]+numberInRow > monster){
                      for (var j = monster; j < possibleuppath[i]+numberInRow; j++) {
                         barriers.contains(j) ? btomonsterbarrFinder.add(true) : true;
                      }
                    }
                    
                     if((monster - (possibleuppath[k] + numberInRow)).abs() >= (monster - (possibleuppath[i] + numberInRow)).abs()){
                        if(!btomonsterbarrFinder.contains(true)){
                          setState(() {
                            currentgap = possibleuppath[i];
                          });
                        }
                     }
                     else if((monster - (possibleuppath[k] + numberInRow)).abs() < (monster - (possibleuppath[i] + numberInRow)).abs()){
                        if(!stomonsterbarrFinder.contains(true)){
                          setState(() {
                            currentgap = possibleuppath[k];
                          });
                        }
                     }
                  }
              }
            }
          }
        }
        else if(possibleuppath.length==1){
         setState(() {
           currentgap = possibleuppath[0];
         });
        }
        print('currentgap : $currentgap');
  }
}
void moveMonsterToUpOrDownFN(){
  if((player/numberInRow).ceil() > (monster/numberInRow).ceil()){
       if(monster > currentgap-numberInRow){
         if(!barriers.contains(monster - 1)){
           setState(() {
              monster--;
           });
         }
         
       }
       else if(monster < currentgap-numberInRow){
         if(!barriers.contains(monster + 1)){
           setState(() {
              monster++;
           });
         }
       }
       else if(monster == currentgap-numberInRow){
         setState(() {
           monster += numberInRow * 2;
         });
       }
       for (var i = 0; i < possibleuppath.length; i++) {
         if(possibleuppath[i] < monster){
           setState(() {
             possibleuppath.remove(possibleuppath[i]);
             monsterCurrentGapFN();
           });
         }
       }
  }
  else if((player/numberInRow).ceil() < (monster/numberInRow).ceil()){
       if(monster > currentgap+numberInRow){
         if(!barriers.contains(monster - 1)){
           setState(() {
              monster--;
           });
         }
         
       }
       else if(monster < currentgap+numberInRow){
         if(!barriers.contains(monster + 1)){
           setState(() {
              monster++;
           });
         }
       }
       else if(monster == currentgap+numberInRow){
         setState(() {
           monster -= numberInRow * 2;
         });
       }
       for (var i = 0; i < possibleuppath.length; i++) {
         if(possibleuppath[i] < monster){
           setState(() {
             possibleuppath.remove(possibleuppath[i]);
             monsterCurrentGapFN();
           });
         }
       }
  }
}
void playerAndMonsterSameLayerFN(){
  List<bool> barrFinder = [];
  if(monster > player){
    barrFinder = [];
    for (var i = player; i < monster; i++) {
      barriers.contains(i) ? barrFinder.add(true) : true ;
    }
    if(!barrFinder.contains(true)){
      setState(() {
        monster--;
      });
    }
    else if(barrFinder.contains(true)){
      if(!barriers.contains(monster - numberInRow)){
        setState(() {
          monster -= numberInRow * 2;
        });
      }
      else if(!barriers.contains(monster - numberInRow - 1)){
         setState(() {
           monster --;
           monster -= numberInRow * 2;
         });
      }
      else if(!barriers.contains(monster - numberInRow + 1)){
         setState(() {
           monster ++;
           monster -= numberInRow * 2;
         });
      }
      else if(!barriers.contains(monster + numberInRow - 1)){
         setState(() {
           monster --;
           monster += numberInRow * 2;
         });
      }
      else if(!barriers.contains(monster + numberInRow + 1)){
         setState(() {
           monster ++;
           monster += numberInRow * 2;
         });
      }
    }
  }
  else if(monster < player){
    barrFinder = [];
    for (var i = monster; i < player; i++) {
      barriers.contains(i) ? barrFinder.add(true) : true ;
    }
    if(!barrFinder.contains(true)){
      setState(() {
        monster++;
      });
    }
    else if(barrFinder.contains(true)){
      if(!barriers.contains(monster - numberInRow)){
        setState(() {
          monster -= numberInRow * 2;
        });
      }
      else if(!barriers.contains(monster - numberInRow - 1)){
         setState(() {
           monster --;
           monster -= numberInRow * 2;
         });
      }
      else if(!barriers.contains(monster - numberInRow + 1)){
         setState(() {
           monster ++;
           monster -= numberInRow * 2;
         });
      }
      else if(!barriers.contains(monster + numberInRow - 1)){
         setState(() {
           monster --;
           monster += numberInRow * 2;
         });
      }
      else if(!barriers.contains(monster + numberInRow + 1)){
         setState(() {
           monster ++;
           monster += numberInRow * 2;
         });
      }
    }
  }
}
void startGame() {
  getFood();
  setState(() {
     playing = true;
  }); 
  timetimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    setState(() {
      time++;
    });
  });
  playertimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (food.contains(player)) {
        food.remove(player);
        setState(() {
          score = score + 10;
        });
      }
      if (score < 100) {
        setState(() {
          myPlayerColor = 'yellow';
          powerlevel = -1;
        });
      }
      if (score > 99 && score < 160) {
        setState(() {
          myPlayerColor = 'red';
          powerlevel = 0;
        });
      } else if (score > 159 && score < 220) {
        setState(() {
          myPlayerColor = 'red';
          powerlevel = 1;
        });
      } else if (score > 219 && score < 280) {
        setState(() {
          myPlayerColor = 'red';
          powerlevel = 2;
        });
      } else if (score > 279) {
        setState(() {
          myPlayerColor = 'red';
          powerlevel = 3;
        });
      }
      if (food.isEmpty) {
        setState(() {
          win = true;
        });
      }
      switch (direction) {
        case "left":
          if (!barriers.contains(player - 1)) {
            setState(() {
              player--;
            });
          }
          break;
        case "right":
          if (!barriers.contains(player + 1)) {
            setState(() {
              player++;
            });
          }
          break;
        case "up":
          if (!barriers.contains(player - numberInRow)) {
            setState(() {
              player -= numberInRow;
            });
          }
          break;
        case "down":
          if (!barriers.contains(player + numberInRow)) {
            setState(() {
              player += numberInRow;
            });
          }
          break;
        default:
      }
  });
//////////////////////////////////////////////////////////// MONSTER AI//////////////////////////////////////////////////////////////
  monstertimer = Timer.periodic(const Duration(milliseconds: 1600), (timer) {
      
///////////////////////////////////////////////////////////////PLAYER MONSTERDAN AŞAĞIDA///////////////////////////////////////////////////////////////////
      if((player/numberInRow).ceil() > (monster/numberInRow).ceil()){ 
           monsterToPlayerGapsFN(); //Playerla monsterarasındaki tüm delikler
           possibleupordownpathHelperFN(); //Playerın üstündeki muhtemel yol
           playerUpOrDownMovementGapModifierFN();//Player yukarı çıktıkça alttaki gaplari siler.
           toPlayerGapModifierFN();//Playera gidilemeyen üstgaplari siler.
           monsterCurrentGapFN();//Monsterın gideceği yakın deliği bulur.
           moveMonsterToUpOrDownFN();
      }
      else if((player/numberInRow).ceil() < (monster/numberInRow).ceil()){
           monsterToPlayerGapsFN();
           possibleupordownpathHelperFN();
           playerUpOrDownMovementGapModifierFN();
           toPlayerGapModifierFN();
           monsterCurrentGapFN();
           moveMonsterToUpOrDownFN();
      }
      else if((player/numberInRow).ceil() == (monster/numberInRow).ceil()){ 
           playerUpOrDownMovementGapModifierFN();
           playerAndMonsterSameLayerFN();
      }
      if (monster == player) {
                if(powerlevel == -1){
                   setState(() {
                    lose = true;
                   });
                }else{
                  setState(() {
                    score -= 60;
                   });
                }
       
      }

   });    
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
}

  void getFood() {
    for (var i = 0; i < numberOfSquares; i++) {
      if (!barriers.contains(i)) {
        food.add(i);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    if(lose){timetimer.cancel();playertimer.cancel();monstertimer.cancel();
    //print('loooose');
    }
    if(win){timetimer.cancel();playertimer.cancel();monstertimer.cancel();
       usersCollection.doc(FirebaseAuth.instance.currentUser!.displayName).update({'time':time.toString()});
       usersCollection.doc(FirebaseAuth.instance.currentUser!.displayName).update({'score':score.toString()});
    }
    return lose ? 
      Scaffold(
            body: Column(
            children: [
              SizedBox(
                height: height*0.85,
                child: Column(
                 children: [
                   Center(
                         child: Column(
                           children: [
                            const SizedBox(height: 90,child: Text(''),),
                             Padding(
                               padding: const EdgeInsets.all(90.0),
                               child: Container(
                                decoration: const BoxDecoration(
                                  boxShadow: [BoxShadow(blurRadius: 3000,spreadRadius: 100,color: Colors.redAccent)]
                                ),
                                 child: const Text(
                                   'LOSE',
                                   style: TextStyle(fontSize: 50,color: Colors.white,fontWeight: FontWeight.bold,letterSpacing: 10),
                                 ),
                               ),
                             ),
                             Padding(
                               padding: const EdgeInsets.only(top: 50.0),
                               child: Text(
                                 'TIME : $time',
                                 style: const TextStyle(fontSize: 50,color: Colors.green),
                               ),
                             ),
                             Padding(
                               padding: const EdgeInsets.all(20.0),
                               child: Text(
                                 'SCORE : $score',
                                 style: const TextStyle(fontSize: 50,color: Color.fromARGB(255, 124, 238, 127)),
                               ),
                             ),
                           ],
                         )
                         ),
                         ]
                              ),
              ),
            SizedBox(
              height: 80,
              child: Container(
                decoration: const BoxDecoration(
                                  boxShadow: [BoxShadow(blurRadius: 30,spreadRadius: 20,color: Colors.green)]
                                ),
                  child: Center(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                    GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyApp())),
                        child: const Icon(
                          Icons.home,
                          size: 50,
                          color: Colors.white,
                        )),
                    GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Game())),
                        child: const Icon(
                          Icons.repeat,
                          size: 50,
                          color: Colors.white,
                        )),
                  ]
                  )
                  )
                  ),
            ),
            ] ),
          )
        : win
            ? Scaffold(
                body: Column(
                  children: [
                    Expanded(
                      flex: 7,
                      child: Container(
                        child: Center(
                            child: Column(
                              children: [
                                          const SizedBox(height: 90,child: Text(''),),
                                          Padding(
                                          padding: const EdgeInsets.all(90.0),
                                          child: Container(
                                           decoration: const BoxDecoration(
                                             boxShadow: [BoxShadow(blurRadius: 70,spreadRadius: 80,color: Colors.green)]
                                           ),
                                            child: const Text(
                                              'WIN',
                                              style: TextStyle(fontSize: 50,color: Colors.white,fontWeight: FontWeight.bold,letterSpacing: 10),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top: 40.0),
                                          child: Text(
                                            'TIME :  $time',
                                            style: const TextStyle(fontSize: 50,color: Colors.green),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(30.0),
                                          child: Text(
                                            'SCORE : $score',
                                            style: const TextStyle(fontSize: 50,color: Color.fromARGB(255, 102, 195, 106)),
                                          ),
                                        ),
                              ],
                            )
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      child: Container(
                        decoration: const BoxDecoration(
                                  boxShadow: [BoxShadow(blurRadius: 30,spreadRadius: 1,color: Colors.green)]
                                ),
                          child: Center(
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                            GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const MyApp()));
                              },
                              child: const Icon(
                                Icons.home,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                            GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const Game()));
                                },
                                child: const Icon(
                                  Icons.repeat,
                                  size: 50,
                                  color: Colors.white,
                                )),
                          ]))),
                    ),
                  ],
                ),
              )
            : StreamBuilder<QuerySnapshot<Object?>>(
                stream: usersCollection.snapshots(),
                builder: (context, snapshot) {
                  ////print('snapshot : ' + snapshot.data!.docs[0].data().toString());
                  if (snapshot.hasError) {
                    //print(snapshot.error);
                    return Text('Error: ${snapshot.error}');
                  }
                  if (snapshot.hasData) {
                  } else if (!snapshot.hasData) {
                    //print('snapshot.data yok Game');
                  }

                  return Scaffold(
                    backgroundColor: Colors.black,
                    body: Column(
                      children: [
                        Expanded(
                            flex: 5,
                            child: GestureDetector(
                              onVerticalDragUpdate: (details) {
                                if (details.delta.dy > 0) {
                                  direction = "down";
                                } else if (details.delta.dy < 0) {
                                  direction = "up";
                                }
                              },
                              onHorizontalDragUpdate: (details) {
                                if (details.delta.dx > 0) {
                                  direction = "right";
                                } else if (details.delta.dx < 0) {
                                  direction = "left";
                                }
                              },
                              child: Container(
                                color: Colors.black,
                                child: GridView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: numberOfSquares,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: numberInRow),
                                    itemBuilder:
                                        (BuildContext contex, int index) {
                                      if (player == index) {
                                        switch (direction) {
                                          case "left":
                                            return Transform.rotate(
                                              angle: pi,
                                              child: MyPlayer(
                                                color: myPlayerColor,
                                                powerlevel: powerlevel,
                                              ),
                                            );
                                          case "right":
                                            return Transform.rotate(
                                              angle: pi * 2,
                                              child: MyPlayer(
                                                color: myPlayerColor,
                                                powerlevel: powerlevel,
                                              ),
                                            );
                                          case "up":
                                            return Transform.rotate(
                                              angle: pi * 3 / 2,
                                              child: MyPlayer(
                                                color: myPlayerColor,
                                                powerlevel: powerlevel,
                                              ),
                                            );
                                          case "down":
                                            return Transform.rotate(
                                              angle: pi * 5 / 2,
                                              child: MyPlayer(
                                                color: myPlayerColor,
                                                powerlevel: powerlevel,
                                              ),
                                            );
                                          default:
                                            return MyPlayer(
                                              color: myPlayerColor,
                                              powerlevel: powerlevel,
                                            );
                                        }
                                      } else if (barriers.contains(index)) {
                                        if (sidebarriers.contains(index)) {
                                          return MyPixel(
                                              innercolor: Colors.blue[800],
                                              outercolor: Colors.blue[900],
                                              child: 
                                                 const Icon(
                                                   Icons.lock,
                                                   size: 13,
                                                 )
                                              );
                                        } else if(levelBarriers.contains(index)){
                                          // removableBarrier = index;
                                          return MyPixel(
                                              innercolor: Colors.blue[800],
                                              outercolor: Colors.blue[900],
                                              child: const Icon(
                                                Icons.lock,
                                                size: 13,
                                                color: Colors.black,
                                              ));
                                        }
                                      } else if (monsterpath.contains(index)) {
                                        if (monster == index) {
                                            monsterpath.add(index);
                                          
                                          return const Monster();
                                          
                                        }
                                        return MyPath(
                                            innercolor: Colors.yellow,
                                            outercolor: Colors.black,
                                            child: Text(index.toString()));
                                      } else {
                                        if (monster == index) {
                                            monsterpath.add(index);
                                          return const Monster();
                                        }
                                        return const MyPath(
                                            
                                            innercolor: Colors.black,
                                            outercolor: Colors.black);
                                      }
                                      return null;
                                    }),
                              ),
                            )),
                        SizedBox(
                          height: 50,
                          child: Row(
                            children: [
                              SizedBox(
                               
                              height: 50,
                              width: width/3,
                               child: const Center(child: Text('POWER',style: TextStyle(color: Colors.purple,fontSize: 30),)),
                                                    ),
                              SizedBox(
                               
                              height: 50,
                              width: width/3,
                               child: const Center(child: Text(':',style: TextStyle(color: Colors.purple,fontSize: 30),)),
                                                    ),
                              SizedBox(
                               
                              height: 50,
                              width: width/3,
                               child: Center(child: Text((powerlevel+1).toString(),style: const TextStyle(color: Colors.purple,fontSize: 30),)),
                                                    ),
                            ],
                          )),
                          SizedBox(
                          height: 50,
                          child: Row(
                            children: [
                              SizedBox(
                               
                              height: 50,
                              width: width/3,
                               child: const Center(child: Text('TIME',style: TextStyle(color: Colors.purple,fontSize: 30),)),
                                                    ),
                              SizedBox(
                               
                              height: 50,
                              width: width/3,
                               child: const Center(child: Text(':',style: TextStyle(color: Colors.purple,fontSize: 30),)),
                                                    ),
                              SizedBox(
                               
                              height: 50,
                              width: width/3,
                               child: Center(child: Text((time).toString(),style: const TextStyle(color: Colors.purple,fontSize: 30),)),
                                                    ),
                            ],
                          )),
                        Expanded(
                            flex: 1,

                            child: Container(
                                color: const Color.fromARGB(144, 136, 255, 0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                        child: const Text(
                                      "  Score    : ",
                                      style: TextStyle(
                                          color: Colors.amberAccent, fontSize: 40),
                                    )),
                                    Container(
                                        child: Text(
                                      score.toString(),
                                      style: const TextStyle(
                                          color: Colors.amberAccent, fontSize: 40),
                                    )),
                                    playing
                                        ? Container(
                                            child: GestureDetector(
                                                onTap: () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const Intro())),
                                                child: Container(
                                                    color: Colors.orange,
                                                    height: 90,
                                                    width: 90,
                                                    child: const Icon(
                                                      Icons.keyboard_return,
                                                      color: Colors.white,
                                                      size: 40,
                                                      fill: 1,
                                                    ))))
                                        : GestureDetector(
                                            onTap :()  {startGame();},
                                            child: Center(
                                              child: Container(
                                                height: 100,
                                                color: Colors.amberAccent,
                                                child: const Center(
                                                  child: Text(
                                                    "P L A Y",
                                                    style: TextStyle(
                                                        color: Colors.purple,
                                                        fontSize: 40),
                                                  ),
                                                ),
                                              ),
                                            )),
                                  ],
                                )))
                      ],
                    ),
                  );
                });
  }
}
