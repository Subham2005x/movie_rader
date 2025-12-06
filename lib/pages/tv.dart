import 'package:flutter/material.dart';
import 'package:movie_rader/pages/category.dart';
import 'package:movie_rader/widgets/MostPopulartv.dart';
import 'package:movie_rader/widgets/airingtodaytv.dart';
import 'package:movie_rader/widgets/popularhinditv.dart';
import 'package:movie_rader/widgets/topratedtv.dart';
import 'package:tmdb_api/tmdb_api.dart';
import 'package:movie_rader/pages/home.dart';
import 'package:movie_rader/pages/searchtv.dart';

class TvShow extends StatefulWidget {
  final int initialIndex;
  const TvShow({super.key, this.initialIndex = 1});

  @override
  State<TvShow> createState() => _TvShowState();
}

class _TvShowState extends State<TvShow> {
  List airingtoday = [];
  List onair = [];
  List mostpopular = [];
  List toprated = [];
  List genres = [];
  List popularhinditv = [];
  bool _isLoading = true;
  bool _hasError = false;
  int _retryCount = 0;
  int selectedGenreId = 0;
  List genresseriesresult = [];
  final int _maxRetries = 5;
  List<String> bannedDomains = [
  "ullu.app",
  "ullu.com",
  "ullu.digital",
  "altbalaji.com",
  "balajitelefilms",
  "kooku.app",
  "kooku.app",
  "hotshots",
  "flizmovies",
  "rabbitmovies",
  "primeshots",
  "huntcinema",
  "boomfilms",
  "hotsflix",
];

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

      Map airingtodayresult = await tmdbcustomlogs.v3.tv.getAiringToday();
      Map genresresult = await tmdbcustomlogs.v3.genres.getTvlist();
      Map onairtodayresult = await tmdbcustomlogs.v3.tv.getOnTheAir();
      Map mostpopularresult = await tmdbcustomlogs.v3.tv.getPopular();
      Map topratedresult = await tmdbcustomlogs.v3.tv.getTopRated();
      Map popularhinditvresult = await tmdbcustomlogs.v3.discover.getTvShows(
        withOrginalLanguage: "hi",
      );

      List popularhinditvsort = [];
      
      for (var item in popularhinditvresult['results']) {
        try {
          // Fetch detailed info for each TV show to get homepage
          Map tvDetails = await tmdbcustomlogs.v3.tv.getDetails(item['id']);
          
          String homepage = tvDetails['homepage'] ?? '';

          // Check for banned domains in homepage
          bool hasBannedDomain = bannedDomains.any((domain) => homepage.toLowerCase().contains(domain.toLowerCase()));
          
          if (!hasBannedDomain) {
        // Add the item with details merged
        popularhinditvsort.add({...item, ...tvDetails});
          }
        } catch (e) {
          print('Error fetching details for TV show ${item['id']}: $e');
          // Skip this item if there's an error
        }
      }

      popularhinditvsort.sort(
        (a, b) => ((b['popularity'] ?? 0) as num).compareTo((a['popularity'] ?? 0) as num),
      );

      final List popularHindiWithDetails = popularhinditvsort;

      if (mounted) {
        setState(() {
          airingtoday = airingtodayresult['results'] ?? [];
          onair = onairtodayresult['results'] ?? [];
          mostpopular = mostpopularresult['results'] ?? [];
          toprated = topratedresult['results'] ?? [];
          genres = genresresult['genres'] ?? [];
          popularhinditv = popularHindiWithDetails;
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
    print(popularhinditv);
  }

  Future<void> selectGenre(int genreId) async {
    setState(() {
      selectedGenreId = genreId;
    });

    // Close the drawer first
    Navigator.pop(context);

    // Small delay to ensure drawer is closed
    await Future.delayed(Duration(milliseconds: 100));

    if (!mounted) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator(color: Colors.red[400]));
      },
    );

    int retryCount = 0;
    int maxRetries = 5;
    bool success = false;

    while (retryCount < maxRetries && !success) {
      try {
        print(
          'Attempting to load genre movies (attempt ${retryCount + 1}/$maxRetries)',
        );

        var tmdbcustomlogs = TMDB(
          ApiKeys(apikey, readaccesstoken),
          logConfig: ConfigLogger(showLogs: true, showErrorLogs: true),
        );

        Map genresseries = await tmdbcustomlogs.v3.discover.getTvShows(
          withGenres: selectedGenreId.toString(),
        );

        genresseriesresult = genresseries['results'] ?? [];
        print('Genre series loaded: ${genresseriesresult.length} series');
        success = true;

        if (mounted) {
          // Close loading dialog
          Navigator.pop(context);

          // Navigate to category page
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryGenre(
                genreresult: genresseriesresult,
                genreName: genres.firstWhere(
                  (genre) => genre['id'] == selectedGenreId,
                  orElse: () => {'name': 'Selected Genre'},
                )['name'],
                type: "Series",
              ),
            ),
          );
        }
      } catch (e) {
        print(
          'Error loading genre movies (attempt ${retryCount + 1}/$maxRetries): $e',
        );
        retryCount++;

        if (retryCount < maxRetries) {
          // Wait before retrying (exponential backoff)
          await Future.delayed(Duration(seconds: 2 * retryCount));
        } else {
          // All retries failed
          if (mounted) {
            // Close loading dialog
            Navigator.pop(context);

            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to load genre movies after $maxRetries attempts. Please try again.',
                ),
                backgroundColor: Colors.red[400],
                duration: Duration(seconds: 4),
              ),
            );
          }
        }
      }
    }
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
            return Home();
          } else if (index == 1) {
            return TvShow(initialIndex: 1);
          } else {
            return Home();
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
                MaterialPageRoute(builder: (context) => Searchtv()),
              );
            },
            icon: Icon(Icons.search),
          ),
        ],
      ),
      drawer: Drawer(child: sideDrawer(context, genres, selectGenre)),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.red[400]),
                  SizedBox(height: 16),
                  Text(
                    'Loading Series...',
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
                  // Comingsoon(comingsoon: comingsoon),
                  // // Tophindi(tophindi: tophindi),
                  // Trendingmovie(trendingmovies: trendingmovies),
                  // Mostpopular(mostpopular: mostpopular),
                  // Toprated(toprated: toprated),
                  TopratedTv(toprated: toprated),
                  Popularhinditv(popularhinditv: popularhinditv),
                  MostpopularTv(mostpopular: mostpopular),
                  Airingtodaytv(airingtoday: airingtoday),
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
        },
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red[400],
        unselectedItemColor: Colors.grey,
        // backgroundColor: Colors.black,
      ),
    );
  }
}

Widget sideDrawer(BuildContext context, List genres, Function(int) onGenreSelected) {
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
          children: [for (var genre in genres) customWrapWidget(genre['name'], genre['id'], onGenreSelected)],
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

Widget customWrapWidget(String text, int id, Function onGenreSelected) {
  return InkWell(
    onTap: () {
      print('Genre selected: $text');
      onGenreSelected(id);
    },
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
