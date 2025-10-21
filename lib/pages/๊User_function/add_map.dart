import 'dart:developer' show log;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class AddAddressPage extends StatefulWidget {
  final String userId; // รับ userId
  const AddAddressPage({super.key, required this.userId});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final MapController mapController = MapController();
  final TextEditingController addressController = TextEditingController();

  LatLng? selectedPoint;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('เพิ่มที่อยู่จัดส่ง'),
        backgroundColor: const Color(0xFF0C3B66),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🏡 ช่องกรอกที่อยู่
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: addressController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'รายละเอียดที่อยู่',
                alignLabelWithHint: true,
                hintText: 'เช่น 123/4 หมู่บ้านสุขสันต์ ต.ในเมือง อ.เมือง',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // 🗺️ แผนที่
          Expanded(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: LatLng(16.246373, 103.251827),
                initialZoom: 15.2,
                onTap: (tapPosition, point) {
                  log(point.toString());
                  setState(() {
                    selectedPoint = point;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=f40b14c2ac6146e39fb5c55a0fbf124b',
                  userAgentPackageName: 'com.example.project_lottoy',
                ),
                MarkerLayer(
                  markers: [
                    if (selectedPoint != null)
                      Marker(
                        point: selectedPoint!,
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

          // 📍 แสดงค่าละติจูด ลองจิจูด
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Text(
              selectedPoint != null
                  ? "ละติจูด: ${selectedPoint!.latitude.toStringAsFixed(6)} | ลองจิจูด: ${selectedPoint!.longitude.toStringAsFixed(6)}"
                  : "ยังไม่ได้เลือกตำแหน่งบนแผนที่",
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),

          // ✅ ปุ่มยืนยัน
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0C3B66),
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 14,
                ),
              ),
              onPressed: () async {
                if (selectedPoint == null || addressController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('กรุณากรอกที่อยู่และเลือกตำแหน่งบนแผนที่'),
                    ),
                  );
                  return;
                }

                try {
                  await FirebaseFirestore.instance.collection("Address").add({
                    "userId": widget.userId, // เชื่อมกับผู้ใช้
                    "address_text": addressController.text.trim(),
                    "latitude": selectedPoint!.latitude,
                    "longitude": selectedPoint!.longitude,
                    "createdAt": FieldValue.serverTimestamp(),
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('บันทึกที่อยู่เรียบร้อยแล้ว')),
                  );

                  Navigator.pop(context); // กลับไปหน้า profile
                } catch (e) {
                  print("Error saving address: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('เกิดข้อผิดพลาดในการบันทึกที่อยู่'),
                    ),
                  );
                }
              },
              child: const Text("ยืนยันที่อยู่"),
            ),
          ),
        ],
      ),
    );
  }
}
