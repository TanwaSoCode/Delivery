import 'package:delivery/pages/%E0%B9%8AUser_function/search_customer_page.dart';
import 'package:flutter/material.dart';
//สร้างรายการ
class CreateParcelScreen extends StatefulWidget {
  const CreateParcelScreen({super.key});

  @override
  State<CreateParcelScreen> createState() => _CreateParcelScreenState();
}

class _CreateParcelScreenState extends State<CreateParcelScreen> {
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController receiverNameController = TextEditingController();
  final TextEditingController receiverPhoneController = TextEditingController();
  final TextEditingController receiverAddressController =
      TextEditingController();

  // File? selectedImage;เลือกรูป

  /*
  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        selectedImage = File(pickedImage.path);
      });
    }
  }
  */
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

                TextField(
                  controller: productNameController,
                  decoration: InputDecoration(
                    hintText: "ชื่อสินค้า",
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

                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "ราคาสินค้า",
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchCustomerPage(),
                        ),
                      );
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

                TextField(
                  controller: receiverNameController,
                  decoration: InputDecoration(
                    hintText: "ชื่อผู้รับสินค้า",
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
                TextField(
                  controller: receiverPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: "เบอร์ผู้รับสินค้า",
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
                TextField(
                  controller: receiverAddressController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: "ที่อยู่ผู้รับสินค้า",
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
                  "รูปสินค้า",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                ElevatedButton.icon(
                  onPressed: () {},
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
                const SizedBox(height: 10),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    // ต้องเพิ่มฟังก์ชันจการเช็คด้วยว่าข้อมูลครบหรือไม่
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("ดำเนินการจัดส่งสินค้าเรียบร้อย!"),
                        ),
                      );
                    },
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
}
