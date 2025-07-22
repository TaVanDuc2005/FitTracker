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
lib/
├── models/
│   ├── food.dart              # Mô tả dữ liệu một món ăn/thức uống (id, tên, calo, v.v).
│   ├── meal.dart              # Mô tả dữ liệu một bữa ăn gồm danh sách các món ăn.
│   └── user.dart              # (Tuỳ chọn) Dữ liệu người dùng như tên, tuổi, chiều cao, cân nặng.

├── screens/
│   ├── initial_screen/
│   │   ├── page1.dart -> page8.dart   # Các bước nhập thông tin người dùng ban đầu.
│   │   └── page9.dart                 # Màn hình tải và xử lý dữ liệu sau khi nhập.
│   └── active_screen/
│       ├── journal/
│       │   ├── food_search_screen.dart     # Giao diện tìm món ăn (giống Shopee Food).
│       │   ├── meal_summary_screen.dart    # Xác nhận món ăn đã chọn.
│       │   └── journal_screen.dart         # Nhật ký ăn uống trong ngày.
│       └── profile/
│           └── profile.dart                # Màn hình hồ sơ người dùng.

├── services/
│   ├── food_service.dart       # Xử lý danh sách món ăn từ local hoặc API.
│   ├── meal_service.dart       # Quản lý CRUD các bữa ăn và món ăn liên quan.
│   └── storage_service.dart    # (Tuỳ chọn) Lưu/đọc dữ liệu người dùng từ local hoặc Firebase.

├── utils/
│   ├── constants.dart          # Các giá trị cố định như màu, giới hạn calo, key v.v.
│   └── helpers.dart            # Hàm hỗ trợ: tính calo, định dạng, tính TDEE, BMI,...

├── widgets/
│   ├── food_item.dart          # Hiển thị một món ăn trong danh sách.
│   └── meal_item.dart          # Hiển thị thông tin bữa ăn: tổng calo, món đã chọn.

└── main.dart                   # Điểm khởi đầu của ứng dụng: cấu hình theme, route, home screen.

