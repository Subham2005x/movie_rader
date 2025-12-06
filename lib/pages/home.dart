import 'package:flutter/material.dart';
import 'package:movie_rader/widgets/comingsoon.dart';
import 'package:tmdb_api/tmdb_api.dart';
import 'package:movie_rader/widgets/trendingmovie.dart';
import 'package:movie_rader/widgets/MostPopular.dart';
import 'package:movie_rader/widgets/toprated.dart';
// import 'package:movie_rader/widgets/tophindi.dart';
import 'package:movie_rader/pages/search.dart';
import 'package:movie_rader/pages/tv.dart' as TvPage;

class Home extends StatefulWidget {
  final int initialIndex;
  const Home({super.key, this.initialIndex = 0});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List trendingmovies = [];
  List comingsoon = [];
  List mostpopular = [];
  List toprated = [];
  List tophindi = [];
  List genres = [];
  bool _isLoading = true;
  bool _hasError = false;
  int _retryCount = 0;
  final int _maxRetries = 5;

  final String apikey = "e0d56cbed100b1c110143ac896b51913";
  final readaccesstoken =
      "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJlMGQ1NmNiZWQxMDBiMWMxMTAxNDNhYzg5NmI1MTkxMyIsIm5iZiI6MTc2MzUzODg0MS4yNDEsInN1YiI6IjY5MWQ3Nzk5NDVhMTQ0OTQxNjJlMTk1NCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.IZUTpsCrXtWdYqs4CrZXhxiX3SgiG4T3sG7B8kkPWBw";

  Future<void> loadmovies() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      var tmdbcustomlogs = TMDB(
        ApiKeys(apikey, readaccesstoken),
        logConfig: ConfigLogger(showLogs: true, showErrorLogs: true),
      );

      Map trendingresult = await tmdbcustomlogs.v3.trending.getTrending(
        mediaType: MediaType.movie,
        timeWindow: TimeWindow.week,
      );
      Map comingsoonresult = await tmdbcustomlogs.v3.movies.getUpcoming();
      Map mostpopularresult = await tmdbcustomlogs.v3.movies.getPopular();
      Map topratedresult = await tmdbcustomlogs.v3.movies.getTopRated();
      Map genresresult = await tmdbcustomlogs.v3.genres.getMovieList();

      // Sort coming soon movies by release date (newest first)
      List comingsoonList = comingsoonresult['results'] ?? [];
      comingsoonList.sort((a, b) {
        String dateA = a['release_date'] ?? '';
        String dateB = b['release_date'] ?? '';
        return dateB.compareTo(dateA); // Descending order (newest first)
      });

      if (mounted) {
        setState(() {
          trendingmovies = trendingresult['results'] ?? [];
          comingsoon = comingsoonList;
          mostpopular = mostpopularresult['results'] ?? [];
          toprated = topratedresult['results'] ?? [];
          genres = genresresult['genres'] ?? [];
          _isLoading = false;
          _retryCount = 0;
        });
      }
    } catch (e) {
      print(
        'Error loading movies (attempt ${_retryCount + 1}/$_maxRetries): $e',
      );

      if (mounted) {
        if (_retryCount < _maxRetries) {
          _retryCount++;
          setState(() {
            _isLoading = true;
          });

          await Future.delayed(Duration(seconds: 2 * _retryCount));

          if (mounted) {
            loadmovies();
          }
        } else {
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
        }
      }
    }
    print(trendingmovies);
  }

  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    loadmovies();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          if (index == 0) {
            return Home(initialIndex: 0);
          } else if (index == 1) {
            return TvPage.TvShow(initialIndex: 1);
          } else {
            return Home(initialIndex: 2);
          }
        },
      ),
    );
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
      drawer: Drawer(child: sideDrawer(context, genres)),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.red[400]),
                  SizedBox(height: 16),
                  Text(
                    'Loading movies...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  if (_retryCount > 0)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Retry attempt $_retryCount/$_maxRetries',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                ],
              ),
            )
          : _hasError
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load movies',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please check your internet connection',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      _retryCount = 0;
                      loadmovies();
                    },
                    icon: Icon(Icons.refresh),
                    label: Text('Retry Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(5, 16, 5, 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Comingsoon(comingsoon: comingsoon),
                  // Tophindi(tophindi: tophindi),
                  Trendingmovie(trendingmovies: trendingmovies),
                  Mostpopular(mostpopular: mostpopular),
                  Toprated(toprated: toprated),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Movies'),
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'Web Series'),
        ],
        onTap: (index) {
          _onItemTapped(index);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                if (index == 0) {
                  return Home();
                } else if (index == 1) {
                  return TvPage.TvShow();
                } else {
                  return Home();
                }
              },
            ),
          );
        },
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

Widget sideDrawer(BuildContext context, List genres) {
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
        height: MediaQuery.of(context).size.height * 0.68,
        padding: EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [for (var genre in genres) customWrapWidget(genre['name'])],
        ),
      ),
      Container(
        child: Align(
          alignment: Alignment.center,
          child: Text(
            "Crafted with ❤️ by Subham",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
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
