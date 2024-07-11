import 'package:flutter/material.dart';
import 'package:tourist_guide/view_model/const/App_Consts.dart';

class HomePageConst extends AppConstant
{
  BuildContext _context ;
  HomePageConst(this._context);
  double get searchTextBoxWidth => MediaQuery.of(_context).size.width * 0.75;
  double get textSize => MediaQuery.of(_context).size.height * 0.025;
  double get cateogeryBoxHeight => MediaQuery.of(_context).size.height * 0.4;
  double get topPlacesBoxHeight => MediaQuery.of(_context).size.height * 0.2;
  double get topTextHeight => MediaQuery.of(_context).size.height * 0.07;
  double get textHeight => MediaQuery.of(_context).size.height * 0.05;
  double get searchBoxHeight => MediaQuery.of(_context).size.height * 0.08;

  @override
  Widget gridChild(List<MyData> data, int index) {
    // TODO: implement gridChild
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          Container(
              child: Image.asset(data[index].image_url,fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              )
          ),
          Align(
            child: Text(
              data[index].title,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            alignment: Alignment.bottomCenter,
          )
        ],
      ),
    );
  }
}
