import 'package:flutter/material.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:new_packers_application/views/PackersMoversScreen.dart';
import 'package:new_packers_application/views/ACServicesScreen.dart';
import 'package:new_packers_application/views/CleaningServicesScreen.dart';
import 'package:new_packers_application/views/OtherHomeServiceScreen.dart';








const Color darkBlue = Color(0xFF03669d);
const Color mediumBlue = Color(0xFF37b3e7);
const Color lightBlue = Color(0xFF7ed2f7);
const Color whiteColor = Color(0xFFf7f7f7);

class HomeServiceView extends StatefulWidget {
  const HomeServiceView({super.key});

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

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }



  // WhatsApp chat
  void _openWhatsApp() async {
    final String phoneNumber = '919022062666';
    final String message = 'Hello from Mumbai Metro Packers & Movers app';

    // WhatsApp app URL
    final Uri whatsappAppUri = Uri.parse(
      'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}',
    );

    // WhatsApp Web fallback URL
    final Uri whatsappWebUri = Uri.parse(
      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',
    );

    try {
      // Try launching the app first
      await launchUrl(whatsappAppUri);
    } catch (e) {
      // If it fails, open WhatsApp Web
      if (await canLaunchUrl(whatsappWebUri)) {
        await launchUrl(whatsappWebUri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }
  }


  // Phone call
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
                  'Hi, Suraj Supekar',
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
            GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16.0),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.0,
              children: [
                _buildButton('Packers & Movers', Icons.local_shipping, onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PackersMoversScreen()),
                  );
                }),
                _buildButton('AC Services', Icons.ac_unit, onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ACServicesScreen()),
                  );
                }),

                _buildButton('Cleaning Services', Icons.cleaning_services, onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CleaningServicesScreen()),
                  );
                }),
                _buildButton('Other Home Service', Icons.home_repair_service, onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OtherHomeServiceScreen()),
                  );
                }),
                _buildButton('Call Us', Icons.call, onTap: _makePhoneCall), // NEW BUTTON
              ],
            ),
            const Spacer(),
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
