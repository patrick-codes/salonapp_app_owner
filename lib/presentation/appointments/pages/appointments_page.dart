import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:googleapis/authorizedbuyersmarketplace/v1.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:m_toast/m_toast.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:salonapp_app_owner/helpers/config/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/constants/color_constants.dart';
import '../../../helpers/text style/text_style.dart';
import '../../../helpers/widgets/show_up_animation.dart';
import '../bloc/appointment_bloc.dart';
import '../repository/data model/appointment_model.dart';

class AppointmentsPage extends StatefulWidget {
  AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<AppointmentBloc>();
    final state = bloc.state;
    if (state is AppointmentsFetchedState) {
      markAllAppointmentsAsSeen(state.appointment);
    }
  }

  Future<void> markAllAppointmentsAsSeen(
      List<AppointmentModel?>? appointments) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = appointments!.map((a) => a!.id!).toList();
    await prefs.setStringList('seen_appointment_ids', ids);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppointmentBloc, AppointmentState>(
      listener: (context, state) {
        if (state is AppointmentsFetchFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage)),
          );
        }
      },
      builder: (context, state) {
        if (state is AppointmentsLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AppointmentsFetchedState) {
          final appointments = state.appointment ?? [];

          return WillPopScope(
            onWillPop: () async {
              context.read<AppointmentBloc>().add(ViewAppointmentEvent());
              return true;
            },
            child: Scaffold(
              backgroundColor: barBg,
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarColor: iconGrey,
                  statusBarIconBrightness: Brightness.light,
                ),
                backgroundColor: Colors.white,
                leading: const Icon(
                  MingCute.arrow_left_fill,
                ),
                centerTitle: true,
                title: Text(
                  "Appointments (${state.appointment!.length})",
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                actions: [
                  GestureDetector(
                    onTap: () {},
                    child: Icon(
                      MingCute.more_2_fill,
                    ),
                  ),
                  SizedBox(width: 8),
                ],
              ),
              body: ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appt = appointments[index];
                  return Container(
                    height: 170,
                    width: SizeConfig.screenWidth,
                    margin: const EdgeInsets.all(8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  MingCute.scissors_2_line,
                                  size: 15,
                                  color: iconGrey,
                                ),
                                SizedBox(width: 5),
                                PrimaryText(
                                  text: appt!.servicesType ?? '',
                                  size: 15,
                                  color: blackColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(
                                  MingCute.phone_line,
                                  size: 15,
                                  color: iconGrey,
                                ),
                                SizedBox(width: 5),
                                PrimaryText(
                                  text: appt.phone ?? '',
                                  size: 13,
                                  color: iconGrey,
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(
                                  MingCute.calendar_line,
                                  size: 15,
                                  color: iconGrey,
                                ),
                                SizedBox(width: 5),
                                PrimaryText(
                                  text: appt.appointmentDate
                                          ?.toLocal()
                                          .toString()
                                          .split(' ')[0] ??
                                      '',
                                  size: 13,
                                  color: blackColor,
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(
                                  MingCute.clock_2_line,
                                  size: 15,
                                  color: iconGrey,
                                ),
                                SizedBox(width: 5),
                                PrimaryText(
                                  text: appt.appointmentDate
                                          ?.toLocal()
                                          .toString()
                                          .split(' ')[1] ??
                                      '',
                                  size: 13,
                                  color: blackColor,
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Container(
                              height: 30,
                              width: 140,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: primaryColor,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  PrimaryText(
                                    text: 'End service',
                                    size: 12,
                                    color: primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              PrimaryText(
                                text: 'PAID',
                                size: 13,
                                color: Colors.lightGreen,
                                fontWeight: FontWeight.bold,
                              ),
                              PrimaryText(
                                text: appt.amount.toString(),
                                size: 13.5,
                                color: blackColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: secondaryBg,
          appBar: AppBar(
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: primaryColor,
              statusBarIconBrightness: Brightness.light,
            ),
            backgroundColor: Colors.white,
            leading: const Icon(
              MingCute.arrow_left_fill,
            ),
            centerTitle: true,
            title: Text(
              "Appointments",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            actions: [
              GestureDetector(
                onTap: () {},
                child: Icon(
                  MingCute.more_2_fill,
                ),
              ),
              SizedBox(width: 8),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/svgs/undraw_file-search_cbur.svg',
                  height: 150,
                  width: 150,
                ),
                SizedBox(height: 20),
                PrimaryText(
                  text: 'No Appointments Found',
                  color: iconGrey,
                  size: 15,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildContactsList(BuildContext context, List<Contact> contacts) {
    return ListTile(
      onTap: () {},
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      horizontalTitleGap: 5,
      minLeadingWidth: 1,
      minVerticalPadding: 2,
      dense: true,
      leading:
          // CircleAvatar(
          //   radius: 30,
          //   child: contact.thumbnail != null
          //       ? MemoryImage(contact.photo!)
          //       : Text(
          //           result = nameConcat(
          //             "${contact.displayName}",
          //           ),
          //           style: Theme.of(context)
          //               .textTheme
          //               .bodyMedium!
          //               .copyWith(
          //                 fontSize: 15,
          //                 fontWeight: FontWeight.bold,
          //               ),
          //       ),
          // ),
          Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60),
              //color: primaryColor,
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 250, 127, 168),
                  Color.fromARGB(255, 225, 0, 105),
                  // const Color.fromARGB(255, 1, 82, 109),
                  // const Color.fromARGB(255, 11, 211, 247)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                "displayName",
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            )),
      ),
      title: Text(
        "No Name",
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Last seen ",
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          Divider(
            color: Colors.grey.shade200,
            thickness: 1,
          ),
        ],
      ),
    );
  }

  Container appointmentContainer(
    BuildContext context,
    String id,
    String imgurl,
    String name,
    double amount,
    String time,
    String service,
    String date,
    String location,
    String code,
    String phone,
  ) {
    return Container(
      height: 245,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          width: 1,
          color: Colors.grey.shade300,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // CediSign(
                    //   size: 16.5,
                    //   weight: FontWeight.bold,
                    //   color: Colors.black87,
                    // ),
                    SizedBox(width: 2),
                    Text(
                      amount.toString(),
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                    ),
                  ],
                )
              ],
            ),
            Divider(
              color: Colors.grey.shade200,
            ),
            SizedBox(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // CachedNetworkImage(
                    //   imageUrl: imgurl,
                    //   imageBuilder: (context, imageProvider) => Container(
                    //     height: 158,
                    //     width: 90,
                    //     decoration: BoxDecoration(
                    //       image: DecorationImage(
                    //         fit: BoxFit.cover,
                    //         image: imageProvider,
                    //       ),
                    //       color: Colors.white,
                    //       borderRadius: BorderRadius.circular(5),
                    //     ),
                    //   ),
                    //   placeholder: (context, url) => Center(
                    //     child: Shimmer.fromColors(
                    //       baseColor: Colors.grey[300]!,
                    //       highlightColor: Colors.grey[200]!,
                    //       child: Container(
                    //         height: 95,
                    //         width: MediaQuery.of(context).size.width,
                    //         decoration: BoxDecoration(
                    //           color: secondaryColor3,
                    //           borderRadius: BorderRadius.only(
                    //             topRight: Radius.circular(8),
                    //             topLeft: Radius.circular(8),
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    //   errorWidget: (context, url, error) => SizedBox(
                    //     height: 40,
                    //     child: Center(
                    //       child: SizedBox(
                    //         height: 20,
                    //         width: 20,
                    //         child: const Icon(
                    //           Icons.error,
                    //           color: iconGrey,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              overflow: TextOverflow.visible,
                              name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    wordSpacing: 2,
                                    //color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      overflow: TextOverflow.ellipsis,
                                      location,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            color: Colors.black45,
                                            fontSize: 14,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  overflow: TextOverflow.visible,
                                  'Service Type',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: Colors.black87,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              overflow: TextOverflow.visible,
                              service,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: iconGrey,
                                    fontSize: 13,
                                  ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  height: 35,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Center(
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/receipt',
                                          arguments: {
                                            'id': id,
                                            'name': name,
                                            'datetime': date,
                                            'amount': amount,
                                            'receiptId': code,
                                            'phone': phone,
                                            'service': service,
                                          },
                                        );
                                        // context.read<AppointmentBloc>().add(
                                        //       DeleteAppointmentEvent(
                                        //           id: id),
                                        //     );
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.receipt_long_rounded,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            "View Receipt",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .copyWith(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
