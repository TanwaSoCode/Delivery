import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery/pages/Rider_function/Rider_order.dart';
import 'package:delivery/pages/Rider_function/Rider_work.dart';
import 'package:delivery/pages/page_login.dart';
import 'package:flutter/material.dart';
class RiderProfile extends StatefulWidget {
  final String userId;
  const RiderProfile({super.key, required this.userId});

  @override
  State<RiderProfile> createState() => _RiderProfileState();
}

class _RiderProfileState extends State<RiderProfile> {
  Map<String, dynamic>? riderData;

  @override
  void initState() {
    super.initState();
    fetchRiderData();
  }

  Future<void> fetchRiderData() async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection("Rider")
          .doc(widget.userId)
          .get();

      if (doc.exists) {
        setState(() {
          riderData = doc.data();
        });
      }
    } catch (e) {
      print("Error fetching rider data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (riderData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final profileUrl = riderData?['profileUrl'] as String?;

    return Scaffold(
      backgroundColor: const Color(0xFF0C3B66),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF4A90E2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: riderData!['profileUrl'] != ""
                        ? NetworkImage(riderData!['profileUrl'])
                        : const AssetImage("assets/images/rider.png")
                              as ImageProvider,
                  ),

                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${riderData!['firstName']} ${riderData!['lastName']}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        riderData!['phone'],
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _menuButton(
                icon: Icons.assignment,
                text: "งานที่ได้รับ",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RiderOrder()),
                  );
                },
              ),
              const SizedBox(height: 10),

              _menuButton(
                icon: Icons.delivery_dining,
                text: "งานที่กำลังดำเนินการ",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RiderWork()),
                  );
                },
              ),
              const SizedBox(height: 10),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.logout, color: Colors.black),
                  label: const Text(
                    "ออกจากระบบ",
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0C3B66)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Color(0xFF0C3B66),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}
///