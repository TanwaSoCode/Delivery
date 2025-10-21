import 'dart:developer' show log;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery/pages/gps.dart';
import 'package:delivery/pages/select_Screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:delivery/pages/page_login.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';

class RegisterScreen extends StatefulWidget {
  final String role;
  const RegisterScreen({super.key, required this.role});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  LatLng? selectedLocation;
  File? profileImage;
  File? vehicleImage;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C3B66),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(25),
            margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.role == "user"
                      ? "สมัครสมาชิก (ผู้ใช้ทั่วไป)"
                      : "สมัครสมาชิก (ไรเดอร์)",
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "ข้อมูลส่วนตัว",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration("เบอร์โทร"),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: firstNameController,
                        decoration: _inputDecoration("ชื่อ"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: lastNameController,
                        decoration: _inputDecoration("นามสกุล"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: _inputDecoration("รหัสผ่าน"),
                ),
                const SizedBox(height: 15),

                // ปุ่มเลือกโปรไฟล์
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C3B66),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    icon: const Icon(Icons.image, color: Colors.white),
                    label: const Text(
                      "เลือกโปรไฟล์",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () => _showImagePickerDialog(true),
                  ),
                ),
                if (profileImage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Image.file(profileImage!, height: 100),
                  ),

                const SizedBox(height: 25),

                if (widget.role == "user") ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "ข้อมูลที่อยู่",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C3B66),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      icon: const Icon(Icons.location_on, color: Colors.white),
                      label: const Text(
                        "ปักหมุดที่อยู่บนแผนที่",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GPSandMapPage(),
                          ),
                        );

                        if (result != null) {
                          log("ค่าพิกัดที่ส่งกลับมา: $result");
                          setState(() {
                            selectedLocation = result;
                          });
                        } else {
                          log("ยังไม่ได้เลือกตำแหน่ง");
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 10),
                  TextField(
                    controller: addressController,
                    decoration: _inputDecoration("ที่อยู่"),
                  ),
                  const SizedBox(height: 20),
                ],

                if (widget.role == "rider") ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "ข้อมูลเพิ่มเติมสำหรับไรเดอร์",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // รูปยานพาหนะ
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C3B66),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      icon: const Icon(Icons.pedal_bike, color: Colors.white),
                      label: const Text(
                        "รูปยานพาหนะ",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () => _showImagePickerDialog(false),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (vehicleImage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Image.file(vehicleImage!, height: 100),
                    ),

                  TextField(
                    controller: licenseController,
                    decoration: _inputDecoration("ทะเบียนรถ"),
                  ),
                  const SizedBox(height: 12),
                ],

                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C3B66),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: isLoading
                        ? null
                        : () async {
                            setState(() => isLoading = true);
                            bool success = await Register(widget.role);
                            setState(() => isLoading = false);

                            if (success && mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "สมัครสมาชิกไม่สำเร็จ กรุณาลองอีกครั้ง",
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "สมัครสมาชิก",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "มีบัญชีผู้ใช้อยู่แล้ว? ",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "เข้าสู่ระบบ",
                        style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  Future<void> _showImagePickerDialog(bool isProfile) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("เลือกรูปภาพ"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("จาก Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery, isProfile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("ถ่ายรูป"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, isProfile);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, bool isProfile) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      File? localFile = await _saveFileLocally(pickedFile);
      if (localFile != null) {
        setState(() {
          if (isProfile) {
            profileImage = localFile;
          } else {
            vehicleImage = localFile;
          }
        });
        print("Picked file saved locally: ${localFile.path}");
      }
    }
  }

  Future<File?> _saveFileLocally(XFile xfile) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName =
          DateTime.now().millisecondsSinceEpoch.toString() + "_" + xfile.name;
      final File localFile = File('${appDir.path}/$fileName');
      await xfile.saveTo(localFile.path);
      return localFile;
    } catch (e) {
      print("Error saving file locally: $e");
      return null;
    }
  }

  Future<bool> Register(String role) async {
    var db = FirebaseFirestore.instance;
    String? profileUrl;
    String? vehicleUrl;
    DocumentReference? userRef;

    // 1. Upload profile
    if (profileImage != null) {
      try {
        final storageRef = FirebaseStorage.instance.ref().child(
          "${role}_${phoneController.text.trim()}_profile.jpg",
        );
        final snapshot = await storageRef.putFile(profileImage!);
        if (snapshot.state == TaskState.success) {
          profileUrl = await storageRef.getDownloadURL();
          print("Profile uploaded: $profileUrl");
        } else {
          print("Profile upload not successful: ${snapshot.state}");
        }
      } catch (e) {
        print("Error uploading profile: $e");
      }
    }

    // 2. Upload vehicle (rider)
    if (role == "rider" && vehicleImage != null) {
      try {
        final storageRef = FirebaseStorage.instance.ref().child(
          "${role}_${phoneController.text.trim()}_vehicle.jpg",
        );
        final snapshot = await storageRef.putFile(vehicleImage!);
        if (snapshot.state == TaskState.success) {
          vehicleUrl = await storageRef.getDownloadURL();
          print("Vehicle uploaded: $vehicleUrl");
        } else {
          print("Vehicle upload not successful: ${snapshot.state}");
        }
      } catch (e) {
        print("Error uploading vehicle: $e");
      }
    }

    // 3. Create user data
    Map<String, dynamic> userData = {
      "phone": phoneController.text.trim(),
      "firstName": firstNameController.text.trim(),
      "lastName": lastNameController.text.trim(),
      "password": passwordController.text.trim(),
      "profileUrl": profileUrl ?? "",
    };

    // 4. Add user to Firestore
    try {
      if (role == "user") {
        userRef = await db.collection("User").add(userData);
        print("User document created: ${userRef.id}");
      } else if (role == "rider") {
        userData["license"] = licenseController.text.trim();
        userData["vehicleUrl"] = vehicleUrl ?? "";
        userRef = await db.collection("Rider").add(userData);
        print("Rider document created: ${userRef.id}");
      }
    } catch (e) {
      print("Error adding user/rider: $e");
      return false;
    }

    // 5. Add address (user only)
    if (role == "user" && selectedLocation != null) {
      try {
        Map<String, dynamic> addressData = {
          "userId": userRef!.id,
          "latitude": selectedLocation!.latitude,
          "longitude": selectedLocation!.longitude,
          "address_text": addressController.text.trim(),
        };
        await db.collection("Address").add(addressData);
        print("Address added successfully!");
      } catch (e) {
        print("Error adding address: $e");
        return false;
      }
    }

    print("Register process completed successfully!");
    return true;
  }
}
