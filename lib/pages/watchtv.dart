import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tmdb_api/tmdb_api.dart';

class WatchTv extends StatefulWidget {
  const WatchTv({super.key, required this.seriesID, required this.seasonNumber, required this.episodeNumber});

  final String seriesID;
  final int seasonNumber;
  final int episodeNumber;

  @override
  State<WatchTv> createState() => _WatchTvState();
}

class _WatchTvState extends State<WatchTv> {
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

      Map movieDetails = await tmdbcustomlogs.v3.tv.getDetails(
        int.parse(widget.seriesID),
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
              // Get the initial provider URL domain
              final providerUrl =
                  'https://www.NontonGo.win/embed/tv/${widget.seriesID}/${widget.seasonNumber}/${widget.episodeNumber}';
              final providerDomain = Uri.parse(providerUrl).host;
              final requestDomain = Uri.parse(request.url).host;

              print('Navigation request: ${request.url}');
              print('Request domain: $requestDomain');

              // Block app store and intent links
              if (request.url.startsWith('intent://') ||
                  request.url.startsWith('market://') ||
                  request.url.startsWith('android-app://') ||
                  request.url.startsWith('tel:') ||
                  request.url.startsWith('mailto:') ||
                  request.url.startsWith('sms:')) {
                print('🚫 Blocked app scheme: ${request.url}');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Blocked suspicious redirect'),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
                return NavigationDecision.prevent;
              }

              // Comprehensive list of blocked domains
              final blockedDomains = [
                // Ad networks
                'googleads', 'doubleclick', 'googlesyndication', 'adclick',
                'adservice', 'ads.google', 'pagead', 'adserver',
                // Social media
                'facebook.com', 'twitter.com', 'instagram.com', 't.me',
                'telegram.me', 'whatsapp.com', 'wa.me',
                // App stores
                'play.google.com', 'apps.apple.com', 'itunes.apple.com',
                // URL shorteners
                'bit.ly', 'tinyurl.com', 'short.link', 'ow.ly', 'goo.gl',
                // Spam/malicious
                'click', 'track', 'redirect', 'popup', 'pop-up',
                'banner', 'affiliate', 'offer', 'download',
                // Betting/adult
                'casino', 'poker', 'betting', 'xxx', 'adult',
              ];

              // Check if domain is blocked
              for (final blocked in blockedDomains) {
                if (requestDomain.toLowerCase().contains(blocked) ||
                    request.url.toLowerCase().contains(blocked)) {
                  print(
                    '🚫 Blocked domain/URL: $requestDomain - ${request.url}',
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Blocked malicious redirect'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                  return NavigationDecision.prevent;
                }
              }

              // Whitelist of allowed domains
              final allowedDomains = [
                // Provider domains
                'vidsrc.in', 'vidsrc.net', 'vidsrc.cc', 'vidsrc.rip',
                'embed.su', 'multiembed.mov', '2embed.cc',
                'player.smashy.stream', 'embed.watch', 'moviesapi.club',
                'player.autoembed.cc', 'nontongo.win',
                // Video CDN and streaming
                'cloudflare.com', 'cloudflare.net', 'fastly.net',
                'akamaized.net', 'bunnycdn.com',
                'vidsrc.stream', 'rabbitstream.net', 'upstream.to',
                'vidcloud.co', 'vidcloud9.com',
                // Google services (safe)
                'googleapis.com', 'gstatic.com',
                // Video players
                'jwpcdn.com', 'jwplatform.com', 'jwplayer.com',
              ];

              // Allow same domain or whitelisted domains
              final isAllowed =
                  requestDomain == providerDomain ||
                  allowedDomains.any(
                    (domain) =>
                        requestDomain.contains(domain) ||
                        domain.contains(requestDomain),
                  );

              if (!isAllowed) {
                print('🚫 Blocked external redirect: $requestDomain');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Blocked external redirect to: $requestDomain',
                      ),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
                return NavigationDecision.prevent;
              }

              print('✅ Allowed navigation: $requestDomain');
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(
          Uri.parse('https://www.NontonGo.win/embed/tv/${widget.seriesID}/${widget.seasonNumber}/${widget.episodeNumber}'),
        );
    } else {
      // For Windows/Web, automatically open in browser
      _isLoading = false;
      Future.delayed(Duration(milliseconds: 500), () {
        _launchURL('https://www.NontonGo.win/embed/tv/${widget.seriesID}/${widget.seasonNumber}/${widget.episodeNumber}');
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
        // actions: [
        //   if (_isWebViewSupported)
        //     IconButton(
        //       icon: Icon(Icons.open_in_browser),
        //       onPressed: () {
        //         _launchURL(
        //           'https://www.nontongo.win/embed/movie/${widget.movieID}',
        //         );
        //       },
        //       tooltip: 'Open in Browser',
        //     ),
        // ],
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
                            "${movieDetails['name'] ?? 'Loading...'}",
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
                              // Season and episode 
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
                                        Icons.tv,
                                        size: 16,
                                        color: Colors.grey[400],
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        "S${widget.seasonNumber} & E${widget.episodeNumber}",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[300],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                ,  
                              SizedBox(width: 12),
                               if (movieDetails['episode_run_time'] != null &&
                                  (movieDetails['episode_run_time'] as List)
                                      .isNotEmpty)
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
                                        Icons.schedule,
                                        size: 16,
                                        color: Colors.grey[400],
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        "${movieDetails['episode_run_time'][0]} min",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[300],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                             

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
                          if (movieDetails['air_date'] != null &&
                              movieDetails['air_date'].toString().isNotEmpty)
                            Text(
                              "📅 Released on: ${movieDetails['air_date']}",
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),

                          // Divider
                          SizedBox(height: 16),
                          Divider(color: Colors.grey[800], thickness: 1),

                          Card(
                            color: Colors.grey[900],
                            margin: EdgeInsets.all(8),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "📺 Instructions to Watch:",
                                    style: TextStyle(
                                      color: Colors.red[400],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    "1. Click on the play button repeatedly in the player to start the Episode playback.",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "2. If the video does not load, wait for a few moments as the server may take time to respond.",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "3. If playback issues persist, click on the player repeatedly until the menu button in the top-left corner is visible. Click on it to change the servers and check for the episode on different servers. \n Don't Worry about those clicking Redirects we have blocked it all and nothing will be opened in background.",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Center(
                                    child: Text(
                                      "🍿 Enjoy your episode!",
                                      style: TextStyle(
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                          'Failed to load season details',
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
                          'Loading Season details...',
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
                              'https://www.NontonGo.win/embed/tv/${widget.seriesID}/${widget.seasonNumber}/${widget.episodeNumber}',
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
