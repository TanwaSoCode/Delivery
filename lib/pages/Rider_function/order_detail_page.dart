import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

// เพิ่มฟังก์ชันเรียกเส้นทางจาก OpenRouteService
Future<List<LatLng>> getRoutePoints(LatLng start, LatLng end) async {
  try {
    const apiKey =
        "eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6ImVjYzc3MWNkYjJiZDRiZjM4ZmIxNmNlMWI1OTM0MWNjIiwiaCI6Im11cm11cjY0In0=";
    final url = Uri.parse(
      "https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}",
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final features = data['features'] as List;

      if (features.isNotEmpty) {
        final coords = features[0]['geometry']['coordinates'] as List;
        return coords.map((c) => LatLng(c[1], c[0])).toList();
      }
    }
    print("Failed to get route: ${response.statusCode}");
    return [];
  } catch (e) {
    print("Error getting route: $e");
    return [];
  }
}

class OrderDetailPage extends StatefulWidget {
  final String orderId;
  final String riderId;

  const OrderDetailPage({
    super.key,
    required this.orderId,
    required this.riderId,
  });

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  bool isLoading = true;
  bool _hasAccepted = false;
  Map<String, dynamic>? orderData;
  Map<String, dynamic>? parcelData;
  List<LatLng> riderPath = [];

  List<List<LatLng>> routeLines = [];
  List<LatLng> currentRoute = [];
  StreamSubscription<Position>? _positionStream;

  String currentStatus = "กำลังจัดส่งงาน";
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPage();
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _initPage() async {
    await fetchOrderDetails();

    // ตรวจสอบว่าออเดอร์นี้ถูกรับแล้วหรือยัง
    if (orderData?['riderId'] == null ||
        orderData?['riderId'] != widget.riderId) {
      // ถ้ายังไม่ถูกรับ ให้เรียก acceptOrder
      await acceptOrder();
    } else {
      // ถ้าถูกรับแล้ว ให้ตั้งค่า _hasAccepted เป็น true
      setState(() {
        _hasAccepted = true;
        currentStatus = orderData?['status'] ?? "ไรเดอร์รับงาน";
      });
    }

    // สร้างเส้นทาง
    if (orderData?['riderLat'] != null &&
        orderData?['riderLng'] != null &&
        orderData?['pickupLat'] != null &&
        orderData?['pickupLng'] != null &&
        orderData?['receiverLat'] != null &&
        orderData?['receiverLng'] != null) {
      final routeFromRider = await getRoutePoints(
        LatLng(orderData!['riderLat'], orderData!['riderLng']),
        LatLng(
          double.parse(orderData!['pickupLat'].toString()),
          double.parse(orderData!['pickupLng'].toString()),
        ),
      );

      final routeToReceiver = await getRoutePoints(
        LatLng(
          double.parse(orderData!['pickupLat'].toString()),
          double.parse(orderData!['pickupLng'].toString()),
        ),
        LatLng(
          double.parse(orderData!['receiverLat'].toString()),
          double.parse(orderData!['receiverLng'].toString()),
        ),
      );

      if (routeFromRider.isNotEmpty && routeToReceiver.isNotEmpty) {
        setState(() {
          routeLines = [routeFromRider, routeToReceiver];
        });
      }
    }

    startRiderLocationTracking();
  }

