import 'package:flutter/material.dart';


class Detailedcomingsoon extends StatefulWidget {
  const Detailedcomingsoon({super.key, required this.movieId});

  final String movieId;

  @override
  State<Detailedcomingsoon> createState() => _DetailedcomingsoonState();
}

class _DetailedcomingsoonState extends State<Detailedcomingsoon> {
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
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              Container(
                // height: MediaQuery.of(context).size.height * 0.33,
                // color: Colors.amber,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(1),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Image.network(
                          "https://beam-images.warnermediacdn.com/BEAM_LWM_DELIVERABLES/aa5b9295-8f9c-44f5-809b-3f2b84badfbf/8a7dd34b09c9c25336a3d850d4c431455e1aaaf0.jpg?host=wbd-images.prod-vod.h264.io&partner=beamcom",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.only(left: 8, top: 8),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "INTERSTELLAR ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                // height: MediaQuery.of(context).size.height * 0.38,
                // color: Colors.blue,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6),
                      height: 50,
                      // color: const Color.fromRGBO(33, 150, 243, 1),
                      child: Row(
                        children: [
                          Text("To be announced"),
                          SizedBox(width: 10),
                          Expanded(
                            child: ListView.builder(
                              itemCount: 5,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (BuildContext context, int index) {
                                return InkWell(
                                  onTap: () {},
                                  splashColor: Colors.transparent,
                                  child: Container(
                                    height: 30,
                                    margin: EdgeInsets.symmetric(horizontal: 5),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.transparent,
                                      border: Border.all(
                                        color: Colors.red,
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Adventure",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
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
                    Container(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            // color: Colors.yellow,
                            alignment: Alignment.topLeft,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Image.network(
                                "https://upload.wikimedia.org/wikipedia/en/b/bc/Interstellar_film_poster.jpg",
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.56,
                            // color: Colors.red[400],
                            alignment: Alignment.topLeft,
                            padding: EdgeInsets.all(10),
                            child: Text(
                              "Stay Tuned !",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        "Credits",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 150,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 10,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage: NetworkImage(
                                    "https://img.huffingtonpost.com/asset/5ff3371b260000ae2b7a3827.jpeg?cache=AfBaoaRwUB&ops=scalefit_500_noupscale",
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Name",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Role",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10),

              Container(
                // height: MediaQuery.of(context).size.height * 0.07,
                // color: Colors.green,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        elevation: WidgetStateProperty.all(5),
                        fixedSize: WidgetStateProperty.all(Size(220, 60)),
                        padding: WidgetStateProperty.all(
                          EdgeInsets.fromLTRB(50, 5, 40, 5),
                        ),
                        backgroundColor: WidgetStateProperty.all(
                          Colors.red[600],
                        ),
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "Coming Soon",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Icon(Icons.play_arrow, size: 35),
                        ],
                      ),
                    ),

                    ElevatedButton(
                      onPressed: () {},
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        elevation: WidgetStateProperty.all(5),
                        fixedSize: WidgetStateProperty.all(Size(140, 60)),
                        padding: WidgetStateProperty.all(
                          EdgeInsets.fromLTRB(30, 5, 25, 5),
                        ),
                        backgroundColor: WidgetStateProperty.all(
                          Colors.blue[800],
                        ),
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "Share ",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(Icons.share, size: 28),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}