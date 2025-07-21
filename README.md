# 📱 FitTracker – Ứng dụng theo dõi sức khỏe thông minh 💪

## 🧭 Giới thiệu

**FitTracker** là một ứng dụng sức khỏe di động chạy trên nền tảng **Android**, giúp người dùng quản lý và cải thiện sức khỏe một cách khoa học và hiệu quả. Ứng dụng hỗ trợ:

- Tính chỉ số **BMI**, **TDEE**.
- Gợi ý lộ trình phù hợp: **Tăng cân**, **Giảm cân**, **Giữ cân**.
- Theo dõi lượng **calo**, **dinh dưỡng**, **nước uống** mỗi ngày.
- Ghi log các bữa ăn: **Breakfast**, **Lunch**, **Dinner**.
- Hiển thị biểu đồ tiến độ **cân nặng** và **dinh dưỡng**.
- Nhắc nhở thông minh: log meal, uống nước, cập nhật cân nặng định kỳ.

---

## 🧱 Cấu trúc thư mục

```bash
.
├── models       # Định nghĩa các model dữ liệu: User, Meal, Log, Goal, ...
├── screens      # Các màn hình giao diện người dùng: Journal, Profile, Setup, ...
├── services     # Các service logic như lưu trữ, xử lý dữ liệu, tính toán chỉ số
├── utils        # Hàm tiện ích, hằng số dùng chung
├── widgets      # Các widget dùng chung: MealItem, WaterProgress, MacroBar, ...
└── main.dart    # Điểm khởi đầu của ứng dụng
