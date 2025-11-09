import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FollowOneOrderPage extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> orderData;

  const FollowOneOrderPage({
    super.key,
    required this.orderId,
    required this.orderData,
  });

  Future<Map<String, dynamic>?> fetchOrderData() async {
    try {
      // ✅ ดึงข้อมูล Order
      final orderSnap = await FirebaseFirestore.instance
          .collection('Order')
          .doc(orderId)
          .get();

      if (!orderSnap.exists) return null;
      final order = orderSnap.data()!;

      // ✅ ดึงข้อมูล Parcel ที่มี orderId ตรงกัน
      final parcelSnap = await FirebaseFirestore.instance
          .collection('Parcel')
          .where('orderId', isEqualTo: orderId)
          .get();

      if (parcelSnap.docs.isNotEmpty) {
        order['parcel'] = parcelSnap.docs.first.data();
      } else {
        print("⚠️ ไม่พบข้อมูลพัสดุของ orderId: $orderId");
      }

      return order;
    } catch (e) {
      print("❌ Error fetching order: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C3B66),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C3B66),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "ติดตามสถานะสินค้า",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchOrderData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text(
                "ไม่พบข้อมูลออเดอร์นี้",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final order = snapshot.data!;
          final parcel = order['parcel'] ?? {};

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ✅ ข้อมูลพัสดุ
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9C4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "ข้อมูลพัสดุ",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text(
                              "ชื่อสินค้า: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                parcel['name'] ?? "ไม่ระบุชื่อพัสดุ",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text(
                              "ราคา: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "${parcel['price'] ?? order['total_cost'] ?? 0} ฿",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ✅ สถานะ
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        order['status'] ?? "รออัปเดตสถานะ",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ✅ ข้อมูลผู้รับ
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A90E2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.person, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              "ข้อมูลผู้รับ",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "ชื่อผู้รับ: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                order['receiverName'] ?? "ไม่พบชื่อผู้รับ",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "ที่อยู่จัดส่ง: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                order['receiverAddress'] ??
                                    "ไม่พบข้อมูลที่อยู่จัดส่ง",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ✅ รูปภาพพัสดุ
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.image, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              "รูปภาพพัสดุ",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child:
                              (order['imagePath'] != null &&
                                  order['imagePath'].toString().isNotEmpty)
                              ? Image.file(
                                  File(order['imagePath']),
                                  fit: BoxFit.cover,
                                  height: 200,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        height: 200,
                                        color: Colors.white12,
                                        alignment: Alignment.center,
                                        child: const Text(
                                          "ไม่สามารถโหลดรูปภาพได้",
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ),
                                )
                              : Container(
                                  height: 200,
                                  color: Colors.white12,
                                  alignment: Alignment.center,
                                  child: const Text(
                                    "ไม่พบรูปภาพ",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
