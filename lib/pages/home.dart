import 'package:flutter/material.dart';
import 'package:movie_rader/widgets/comingsoon.dart';
import 'package:tmdb_api/tmdb_api.dart';
import 'package:movie_rader/widgets/trendingmovie.dart';
import 'package:movie_rader/widgets/MostPopular.dart';
import 'package:movie_rader/widgets/toprated.dart';
import 'package:movie_rader/pages/search.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List trendingmovies = [];
  final String apikey = "e0d56cbed100b1c110143ac896b51913";
  final readaccesstoken =
      "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJlMGQ1NmNiZWQxMDBiMWMxMTAxNDNhYzg5NmI1MTkxMyIsIm5iZiI6MTc2MzUzODg0MS4yNDEsInN1YiI6IjY5MWQ3Nzk5NDVhMTQ0OTQxNjJlMTk1NCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.IZUTpsCrXtWdYqs4CrZXhxiX3SgiG4T3sG7B8kkPWBw";

  @override
  void initState() {
    loadmovies();
    super.initState();
  }

  loadmovies() async {
    var tmdbcustomlogs = TMDB(ApiKeys(apikey, readaccesstoken));
    logConfig:
    ConfigLogger(showLogs: true, showErrorLogs: true);
    Map trendingresult = await tmdbcustomlogs.v3.trending.getTrending();

    setState(() {
      trendingmovies = trendingresult['results'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Movie Radar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.red[400],
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchMovie()),
              );
            },
            icon: Icon(Icons.search),
          ),
        ],
      ),
      drawer: Drawer(child: sideDrawer(context)),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(5, 16, 5, 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Comingsoon(comingsoon: trendingmovies),
            Trendingmovie(trendingmovies: trendingmovies),
            Mostpopular(mostpopular: trendingmovies),
            Toprated(toprated: trendingmovies),
          ],
        ),
      ),
    );
  }
}

Widget sideDrawer(BuildContext context) {
  return ListView(
    children: [
      DrawerHeader(
        child: Row(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                "https://w7.pngwing.com/pngs/340/946/png-transparent-avatar-user-computer-icons-software-developer-avatar-child-face-heroes-thumbnail.png",
              ),
            ),
            Column(
              children: [
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(8),
                  child: Text("Guest Account"),
                ),
                Container(),
              ],
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
        child: Text(
          "Genre",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            customWrapWidget("Adventure"),
            customWrapWidget("Movies"),
            customWrapWidget("TV Shows"),
            customWrapWidget("Favorites "),
            customWrapWidget("Settings"),
            customWrapWidget("Settings"),
            customWrapWidget("Settings"),
            customWrapWidget("Settings"),
          ],
        ),
      ),
      Container(
        child: Align(
          alignment: Alignment.center,
          child: Text("Crafted with ❤️ by Subham"),
        ),
      ),
    ],
  );
}

Widget customWrapWidget(String text) {
  return InkWell(
    onTap: () {},
    splashColor: Colors.transparent,
    child: Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.transparent,
        border: Border.all(color: Colors.red, width: 2),
      ),
      child: Text(text, style: TextStyle(color: Colors.white)),
    ),
  );
}
