import 'package:flutter/material.dart';
import 'package:tourist_guide/view_model/const/App_Consts.dart';

class ListPageConst extends AppConstant{
  BuildContext _context ;
  ListPageConst(this._context);

  double get titleHeight => MediaQuery.of(_context).size.height*0.1 ;
  double get titleSize => MediaQuery.of(_context).size.height*0.02 ;
  double get listBoxHeight => MediaQuery.of(_context).size.height*0.8 ;

  double get boxWidth => MediaQuery.of(_context).size.width ;
  double get boxHeight => MediaQuery.of(_context).size.height;

  double get childWidth => MediaQuery.of(_context).size.width*0.2  ;
  double get childHeight => MediaQuery.of(_context).size.height;

  double get bigTextSize => MediaQuery.of(_context).size.height*0.02 ;
  double get smallTextSize => MediaQuery.of(_context).size.height*0.015 ;


  @override
  Widget gridChild(List<MyData> data, int index) {
    // TODO: implement gridChild
    return SizedBox(
      height: boxHeight,
      width: boxWidth,
      child: Align(
        alignment: Alignment.topLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              child: ClipRRect(
                child: Image.asset(dataList[index].image_url,fit: BoxFit.cover,),
                borderRadius: BorderRadius.circular(30),
              ),
              height: childHeight,
              width: childWidth,
            ),
            SizedBox(width: 10,),
            SizedBox(
              height: childHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tourist Name",style: TextStyle(
                      fontWeight: FontWeight.bold,
                    fontSize: bigTextSize
                  ),),
                  SizedBox(height: 3,),
                  Text("Rating 9.8/10",style: TextStyle(fontSize: smallTextSize),),
                  Text("Temp : 300C",style: TextStyle(fontSize: smallTextSize),)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}