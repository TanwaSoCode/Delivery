import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SelectAddressPage extends StatefulWidget {
  final String userId; // userId ที่ส่งมาจาก SearchCustomerPage

  const SelectAddressPage({super.key, required this.userId});

  @override
  State<SelectAddressPage> createState() => _SelectAddressPageState();
}

class _SelectAddressPageState extends State<SelectAddressPage> {
  List<Map<String, dynamic>> addresses = [];
  Map<String, dynamic>? selectedAddress;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAddresses();
  }

  Future<void> fetchAddresses() async {
    try {
      // ดึงข้อมูล address จาก collection 'Address' ตาม userId
      final snapshot = await FirebaseFirestore.instance
          .collection('Address')
          .where('userId', isEqualTo: widget.userId)
          .get();

      final fetchedAddresses = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['address_text'] ?? '', // เปลี่ยนจาก addressName
          'lat': data['latitude'].toString(),
          'lng': data['longitude'].toString(),
        };
      }).toList();

      setState(() {
        addresses = fetchedAddresses;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching addresses: $e");
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เกิดข้อผิดพลาดในการดึงที่อยู่')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0C3B66),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0C3B66),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C3B66),
        title: const Text(
          "เลือกที่อยู่ผู้รับ",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "ข้อมูลที่อยู่ (${addresses.length} รายการ)",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  final address = addresses[index];
                  final isSelected = selectedAddress == address;

                  return GestureDetector(
                    onTap: () => setState(() => selectedAddress = address),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.yellow[600]
                            : const Color(0xFF4E7CBF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  address['name'],
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "พิกัด: ${address['lat']}, ${address['lng']}",
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.black87
                                  : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: selectedAddress != null
                  ? () {
                      Navigator.pop(context, {
                        'address': selectedAddress!['name'], // ส่งเฉพาะที่อยู่
                      });
                    }
                  : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: const Text(
                "ยืนยัน",
                style: TextStyle(color: Color(0xFF0C3B66)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
///
