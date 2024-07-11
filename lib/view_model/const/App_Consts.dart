import 'package:flutter/material.dart';

abstract class AppConstant {
  Container searchBox({bool? noBorder=false}) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          border:noBorder! == true  ? null : Border.all(color: Colors.black,width: 0)
      ),
      padding: EdgeInsets.fromLTRB(15, 00, 0, 0),
      margin: EdgeInsets.only(top: 10),
      child:Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                    hintText: "Search here",
                    border: InputBorder.none
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: (){},
            ),
          ]
      ),
    );
  }

  GridView homePageGridView({required List<MyData> data,required Widget destination,
    required int crossCount, required double mainSpace,
    double? crossSpace, double? aspectRatio,
    Axis? scrolDirection} ) {
    return GridView.builder(
      scrollDirection: scrolDirection ?? Axis.horizontal,
      itemCount: data.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossCount,
          childAspectRatio: aspectRatio ?? 1,
          crossAxisSpacing:crossSpace ?? 1,
          mainAxisSpacing: mainSpace
      ),
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context){
              return destination;
            }));
            print("Clicked");
          },
          child:  gridChild(data, index),
        );
      },
    );
  }

  Widget gridChild(List<MyData> data, int index) ;

  final List<MyData> dataList = [
    MyData(icon: Icons.home, title: 'Tourist Place', image_url: 'assets/images/img.png'),
    MyData(icon: Icons.settings, title: 'Tourist Place', image_url: 'assets/images/img1.jpeg'),
    MyData(icon: Icons.person, title: 'Tourist Place', image_url: 'assets/images/img2.png'),
    MyData(icon: Icons.home, title: 'Tourist Place', image_url: 'assets/images/img.png'),
    MyData(icon: Icons.settings, title: 'Tourist Place', image_url: 'assets/images/img1.jpeg'),
    MyData(icon: Icons.person, title: 'Tourist Place', image_url: 'assets/images/img2.png'),
    MyData(icon: Icons.home, title: 'Tourist Place', image_url: 'assets/images/img.png'),
    MyData(icon: Icons.settings, title: 'Tourist Place', image_url: 'assets/images/img1.jpeg'),
    MyData(icon: Icons.person, title: 'Tourist Place', image_url: 'assets/images/img2.png'),
  ];

}

class MyData {
  final IconData icon;
  final String title;
  final String image_url;

  MyData({required this.icon, required this.title, required this.image_url});
}