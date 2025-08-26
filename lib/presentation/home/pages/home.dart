import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:salonapp_app_owner/helpers/constants/color_constants.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:salonapp_app_owner/helpers/widgets/custom_button.dart';
import 'package:salonapp_app_owner/presentation/appointments/bloc/appointment_bloc.dart';
import 'package:salonapp_app_owner/presentation/authentication/bloc/auth_bloc.dart';
import '../../../helpers/config/size_config.dart';
import '../../../helpers/text style/text_style.dart';
import '../../../helpers/widgets/app_bar.dart';
import '../../../helpers/widgets/grid_view.dart';
import '../../../helpers/widgets/show_up_animation.dart';
import '../../location/bloc/location_bloc.dart';
import '../../notifications/components/local notification/local_notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  List<Icon> icons = <Icon>[
    const Icon(
      MingCute.scissors_line,
      color: primaryColor,
    ),
    const Icon(
      MingCute.hair_line,
      color: primaryColor,
    ),
    const Icon(
      MingCute.sob_fill,
      color: primaryColor,
    ),
    const Icon(
      MingCute.brush_line,
      color: primaryColor,
    ),
    const Icon(
      MingCute.hair_line,
      color: primaryColor,
    ),
    const Icon(
      MingCute.sob_fill,
      color: primaryColor,
    ),
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
    "undraw_barber_utly",
    "undraw_people_ka7y",
    "undraw_pie-graph_8m6b",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final locationState = BlocProvider.of<LocationBloc>(context).state;
    if (locationState is LocationFetchedState) {}
    Future.delayed(Duration.zero, () {
      NotificationService.onNotificationClick = (String? payload) {
        if (payload != null) {
          Navigator.pushNamed(context, payload);
        }
      };
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        context.read<LocationBloc>().wentToSettings) {
      context.read<LocationBloc>().wentToSettings = false;

      Future.delayed(Duration(seconds: 2), () {
        context.read<LocationBloc>().add(LoadLocationEvent());
      });
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppointmentBloc, AppointmentState>(
      listener: (BuildContext context, state) {
        if (state is AuthLogoutSuccesState) {
          Navigator.pushNamed(context, '/');
        } else if (state is AuthenticatedState) {}
      },
      builder: (BuildContext context, state) {
        int unreadCount = 0;
        if (state is AppointmentsFetchedState) {
          unreadCount = state.unreadCount;
          debugPrint("Unread Count: $unreadCount");
        }
        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 242, 242, 242),
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(65),
            child: CustomAppBar(
              count: unreadCount,
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(12.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/createshop');
              },
              child: Container(
                height: 55,
                width: SizeConfig.screenWidth,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        MingCute.add_circle_fill,
                        color: whiteColor,
                        size: 25,
                      ),
                      SizedBox(width: 5),
                      PrimaryText(
                        text: 'Create Your Shop',
                        size: 14,
                        color: whiteColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    //createShopContainer(context),
                    dashboardWidget(context),
                  ],
                ),
              ),
              //dashboardWidget(context),
            ),
          ),
        );
      },
    );
  }

  DottedBorder createShopContainer(BuildContext context) {
    return DottedBorder(
      strokeWidth: 1,
      dashPattern: const [6, 4],
      color: iconGrey,
      borderType: BorderType.RRect,
      radius: const Radius.circular(5),
      child: Container(
        height: MediaQuery.of(context).size.height / 2,
        padding: const EdgeInsets.all(15),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              blurRadius: 5,
              spreadRadius: 0.5,
              color: Color.fromARGB(255, 234, 233, 233),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              height: 140,
              width: 140,
              "assets/svgs/feedbackImage.png",
            ),
            SizedBox(height: 20),
            PrimaryText(
              text: 'No shop available',
              color: Colors.redAccent,
              fontWeight: FontWeight.w600,
              size: 18,
            ),
            SizedBox(height: 8),
            SizedBox(
              width: 273,
              child: Column(
                children: [
                  Text(
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    "No additional fee or taxes will be collected by the salon/barbershop owner when you arrive at the shop.",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            CustomButton(
              icon: MingCute.add_circle_fill,
              text: ' Create Shop',
              onpressed: () {
                Navigator.pushNamed(context, '/createshop');
              },
              color: blackColor,
            ),
          ],
        ),
      ),
    );
  }

  Column dashboardWidget(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PrimaryText(
              text: "Active Shops",
              color: Colors.black,
              fontWeight: FontWeight.w600,
              size: 14,
            ),
          ],
        ),
        SizedBox(height: 8),
        ShowUpAnimation(
          delay: 300,
          child: buildShopCard(
            Colors.black,
            context,
            "Toronto Haircut",
            "Weija-Scc, Accra",
            "assets/svgs/${svgs[0]}.svg",
            0,
            0,
            Colors.white,
            Colors.white,
            Colors.grey.shade200,
          ),
        ),
        SizedBox(height: 20),
        PrimaryText(
          text: "Dashboard",
          color: Colors.black,
          fontWeight: FontWeight.w600,
          size: 15,
        ),
        SizedBox(height: 8),
        GridViewComponent(),
      ],
    );
  }

  Future<void> scrollBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      clipBehavior: Clip.hardEdge,
      //enableDrag: true,
      //useSafeArea: true,
      showDragHandle: true,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          minChildSize: 0.2,
          maxChildSize: 0.9,
          builder: (BuildContext context, ScrollController scrollController) {
            return SizedBox(
              height: 125,
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                itemCount: 4,
                scrollDirection: Axis.vertical,
                itemBuilder: (BuildContext context, int index) {
                  return ShowUpAnimation(
                    delay: 300,
                    child: buildShopCard(
                      Colors.white,
                      context,
                      "Toronto Haircut",
                      "Weija-Scc, Accra",
                      "assets/svgs/${svgs[0]}.svg",
                      10,
                      10,
                      Colors.black,
                      Colors.grey.shade500,
                      Colors.grey.shade200,
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget buildShopCard(
    Color color,
    BuildContext context,
    String title,
    String location,
    String imgs,
    double horiMargin,
    double vertMargin,
    Color textColor,
    Color subtextColor,
    Color brColor,
  ) {
    return Column(
      children: [
        Container(
          height: 130,
          width: MediaQuery.of(context).size.width,
          // padding: const EdgeInsets.symmetric(horizontal: 10),
          // margin: const EdgeInsets.symmetric(horizontal: 5),
          margin: EdgeInsets.symmetric(
            horizontal: horiMargin,
            vertical: vertMargin,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              width: 1.5,
              color: brColor,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 2,
                spreadRadius: 1,
                color: secondaryColor2,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    PrimaryText(
                      textOverflow: TextOverflow.ellipsis,
                      text: title,
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      size: 20,
                    ),
                    SizedBox(height: 2),
                    PrimaryText(
                      text: location,
                      color: subtextColor,
                      fontWeight: FontWeight.w500,
                      size: 11,
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        // Navigator.pushNamed(context, '/appointment');
                      },
                      child: Container(
                        height: 30,
                        width: 105,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: whiteColor,
                          ),
                          color: blackColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Text(
                            "Manage Shop",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    SvgPicture.asset(
                      imgs,
                      height: 90,
                      width: 108,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class adWidget extends StatelessWidget {
  const adWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        // image: DecorationImage(
        //   image: Image.asset("assets/svgs/back.png").image,
        // ),
        border: Border.all(
          width: 1,
          color: Colors.grey.shade300,
        ),
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
