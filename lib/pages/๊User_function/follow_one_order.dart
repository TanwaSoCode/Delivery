import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//หน้านี one order

class FollowOneOrderPage extends StatelessWidget {
  final Map<String, dynamic> orderData;
  const FollowOneOrderPage({super.key, required this.orderData});

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

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //ข้อมูลสินค้าที่สั่ง
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
                      "ข้อมูลสินค้าที่สั่ง",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      orderData['product'] ?? "ไม่ระบุสินค้า",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C3B66),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${orderData['price'] ?? '0'}.–",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              //สถานะ
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9C4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 6),
                      Text(
                        orderData['status'] ?? "รออัปเดตสถานะ",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              //ที่อยู
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
                        Icon(Icons.location_on, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          "ที่อยู่จัดส่ง",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      orderData['address'] ?? "ไม่พบข้อมูลที่อยู่",
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          orderData['id'] ?? "ไม่พบข้อมูลเบอร์โทร",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        orderData['image'] ?? "",
                        fit: BoxFit.cover,
                        height: 150,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.white12,
                            height: 150,
                            alignment: Alignment.center,
                            child: const Text(
                              "ไม่พบรูปภาพ",
                              style: TextStyle(color: Colors.white70),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
