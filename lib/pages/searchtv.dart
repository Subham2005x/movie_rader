import 'package:flutter/material.dart';
import 'package:movie_rader/pages/detailedtv.dart';
import 'package:tmdb_api/tmdb_api.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Searchtv extends StatefulWidget {
  const Searchtv({super.key});

  @override
  State<Searchtv> createState() => _SearchtvState();
}

class _SearchtvState extends State<Searchtv> {
  List searchResult = [];
  final String apikey = dotenv.env['ApiKey'] ?? '';
  final readaccesstoken = dotenv.env['readAccessToken'] ?? '';
  bool _isSearching = false;
  String _lastQuery = '';
  int _retryCount = 0;
  final int _maxRetries = 3;

  Future<void> loadmovies(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResult = [];
        _isSearching = false;
      });
      return;
    }

    _lastQuery = query;
    if (!mounted) return;

    setState(() {
      _isSearching = true;
    });

    try {
      var tmdbcustomlogs = TMDB(ApiKeys(apikey, readaccesstoken));
      Map result = await tmdbcustomlogs.v3.search.queryTvShows(query);

      if (mounted && _lastQuery == query) {
        setState(() {
          searchResult = result['results'] ?? [];
          _isSearching = false;
          _retryCount = 0;
        });
      }
    } catch (e) {
      print('Error searching movies: $e');

      if (_retryCount < _maxRetries && mounted && _lastQuery == query) {
        _retryCount++;
        print('Retrying search... Attempt $_retryCount of $_maxRetries');
        await Future.delayed(Duration(seconds: 2 * _retryCount));
        if (mounted && _lastQuery == query) {
          await loadmovies(query);
        }
      } else {
        if (mounted && _lastQuery == query) {
          setState(() {
            _isSearching = false;
            searchResult = [];
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to search. Please check your connection.'),
              backgroundColor: Colors.red[400],
            ),
          );
        }
      }
    }
    print(searchResult);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Movie Radar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red[400],
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for a web series',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  loadmovies(value);
                },
              ),
            ),
            Expanded(
              child: _isSearching
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.red[400]),
                          SizedBox(height: 16),
                          Text(
                            'Searching...',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                          if (_retryCount > 0)
                            Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'Retrying... ($_retryCount/$_maxRetries)',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ),
                        ],
                      ),
                    )
                  : searchResult.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 80, color: Colors.grey[700]),
                          SizedBox(height: 16),
                          Text(
                            'Search for web series',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.all(6),
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: searchResult.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailedTv(
                                    movieId: searchResult[index]['id']
                                        .toString(),
                                  ),
                                ),
                              );
                            },
                            splashColor: Colors.transparent,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey[900],
                              ),
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                              padding: EdgeInsets.all(8),
                              // color: Colors.amber,
                              height: 250,
                              child: Row(
                                children: [
                                  Container(
                                    width: 150,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[800],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child:
                                          searchResult[index]['poster_path'] !=
                                              null
                                          ? Image.network(
                                              'https://image.tmdb.org/t/p/w200${searchResult[index]['poster_path']}',
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Center(
                                                      child: Icon(
                                                        Icons.movie,
                                                        color: Colors.grey[600],
                                                        size: 40,
                                                      ),
                                                    );
                                                  },
                                            )
                                          : Center(
                                              child: Icon(
                                                Icons.movie,
                                                color: Colors.grey[600],
                                                size: 40,
                                              ),
                                            ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 12),
                                        Text(
                                          searchResult[index]['name'] ??
                                              "Movie Name",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              size: 14,
                                              color: Colors.grey[400],
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              searchResult[index]['first_air_date'] !=
                                                          null &&
                                                      searchResult[index]['first_air_date']
                                                          .toString()
                                                          .isNotEmpty
                                                  ? searchResult[index]['first_air_date']
                                                        .toString()
                                                  : "N/A",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey[400],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              size: 18,
                                              color: Colors.amber,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              searchResult[index]['vote_average'] !=
                                                      null
                                                  ? "${(searchResult[index]['vote_average'] as num).toStringAsFixed(1)}"
                                                  : "N/A",
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.grey[400],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget customWrapWidget(String text) {
  return InkWell(
    onTap: () {},
    splashColor: Colors.transparent,
    child: Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.transparent,
        border: Border.all(color: Colors.red, width: 2),
      ),
      child: Text(text, style: TextStyle(color: Colors.white, fontSize: 14)),
    ),
  );
}
