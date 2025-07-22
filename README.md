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
├── models       # Định nghĩa các model dữ liệu dùng trong toàn bộ ứng dụng.
│   ├── food.dart        # Mô tả dữ liệu một món ăn/thức uống (id, tên, calo, v.v).
│   ├── meal.dart        # Mô tả dữ liệu một bữa ăn gồm danh sách các món ăn.
│   └── user.dart        # (Tuỳ chọn) Dữ liệu người dùng như tên, chiều cao, cân nặng.
│
├── screens      # Các màn hình giao diện chính mà người dùng sẽ tương tác.
│   ├── initial_screen/
|   |   ├──page1 -> page8 # thong tin nguoi dung
|   |   └──page9 #load thong tin
|   |             
│   └── active_screen/
|           journal/
|               ├── food_search_screen.dart      # Giao diện tìm kiếm món ăn (giống Shopee Food).
|               ├── meal_summary_screen.dart     # Giao diện xác nhận các món đã chọn cho bữa ăn.
 |              └── journal_screen.dart                 # Màn hình chính hiển thị các bữa ăn trong ngày.
            profile/
                    proffile.dart
├── services     # Xử lý logic nghiệp vụ, quản lý dữ liệu và trạng thái.
│   ├── food_service.dart       # Quản lý danh sách các món ăn có sẵn (từ local hoặc API).
│   ├── meal_service.dart       # Quản lý danh sách món ăn theo từng bữa (CRUD cho bữa ăn).
│   └── storage_service.dart    # (Tuỳ chọn) Lưu/đọc dữ liệu người dùng từ local/Firebase.
│
├── utils        # Chứa các hằng số, hàm tiện ích dùng chung toàn ứng dụng.
│   ├── constants.dart          # Các giá trị cố định như giới hạn calo, màu sắc, key, v.v.
│   └── helpers.dart            # Các hàm hỗ trợ xử lý dữ liệu (tính calo, định dạng, v.v).
│
├── widgets      # Các widget tùy chỉnh và tái sử dụng được giữa nhiều màn hình.
│   ├── food_item.dart          # Hiển thị một món ăn trong danh sách.
│   └── meal_item.dart          # Hiển thị một bữa ăn với tổng calo và món đã chọn.
│
└── main.dart    # Điểm khởi đầu của ứng dụng Flutter, cấu hình theme, route và home screen.

