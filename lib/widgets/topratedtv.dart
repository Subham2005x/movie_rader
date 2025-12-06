import 'package:flutter/material.dart';
import 'package:movie_rader/pages/detailed.dart';
import 'package:movie_rader/pages/detailedtv.dart';
// import 'package:google_fonts/google_fonts.dart';

class TopratedTv extends StatefulWidget {
  const TopratedTv({super.key, required this.toprated });

  final List toprated;
  @override
  State<TopratedTv> createState() => _TopratedTvState();
}

class _TopratedTvState extends State<TopratedTv> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.blue,
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.all(8),
            child: Text(
              "Top Rated",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 314,
            child: widget.toprated.isEmpty
                ? Center(
                    child: CircularProgressIndicator(color: Colors.red[400]),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.toprated.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailedTv(
                                movieId: widget.toprated[index]['id']
                                .toString(),
                              ),
                            ),
                          ),
                        },
                        child: Container(
                          height: 300,
                          width: 150,
                          margin: EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 250,
                                width: 150,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      "https://image.tmdb.org/t/p/w500${widget.toprated[index]['poster_path']}",
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
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
                                          "${widget.toprated[index]['name'] ?? 'Series Name'}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          "${widget.toprated[index]['first_air_date'] == null ? 'N/A' : widget.toprated[index]['first_air_date'].substring(0, 4)}",
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
                                      Text("${widget.toprated[index]['vote_average'] == null ? 'N/A' : widget.toprated[index]['vote_average'].toStringAsFixed(1)}"),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
