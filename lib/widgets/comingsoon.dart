import 'package:flutter/material.dart';
import 'package:movie_rader/pages/detailedcomingsoon.dart';
class Comingsoon extends StatefulWidget {
  const Comingsoon({super.key, required this.comingsoon});
  final List comingsoon;

  @override
  State<Comingsoon> createState() => _ComingsoonState();
}

class _ComingsoonState extends State<Comingsoon> {
  List<bool> interestedList = List.generate(10, (_) => false);

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
              "Releasing Soon",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 275,
            child: widget.comingsoon.isEmpty
                ? Center(child: CircularProgressIndicator(color: Colors.red[400]))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.comingsoon.length > 10 ? 10 : widget.comingsoon.length,
                    itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () => {
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Detailedcomingsoon(
                                movieId: widget.comingsoon[index]['id']
                                    .toString(),
                              ),
                            ),
                          ),
                  },
                  child: Container(
                    height: 200,
                    width: 300,
                    margin: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 200,
                          width: 300,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            image: DecorationImage(
                              image: NetworkImage(
                                "https://image.tmdb.org/t/p/w500${widget.comingsoon[index]['backdrop_path']}",
                              ),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${widget.comingsoon[index]['title']}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    "${widget.comingsoon[index]['release_date']}",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  interestedList[index] =
                                      !interestedList[index];
                                });
                              },
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                  interestedList[index]
                                      ? Colors.red[500]
                                      : Colors.transparent,
                                ),
                                fixedSize: WidgetStateProperty.all(
                                  Size(90, 10),
                                ),
                                foregroundColor: WidgetStateProperty.all(
                                  Colors.white,
                                ),
                                elevation: WidgetStateProperty.all(3),
                                padding: WidgetStateProperty.all(
                                  EdgeInsets.all(3),
                                ),
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              child: Text(
                                interestedList[index]
                                    ? "Interested"
                                    : "🔔",
                              ),
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
