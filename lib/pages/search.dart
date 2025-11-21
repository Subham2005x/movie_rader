import 'package:flutter/material.dart';

class SearchMovie extends StatefulWidget {
  const SearchMovie({super.key});

  @override
  State<SearchMovie> createState() => _SearchMovieState();
}

class _SearchMovieState extends State<SearchMovie> {
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
                  hintText: 'Search for a movie',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  // Implement search logic here
                },
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(6),
                // color: Colors.cyan,
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: 5,

                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {},
                      splashColor: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[900],
                        ),
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                        padding: EdgeInsets.all(8),
                        // color: Colors.amber,
                        height: 200,
                        child: Row(
                          children: [
                            Container(
                              child: Image.network(
                                "https://static.wikia.nocookie.net/mrbean/images/4/49/BeanAnimated.jpg/revision/latest?cb=20250521143815",
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.57,
                              alignment: Alignment.topLeft,
                              padding: EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  Container(
                                    alignment: Alignment.topLeft,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Movie Name",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                          ),
                                        ),
                                        Text(
                                          "2025",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "1H 30m",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      alignment: Alignment.topLeft,
                                      child: Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: [
                                          customWrapWidget("Action"),
                                          customWrapWidget("Comedy"),
                                          customWrapWidget("Drama"),
                                          customWrapWidget("Drama"),
                                        ],
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
