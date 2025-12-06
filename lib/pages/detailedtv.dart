import 'package:flutter/material.dart';
import 'package:movie_rader/pages/watchtv.dart';
import 'package:tmdb_api/tmdb_api.dart';

class DetailedTv extends StatefulWidget {
  const DetailedTv({super.key, required this.movieId});

  final String movieId;

  @override
  State<DetailedTv> createState() => _DetailedTvState();
}

class _DetailedTvState extends State<DetailedTv> {
  Map<dynamic, dynamic> movieDetails = {};
  Map<dynamic, dynamic> movieCredits = {};
  Map<dynamic, dynamic> seasonDetail = {};
  bool _isLoading = true;
  bool _hasError = false;
  int _retryCount = 0;
  final int _maxRetries = 5;

  @override
  void initState() {
    super.initState();
    _loadMovieDetails();
  }

  final String apikey = "e0d56cbed100b1c110143ac896b51913";
  final readaccesstoken =
      "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJlMGQ1NmNiZWQxMDBiMWMxMTAxNDNhYzg5NmI1MTkxMyIsIm5iZiI6MTc2MzUzODg0MS4yNDEsInN1YiI6IjY5MWQ3Nzk5NDVhMTQ0OTQxNjJlMTk1NCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.IZUTpsCrXtWdYqs4CrZXhxiX3SgiG4T3sG7B8kkPWBw";

  Future<void> _loadMovieDetails() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      var tmdbcustomlogs = TMDB(ApiKeys(apikey, readaccesstoken));

      Map movieDetails = await tmdbcustomlogs.v3.tv.getDetails(
        int.parse(widget.movieId),
      );
      Map seasonDetails = await tmdbcustomlogs.v3.tvSeasons.getDetails(
        int.parse(widget.movieId),
        slectedSeasonIndex + 1,
      );
      Map movieCredits = await tmdbcustomlogs.v3.tv.getCredits(
        int.parse(widget.movieId),
      );

