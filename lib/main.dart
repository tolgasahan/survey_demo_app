import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Survey"),
        ),
        body: SurveyList(),
      ),
    );
  }
}

class SurveyList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SurveyListState();
  }
}

class SurveyListState extends State {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("langsurvey").snapshots(),
      builder: (context,snapshot){
        if(!snapshot.hasData){
          return LinearProgressIndicator();
        }
        else{
          return buildBody(context, snapshot.data!.docs);
        }
      });
      

  }

  Widget buildBody(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: EdgeInsets.only(top: 20.0),
      children: snapshot.map<Widget>((data) => buildListItem(context, data)).toList(),
    );
  }

  buildListItem(BuildContext context, DocumentSnapshot data) {


    final row = Survey.fromSnapshot(data);
    return Padding(
      key: ValueKey(row.name),
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5.0)),
        child: ListTile(
          title: Text(row.name),
          trailing: Text(row.vote.toString()),
          onTap: () =>FirebaseFirestore.instance.runTransaction((transaction) async{
            final freshSnapshot = await transaction.get(row.reference as DocumentReference);
            final fresh = Survey.fromSnapshot(freshSnapshot);
            await transaction.update(row.reference as DocumentReference, {"vote":fresh.vote+1});
          }),
        ),
      ),
    );
  }
}

final fakeSnapshot = [
  {"name": "C#", "vote": 4},
  {"name": "Java", "vote": 6},
  {"name": "Dart", "vote": 1},
  {"name": "C++", "vote": 9},
  {"name": "Perl", "vote": 22},
];

class Survey {
  String name;
  int vote;
  DocumentReference? reference;

  Survey.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map["name"] != null),
        assert(map["vote"] != null),
        name = map["name"],
        vote = map["vote"];


  Survey.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data() as Map<String,dynamic>,
            reference: snapshot.reference);
}
