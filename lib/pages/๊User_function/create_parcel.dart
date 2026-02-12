import 'dart:io';
import 'package:delivery/pages/%E0%B9%8AUser_function/search_customer_page.dart';
import 'package:delivery/pages/gps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';

class CreateParcelScreen extends StatefulWidget {
  final String senderId; // รับไอดีผู้ส่ง
  const CreateParcelScreen({super.key, required this.senderId});

  @override
  State<CreateParcelScreen> createState() => _CreateParcelScreenState();
}

class _CreateParcelScreenState extends State<CreateParcelScreen> {
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController receiverNameController = TextEditingController();
  final TextEditingController receiverPhoneController = TextEditingController();
  final TextEditingController receiveruserIdController =
      TextEditingController();
  final TextEditingController receiverAddressController =
      TextEditingController();

  File? productImage;
  final ImagePicker _picker = ImagePicker();

  // เพิ่มตัวแปรสำหรับเก็บพิกัดผู้รับ
  String? receiverLat;
  String? receiverLng;
  LatLng? pickupPoint;

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
          "จัดส่งสินค้า",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "ข้อมูลสินค้า",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                // ชื่อสินค้า
                const Text(
                  "ชื่อสินค้า",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: productNameController,
                  decoration: InputDecoration(
                    hintText: "กรอกชื่อสินค้า",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // ราคาสินค้า
                const Text(
                  "ราคาสินค้า",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "กรอกราคาสินค้า",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "ข้อมูลผู้รับสินค้า",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final selectedReceiver = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchCustomerPage(),
                        ),
                      );

                      if (selectedReceiver != null) {
                        setState(() {
                          receiverNameController.text =
                              selectedReceiver['name'] ?? '';
                          receiverPhoneController.text =
                              selectedReceiver['phone'] ?? '';
                          receiverAddressController.text =
                              selectedReceiver['address'] ?? '';
                          receiverLat =
                              selectedReceiver['lat']; // เก็บเป็นตัวแปร state
                          receiverLng =
                              selectedReceiver['lng']; // เก็บเป็นตัวแปร state
                          receiveruserIdController.text =
                              selectedReceiver['userId'] ?? '';
                        });
                      }
                    },
                    icon: const Icon(Icons.search, color: Colors.white),
                    label: const Text(
                      "ค้นหาข้อมูลผู้รับสินค้า",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C3B66),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // ชื่อผู้รับ
                const Text(
                  "ชื่อผู้รับสินค้า",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: receiverNameController,
                  decoration: InputDecoration(
                    hintText: "กรอกชื่อผู้รับสินค้า",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // เบอร์ผู้รับ
                const Text(
                  "เบอร์ผู้รับสินค้า",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: receiverPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: "กรอกเบอร์ผู้รับสินค้า",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // ที่อยู่ผู้รับ
                const Text(
                  "ที่อยู่ผู้รับสินค้า",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: receiverAddressController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: "กรอกที่อยู่ผู้รับสินค้า",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // แผนที่แสดงพิกัดผู้รับ (ถ้ามีพิกัด)
                if (receiverLat != null && receiverLng != null)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white),
                    ),
                    child: FlutterMap(
                      mapController: MapController(),
                      options: MapOptions(
                        initialCenter: LatLng(
                          double.parse(receiverLat!),
                          double.parse(receiverLng!),
                        ),
                        initialZoom: 15.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c'],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(
                                double.parse(receiverLat!),
                                double.parse(receiverLng!),
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
                      ],
                    ),
                  ),
                const SizedBox(height: 20),

                const Text(
                  "รูปภาพสินค้า",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showImagePickerDialog,
                    icon: const Icon(Icons.image, color: Colors.white),
                    label: const Text(
                      "เลือกรูปสินค้า",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C3B66),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
                if (productImage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Image.file(productImage!, height: 100),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final selected = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const GPSandMapPage(), // ใช้หน้าเลือกตำแหน่ง
                        ),
                      );

                      if (selected != null && selected is LatLng) {
                        setState(() {
                          pickupPoint = selected;
                        });
                      }
                    },
                    icon: const Icon(Icons.map, color: Colors.white),
                    label: Text(
                      pickupPoint != null
                          ? "ตำแหน่งรับ: (${pickupPoint!.latitude.toStringAsFixed(6)}, ${pickupPoint!.longitude.toStringAsFixed(6)})"
                          : "เลือกตำแหน่งรับสินค้า",
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C3B66),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _confirmOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),

                    child: const Text(
                      "ยืนยันการจัดส่งสินค้า",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("เลือกรูปภาพสินค้า"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("จาก Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("ถ่ายรูป"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      File? localFile = await _saveFileLocally(pickedFile);
      if (localFile != null) {
        setState(() {
          productImage = localFile; // ใช้ไฟล์ local
        });
        print("Picked file saved locally: ${localFile.path}");
      } else {
        print("❌ Failed to save local file");
      }
    }
  }

  Future<File?> _saveFileLocally(XFile xfile) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final path =
          "${dir.path}/parcel_${DateTime.now().millisecondsSinceEpoch}_${xfile.name}";
      final file = File(path);
      await xfile.saveTo(file.path);
      return file;
    } catch (e) {
      print("❌ Error saving local file: $e");
      return null;
    }
  }

  Future<void> _confirmOrder() async {
    if (productImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("กรุณาเลือกรูปสินค้าก่อน")));
      return;
    }

    try {
      // 1️⃣ บันทึกไฟล์ลง local ก่อน
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName =
          "parcel_${DateTime.now().millisecondsSinceEpoch}_${productNameController.text}.jpg";
      final File localFile = File('${appDir.path}/$fileName');
      await productImage!.copy(localFile.path);
      print("✅ File saved locally: ${localFile.path}");

      // 2️⃣ สร้าง Order ก่อน เพื่อให้ได้ orderId
      final orderRef = await FirebaseFirestore.instance
          .collection("Order")
          .add({
            "userId": receiveruserIdController.text.trim(),
            "senderId": widget.senderId,
            "receiverName": receiverNameController.text.trim(),
            "receiverAddress": receiverAddressController.text.trim(),
            "receiverLat": receiverLat,
            "receiverLng": receiverLng,
            "pickupLat": pickupPoint?.latitude.toString(),
            "pickupLng": pickupPoint?.longitude.toString(),
            "total_cost": double.tryParse(priceController.text.trim()) ?? 0,
            "status": "รอไรเดอร์รับออเดอร์",
            "imagePath": localFile.path,
            "createdAt": Timestamp.now(),
          });

      // 3️⃣ สร้าง Parcel โดยใส่ orderId ไปด้วย
      await FirebaseFirestore.instance.collection("Parcel").add({
        "name": productNameController.text.trim(),
        "price": double.tryParse(priceController.text.trim()) ?? 0,
        "createdAt": Timestamp.now(),
        "orderId": orderRef.id,
      });

      // ✅ แจ้งเตือนแล้วกลับหน้าก่อนหน้า
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ดำเนินการจัดส่งสินค้าเรียบร้อย!")),
        );
        Navigator.pop(context, true); // ส่ง true กลับไปถ้าหน้าก่อนต้อง refresh
      }
    } catch (e) {
      print("❌ ERROR: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
    }
  }
}
