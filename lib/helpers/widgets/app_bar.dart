// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:salonapp_app_owner/helpers/constants/color_constants.dart';

class CustomAppBar extends StatelessWidget {
  int? count;
  CustomAppBar({
    Key? key,
    this.count,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      leadingWidth: 10,
      title: Row(
        children: [
          avatarContainer(),
          const SizedBox(width: 8),
          locationContainer(context),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () {},
          child: count! > 0
              ? Badge(
                  label: Text("$count"),
                  smallSize: 5,
                  child: Icon(
                    MingCute.notification_line,
                    color: iconGrey,
                  ),
                )
              : Icon(
                  MingCute.notification_line,
                  color: iconGrey,
                ),
        ),
        SizedBox(width: 17),
      ],
    );
  }

  Container avatarContainer() {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: Image.asset(
            "assets/images/img-one.jpg",
          ).image,
        ),
        color: const Color.fromARGB(255, 147, 227, 249),
        borderRadius: BorderRadius.circular(40),
      ),
    );
  }

  Container locationContainer(BuildContext context) {
    return Container(
      height: 35,
      width: 180,
      decoration: BoxDecoration(
        color: Colors.grey.shade200.withOpacity(0.4),
        border: Border.all(
          width: 1,
          color: Colors.grey.shade400.withOpacity(0.5),
        ),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.add_location_outlined,
                  size: 20,
                ),
                const SizedBox(width: 5),
                Text(
                  "Weija-SCC, Accra",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                ),
              ],
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
              weight: 8,
              grade: 8,
              opticalSize: 8,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}
