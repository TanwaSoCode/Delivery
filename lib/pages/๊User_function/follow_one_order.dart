import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// เพิ่มฟังก์ชันเรียกเส้นทางจาก OpenRouteService
Future<List<LatLng>> getRoutePoints(LatLng start, LatLng end) async {
  const apiKey =
      "eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6ImVjYzc3MWNkYjJiZDRiZjM4ZmIxNmNlMWI1OTM0MWNjIiwiaCI6Im11cm11cjY0In0=";
  final url = Uri.parse(
    "https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}",
  );

  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final coords = data['features'][0]['geometry']['coordinates'] as List;
    return coords.map((c) => LatLng(c[1], c[0])).toList();
  } else {
    print("Failed to get route: ${response.statusCode}");
    return [];
  }
}

class FollowOneOrderPage extends StatefulWidget {
  final String orderId;
  final Map<String, dynamic> orderData;

  const FollowOneOrderPage({
    super.key,
    required this.orderId,
    required this.orderData,
  });

  @override
  State<FollowOneOrderPage> createState() => _FollowOneOrderPageState();
}

class _FollowOneOrderPageState extends State<FollowOneOrderPage> {
  List<List<LatLng>> routeLines = [];
  Map<String, dynamic>? currentOrderData;

  Future<Map<String, dynamic>?> fetchOrderData() async {
    try {
      final orderSnap = await FirebaseFirestore.instance
          .collection('Order')
          .doc(widget.orderId)
          .get();

      if (!orderSnap.exists) return null;

      final order = orderSnap.data()!;
      currentOrderData = order;

      // ✅ โหลดเส้นทางตามสถานะปัจจุบัน
      await _loadRoutesBasedOnStatus(order);

      return order;
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<void> _loadRoutesBasedOnStatus(Map<String, dynamic> order) async {
    routeLines.clear();

    if (order['pickupLat'] != null &&
        order['receiverLat'] != null &&
        order['riderLat'] != null) {
      final pickupLatLng = LatLng(
        double.parse(order['pickupLat']),
        double.parse(order['pickupLng']),
      );
      final receiverLatLng = LatLng(
        double.parse(order['receiverLat']),
        double.parse(order['receiverLng']),
      );
      final riderLatLng = LatLng(order['riderLat'], order['riderLng']);

      final status = order['status'] ?? 'ไรเดอร์รับงาน';

      switch (status) {
        case 'ไรเดอร์รับงาน':
          // เส้นทางจากไรเดอร์ไปจุดรับสินค้า
          final routeToPickup = await getRoutePoints(riderLatLng, pickupLatLng);
          if (routeToPickup.isNotEmpty) {
            routeLines.add(routeToPickup);
          }
          break;

        case 'รับสินค้าแล้ว':
          // เส้นทางจากไรเดอร์ไปจุดรับสินค้า (สีเขียว)
          final routeToPickup = await getRoutePoints(riderLatLng, pickupLatLng);
          if (routeToPickup.isNotEmpty) {
            routeLines.add(routeToPickup);
          }
          break;

        case 'กำลังเดินทางไปส่ง':
          // เส้นทางจากจุดรับสินค้าไปจุดส่ง (สีส้ม)
          final routeToReceiver = await getRoutePoints(
            pickupLatLng,
            receiverLatLng,
          );
          if (routeToReceiver.isNotEmpty) {
            routeLines.add(routeToReceiver);
          }
          break;

        case 'นำส่งสินค้าแล้ว':
          // เส้นทางจากจุดรับสินค้าไปจุดส่ง (สีน้ำเงิน - เสร็จสมบูรณ์)
          final routeToReceiver = await getRoutePoints(
            pickupLatLng,
            receiverLatLng,
          );
          if (routeToReceiver.isNotEmpty) {
            routeLines.add(routeToReceiver);
          }
          break;

        default:
          // เส้นทางจากจุดรับไปจุดส่งเป็นค่าเริ่มต้น
          final defaultRoute = await getRoutePoints(
            pickupLatLng,
            receiverLatLng,
          );
          if (defaultRoute.isNotEmpty) {
            routeLines.add(defaultRoute);
          }
          break;
      }
    }
  }

  Color _getRouteColor(String status) {
    switch (status) {
      case 'ไรเดอร์รับงาน':
        return Colors.blue; // สีน้ำเงิน - กำลังไปรับ
      case 'รับสินค้าแล้ว':
        return Colors.green; // สีเขียว - รับสินค้าแล้ว
      case 'กำลังเดินทางไปส่ง':
        return Colors.orange; // สีส้ม - กำลังส่ง
      case 'นำส่งสินค้าแล้ว':
        return Colors.purple; // สีม่วง - ส่งสำเร็จ
      default:
        return Colors.grey; // สีเทา - ไม่ทราบสถานะ
    }
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'ไรเดอร์รับงาน':
        return 'ไรเดอร์รับงานและกำลังเดินทางไปรับสินค้า';
      case 'รับสินค้าแล้ว':
        return 'ไรเดอร์รับสินค้าเรียบร้อยแล้ว';
      case 'กำลังเดินทางไปส่ง':
        return 'ไรเดอร์กำลังเดินทางไปส่งสินค้า';
      case 'นำส่งสินค้าแล้ว':
        return 'ส่งสินค้าเรียบร้อยแล้ว';
      default:
        return 'รออัปเดตสถานะ';
    }
  }

  Widget _buildStatusImage(String title, String? imagePath) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white30),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: (imagePath != null && imagePath.isNotEmpty)
                ? Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildPlaceholderImage('ไม่สามารถโหลดรูปภาพ'),
                  )
                : _buildPlaceholderImage('ยังไม่ถ่ายภาพ'),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPlaceholderImage(String text) {
    return Container(
      color: Colors.white12,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.photo, size: 40, color: Colors.white70),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
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
          final status = order['status'] ?? 'ไรเดอร์รับงาน';

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

                  // ✅ สถานะปัจจุบัน
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
                            Icon(Icons.info, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "สถานะปัจจุบัน",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getStatusDescription(status),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

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

                  // ✅ แผนที่แสดงตำแหน่งจัดส่ง
                  Container(
                    height: 350,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(
                            double.parse(order['pickupLat'] ?? '16.246373'),
                            double.parse(order['pickupLng'] ?? '103.251827'),
                          ),
                          initialZoom: 15.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=f40b14c2ac6146e39fb5c55a0fbf124b',
                            userAgentPackageName: 'com.example.delivery',
                          ),

                          // ✅ เส้นทางตามสถานะ
                          PolylineLayer(
                            polylines: [
                              for (var line in routeLines)
                                Polyline(
                                  points: line,
                                  color: _getRouteColor(status),
                                  strokeWidth: 4,
                                ),
                            ],
                          ),

                          // ✅ Marker พร้อม popup
                          PopupMarkerLayerWidget(
                            options: PopupMarkerLayerOptions(
                              markers: [
                                if (order['riderLat'] != null &&
                                    order['riderLng'] != null)
                                  Marker(
                                    point: LatLng(
                                      order['riderLat'],
                                      order['riderLng'],
                                    ),
                                    width: 50,
                                    height: 50,
                                    child: const Icon(
                                      Icons.directions_bike,
                                      color: Colors.blue,
                                      size: 40,
                                    ),
                                  ),
                                if (order['pickupLat'] != null &&
                                    order['pickupLng'] != null)
                                  Marker(
                                    point: LatLng(
                                      double.parse(order['pickupLat']),
                                      double.parse(order['pickupLng']),
                                    ),
                                    width: 50,
                                    height: 50,
                                    child: const Icon(
                                      Icons.store,
                                      color: Colors.orange,
                                      size: 40,
                                    ),
                                  ),
                                if (order['receiverLat'] != null &&
                                    order['receiverLng'] != null)
                                  Marker(
                                    point: LatLng(
                                      double.parse(order['receiverLat']),
                                      double.parse(order['receiverLng']),
                                    ),
                                    width: 50,
                                    height: 50,
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                  ),
                              ],
                              popupDisplayOptions: PopupDisplayOptions(
                                builder: (BuildContext context, Marker marker) {
                                  String type = '';
                                  String description = '';

                                  if (order['riderLat'] != null &&
                                      marker.point.latitude ==
                                          order['riderLat'] &&
                                      marker.point.longitude ==
                                          order['riderLng']) {
                                    type = 'ไรเดอร์';
                                    description = 'ผู้จัดส่งสินค้า';
                                  } else if (order['pickupLat'] != null &&
                                      marker.point.latitude ==
                                          double.parse(order['pickupLat']) &&
                                      marker.point.longitude ==
                                          double.parse(order['pickupLng'])) {
                                    type = 'จุดรับสินค้า';
                                    description = 'ร้านค้า/จุดรับพัสดุ';
                                  } else if (order['receiverLat'] != null &&
                                      marker.point.latitude ==
                                          double.parse(order['receiverLat']) &&
                                      marker.point.longitude ==
                                          double.parse(order['receiverLng'])) {
                                    type = 'จุดส่งสินค้า';
                                    description = 'ที่อยู่ผู้รับ';
                                  }

                                  return Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            type,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            description,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ✅ รูปภาพทั้งหมดตามสถานะ
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
                            Icon(Icons.photo_library, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "รูปภาพการจัดส่ง",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // รูปภาพสถานะต่างๆ
                        _buildStatusImage("ไรเดอร์รับงาน", order['imagePath']),
                        _buildStatusImage(
                          "รับสินค้าแล้ว",
                          order['รับสินค้าแล้ว_image'],
                        ),
                        _buildStatusImage(
                          "กำลังเดินทางไปส่ง",
                          order['กำลังเดินทางไปส่ง_image'],
                        ),
                        _buildStatusImage(
                          "นำส่งสินค้าแล้ว",
                          order['นำส่งสินค้าแล้ว_image'],
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
