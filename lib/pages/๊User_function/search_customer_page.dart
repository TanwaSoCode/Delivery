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

  Future<void> _search() async {
    final input = phoneController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณากรอกเบอร์โทรศัพท์')));
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('phone', isEqualTo: input)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          searchResults = [];
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ไม่พบผู้ใช้เบอร์นี้')));
        return;
      }

      // แปลงข้อมูลเอกสารให้เป็น Map
      final results = snapshot.docs.map((doc) {
        final data = doc.data();
        List<Map<String, dynamic>> addresses = [];
        if (data['addresses'] != null) {
          addresses = List<Map<String, dynamic>>.from(data['addresses']);
        }
        return {
          'userId': doc.id, // เพิ่ม userId ของ document
          'name': '${data['firstName']} ${data['lastName']}',
          'phone': data['phone'],
          'addresses': addresses,
        };
      }).toList();

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
            if (searchResults.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final receiver = searchResults[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4E7CBF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            receiver['name'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            receiver['phone'] ?? '',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () async {
                                final selected = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SelectAddressPage(
                                      userId:
                                          receiver['userId'], // ส่ง userId ไปด้วย
                                    ),
                                  ),
                                );

                                if (selected != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'เลือกที่อยู่: ${selected['name']}',
                                      ),
                                    ),
                                  );
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
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
