import 'package:flutter/material.dart';
import 'package:movie_rader/pages/detailed.dart';

class Toprated extends StatefulWidget {
  const Toprated({super.key, required this.toprated});

  final List toprated;

  @override
  State<Toprated> createState() => _TopratedState();
}

class _TopratedState extends State<Toprated> {
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
                    itemCount: widget.toprated.length > 10
                        ? 10
                        : widget.toprated.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Detailed(
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
                                          "Movie Name",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          "Year",
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
                                      Text("8.5"),
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
