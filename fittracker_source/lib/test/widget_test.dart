import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fittracker_source/models/food.dart';

class FoodTestScreen extends StatefulWidget {
  const FoodTestScreen({super.key});

  @override
  State<FoodTestScreen> createState() => _FoodTestScreenState();
}

class _FoodTestScreenState extends State<FoodTestScreen> {
  List<Food> _foods = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchFoods();
  }

  Future<void> _fetchFoods() async {
    try {
      print("Đang truy vấn Firestore...");
      final snapshot = await FirebaseFirestore.instance.collection('list_food').get();
      print("Số lượng món ăn lấy được: ${snapshot.docs.length}");

      // 🔍 Kiểm tra từng document để phát hiện lỗi
      for (var doc in snapshot.docs) {
        final data = doc.data();
        try {
          final food = Food.fromMap(data);
          print("✅ Loaded: ${food.name}");
        } catch (e) {
          print("❌ Lỗi ở document: ${data['name'] ?? 'Không có tên'} — $e");
          print("Dữ liệu lỗi: $data");
        }
      }

      // Nếu muốn tiếp tục hiển thị các món hợp lệ:
      final foods = snapshot.docs.map((doc) {
        try {
          return Food.fromMap(doc.data());
        } catch (_) {
          return null;
        }
      }).whereType<Food>().toList();

      setState(() {
        _foods = foods;
        _isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi truy vấn Firestore: $e");
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kiểm tra dữ liệu món ăn')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Lỗi: $_error'))
              : _foods.isEmpty
                  ? const Center(child: Text('Không có món ăn nào'))
                  : ListView.builder(
                      itemCount: _foods.length,
                      itemBuilder: (context, index) {
                        final food = _foods[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: Image.network(
                              food.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.fastfood),
                            ),
                            title: Text(food.name),
                            subtitle: Text('${food.calories} Cal - ${food.description}'),
                          ),
                        );
                      },
                    ),
    );
  }
}