      if (mounted) {
        setState(() {
          this.movieDetails = movieDetails;
          this.movieCredits = movieCredits;
          this.seasonDetail = seasonDetails;
          _isLoading = false;
          _retryCount = 0; // Reset retry count on success
        });
      }
    } catch (e) {
      print(
        'Error loading movie details (attempt ${_retryCount + 1}/$_maxRetries): $e',
      );

      if (mounted) {
        if (_retryCount < _maxRetries) {
          // Auto-retry after a delay
          _retryCount++;
          setState(() {
            _isLoading = true;
          });

          // Wait before retrying (exponential backoff)
          await Future.delayed(Duration(seconds: 2 * _retryCount));

          if (mounted) {
            _loadMovieDetails();
          }
        } else {
          // Max retries reached
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
        }
      }
    }
    print(seasonDetail);
  }

  int slectedSeasonIndex = 0;

  @override
  void didUpdateWidget(DetailedTv oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload data if movieId changes
    if (oldWidget.movieId != widget.movieId) {
      _loadMovieDetails();
    }
    print(movieDetails);
  }

  details() async {
    await _loadMovieDetails();
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
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.red[400]),
                  SizedBox(height: 16),
                  Text(
                    'Loading Season details...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  if (_retryCount > 0)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Fetch attempt $_retryCount/$_maxRetries',
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
                    'Failed to load movie details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please try again',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      _retryCount = 0; // Reset retry count for manual retry
                      _loadMovieDetails();
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
              child: Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    Container(
                      // height: MediaQuery.of(context).size.height * 0.33,
                      // color: Colors.amber,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(1),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: movieDetails['backdrop_path'] != null
                                  ? Image.network(
                                      "https://image.tmdb.org/t/p/original${movieDetails['backdrop_path']}",
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        else {
                                          return Container(
                                            height: 200,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.red[400],
                                                value:
                                                    loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                    : null,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    )
                                  : Container(
                                      height: 200,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.red[400],
                                        ),
                                      ),
                                    ),
                            ),
                          ),

                          Container(
                            padding: EdgeInsets.only(left: 8, top: 8),
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              "${movieDetails['name'] ?? 'Loading...'}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      // height: MediaQuery.of(context).size.height * 0.38,
                      // color: Colors.blue,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(6),
                            height: 50,
                            // color: const Color.fromRGBO(33, 150, 243, 1),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                  size: 20,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  "${movieDetails['vote_average']?.toStringAsFixed(1) ?? ' '}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Icon(
                                  Icons.align_horizontal_left_rounded,
                                  size: 20,
                                ),
                                SizedBox(width: 5),
                                Container(
                                  child: Text(
                                    movieDetails['number_of_seasons'] != null
                                        ? '${movieDetails['number_of_seasons']} Season'
                                        : ' N/A ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),

                                SizedBox(width: 10),
                                Expanded(
                                  child: SizedBox(
                                    height: 38,
                                    child: ListView.builder(
                                      physics: BouncingScrollPhysics(),
                                      itemCount: movieDetails["genres"] != null
                                          ? movieDetails["genres"].length
                                          : 0,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                            return InkWell(
                                              onTap: () {},
                                              splashColor: Colors.transparent,
                                              child: Container(
                                                height: 30,
                                                margin: EdgeInsets.symmetric(
                                                  horizontal: 5,
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: Colors.transparent,
                                                  border: Border.all(
                                                    color: Colors.red,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    "${movieDetails["genres"][index]["name"]}",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                    ),
                                                  ),
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
                          Container(
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: Row(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  // color: Colors.yellow,
                                  alignment: Alignment.topLeft,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: movieDetails["poster_path"] != null
                                        ? Image.network(
                                            "https://image.tmdb.org/t/p/w500${movieDetails['poster_path']}",
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Center(
                                                child: CircularProgressIndicator(
                                                  color: Colors.red[400],
                                                  value:
                                                      loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                      : null,
                                                ),
                                              );
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Container(
                                                    color: Colors.grey[800],
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.movie,
                                                        size: 50,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  );
                                                },
                                          )
                                        : Container(
                                            color: Colors.grey[800],
                                            child: Center(
                                              child: Icon(
                                                Icons.movie,
                                                size: 50,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.56,
                                  // color: Colors.red[400],
                                  alignment: Alignment.topLeft,
                                  padding: EdgeInsets.all(10),
                                  child: SingleChildScrollView(
                                    child: Text(
                                      "${movieDetails['overview'] ?? 'Loading...'}",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Divider(color: Colors.grey),

                    Container(
                      // color: Colors.amber,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              "Seasons ",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            height: 60,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: movieDetails['seasons'] != null
                                  ? movieDetails['seasons'].length
                                  : 0,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  width: 140,
                                  margin: EdgeInsets.symmetric(horizontal: 8),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 8),
                                      InkWell(
                                        splashColor: Colors.transparent,
                                        onTap: () {
                                          setState(() {
                                            slectedSeasonIndex = index;
                                            _loadMovieDetails();
                                          });
                                        },
                                        child: Container(
                                          height: 35,
                                          width: 140,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            color: slectedSeasonIndex == index
                                                ? Colors.red[400]
                                                : Colors.transparent,
                                            border: Border.all(
                                              color: Colors.red,
                                              width: 1,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "${movieDetails["seasons"][index]["name"]}",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: seasonDetail['episodes'].length ?? 0,
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WatchTv(
                                        seriesID: widget.movieId,
                                        seasonNumber:
                                            seasonDetail['season_number'],
                                        episodeNumber:
                                            seasonDetail['episodes'][index]['episode_number'],
                                      ),
                                    ),
                                  );
                                },
                                splashColor: Colors.transparent,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                    color: Colors.grey[900],
                                  ),
                                  height: 120,
                                  margin: EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 120,
                                        height: 100,
                                        margin: EdgeInsets.only(
                                          right: 12,
                                          left: 8,
                                        ),
                                        child:
                                            seasonDetail['episodes'][index]['still_path'] !=
                                                null
                                            ? Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    child: Image.network(
                                                      "https://image.tmdb.org/t/p/w200${seasonDetail['episodes'][index]['still_path']}",
                                                      fit: BoxFit.cover,
                                                      width: 120,
                                                      height: 100,
                                                      loadingBuilder:
                                                          (
                                                            context,
                                                            child,
                                                            loadingProgress,
                                                          ) {
                                                            if (loadingProgress ==
                                                                null)
                                                              return child;
                                                            return Center(
                                                              child: CircularProgressIndicator(
                                                                color: Colors
                                                                    .red[400],
                                                                value:
                                                                    loadingProgress
                                                                            .expectedTotalBytes !=
                                                                        null
                                                                    ? loadingProgress
                                                                              .cumulativeBytesLoaded /
                                                                          loadingProgress
                                                                              .expectedTotalBytes!
                                                                    : null,
                                                              ),
                                                            );
                                                          },
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 25,
                                                    left: 35,
                                                    child: Icon(
                                                      Icons
                                                          .play_circle_outlined,
                                                      size: 50,
                                                      color: Colors.white70,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  color: Colors.grey[800],
                                                ),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.movie,
                                                    size: 50,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "${seasonDetail['episodes'][index]['name']}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 4),
                                            Container(
                                              width:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.55,
                                              height: 61,
                                              child: SingleChildScrollView(
                                                child: Text(
                                                  "${seasonDetail['episodes'][index]['overview'] ?? 'No description available'}",
                                                  style: TextStyle(
                                                    color: Colors.grey[400],
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
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
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              "Credits",
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 150,
                            width: MediaQuery.of(context).size.width,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: movieCredits['cast'] != null
                                  ? movieCredits['cast'].length
                                  : 0,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  margin: EdgeInsets.symmetric(horizontal: 8),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        radius: 50,
                                        backgroundColor: Colors.grey[800],
                                        child: ClipOval(
                                          child:
                                              (movieCredits['cast'] != null &&
                                                  movieCredits['cast'].length >
                                                      index &&
                                                  movieCredits['cast'][index]['profile_path'] !=
                                                      null)
                                              ? Image.network(
                                                  "https://image.tmdb.org/t/p/w200${movieCredits['cast'][index]['profile_path']}",
                                                  fit: BoxFit.cover,
                                                  width: 100,
                                                  height: 100,
                                                  loadingBuilder: (context, child, loadingProgress) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return Center(
                                                      child: CircularProgressIndicator(
                                                        color: Colors.red[400],
                                                        strokeWidth: 2,
                                                        value:
                                                            loadingProgress
                                                                    .expectedTotalBytes !=
                                                                null
                                                            ? loadingProgress
                                                                      .cumulativeBytesLoaded /
                                                                  loadingProgress
                                                                      .expectedTotalBytes!
                                                            : null,
                                                      ),
                                                    );
                                                  },
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return Icon(
                                                          Icons.person,
                                                          size: 50,
                                                          color: Colors.grey,
                                                        );
                                                      },
                                                )
                                              : Icon(
                                                  Icons.person,
                                                  size: 50,
                                                  color: Colors.grey,
                                                ),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "${movieCredits['cast'][index]['name']}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "${movieCredits['cast'][index]['character'] ?? movieCredits['cast'][index]['known_for_department']}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 10),

                    // Container(
                    //   // height: MediaQuery.of(context).size.height * 0.07,
                    //   // color: Colors.green,
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //     children: [
                    //       ElevatedButton(
                    //         onPressed: () {
                    //           Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //               builder: (context) =>
                    //                   Watch(movieID: widget.movieId),
                    //             ),
                    //           );
                    //         },
                    //         style: ButtonStyle(
                    //           shape: WidgetStateProperty.all(
                    //             RoundedRectangleBorder(
                    //               borderRadius: BorderRadius.circular(25),
                    //             ),
                    //           ),
                    //           elevation: WidgetStateProperty.all(5),
                    //           fixedSize: WidgetStateProperty.all(Size(220, 60)),
                    //           padding: WidgetStateProperty.all(
                    //             EdgeInsets.fromLTRB(50, 5, 40, 5),
                    //           ),
                    //           backgroundColor: WidgetStateProperty.all(
                    //             Colors.red[600],
                    //           ),
                    //           foregroundColor: WidgetStateProperty.all(
                    //             Colors.white,
                    //           ),
                    //         ),
                    //         child: Row(
                    //           children: [
                    //             Text(
                    //               "Watch Now",
                    //               style: TextStyle(
                    //                 fontSize: 18,
                    //                 fontWeight: FontWeight.bold,
                    //               ),
                    //             ),
                    //             Icon(Icons.play_arrow, size: 35),
                    //           ],
                    //         ),
                    //       ),

                    //       ElevatedButton(
                    //         onPressed: () {
                    //           Share.share(
                    //             'Check out this movie: ${movieDetails['homepage']}',
                    //           );
                    //         },
                    //         style: ButtonStyle(
                    //           shape: WidgetStateProperty.all(
                    //             RoundedRectangleBorder(
                    //               borderRadius: BorderRadius.circular(25),
                    //             ),
                    //           ),
                    //           elevation: WidgetStateProperty.all(5),
                    //           fixedSize: WidgetStateProperty.all(Size(140, 60)),
                    //           padding: WidgetStateProperty.all(
                    //             EdgeInsets.fromLTRB(30, 5, 25, 5),
                    //           ),
                    //           backgroundColor: WidgetStateProperty.all(
                    //             Colors.blue[800],
                    //           ),
                    //           foregroundColor: WidgetStateProperty.all(
                    //             Colors.white,
                    //           ),
                    //         ),
                    //         child: Row(
                    //           children: [
                    //             Text(
                    //               "Share ",
                    //               style: TextStyle(
                    //                 fontSize: 18,
                    //                 fontWeight: FontWeight.bold,
                    //               ),
                    //             ),
                    //             Icon(Icons.share, size: 28),
                    //           ],
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
    );
  }
}
