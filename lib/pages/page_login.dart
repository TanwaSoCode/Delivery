import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery/pages/Rider_Profile.dart';
import 'package:delivery/pages/User_Proflie.dart';
import 'package:delivery/pages/select_Screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? selectedRole;
  final List<String> roles = ["ผู้ใช้ทั่วไป", "ไรเดอร์"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C3B66),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          margin: const EdgeInsets.symmetric(horizontal: 25),
          decoration: BoxDecoration(
            color: const Color(0xFF4A90E2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "เข้าสู่ระบบ",
                style: TextStyle(
                  color: Colors.yellow,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),

              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: "เบอร์โทรศัพท์",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                items: roles.map((role) {
                  return DropdownMenuItem(value: role, child: Text(role));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRole = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "เลือกบทบาท",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "รหัสผ่าน",
                  suffixIcon: const Icon(Icons.lock, color: Colors.black54),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),

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
                  onPressed: () async {
                    await loginUser(); // เรียก method แยก
                  },

                  child: const Text(
                    "เข้าสู่ระบบ",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "ยังไม่มีบัญชีผู้ใช้? ",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SelectScreen(phone: ''),
                        ),
                      );
                    },
                    child: const Text(
                      "สมัครสมาชิก",
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
    );
  }

  Future<void> loginUser() async {
    if (selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณาเลือกบทบาทก่อนเข้าสู่ระบบ")),
      );
      return;
    }

    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณากรอกเบอร์โทรและรหัสผ่าน")),
      );
      return;
    }

    String collection = selectedRole == "ผู้ใช้ทั่วไป" ? "User" : "Rider";

    try {
      var snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .where("phone", isEqualTo: phone)
          .get();

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("ไม่พบผู้ใช้")));
        return;
      }

      var userDoc = snapshot.docs.first; // <-- เพิ่มตรงนี้
      var userData = userDoc.data();
      var userId = userDoc.id; // <-- นี่คือ id ที่ไม่ซ้ำ

      if (userData["password"] == password) {
        if (selectedRole == "ผู้ใช้ทั่วไป") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UserProflie(userId: userId), // ส่ง id
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RiderProfile(userId: userId), // ส่ง id
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("รหัสผ่านไม่ถูกต้อง")));
      }
    } catch (e) {
      print("Login error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("เกิดข้อผิดพลาด กรุณาลองใหม่")),
      );
    }
  }
}
