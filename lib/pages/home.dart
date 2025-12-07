import 'package:flutter/material.dart';
import 'package:movie_rader/pages/search.dart';
import 'package:movie_rader/widgets/comingsoon.dart';
import 'package:movie_rader/widgets/newrealeasehindi.dart';
import 'package:movie_rader/widgets/tophindi.dart';
import 'package:tmdb_api/tmdb_api.dart';
import 'package:movie_rader/widgets/trendingmovie.dart';
import 'package:movie_rader/widgets/MostPopular.dart';
import 'package:movie_rader/widgets/toprated.dart';
// import 'package:movie_rader/widgets/tophindi.dart';
import 'package:movie_rader/pages/tv.dart' as TvPage;
import 'package:movie_rader/pages/category.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  List popularhindi = [];
  List genres = [];
  List newreleases = [];
  List genresmoviesresult = [];
  bool _isLoading = true;
  bool _hasError = false;
  int _retryCount = 0;
  final int _maxRetries = 5;
  int selectedGenreId = -1;

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

  final String apikey = dotenv.env['ApiKey'] ?? '';
  final readaccesstoken = dotenv.env['readAccessToken'] ?? '';

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
      Map popularhindimovieresult = await tmdbcustomlogs.v3.discover.getMovies(
        // primaryReleaseYear: DateTime.now().year,
        year: DateTime.now().year,
        voteAverageGreaterThan: 6,

        // sortBy: SortMoviesBy.popularityDesc,
        withOrginalLanguage: "hi",
      );
      Map newreleasesresult = await tmdbcustomlogs.v3.discover.getMovies(
        primaryReleaseYear: DateTime.now().year,
        sortBy: SortMoviesBy.releaseDateDesc,
        withOrginalLanguage: "hi",
      );

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
          popularhindi = popularhindimovieresult['results'] ?? [];
          newreleases = newreleasesresult['results'] ?? [];
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

    print(genresmoviesresult);
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

        Map genresmovies = await tmdbcustomlogs.v3.discover.getMovies(
          withGenres: selectedGenreId.toString(),
        );

        genresmoviesresult = genresmovies['results'] ?? [];

        print('Genre movies loaded: ${genresmoviesresult.length} movies');
        success = true;

        if (mounted) {
          // Close loading dialog
          Navigator.pop(context);

          // Navigate to category page
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryGenre(
                genreresult: genresmoviesresult,
                genreName: genres.firstWhere(
                  (genre) => genre['id'] == selectedGenreId,
                  orElse: () => {'name': 'Selected Genre'},
                )['name'],
                type: "Movies",
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
                MaterialPageRoute(
                  builder: (context) =>
                      SearchMovie(),
                ),
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
                  Tophindi(tophindi: popularhindi),
                  Trendingmovie(trendingmovies: trendingmovies),
                  Mostpopular(mostpopular: mostpopular),
                  NewReleaseHindi(newreleasehindi: newreleases),
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
        // backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

Widget sideDrawer(
  BuildContext context,
  List genres,
  Function(int) onGenreSelected,
) {
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
          children: [
            for (var genre in genres)
              customWrapWidget(genre['name'], genre['id'], onGenreSelected),
          ],
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

Widget customWrapWidget(String text, int id, Function(int) onGenreSelected) {
  return InkWell(
    onTap: () {
      print("Selected Genre ID: $id");
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