  Future<void> startRiderLocationTracking() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("ต้องการสิทธิ์การเข้าถึงตำแหน่งเพื่อติดตามการจัดส่ง"),
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("ไม่สามารถเข้าถึงตำแหน่งได้ กรุณาอนุญาตในตั้งค่า"),
        ),
      );
      return;
    }

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          ),
        ).listen(
          (Position position) async {
            try {
              await FirebaseFirestore.instance
                  .collection("Order")
                  .doc(widget.orderId)
                  .update({
                    "riderLat": position.latitude,
                    "riderLng": position.longitude,
                  });

              setState(() {
                orderData?['riderLat'] = position.latitude;
                orderData?['riderLng'] = position.longitude;
                riderPath.add(LatLng(position.latitude, position.longitude));
              });
            } catch (e) {
              print("❌ เกิดข้อผิดพลาดในการอัปเดตตำแหน่ง: $e");
            }
          },
          onError: (error) {
            print("❌ ข้อผิดพลาดในการติดตามตำแหน่ง: $error");
          },
        );
  }

  Future<void> _takePhotoAndUpdateStatus(
    String status,
    String description,
  ) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (image != null) {
        final String newFileName =
            '${widget.orderId}_${status}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String newPath =
            '${image.path.split('/').sublist(0, image.path.split('/').length - 1).join('/')}/$newFileName';

        final File originalFile = File(image.path);
        final File newFile = await originalFile.copy(newPath);
        await originalFile.delete();

        // อัปเดตสถานะและ path ภาพใน Firestore
        await FirebaseFirestore.instance
            .collection("Order")
            .doc(widget.orderId)
            .update({
              "status": status,
              "${status.toLowerCase()}_image": newPath,
              "${status.toLowerCase()}_timestamp": FieldValue.serverTimestamp(),
            });

        // ถ้าเป็นสถานะส่งสำเร็จ
        if (status == "นำส่งสินค้าแล้ว") {
          await FirebaseFirestore.instance
              .collection("Rider")
              .doc(widget.riderId)
              .update({
                "status": "ว่าง",
                "updated_at": FieldValue.serverTimestamp(),
              });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ จัดส่งสำเร็จ! กลับสู่หน้าหลัก"),
              duration: Duration(seconds: 2),
            ),
          );

          await Future.delayed(const Duration(seconds: 2));

          if (mounted) {
            Navigator.of(context).pop();
          }
          return;
        }

        setState(() {
          currentStatus = status;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("$description สำเร็จ ✅")));

        await fetchOrderDetails();
      }
    } catch (e) {
      print("❌ เกิดข้อผิดพลาดในการถ่ายภาพและอัปเดตสถานะ: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("$description ล้มเหลว: $e")));
    }
  }

  Future<void> acceptOrder() async {
    print("🚀 เริ่มทำงาน acceptOrder()");

    try {
      final position = await _getCurrentPosition();
      print("📍 พิกัดปัจจุบัน: ${position.latitude}, ${position.longitude}");

      // อัปเดต Order ด้วยข้อมูลไรเดอร์
      await FirebaseFirestore.instance
          .collection("Order")
          .doc(widget.orderId)
          .update({
            "status": "ไรเดอร์รับงาน",
            "riderId": widget.riderId,
            "riderLat": position.latitude,
            "riderLng": position.longitude,
            "accepted_timestamp": FieldValue.serverTimestamp(),
          });

      // อัพเดตสถานะไรเดอร์
      await FirebaseFirestore.instance
          .collection("Rider")
          .doc(widget.riderId)
          .update({
            "status": "กำลังจัดส่งงาน",
            "updated_at": FieldValue.serverTimestamp(),
          });

      print("✅ อัปเดต Order และ Rider สำเร็จ");

      setState(() {
        _hasAccepted = true;
        currentStatus = "ไรเดอร์รับงาน";
      });

      await fetchOrderDetails();
    } catch (e) {
      print("❌ เกิดข้อผิดพลาดใน acceptOrder(): $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("รับออเดอร์ล้มเหลว: $e")));
    }
  }

  Future<Position> _getCurrentPosition() async {
    print("📡 กำลังขอตำแหน่งปัจจุบัน...");
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> fetchOrderDetails() async {
    print("📦 โหลดข้อมูลออเดอร์จาก Firestore...");
    try {
      final orderDoc = await FirebaseFirestore.instance
          .collection("Order")
          .doc(widget.orderId)
          .get();

      if (!orderDoc.exists) {
        print("⚠️ ไม่พบเอกสาร Order");
        setState(() => isLoading = false);
        return;
      }

      final order = orderDoc.data()!;
      print("✅ โหลด Order สำเร็จ: ${order['status']}");

      final parcelSnap = await FirebaseFirestore.instance
          .collection("Parcel")
          .where("orderId", isEqualTo: widget.orderId)
          .limit(1)
          .get();

      setState(() {
        orderData = order;
        parcelData = parcelSnap.docs.isNotEmpty
            ? parcelSnap.docs.first.data()
            : null;
        currentStatus = orderData?['status'] ?? "ไรเดอร์รับงาน";
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching order: $e");
      setState(() => isLoading = false);
    }
  }

  Widget _buildPhotoButton(
    String status,
    String buttonText,
    String description,
  ) {
    return ElevatedButton(
      onPressed: () => _takePhotoAndUpdateStatus(status, description),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.camera_alt, size: 20),
          const SizedBox(width: 8),
          Text(buttonText),
        ],
      ),
    );
  }

  Widget _buildStatusWithImage(
    String status,
    String imageField, {
    String? localImagePath,
  }) {
    // ตรวจสอบว่ามีภาพจาก field ที่ระบุหรือไม่
    bool hasImage = orderData?[imageField] != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "$status: ",
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              hasImage ? "✅ ถ่ายภาพแล้ว" : "❌ ยังไม่ถ่ายภาพ",
              style: TextStyle(
                color: hasImage ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (hasImage) ...[
          const SizedBox(height: 8),
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(orderData![imageField]),
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.error, color: Colors.red),
                  );
                },
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0C3B66),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (orderData == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0C3B66),
        body: Center(
          child: Text(
            "ไม่พบข้อมูลออเดอร์",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0C3B66),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C3B66),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "รายละเอียดงาน",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ส่วนข้อมูลการจัดส่ง
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "การจัดส่ง",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          currentStatus,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "รหัสออเดอร์: ${widget.orderId}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "ผู้รับ: ${orderData!['receiverName'] ?? '-'}",
                          style: const TextStyle(color: Colors.black),
                        ),
                        Text(
                          "ที่อยู่: ${orderData!['receiverAddress'] ?? '-'}",
                          style: const TextStyle(color: Colors.black),
                        ),
                        Text(
                          "เบอร์โทร: ${orderData!['receiverPhone'] ?? '-'}",
                          style: const TextStyle(color: Colors.black),
                        ),
                        Text(
                          "ค่าจัดส่ง: ${orderData!['total_cost'] ?? 0} ฿",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (parcelData != null) ...[
                          const Divider(),
                          Text(
                            "ชื่อพัสดุ: ${parcelData!['name'] ?? '-'}",
                            style: const TextStyle(color: Colors.black),
                          ),
                          Text(
                            "รายละเอียด: ${parcelData!['description'] ?? '-'}",
                            style: const TextStyle(color: Colors.black),
                          ),
                          Text(
                            "ราคา: ${parcelData!['price'] ?? 0} ฿",
                            style: const TextStyle(color: Colors.black),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ส่วนปุ่มถ่ายภาพตามสถานะ
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "อัปเดตสถานะการจัดส่ง",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPhotoButton(
                        "รับสินค้าแล้ว",
                        "รับสินค้า",
                        "อัปเดตสถานะรับสินค้า",
                      ),
                      _buildPhotoButton(
                        "กำลังเดินทางไปส่ง",
                        "กำลังส่ง",
                        "อัปเดตสถานะกำลังส่ง",
                      ),
                      _buildPhotoButton(
                        "นำส่งสินค้าแล้ว",
                        "ส่งสำเร็จ",
                        "อัปเดตสถานะส่งสำเร็จ",
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  _buildStatusWithImage("ไรเดอร์รับงาน", "ไรเดอร์รับงาน_image"),
                  _buildStatusWithImage("รับสินค้าแล้ว", "รับสินค้าแล้ว_image"),
                  _buildStatusWithImage(
                    "กำลังเดินทางไปส่ง",
                    "กำลังเดินทางไปส่ง_image",
                  ),
                  _buildStatusWithImage(
                    "นำส่งสินค้าแล้ว",
                    "นำส่งสินค้าแล้ว_image",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ส่วนแผนที่
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "แผนที่การจัดส่ง",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
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
                          initialCenter:
                              orderData != null &&
                                  orderData!['pickupLat'] != null
                              ? LatLng(
                                  double.parse(
                                    orderData!['pickupLat'].toString(),
                                  ),
                                  double.parse(
                                    orderData!['pickupLng'].toString(),
                                  ),
                                )
                              : const LatLng(13.7563, 100.5018),
                          initialZoom: 15.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=f40b14c2ac6146e39fb5c55a0fbf124b',
                            userAgentPackageName: 'com.example.delivery',
                          ),
                          MarkerLayer(
                            markers: [
                              if (orderData?['riderLat'] != null &&
                                  orderData?['riderLng'] != null)
                                Marker(
                                  point: LatLng(
                                    orderData!['riderLat'],
                                    orderData!['riderLng'],
                                  ),
                                  width: 50,
                                  height: 50,
                                  child: const Icon(
                                    Icons.directions_bike,
                                    color: Colors.blue,
                                    size: 40,
                                  ),
                                ),
                              if (orderData?['pickupLat'] != null &&
                                  orderData?['pickupLng'] != null)
                                Marker(
                                  point: LatLng(
                                    double.parse(
                                      orderData!['pickupLat'].toString(),
                                    ),
                                    double.parse(
                                      orderData!['pickupLng'].toString(),
                                    ),
                                  ),
                                  width: 50,
                                  height: 50,
                                  child: const Icon(
                                    Icons.store,
                                    color: Colors.orange,
                                    size: 40,
                                  ),
                                ),
                              if (orderData?['receiverLat'] != null &&
                                  orderData?['receiverLng'] != null)
                                Marker(
                                  point: LatLng(
                                    double.parse(
                                      orderData!['receiverLat'].toString(),
                                    ),
                                    double.parse(
                                      orderData!['receiverLng'].toString(),
                                    ),
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
                          ),
                          if (routeLines.isNotEmpty)
                            PolylineLayer(
                              polylines: [
                                for (var line in routeLines)
                                  if (line.isNotEmpty)
                                    Polyline(
                                      points: line,
                                      color: Colors.green,
                                      strokeWidth: 4,
                                    ),
                              ],
                            ),
                        ],
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
  }
}
