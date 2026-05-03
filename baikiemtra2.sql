CREATE DATABASE [QuanLyThuVien_K235480106105];
GO
USE [QuanLyThuVien_K235480106105];
GO
CREATE TABLE [TheLoai] (
    [MaTheLoai] [int] IDENTITY(1,1) NOT NULL,
    [TenTheLoai] [nvarchar](100) NOT NULL,
    CONSTRAINT [PK_TheLoai] PRIMARY KEY ([MaTheLoai])
);
CREATE TABLE [Sach] (
    [MaSach] [nvarchar](20) NOT NULL,
    [TenSach] [nvarchar](200) NOT NULL,
    [MaTheLoai] [int] NOT NULL,
    [GiaTien] [money] NULL,
    [SoLuong] [int] DEFAULT 0,
    [NgayNhapKho] [date] DEFAULT GETDATE(),
    CONSTRAINT [PK_Sach] PRIMARY KEY ([MaSach]),
    CONSTRAINT [FK_Sach_TheLoai] FOREIGN KEY ([MaTheLoai]) REFERENCES [TheLoai]([MaTheLoai]),
    CONSTRAINT [CK_GiaTien] CHECK ([GiaTien] >= 0),
    CONSTRAINT [CK_SoLuong] CHECK ([SoLuong] BETWEEN 0 AND 1000)
);
CREATE TABLE [DocGia] (
    [MaDocGia] [nvarchar](20) NOT NULL,
    [HoTenDocGia] [nvarchar](100) NOT NULL,
    [NgaySinh] [date] NULL,
    [SoDienThoai] [varchar](15) NULL,
    [Email] [varchar](50) UNIQUE,
    [TienKyQuy] [money] DEFAULT 0,
    CONSTRAINT [PK_DocGia] PRIMARY KEY ([MaDocGia]),
    CONSTRAINT [CK_TienKyQuy] CHECK ([TienKyQuy] >= 0)
);
INSERT INTO [TheLoai] ([TenTheLoai])
VALUES 
(N'Văn học trong nước'),
(N'Kinh tế - Kỹ năng'),
(N'Công nghệ thông tin'),
(N'Ngoại ngữ');
GO
INSERT INTO [Sach] ([MaSach], [TenSach], [MaTheLoai], [GiaTien], [SoLuong], [NgayNhapKho])
VALUES 
(N'S001', N'Cho tôi xin một vé đi tuổi thơ', 1, 85000, 50, '2024-01-15'),
(N'S002', N'Đắc nhân tâm', 2, 120000, 30, '2024-02-10'),
(N'S003', N'Giáo trình SQL Server', 3, 150000, 20, '2024-03-05'),
(N'S004', N'English Grammar in Use', 4, 250000, 15, '2024-04-12');
GO
INSERT INTO [DocGia] ([MaDocGia], [HoTenDocGia], [NgaySinh], [SoDienThoai], [Email], [TienKyQuy])
VALUES 
(N'DG001', N'Nguyễn Văn A', '2002-05-20', '0912345678', 'vana@gmail.com', 100000),
(N'DG002', N'Trần Thị B', '2001-11-12', '0988776655', 'thib@gmail.com', 50000),
(N'DG003', N'Lê Hoàng C', '2003-02-28', '0905112233', 'hoangc@gmail.com', 200000);
GO

SELECT 
    [TenSach],
    FORMAT([GiaTien], 'N0') + ' VNĐ' AS [GiaNiemYet], -- Định dạng VNĐ
    DATEDIFF(day, [NgayNhapKho], GETDATE()) AS [SoNgayTrongKho] -- Tính thâm niên sách
FROM [Sach];

CREATE FUNCTION [fn_TinhGiaTriTonKho](@MaSach nvarchar(20))
RETURNS money
AS
BEGIN
    DECLARE @TongGiaTri money;
    SELECT @TongGiaTri = [GiaTien] * [SoLuong] 
    FROM [Sach] 
    WHERE [MaSach] = @MaSach;
    
    RETURN ISNULL(@TongGiaTri, 0);
END;
GO

SELECT [TenSach], [dbo].[fn_TinhGiaTriTonKho]([MaSach]) AS [GiaTriVatTu]
FROM [Sach];


CREATE FUNCTION [fn_LaySachTheoTheLoai](@TenTL nvarchar(100))
RETURNS TABLE
AS
RETURN (
    SELECT S.[MaSach], S.[TenSach], S.[GiaTien]
    FROM [Sach] S
    JOIN [TheLoai] T ON S.[MaTheLoai] = T.[MaTheLoai]
    WHERE T.[TenTheLoai] LIKE '%' + @TenTL + '%'
);
GO
SELECT * FROM [dbo].[fn_LaySachTheoTheLoai](N'Kinh tế');



CREATE FUNCTION [fn_PhanLoaiHangDocGia]()
RETURNS @BangXepHang TABLE (
    [MaDG] nvarchar(20),
    [TenDG] nvarchar(100),
    [TienKyQuy] money,
    [HangThanhVien] nvarchar(20)
)
AS
BEGIN
    INSERT INTO @BangXepHang
    SELECT [MaDocGia], [HoTenDocGia], [TienKyQuy],
        CASE 
            WHEN [TienKyQuy] < 50000 THEN N'Bronze'
            WHEN [TienKyQuy] BETWEEN 50000 AND 150000 THEN N'Silver'
            ELSE N'Gold'
        END
    FROM [DocGia];
    
    RETURN;
