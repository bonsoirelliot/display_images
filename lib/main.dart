import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'List of Images',
      home: MyHomePage(),
      initialRoute: MyHomePage.id,
    );
  }
}

class MyHomePage extends StatefulWidget {
  static const String id = 'HOME';

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<ImagePlace>> _getImages() async {
    http.Response response = await http.get(
        "https://api.unsplash.com/photos/?client_id=ab3411e4ac868c2646c0ed488dfd919ef612b04c264f3374c97fff98ed253dc9");
    var jsonData = json.decode(response.body);

    List<ImagePlace> imageplaces = [];

    for (var i in jsonData) {
      ImagePlace imageplace = ImagePlace(
        i['urls']['thumb'],
        i['urls']['regular'],
        i['user']['name'],
        i['alt_description'],
      );
      imageplaces.add(imageplace);
    }
    return imageplaces;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        title: Text('Get the images from API'),
        backgroundColor: Colors.blueGrey,
      ),
      body: SafeArea(
        child: Container(
          child: FutureBuilder(
            future: _getImages(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return Container(
                    child: Center(child: CircularProgressIndicator()));
              } else {
                return ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(snapshot.data[index].imageUrl),
                        radius: 30,
                      ),
                      title: Text(snapshot.data[index].name),
                      subtitle: Text(snapshot.data[index].authorName),
                      trailing: CircleAvatar(
                        child: Text(index.toString(),
                            style: TextStyle(color: Colors.white)),
                        backgroundColor: Colors.blueGrey,
                      ),
                      contentPadding: EdgeInsets.all(15),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ImagePage(
                                      imageUrl:
                                          snapshot.data[index].regularImageUrl,
                                    )));
                      },
                    );
                  },
                  itemCount: snapshot.data.length,
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class ImagePage extends StatelessWidget {
  final String imageUrl;

  const ImagePage({Key key, this.imageUrl}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey,
            leading: FloatingActionButton(
              backgroundColor: Colors.blueGrey[600],
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Icon(Icons.arrow_back))),
        body: Container(
          alignment: Alignment.center,
          child: Image(
            image: NetworkImage(imageUrl),
            fit: BoxFit.contain,
          ),
        ));
  }
}

class ImagePlace {
  final String imageUrl;
  final String regularImageUrl;
  final String authorName;
  final String name;

  ImagePlace(this.imageUrl, this.regularImageUrl, this.authorName, this.name);
}
