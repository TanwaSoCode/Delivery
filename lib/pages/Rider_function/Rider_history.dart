import 'package:flutter/material.dart';

class RiderHistoryPage extends StatelessWidget {
  const RiderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    //ข้อมูลประวัติการส่ง
    final List<Map<String, dynamic>> historyData = [
      {
        "orderId": "#ORD-10001",
        "status": "จัดส่งสำเร็จ",
        "address": "หอพักนิสิต มมส",
        "date": "19 ตุลาคม 2025, 14:32 น.",
      },
      {
        "orderId": "#ORD-10002",
        "status": "จัดส่งสำเร็จ",
        "address": "ตลาดโนนศิลา",
        "date": "19 ตุลาคม 2025, 11:20 น.",
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0C3B66),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C3B66),
        centerTitle: true,
        title: const Text(
          "ประวัติการส่ง",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var item in historyData)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["orderId"],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "สถานะ: ${item["status"]}",
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "ที่อยู่: ${item["address"]}",
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "วันที่จัดส่ง: ${item["date"]}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
