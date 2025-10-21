import 'package:delivery/pages/๊User_function/follow_one_order.dart';
import 'package:flutter/material.dart';

//ติดตามสถานะสินค้าที่ส่ง
class FollowAllOrderPage extends StatelessWidget {
  const FollowAllOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    //ข้อมูลออเดอร์ทั้งหมด
    final List<Map<String, dynamic>> orders = [
      {
        'id': '098765431',
        'status': 'รอไรเดอร์รับสินค้า',
        'price': '200',
        'product': 'ข้าวกล่อง',
        'address': 'ม.เทคโนโลยีราชมงคลธัญบุรี',
        'image': 'assets/images/rider1.png',
      },
      {
        'id': '123456789',
        'status': 'ไรเดอร์รับสินค้าแล้ว',
        'price': '80,000',
        'product': 'iPhone 17 Pro Max',
        'address': 'คณะวิทยาการสารสนเทศ ม.ใหม่ มหาวิทยาลัยมหาสารคาม',
        'image': 'assets/images/rider2.png',
      },
      {
        'id': '555555555',
        'status': 'ไรเดอร์อยู่ระหว่างนำส่งสินค้า',
        'price': '127',
        'product': 'กาแฟ 3 กล่อง',
        'address': 'หอพักพีรดา อ.เมือง จ.ขอนแก่น',
        'image': 'assets/images/rider3.png',
      },
    ];

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
          "ติดตามสถานะสินค้าที่ส่ง",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //แผนที่
            Container(
              margin: const EdgeInsets.all(16),
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.grey[300],
              ),
              child: const Center(
                child: Icon(Icons.map, color: Colors.grey, size: 80),
              ),
            ),

            //จำนวนออเดอร์ทั้งหมด
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
                    "ขณะนี้มีรายการส่งของทั้งหมด",
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

            //รายการออเดอร์ทั้งหมด
            for (var order in orders)
              OrderCard(
                status: order['status'],
                price: order['price'],
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        FollowOneOrderPage(orderData: orderData),
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
