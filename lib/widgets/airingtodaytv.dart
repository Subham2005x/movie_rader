import 'package:flutter/material.dart';
import 'package:movie_rader/pages/detailed.dart';
import 'package:movie_rader/pages/detailedtv.dart';
// import 'package:google_fonts/google_fonts.dart';

class Airingtodaytv extends StatefulWidget {
  const Airingtodaytv({super.key, required this.airingtoday });

  final List airingtoday;
  @override
  State<Airingtodaytv> createState() => _AiringtodaytvState();
}

class _AiringtodaytvState extends State<Airingtodaytv> {
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
              "Airing Today",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 314,
            child: widget.airingtoday.isEmpty
                ? Center(
                    child: CircularProgressIndicator(color: Colors.red[400]),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.airingtoday.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailedTv(
                                movieId: widget.airingtoday[index]['id']
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
                                      "https://image.tmdb.org/t/p/w500${widget.airingtoday[index]['poster_path']}",
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
                                          "${widget.airingtoday[index]['name'] ?? 'Series Name'}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          "${widget.airingtoday[index]['first_air_date'] == null ? 'N/A' : widget.airingtoday[index]['first_air_date'].substring(0, 4)}",
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
                                      Text("${widget.airingtoday[index]['vote_average'] == null ? 'N/A' : widget.airingtoday[index]['vote_average'].toStringAsFixed(1)}"),
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
