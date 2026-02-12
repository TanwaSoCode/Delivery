import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery/pages/%E0%B9%8AUser_function/select_address_page.dart';
import 'package:flutter/material.dart';

class SearchCustomerPage extends StatefulWidget {
  const SearchCustomerPage({super.key});

  @override
  State<SearchCustomerPage> createState() => _SearchCustomerPageState();
}

class _SearchCustomerPageState extends State<SearchCustomerPage> {
  final TextEditingController phoneController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  List<Map<String, dynamic>> allUsers = [];

  @override
  void initState() {
    super.initState();
    _loadAllUsers();
  }

  Future<void> _loadAllUsers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('User')
          .get();
      final users = snapshot.docs.map((doc) {
        final data = doc.data();
        List<Map<String, dynamic>> addresses = [];
        if (data['addresses'] != null) {
          addresses = List<Map<String, dynamic>>.from(data['addresses']);
        }
        return {
          'userId': doc.id,
          'name': '${data['firstName']} ${data['lastName']}',
          'phone': data['phone'],
          'addresses': addresses,
        };
      }).toList();

      setState(() {
        allUsers = users;
      });
    } catch (e) {
      print("Error loading users: $e");
    }
  }

  Future<void> _search() async {
    final input = phoneController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณากรอกเบอร์โทรศัพท์')));
      return;
    }

    try {
      // 1) พยายามทำ prefix search บนเซิร์ฟเวอร์ (เร็วกว่า) - จะหาเบอร์ที่เริ่มต้นด้วย input
      final prefixSnapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('phone', isGreaterThanOrEqualTo: input)
          .where('phone', isLessThanOrEqualTo: input + '\uf8ff')
          .get();

      List<Map<String, dynamic>> results = prefixSnapshot.docs.map((doc) {
        final data = doc.data();
        List<Map<String, dynamic>> addresses = [];
        if (data['addresses'] != null) {
          addresses = List<Map<String, dynamic>>.from(data['addresses']);
        }
        return {
          'userId': doc.id,
          'name': '${data['firstName']} ${data['lastName']}',
          'phone': data['phone'],
          'addresses': addresses,
        };
      }).toList();

      // 2) ถ้าต้องการ behaviour แบบ %input% (contains) และ prefix ไม่พอ
      //    ให้กรองฝั่งไคลเอนต์ (Firestore ไม่มี substring contains query)
      //    -- ถ้าฐานข้อมูลใหญ่ อาจช้าหรือเปลือง อ่านข้อควรระวังด้านล่าง
      if (results.isEmpty) {
        final allSnap = await FirebaseFirestore.instance
            .collection('User')
            .get();
        final filtered = allSnap.docs
            .where((doc) {
              final phone = (doc.data()['phone'] ?? '').toString();
              return phone.contains(input);
            })
            .map((doc) {
              final data = doc.data();
              List<Map<String, dynamic>> addresses = [];
              if (data['addresses'] != null) {
                addresses = List<Map<String, dynamic>>.from(data['addresses']);
              }
              return {
                'userId': doc.id,
                'name': '${data['firstName']} ${data['lastName']}',
                'phone': data['phone'],
                'addresses': addresses,
              };
            })
            .toList();

        results = filtered;
      }

      if (results.isEmpty) {
        setState(() {
          searchResults = [];
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ไม่พบผู้ใช้เบอร์นี้')));
        return;
      }

      setState(() {
        searchResults = results;
      });
    } catch (e) {
      print("Error searching user: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('เกิดข้อผิดพลาดในการค้นหา')));
    }
  }

  Widget _buildUserCard(Map<String, dynamic> receiver) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4E7CBF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🔹 รูปโปรไฟล์
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            backgroundImage:
                (receiver['profileUrl'] != null &&
                    receiver['profileUrl'].toString().isNotEmpty)
                ? NetworkImage(receiver['profileUrl'])
                : const AssetImage('assets/images/default_profile.png')
                      as ImageProvider,
          ),
          const SizedBox(width: 16),

          // 🔹 ข้อมูลผู้ใช้
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${receiver['name'] ?? ''}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'โทร: ${receiver['phone'] ?? ''}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () async {
                      final selectedAddress = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SelectAddressPage(userId: receiver['userId']),
                        ),
                      );

                      if (selectedAddress != null) {
                        Navigator.pop(context, {
                          'name': receiver['name'],
                          'phone': receiver['phone'],
                          'address': selectedAddress['address'],
                          'lat': selectedAddress['lat'],
                          'lng': selectedAddress['lng'],
                          'userId': receiver['userId'],
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                    ),
                    child: const Text(
                      'เลือกที่อยู่ผู้รับ',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ค้นหาข้อมูลผู้รับ',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'เบอร์โทรศัพท์',
                labelStyle: const TextStyle(color: Colors.white),
                filled: true,
                fillColor: const Color(0xFF4E7CBF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.phone, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _search,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 30,
                ),
              ),
              child: const Text(
                'ค้นหา',
                style: TextStyle(
                  color: Color(0xFF0C3B66),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: (searchResults.isNotEmpty)
                  ? ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) =>
                          _buildUserCard(searchResults[index]),
                    )
                  : (allUsers.isNotEmpty)
                  ? ListView.builder(
                      itemCount: allUsers.length,
                      itemBuilder: (context, index) =>
                          _buildUserCard(allUsers[index]),
                    )
                  : const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
