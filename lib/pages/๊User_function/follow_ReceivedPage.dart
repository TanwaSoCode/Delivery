import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery/pages/๊User_function/follow_one_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class FollowAllReceivedPage extends StatefulWidget {
  final String userId; // รับไอดีผู้รับ
  const FollowAllReceivedPage({super.key, required this.userId});

  @override
  State<FollowAllReceivedPage> createState() => _FollowAllReceivedPageState();
}

class _FollowAllReceivedPageState extends State<FollowAllReceivedPage> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      print("User ID ที่ส่งเข้ามา: ${widget.userId}");
      final snapshot = await FirebaseFirestore.instance
          .collection("Order")
          .where("userId", isEqualTo: widget.userId)
          // .orderBy("createdAt", descending: true) // ถ้าต้องการเรียงตามวันที่
          .get();

      print("จำนวนเอกสารที่เจอ: ${snapshot.docs.length}");

      setState(() {
        orders = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching orders: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
          "ติดตามสถานะสินค้าที่รับ",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // แผนที่
            Container(
              margin: const EdgeInsets.all(16),
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.grey[300],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(16.246373, 103.251827),
                    initialZoom: 15.2,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=f40b14c2ac6146e39fb5c55a0fbf124b',
                      userAgentPackageName: 'com.example.delivery',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(16.246373, 103.251827),
                          width: 50,
                          height: 50,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // จำนวนออเดอร์ทั้งหมด
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "ขณะนี้มีรายการสินค้าที่คุณจะได้รับทั้งหมด",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${orders.length} รายการ",
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // แสดงรายการออเดอร์
            for (var order in orders)
              OrderCard(
                status: order['status'] ?? "ไม่ระบุสถานะ",
                price: "${order['total_cost'] ?? 0}",
                orderData: order,
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final String status;
  final String price;
  final Map<String, dynamic> orderData;

  const OrderCard({
    super.key,
    required this.status,
    required this.price,
    required this.orderData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4A90E2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "สถานะออเดอร์",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 5),
          Text(
            status,
            style: const TextStyle(
              color: Colors.yellow,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "$price.-",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[600],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                final orderId = orderData['id'];
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FollowOneOrderPage(
                      orderId: orderId, // ส่งเฉพาะ orderId ไป
                      orderData: orderData, // (ถ้าอยากส่งข้อมูลอื่นไปด้วยก็ได้)
                    ),
                  ),
                );
              },
              child: const Text("คลิกเพื่อติดตาม"),
            ),
          ),
        ],
      ),
    );
  }
}
