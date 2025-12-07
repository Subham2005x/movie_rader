import 'package:flutter/material.dart';
import 'package:movie_rader/pages/detailed.dart';

class CategoryGenre extends StatefulWidget {
  const CategoryGenre({super.key, required this.genreresult, this.genreName, this.type});

  final List genreresult;
  final String? genreName;
  final String? type;

  @override
  State<CategoryGenre> createState() => _CategoryGenreState();
}

class _CategoryGenreState extends State<CategoryGenre> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading delay to show proper loading state
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.red[400]))
          : widget.genreresult.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.movie_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No movies found",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Container(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.all(8),
                    child: Text(
                      "${widget.type} of ${widget.genreName} Genre",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.6,
                          ),
                      scrollDirection: Axis.vertical,
                      itemCount: widget.genreresult.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          margin: EdgeInsets.all(8),
                          child: InkWell(
                            onTap: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Detailed(
                                    movieId: widget.genreresult[index]['id']
                                        .toString(),
                                  ),
                                ),
                              ),
                            },
                            child: Container(
                              height: 300,
                              width: 150,
                              padding: EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 250,
                                    width: 170,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[900],
                                      image:
                                          widget.genreresult[index]['poster_path'] !=
                                              null
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                "https://image.tmdb.org/t/p/w500${widget.genreresult[index]['poster_path']}",
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child:
                                        widget.genreresult[index]['poster_path'] ==
                                            null
                                        ? Center(
                                            child: Icon(
                                              Icons.movie,
                                              size: 50,
                                              color: Colors.grey,
                                            ),
                                          )
                                        : null,
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${widget.type != 'Series' ? widget.genreresult[index]['title'] ?? 'Movie Name' : widget.genreresult[index]['name'] ?? 'Series Name'}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              widget.genreresult[index]
                                                          ['release_date'] !=
                                                      null
                                                  ? DateTime.parse(
                                                          widget.genreresult[
                                                                  index]
                                                              ['release_date'])
                                                      .year
                                                      .toString()
                                                  : widget.genreresult[index]
                                                              ['first_air_date'] !=
                                                          null
                                                      ? DateTime.parse(
                                                              widget.genreresult[
                                                                      index]
                                                                  [
                                                                  'first_air_date'])
                                                          .year
                                                          .toString()
                                                      : 'Year',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            color: Colors.yellow,
                                            size: 16,
                                          ),
                                          SizedBox(width: 2),
                                          Text(
                                            "${widget.genreresult[index]['vote_average'] == null ? 'N/A' : widget.genreresult[index]['vote_average'].toStringAsFixed(1)}",
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
       
                ],
              ),
            ),
    );
  }
}
