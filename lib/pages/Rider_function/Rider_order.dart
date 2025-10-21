import 'package:flutter/material.dart';
import 'order_detail_page.dart';

class RiderOrder extends StatelessWidget {
  const RiderOrder({super.key});

  //ตัวอย่างข้อมูลงานที่พร้อมรับ
  final List<Map<String, String>> jobs = const [
    {"id": "#ORD-0123456789", "distance": "5 เมตร"},
    {"id": "#ORD-098765431", "distance": "10 เมตร"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C3B66),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C3B66),
        elevation: 0,
        title: const Text(
          "งานที่พร้อมรับ",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFB3D4FC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job['id']!,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job['distance']!,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OrderDetailPage(orderId: job['id']!),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C3B66),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "รับงาน",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
