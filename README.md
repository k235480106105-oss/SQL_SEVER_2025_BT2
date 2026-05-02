# Bài tập môn Hệ quản trị cơ sở dữ liệu - TE560, Lớp: K59KMT
## YÊU CẦU BÀI TẬP 
1. Thiết kế và Khởi tạo Cấu trúc Dữ liệu

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/9132c81c-dd91-43e4-a149-31439af1e7ca" />
Tạo Database mới với tên QuanLyThuVien_K235480106105.

- Tạo 3 bảng có quan hệ với nhau.
- Bảng 1: [TheLoai] - Danh mục thể loại
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/53112b62-4279-43a6-97f4-f30d60875950" />

- PK (Primary Key): [MaTheLoai] là khóa chính, dùng để định danh duy nhất mỗi thể loại sách.

- Bảng 2: [Sach] - Thông tin sách
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/fd07c7bf-1985-40eb-b0fc-21aefcce570b" />

- PK: [MaSach] định danh duy nhất cho mỗi đầu sách.
- FK: [MaTheLoai] Tham chiếu đến bảng [TheLoai].
- CK: [GiaTien] >= 0: Đảm bảo giá tiền không bị nhập sai thành số âm.

- Bảng 3: [DocGia] - Thông tin người mượn

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/3a8e4e65-cbd6-4de0-a629-fc8ef36fff7b" />

- PK: [MaDocGia] khóa chính quản lý độc giả.
- Unique: [Email] đảm bảo mỗi độc giả chỉ có một tài khoản duy nhất dựa trên email.
  <img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/aa57ea03-4d6b-48cf-b7c0-a377fef709a7" />
Khởi tạo 3 bảng thành công
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/3ebb3e83-a442-4b3b-9a00-3292172c1029" />


- INSERT dữ liệu cho 3 bảng










