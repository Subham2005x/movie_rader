# Movie Radar 🎬

A feature-rich Flutter application for discovering and exploring movies and TV shows, powered by The Movie Database (TMDB) API.

## Features ✨

### Movies
- 🔥 **Trending Movies** - Weekly trending movies
- 🆕 **Coming Soon** - Upcoming movie releases
- ⭐ **Top Rated** - Highest-rated movies
- 📈 **Most Popular** - Popular movies worldwide
- 🇮🇳 **Hindi Movies** - Popular and new Hindi releases
- 🎭 **Genre-based Filtering** - Browse movies by genre
- 🔍 **Search** - Find any movie instantly

### TV Shows
- 📺 **Airing Today** - Currently airing TV shows
- 🌟 **On Air** - Shows currently on air
- 🏆 **Top Rated TV Shows** - Best-rated series
- 🔥 **Popular TV Shows** - Trending series
- 🇮🇳 **Hindi TV Shows** - Popular Hindi series

### Video Player
- 🎥 **Multi-Provider Support** - 13+ video embed providers
- 🔄 **Auto-Failover** - Automatically tries next provider if one fails
- 🛡️ **Security** - Blocks malicious redirects and ads
- ▶️ **Embedded Playback** - Watch directly in the app

### Additional Features
- 📱 **Responsive Design** - Works on all screen sizes
- 🌙 **Dark Theme** - Eye-friendly dark mode
- 🔁 **Auto-Retry** - Automatic retry on API failures
- 📄 **Pagination** - Load more content with "Load More" button
- 🎯 **Genre Drawer** - Easy navigation by genre
- ⚡ **Fast Loading** - Optimized performance

## Screenshots 📸

<p align="center">
  <img src="assets/WhatsApp Image 2025-12-11 at 7.26.43 PM.jpeg" width="200" alt="Screenshot 1"/>
  <img src="assets/WhatsApp Image 2025-12-11 at 7.22.47 PM.jpeg" width="200" alt="Screenshot 2"/>
  <img src="assets/WhatsApp Image 2025-12-11 at 7.26.42 PM.jpeg" width="200" alt="Screenshot 3"/>
</p>

<p align="center">
  <img src="assets/WhatsApp Image 2025-12-11 at 7.22.47 PM (1).jpeg" width="200" alt="Screenshot 4"/>
  <img src="assets/WhatsApp Image 2025-12-11 at 7.22.46 PM.jpeg" width="200" alt="Screenshot 5"/>
</p>


## Tech Stack 🛠️

- **Flutter** - UI Framework
- **Dart** - Programming Language
- **TMDB API** - Movie and TV show data
- **webview_flutter** - Embedded video player
- **url_launcher** - External link handling

## Getting Started 🚀

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code
- TMDB API Key

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Subham2005x/movie_rader.git
   cd movie_rader
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building APK

To build a release APK:
```bash
flutter build apk --release
```

To build an app bundle:
```bash
flutter build appbundle --release
```

## Configuration ⚙️

The app uses TMDB API. The API key is configured in `lib/pages/home.dart`:

```dart
final String apikey = "e0d56cbed100b1c1191xxxxxxx";
final readaccesstoken = "your_token_here";
```

## Video Providers 🎬

The app supports 13+ video embed providers with automatic failover:
- VidSrc.in
- VidSrc.net
- VidSrc.cc
- VidSrc.rip
- Embed.su
- 2Embed
- And more...

## Security Features 🔒

- Blocks malicious redirects (ads, malware, phishing)
- Prevents navigation to app stores and social media
- Filters URL shorteners
- Blocks 20+ known malicious domains

## Project Structure 📁

```
lib/
├── main.dart                 # App entry point
├── pages/
│   ├── home.dart            # Home screen with movies
│   ├── tv.dart              # TV shows screen
│   ├── detailed.dart        # Movie details
│   ├── detailedtv.dart     # TV show details
│   ├── category.dart        # Genre-based listing
│   ├── search.dart          # Movie search
│   ├── searchtv.dart        # TV show search
│   └── watch.dart           # Video player
└── widgets/
    ├── trendingmovie.dart   # Trending movies widget
    ├── comingsoon.dart      # Coming soon widget
    ├── toprated.dart        # Top rated widget
    ├── MostPopular.dart     # Popular movies widget
    └── ...                  # Other widgets
```

## Features in Detail 📝

### Auto-Retry Mechanism
- Automatically retries failed API calls up to 5 times
- Exponential backoff (2s, 4s, 6s, 8s, 10s)
- Shows retry attempt count to user
- Displays error message after all retries fail

### Genre Navigation
- Side drawer with all available genres
- Click genre to load genre-specific movies
- Shows loading indicator during fetch
- Automatic retry on failure

### Video Player
- Tests each provider for 3 seconds
- Automatically switches to next if loading fails
- Manual provider switcher in app bar
- Shows loading progress for each provider

### Bottom Navigation
- Movies tab
- Web Series tab
- Maintains selection state
- Smooth navigation between tabs

## Contributing 🤝

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License 📄

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments 🙏

- [TMDB](https://www.themoviedb.org/) for providing the movie database API
- Flutter team for the amazing framework
- All video provider services

## Contact 📧

**Subham Nabik**
- GitHub: [@Subham2005x](https://github.com/Subham2005x)

## Disclaimer ⚠️

This app uses TMDB API for movie data and third-party embed providers for video playback. The app is for educational purposes only. Please ensure you comply with all applicable laws and terms of service when using video content.

---

**Crafted with ❤️ by Subham**
