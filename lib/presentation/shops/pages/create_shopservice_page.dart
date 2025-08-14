import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../authentication/bloc/auth_bloc.dart';
import '../bloc/shops_bloc.dart';
import '../components/createservice_controllers.dart';
import 'package:intl/intl.dart';

class CreateShopPage extends StatefulWidget {
  const CreateShopPage({super.key});

  @override
  State<CreateShopPage> createState() => _CreateShopPageState();
}

class _CreateShopPageState extends State<CreateShopPage> {
  final controller = CreateShopController();
  final firebaseUser = FirebaseAuth.instance.currentUser!.uid;
  final _formKey = GlobalKey<FormState>();

  // Dropdown options
  final List<String> categories = ["Unisex", "Men", "Women"];
  final List<String> openingDaysList = [
    "Mondays - Saturdays",
    "Tuesdays - Sundays",
    "All Week"
  ];
  final List<String> openingTimesList = [
    "8:30am - 9:30pm",
    "9:00am - 8:00pm",
    "10:00am - 7:00pm"
  ];
  final List<String> servicesList = [
    "Haircut",
    "Locks",
    "Washing",
    "Shaving",
    "Dyeing"
  ];

  // Selected values
  String? selectedCategory;
  String? selectedDays;
  String? selectedTimes;
  List<String> selectedServices = [];
  List<String> workImages = [];
  List<String> workImageUrls = [];
  String? profileImageUrl;

  String _formatDateHuman(DateTime date) {
    final day = date.day;
    final suffix = (day >= 11 && day <= 13)
        ? 'th'
        : (day % 10 == 1)
            ? 'st'
            : (day % 10 == 2)
                ? 'nd'
                : (day % 10 == 3)
                    ? 'rd'
                    : 'th';
    final month = DateFormat('MMMM').format(date); // "January"
    return '$day$suffix $month ${date.year}'; // e.g., "6th January 2025"
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShopsBloc, ShopsState>(
      listener: (context, state) {
        if (state is ShopCreatedSuccesState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          Navigator.pop(context);
        } else if (state is ShopCreateFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        } else if (state is AuthLogoutSuccesState) {
          Navigator.pushNamed(context, '/');
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Create Shop"),
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Shop Name
                    TextFormField(
                      controller: CreateShopController.shopName,
                      decoration: const InputDecoration(
                        labelText: "Shop Name",
                        filled: true,
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          val!.isEmpty ? "Please enter shop name" : null,
                    ),
                    const SizedBox(height: 16),

                    // Category
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: categories
                          .map((cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => selectedCategory = val),
                      decoration: const InputDecoration(
                        labelText: "Category",
                        border: OutlineInputBorder(),
                        filled: true,
                      ),
                      validator: (val) =>
                          val == null ? "Please select category" : null,
                    ),
                    const SizedBox(height: 16),

                    // Opening Days
                    DropdownButtonFormField<String>(
                      value: selectedDays,
                      items: openingDaysList
                          .map((day) =>
                              DropdownMenuItem(value: day, child: Text(day)))
                          .toList(),
                      onChanged: (val) => setState(() => selectedDays = val),
                      decoration: const InputDecoration(
                        labelText: "Opening Days",
                        border: OutlineInputBorder(),
                        filled: true,
                      ),
                      validator: (val) =>
                          val == null ? "Please select opening days" : null,
                    ),
                    const SizedBox(height: 16),

                    // Opening Times
                    DropdownButtonFormField<String>(
                      value: selectedTimes,
                      items: openingTimesList
                          .map((time) =>
                              DropdownMenuItem(value: time, child: Text(time)))
                          .toList(),
                      onChanged: (val) => setState(() => selectedTimes = val),
                      decoration: const InputDecoration(
                        labelText: "Opening Times",
                        border: OutlineInputBorder(),
                        filled: true,
                      ),
                      validator: (val) =>
                          val == null ? "Please select opening times" : null,
                    ),
                    const SizedBox(height: 16),

                    // Location
                    TextFormField(
                      controller: CreateShopController.location,
                      decoration: const InputDecoration(
                        labelText: "Location",
                        filled: true,
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          val!.isEmpty ? "Please enter location" : null,
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    TextFormField(
                      controller: CreateShopController.phone,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Phone",
                        filled: true,
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          val!.isEmpty ? "Please enter phone number" : null,
                    ),
                    const SizedBox(height: 16),

                    // WhatsApp
                    TextFormField(
                      controller: CreateShopController.whatsapp,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "WhatsApp",
                        filled: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Services - Multi Select
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: servicesList.map((service) {
                        final isSelected = selectedServices.contains(service);
                        return FilterChip(
                          label: Text(service),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedServices.add(service);
                              } else {
                                selectedServices.remove(service);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Profile Image Picker
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<ShopsBloc>().add(PickImageEvent());
                      },
                      icon: const Icon(Icons.image),
                      label: const Text("Pick Profile Image"),
                    ),
                    const SizedBox(height: 16),

                    // Work Images Picker
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<ShopsBloc>().add(PickWorkImagesEvent());
                      },
                      icon: const Icon(Icons.collections),
                      label: const Text("Pick Work Images"),
                    ),
                    const SizedBox(height: 16),
                    if (profileImageUrl != null)
                      ListTile(
                        leading: CircleAvatar(
                            backgroundImage: NetworkImage(profileImageUrl!)),
                        title: const Text('Profile Image'),
                        subtitle: Text(profileImageUrl!),
                      ),

                    if (workImageUrls.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: workImageUrls.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8),
                        itemBuilder: (_, i) => ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(workImageUrls[i],
                              fit: BoxFit.cover),
                        ),
                      ),

                    // Submit Button
                    state is ShopsLoadingState
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                final create = CreateShopEvent(
                                  shopOwnerId: firebaseUser,
                                  shopName:
                                      CreateShopController.shopName.text.trim(),
                                  category: selectedCategory!,
                                  openingDays: selectedDays!,
                                  operningTimes: selectedTimes!,
                                  location:
                                      CreateShopController.location.text.trim(),
                                  phone: CreateShopController.phone.text.trim(),
                                  whatsapp:
                                      CreateShopController.whatsapp.text.trim(),
                                  services: selectedServices.join(", "),
                                  profileImg: profileImageUrl ?? '',
                                  dateJoined: _formatDateHuman(DateTime.now()),
                                  distanceToUser: 0.0,
                                  cordinates: [
                                    double.tryParse(
                                        CreateShopController.latitude.text),
                                    double.tryParse(
                                        CreateShopController.longitude.text),
                                  ],
                                  isOpen: true,
                                )..workImgs.addAll(workImageUrls);

                                context.read<ShopsBloc>().add(create);
                              }
                            },
                            child: const Text("Submit"),
                          ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
