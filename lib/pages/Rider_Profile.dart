import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery/pages/Rider_function/order_detail_page.dart';
import 'package:delivery/pages/page_login.dart';
import 'package:flutter/material.dart';
import 'dart:io'; // เพิ่ม import นี้สำหรับ File

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

  /// ✅ ฟังก์ชันดึงรูปภาพที่รองรับทั้ง Firebase Storage และ Local Path
  ImageProvider getProfileImage() {
    if (riderData == null) {
      return const AssetImage("assets/images/rider.png");
    }

    // ตรวจสอบถ้ามี profileUrl และไม่ว่างเปล่า
    final profileUrl = riderData?['profileUrl'] as String?;
    if (profileUrl != null && profileUrl.isNotEmpty) {
      return NetworkImage(profileUrl);
    }

    // ตรวจสอบถ้ามี profilePath และไม่ว่างเปล่า
    final profilePath = riderData?['profilePath'] as String?;
    if (profilePath != null && profilePath.isNotEmpty) {
      try {
        final file = File(profilePath);
        if (file.existsSync()) {
          return FileImage(file);
        }
      } catch (e) {
        print("Error loading local image: $e");
      }
    }

    // ถ้าไม่มีทั้งคู่ ใช้รูป default
    return const AssetImage("assets/images/rider.png");
  }

  /// ✅ ดึงข้อมูลออเดอร์ที่รอไรเดอร์รับเท่านั้น
  Stream<QuerySnapshot> getAvailableOrders() {
    return FirebaseFirestore.instance
        .collection("Order")
        .where("status", isEqualTo: "รอไรเดอร์รับออเดอร์")
        .snapshots();
  }

  /// ✅ ฟังก์ชันรีเฟรชหน้า
  Future<void> _refreshOrders() async {
    setState(() {});
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    if (riderData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
                  CircleAvatar(radius: 35, backgroundImage: getProfileImage()),
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
                        riderData!['phone'] ?? '-',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        "สถานะ: ${riderData!['status'] ?? 'ว่าง'}",
                        style: TextStyle(
                          color: (riderData!['status'] == 'กำลังจัดส่งงาน')
                              ? Colors.orange
                              : Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ✅ ปุ่มดูงานที่กำลังรับ
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.assignment, color: Colors.black),
                  label: const Text(
                    "งานที่กำลังรับ",
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    // ดึงออเดอร์ที่ไรเดอร์กำลังรับ
                    final querySnapshot = await FirebaseFirestore.instance
                        .collection("Order")
                        .where("riderId", isEqualTo: widget.userId)
                        .where(
                          "status",
                          whereIn: [
                            "ไรเดอร์รับงาน",
                            "รับสินค้าแล้ว",
                            "กำลังเดินทางไปส่ง",
                          ],
                        )
                        .get();

                    if (querySnapshot.docs.isEmpty) {
                      // ❌ ไม่มีงานกำลังรับ
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("ไม่มีงานกำลังรับ"),
                          content: const Text(
                            "คุณยังไม่ได้รับงานใด ๆ ในขณะนี้",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("ตกลง"),
                            ),
                          ],
                        ),
                      );
                      return;
                    }

                    // ✅ ถ้ามีงาน กดไปหน้า OrderDetailPage ของงานแรก
                    final orderDoc = querySnapshot.docs.first;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailPage(
                          orderId: orderDoc.id,
                          riderId: widget.userId,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // ✅ ปุ่มออกจากระบบ
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

              const SizedBox(height: 20),

              // ✅ รายการออเดอร์พร้อมรีเฟรช
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshOrders,
                  color: Colors.white,
                  backgroundColor: const Color(0xFF0C3B66),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: getAvailableOrders(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            "ยังไม่มีออเดอร์ให้รับในขณะนี้",
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      final orders = snapshot.data!.docs;

                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final data =
                              orders[index].data() as Map<String, dynamic>;

                          return Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "ผู้รับ: ${data['receiverName'] ?? '-'}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.shade300,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          data['status'] ?? "",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "ที่อยู่: ${data['receiverAddress'] ?? '-'}",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "ค่าจัดส่ง: ${data['total_cost'] ?? 0} ฿",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final riderDoc = await FirebaseFirestore
                                            .instance
                                            .collection("Rider")
                                            .doc(widget.userId)
                                            .get();

                                        final riderStatus =
                                            riderDoc.data()?['status'] ??
                                            "ว่าง";

                                        if (riderStatus == "กำลังจัดส่งงาน") {
                                          // ❌ เตือนว่าไม่สามารถรับงานใหม่ได้
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text(
                                                "ไม่สามารถรับงานได้",
                                              ),
                                              content: const Text(
                                                "คุณกำลังมีงานที่รับอยู่แล้ว ไม่สามารถรับงานซ้ำได้",
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text("ตกลง"),
                                                ),
                                              ],
                                            ),
                                          );
                                          return;
                                        }

                                        // ✅ ถ้าว่าง ให้ไปหน้า OrderDetailPage
                                        // และอัปเดตสถานะไรเดอร์เป็นกำลังจัดส่งงาน
                                        await FirebaseFirestore.instance
                                            .collection("Rider")
                                            .doc(widget.userId)
                                            .update({
                                              'status': 'กำลังจัดส่งงาน',
                                            });

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                OrderDetailPage(
                                                  orderId: orders[index].id,
                                                  riderId: widget.userId,
                                                ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF0C3B66,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        "รับงานนี้",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
