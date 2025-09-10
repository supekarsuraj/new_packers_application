import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:new_packers_application/views/PackersMoversScreen.dart';
import 'package:new_packers_application/views/ACServicesScreen.dart';
import 'package:new_packers_application/views/CleaningServicesScreen.dart';
import 'package:new_packers_application/views/OtherHomeServiceScreen.dart';
import '../lib/views/MyRequestScreen.dart';
import '../models/UserData.dart';

const Color darkBlue = Color(0xFF03669d);
const Color mediumBlue = Color(0xFF37b3e7);
const Color lightBlue = Color(0xFF7ed2f7);
const Color whiteColor = Color(0xFFf7f7f7);

class HomeServiceView extends StatefulWidget {
  final UserData? userData;

  const HomeServiceView({super.key, this.userData});

  @override
  State<HomeServiceView> createState() => _HomeServiceViewState();
}

class _HomeServiceViewState extends State<HomeServiceView> {
  final List<String> images = [
    'assets/parcelwala4.jpg',
    'assets/parcelwala5.jpg',
    'assets/parcelwala6.jpg',
    'assets/parcelwala7.jpg',
  ];

  int currentIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  List<dynamic> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();

    Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (mounted) {
        setState(() {
          currentIndex = (currentIndex + 1) % images.length;
          _pageController.animateToPage(
            currentIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      }
    });
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse("https://54kidsstreet.org/api/category"),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          categories = jsonData["data"];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToMyRequest() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyRequestScreen()),
    );
  }

  void _openWhatsApp() async {
    final String phoneNumber = '919022062666';
    final String message = 'Hello from Mumbai Metro Packers & Movers app';

    final Uri whatsappAppUri = Uri.parse(
      'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}',
    );

    final Uri whatsappWebUri = Uri.parse(
      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',
    );

    try {
      await launchUrl(whatsappAppUri);
    } catch (e) {
      if (await canLaunchUrl(whatsappWebUri)) {
        await launchUrl(whatsappWebUri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }
  }

  void _makePhoneCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '8888888888');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone app')),
      );
    }
  }

  Widget _buildButton(String title, IconData icon, {VoidCallback? onTap}) {
    return ElevatedButton(
      onPressed: onTap ?? () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: whiteColor,
        side: const BorderSide(color: mediumBlue, width: 2),
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: mediumBlue, size: 28),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              color: darkBlue,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Convert API category to button
  Widget _buildCategoryButton(Map<String, dynamic> category) {
    String name = category["name"] ?? "Unknown";
    String? imageUrl = category["image_url"];

    IconData defaultIcon = Icons.category;

    return ElevatedButton(
      onPressed: () {
        // Navigate based on category name
        if (name.toLowerCase().contains("packer")) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const PackersMoversScreen()));
        } else if (name.toLowerCase().contains("ac")) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ACServicesScreen()));
        } else if (name.toLowerCase().contains("clean")) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CleaningServicesScreen()));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const OtherHomeServiceScreen()));
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: whiteColor,
        side: const BorderSide(color: mediumBlue, width: 2),
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          imageUrl != null && imageUrl.isNotEmpty
              ? Image.network(imageUrl, height: 28, width: 28, errorBuilder: (c, e, s) {
            return Icon(defaultIcon, color: mediumBlue, size: 28);
          })
              : Icon(defaultIcon, color: mediumBlue, size: 28),
          const SizedBox(height: 5),
          Text(
            name,
            style: const TextStyle(
              color: darkBlue,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        title: const Text(
          'Mumbai Metro Packers and Movers',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: whiteColor,
            fontSize: 18,
          ),
        ),
        backgroundColor: darkBlue,
        elevation: 2,
        centerTitle: false,
        titleSpacing: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: whiteColor),
            onPressed: () {},
          ),
        ),
      ),
      body: Container(
        color: whiteColor,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Hi, ${widget.userData?.customerName ?? 'User'}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: darkBlue,
                  ),
                ),
              ),
            ),
            Container(
              height: 200,
              color: lightBlue,
              child: PageView.builder(
                controller: _pageController,
                itemCount: images.length,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Image.asset(images[index], fit: BoxFit.cover);
                },
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(16.0),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.0,
                children: [
                  ...categories.map((cat) => _buildCategoryButton(cat)).toList(),
                  _buildButton('My Request', Icons.check_circle, onTap: _navigateToMyRequest),
                  _buildButton('Call Us', Icons.call, onTap: _makePhoneCall),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _openWhatsApp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.chat, color: Colors.white),
                    SizedBox(width: 10),
                    Text('Chat with us',
                        style: TextStyle(color: Colors.white)),
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
