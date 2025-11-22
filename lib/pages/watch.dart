import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tmdb_api/tmdb_api.dart';

class Watch extends StatefulWidget {
  const Watch({super.key, required this.movieID});

  final String movieID;

  @override
  State<Watch> createState() => _WatchState();
}

class _WatchState extends State<Watch> {
  Map<dynamic, dynamic> movieDetails = {};
  final String apikey = "e0d56cbed100b1c110143ac896b51913";
  final readaccesstoken =
      "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJlMGQ1NmNiZWQxMDBiMWMxMTAxNDNhYzg5NmI1MTkxMyIsIm5iZiI6MTc2MzUzODg0MS4yNDEsInN1YiI6IjY5MWQ3Nzk5NDVhMTQ0OTQxNjJlMTk1NCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.IZUTpsCrXtWdYqs4CrZXhxiX3SgiG4T3sG7B8kkPWBw";

  WebViewController? _controller;
  bool _isLoading = true;
  bool _isWebViewSupported = false;
  bool _hasError = false;
  int _retryCount = 0;
  final int _maxRetries = 5;

  Future<void> details() async {
    if (!mounted) return;

    try {
      var tmdbcustomlogs = TMDB(ApiKeys(apikey, readaccesstoken));

      Map movieDetails = await tmdbcustomlogs.v3.movies.getDetails(
        int.parse(widget.movieID),
      );

      if (mounted) {
        setState(() {
          this.movieDetails = movieDetails;
          _hasError = false;
          _retryCount = 0;
        });
      }
    } catch (e) {
      print('Error loading movie details: $e');

      if (_retryCount < _maxRetries) {
        _retryCount++;
        print('Retrying... Attempt $_retryCount of $_maxRetries');

        await Future.delayed(Duration(seconds: 2 * _retryCount));

        if (mounted) {
          await details();
        }
      } else {
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
      }
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open video in browser')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    details();

    // Check if platform supports WebView (Android/iOS only)
    _isWebViewSupported = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    if (_isWebViewSupported) {
      // Initialize WebView controller for mobile platforms
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..enableZoom(false)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              setState(() {
                _isLoading = true;
              });
            },
            onPageFinished: (String url) {
              setState(() {
                _isLoading = false;
              });
            },
            onWebResourceError: (WebResourceError error) {
              // Ignore common embed errors - these don't prevent video playback
              final ignoredErrors = [
                'ERR_UNKNOWN_URL_SCHEME',
                'ERR_BLOCKED_BY_ORB',
                'ERR_BLOCKED_BY_RESPONSE',
                'ERR_ABORTED',
              ];

              if (!ignoredErrors.any((e) => error.description.contains(e))) {
                print('WebView error: ${error.description}');
                setState(() {
                  _isLoading = false;
                });
              }
            },
            onNavigationRequest: (NavigationRequest request) {
              // Block navigation to unknown URL schemes but allow the page to load
              if (request.url.startsWith('intent://') ||
                  request.url.startsWith('market://') ||
                  request.url.startsWith('android-app://')) {
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(
          Uri.parse(
            'https://player.autoembed.cc/embed/movie/${widget.movieID}',
          ),
        );
    } else {
      // For Windows/Web, automatically open in browser
      _isLoading = false;
      Future.delayed(Duration(milliseconds: 500), () {
        _launchURL('https://player.autoembed.cc/embed/movie/${widget.movieID}');
      });
    }
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
        actions: [
          if (_isWebViewSupported)
            IconButton(
              icon: Icon(Icons.open_in_browser),
              onPressed: () {
                _launchURL(
                  'https://player.autoembed.cc/embed/movie/${widget.movieID}',
                );
              },
              tooltip: 'Open in Browser',
            ),
        ],
      ),
      body: _isWebViewSupported
          ? SingleChildScrollView(
              child: Column(
                children: [
                  // Video Player Container (YouTube-style)
                  Container(
                    width: double.infinity,
                    height: 250,
                    color: Colors.black,
                    child: Stack(
                      children: [
                        if (_controller != null)
                          WebViewWidget(controller: _controller!),
                        if (_isLoading)
                          Container(
                            color: Colors.black,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Colors.red[400],
                                    strokeWidth: 3,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Loading video player...',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Movie Details Below Video (YouTube-style)
                  if (_hasError)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Failed to load movie details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Please check your internet connection',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _hasError = false;
                                  _retryCount = 0;
                                });
                                details();
                              },
                              icon: Icon(Icons.refresh),
                              label: Text('Retry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[400],
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (movieDetails.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(80),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.red[400]),
                            if (_retryCount > 0)
                              Padding(
                                padding: EdgeInsets.only(top: 16),
                                child: Text(
                                  'Retrying... ($_retryCount/$_maxRetries)',
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                              ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            "${movieDetails['original_title'] ?? 'Loading...'}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),

                          SizedBox(height: 12),

                          // Runtime and Rating Row
                          Row(
                            children: [
                              // Runtime
                              if (movieDetails['runtime'] != null &&
                                  movieDetails['runtime'] > 0)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[850],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: Colors.grey[400],
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        '${movieDetails['runtime'] ~/ 60}h ${movieDetails['runtime'] % 60}m',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[300],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[850],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Runtime N/A',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ),

                              SizedBox(width: 12),

                              // Rating
                              if (movieDetails['vote_average'] != null &&
                                  movieDetails['vote_average'] > 0)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[850],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 16,
                                        color: Colors.amber,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        "${(movieDetails['vote_average'] as num).toStringAsFixed(1)}/10",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[300],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[850],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Not Rated',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ),

                              SizedBox(width: 12),
                            ],
                          ),

                          SizedBox(height: 16),

                          // Release Date
                          if (movieDetails['release_date'] != null &&
                              movieDetails['release_date']
                                  .toString()
                                  .isNotEmpty)
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: Colors.grey[500],
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "Released: ${movieDetails['release_date']}",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),

                          // Divider
                          SizedBox(height: 16),
                          Divider(color: Colors.grey[800], thickness: 1),
                          SizedBox(height: 16),

                          Center(
                            child: Text(
                              "The Movie might take a few Minutes to load please wait ! ",
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            )
          : Center(
              child: _hasError
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 80,
                          color: Colors.red[400],
                        ),
                        SizedBox(height: 24),
                        Text(
                          'Failed to load movie details',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Please check your internet connection',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _hasError = false;
                              _retryCount = 0;
                            });
                            details();
                          },
                          icon: Icon(Icons.refresh),
                          label: Text('Retry', style: TextStyle(fontSize: 18)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[400],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ],
                    )
                  : movieDetails.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.red[400]),
                        SizedBox(height: 16),
                        Text(
                          'Loading movie details...',
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
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.computer, size: 80, color: Colors.red[400]),
                        SizedBox(height: 24),
                        Text(
                          'Video Player on Desktop',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'The video player will open in your default browser for the best viewing experience.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                        SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: () {
                            _launchURL(
                              'https://player.autoembed.cc/embed/movie/${widget.movieID}',
                            );
                          },
                          icon: Icon(Icons.play_circle_outline, size: 28),
                          label: Text(
                            'Watch in Browser',
                            style: TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[400],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        if (movieDetails['original_title'] != null)
                          Text(
                            "${movieDetails['original_title']}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        if (movieDetails['runtime'] != null)
                          Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              '${movieDetails['runtime'] ~/ 60}H ${movieDetails['runtime'] % 60}m',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(25),
        // color: Colors.grey[900],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Crafted with ❤️ by Subham",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
