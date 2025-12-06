import 'package:flutter/material.dart';
import 'package:movie_rader/pages/detailed.dart';
import 'package:movie_rader/pages/detailedtv.dart';

class MostpopularTv extends StatefulWidget {
  const MostpopularTv({super.key, required this.mostpopular});

  final List mostpopular;

  @override
  State<MostpopularTv> createState() => _MostpopularTvState();
}

class _MostpopularTvState extends State<MostpopularTv> {
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
              "Most Popular",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 300,
            child: widget.mostpopular.isEmpty
                ? Center(
                    child: CircularProgressIndicator(color: Colors.red[400]),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.mostpopular.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailedTv(
                                movieId: widget.mostpopular[index]['id']
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
                                height: 230,
                                width: 150,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      "https://image.tmdb.org/t/p/w500${widget.mostpopular[index]['poster_path']}",
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
                                          widget.mostpopular[index]['name'] ?? "Series Name",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          widget.mostpopular[index]['first_air_date'] != null
                                              ? widget.mostpopular[index]['first_air_date'].toString().split('-')[0]
                                              : "Year",
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
                                      Text("${widget.mostpopular[index]['vote_average'] == null ? 'N/A' : widget.mostpopular[index]['vote_average'].toStringAsFixed(1)}"),
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
