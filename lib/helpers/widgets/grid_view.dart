import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:icons_plus/icons_plus.dart';

import '../constants/color_constants.dart';
import '../text style/text_style.dart';

class GridViewComponent extends StatelessWidget {
  GridViewComponent({
    super.key,
  });

  List<Color> colors = <Color>[
    Colors.red,
    Colors.green,
    Colors.green,
    Colors.red,
  ];
  List<String> title = <String>[
    "Haircuts",
    "Shaves",
    "Dyeing",
    "Shampoo",
    "Locking",
    "Natural",
  ];
  List<String> svgs = <String>[
    "undraw_pie-graph_8m6b",
    "undraw_barber_utly",
    "undraw_people_ka7y",
    "undraw_going-upwards_0y3z",
  ];
  List<Icon> icons = <Icon>[
    Icon(
      MingCute.arrows_down_line,
      size: 11.5,
      color: Colors.red,
    ),
    Icon(
      MingCute.arrows_up_line,
      size: 11.5,
      color: Colors.green,
    ),
    Icon(
      MingCute.arrows_up_line,
      size: 11.5,
      color: Colors.green,
    ),
    Icon(
      MingCute.arrows_down_line,
      size: 11.5,
      color: Colors.red,
    ),
  ];

  List<Map<String, String>> dashboardContentTitle = [
    {'Title': 'Revenue', 'Amount': '34,452', 'Previous Percent': '2.65%'},
    {'Title': 'Orders', 'Amount': '5,643', 'Previous Percent': '0.82%'},
    {'Title': 'Customers', 'Amount': '45,254', 'Previous Percent': '6.34%'},
    {'Title': 'Growth', 'Amount': '+12.58%', 'Previous Percent': '10.51%'},
  ];
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.6,
        mainAxisExtent: 170,
      ),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dashboardContentTitle.length,
      itemBuilder: (BuildContext context, int index) {
        final content = dashboardContentTitle[index];
        return GestureDetector(
          onTap: () {
            // Navigator.pushNamed(
            //   context,
            //   '/mainshopinfo',
            //   arguments: {
            //     'id': shops![index].shopId,
            //   },
            // );
          },
          child: Container(
            width: 150,
            height: 170,
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 2,
                  spreadRadius: 0.5,
                  color: Colors.black12,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/svgs/${svgs[index]}.svg",
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 3),
                  PrimaryText(
                    text: content['Amount'] ?? '',
                    color: blackColor,
                    fontWeight: FontWeight.w600,
                    size: 18,
                  ),
                  //SizedBox(height: 5),
                  PrimaryText(
                    text: content['Title'] ?? '',
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                    size: 15,
                  ),
                  SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      icons[index],
                      PrimaryText(
                        text: content['Previous Percent'] ?? '',
                        color: colors[index],
                        fontWeight: FontWeight.w500,
                        size: 10,
                      ),
                      SizedBox(width: 5),
                      PrimaryText(
                        text: 'since last week',
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                        size: 11,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