END;
GO

SELECT * FROM [dbo].[fn_PhanLoaiHangDocGia]() WHERE [HangThanhVien] = N'Gold';

CREATE PROCEDURE [sp_NhapSachMoi]
    @MaS nvarchar(20),
    @TenS nvarchar(200),
    @MaTL int,
    @Gia money,
    @SL int
AS
BEGIN
    IF @Gia <= 0
    BEGIN
        PRINT N'Lỗi: Giá tiền phải lớn hơn 0!';
    END
    ELSE
    BEGIN
        INSERT INTO [Sach] ([MaSach], [TenSach], [MaTheLoai], [GiaTien], [SoLuong], [NgayNhapKho])
        VALUES (@MaS, @TenS, @MaTL, @Gia, @SL, GETDATE());
        PRINT N'Thêm sách thành công.';
    END
END;
GO

EXEC [sp_NhapSachMoi] 'S005', N'Lập trình Python', 3, 20000, 10;



CREATE PROCEDURE [sp_TongSoLuongSach]
    @TongSL int OUTPUT
AS
BEGIN
    SELECT @TongSL = SUM([SoLuong]) FROM [Sach];
END;
GO


DECLARE @Result int;
EXEC [sp_TongSoLuongSach] @TongSL = @Result OUTPUT;
PRINT N'Tổng số lượng sách trong kho là: ' + CAST(@Result AS nvarchar(10));



CREATE PROCEDURE [sp_BaoCaoSachChiTiet]
AS
BEGIN
    SELECT 
        S.[MaSach], 
        S.[TenSach], 
        T.[TenTheLoai], 
        FORMAT(S.[GiaTien], 'N0') + ' VNĐ' AS [DonGia]
    FROM [Sach] S
    INNER JOIN [TheLoai] T ON S.[MaTheLoai] = T.[MaTheLoai]
    ORDER BY T.[TenTheLoai] ASC;
END;
GO

EXEC [sp_BaoCaoSachChiTiet];




CREATE TABLE [NhatKyNhapKho] (
    [MaNhatKy] [int] IDENTITY(1,1) PRIMARY KEY,
    [MaSach] [nvarchar](20),
    [SoLuongMoi] [int],
    [NgayGhi] [datetime] DEFAULT GETDATE()
);
GO


CREATE TRIGGER [trg_SauKhiNhapSach]
ON [Sach]
AFTER INSERT
AS
BEGIN
    INSERT INTO [NhatKyNhapKho] ([MaSach], [SoLuongMoi])
    SELECT [MaSach], [SoLuong] FROM inserted;
END;
GO


INSERT INTO [Sach] ([MaSach], [TenSach], [MaTheLoai], [GiaTien], [SoLuong], [NgayNhapKho])
VALUES (N'S999', N'Sách Test Trigger', 1, 50000, 10, GETDATE());

SELECT * FROM [NhatKyNhapKho];

SET STATISTICS TIME ON;
-- Khai báo các biến để chứa dữ liệu từng dòng
DECLARE @TenS nvarchar(200);
DECLARE @Sl int;
DECLARE @NgayNhap datetime;
DECLARE @ThanhNien int;

-- 1. Khai báo Cursor
DECLARE cur_XuLySach CURSOR FOR 
SELECT [TenSach], [SoLuong], [NgayNhapKho] FROM [Sach];

-- 2. Mở Cursor
OPEN cur_XuLySach;

-- 3. Lấy dòng dữ liệu đầu tiên
FETCH NEXT FROM cur_XuLySach INTO @TenS, @Sl, @NgayNhap;

-- 4. Vòng lặp duyệt qua từng dòng
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @ThanhNien = DATEDIFF(day, @NgayNhap, GETDATE());

    IF (@ThanhNien > 800 AND @Sl > 20)
        PRINT N'Sách [' + @TenS + N'] - Tình trạng: QUÁ CŨ, CẦN XẢ KHO!';
    ELSE IF (@Sl < 5)
        PRINT N'Sách [' + @TenS + N'] - Tình trạng: SẮP HẾT HÀNG!';
    ELSE
        PRINT N'Sách [' + @TenS + N'] - Tình trạng: Bình thường.';

    -- Lấy dòng tiếp theo
    FETCH NEXT FROM cur_XuLySach INTO @TenS, @Sl, @NgayNhap;
END;

-- 5. Đóng và giải phóng bộ nhớ
CLOSE cur_XuLySach;
DEALLOCATE cur_XuLySach;



SET STATISTICS TIME ON;

SELECT [TenSach],
    CASE 
        WHEN DATEDIFF(day, [NgayNhapKho], GETDATE()) > 800 AND [SoLuong] > 20 THEN N'QUÁ CŨ, CẦN XẢ KHO!'
        WHEN [SoLuong] < 5 THEN N'SẮP HẾT HÀNG!'
        ELSE N'Bình thường.'
    END AS [TrangThai]
FROM [Sach];

SET STATISTICS TIME OFF;