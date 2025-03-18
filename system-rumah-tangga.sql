/* Create Database */
DROP DATABASE PerlengkapanRumahTangga;
CREATE DATABASE PerlengkapanRumahTangga;
USE PerlengkapanRumahTangga;

/* Making Tables */
CREATE TABLE Pembeli (
	ID_Customer VARCHAR(255) NOT NULL,
	NamaDepan CHAR(255) NOT NULL,
	NamaBelakang CHAR(255),
	BirthDate DATE,
	Alamat VARCHAR(255),
	ZipCode INT,
	Kota CHAR(255),
	Pekerjaan VARCHAR(255),
	PRIMARY KEY (ID_Customer)
);

CREATE TABLE PhonePembeli (
	ID_Customer VARCHAR(255),
	NoTelp VARCHAR(255),
	PRIMARY KEY (NoTelp),
	FOREIGN KEY (ID_Customer) REFERENCES Pembeli(ID_Customer)
	ON DELETE CASCADE
);

CREATE TABLE Karyawan (
	ID_Karyawan VARCHAR(255) NOT NULL,
	NamaDepan CHAR(255),
	NamaBelakang CHAR(255),
	Email VARCHAR(255),
	Kota CHAR(255),
	ZipCode CHAR(255),
	Alamat VARCHAR(255),
	JobID VARCHAR(255),
	ID_Manager VARCHAR(255),
	PRIMARY KEY (ID_Karyawan),
	FOREIGN KEY (ID_Manager) REFERENCES Karyawan(ID_Karyawan)
);

CREATE TABLE Job (
	JobID VARCHAR(255) NOT NULL,
	JobDesc VARCHAR(255),
	Salary INT,
	PRIMARY KEY (JobID)
);

CREATE TABLE Produk (
	ID_Produk VARCHAR(255) NOT NULL,
	NamaProduk VARCHAR(255),
	Kategori VARCHAR(255),
	Harga BIGINT,
	Qty INT,
	PRIMARY KEY (ID_Produk)
);

CREATE TABLE Supplier (
	ID_Supplier VARCHAR(255) NOT NULL,
	NamaSupplier VARCHAR(255),
	Alamat VARCHAR(255),
	NoTelp VARCHAR(255),
	PRIMARY KEY (ID_Supplier)
);

CREATE TABLE PenyediaanProduk (
	ID_Supplier VARCHAR(255),
	ID_Produk VARCHAR(255),
	ProsesDate DATE,
	TotalHarga BIGINT,
	PRIMARY KEY (ID_Supplier, ID_Produk),
	FOREIGN KEY (ID_Supplier) REFERENCES Supplier(ID_Supplier),
	FOREIGN KEY (ID_Produk) REFERENCES Produk(ID_Produk)
);

CREATE TABLE OrderProduk (
	ID_Customer VARCHAR(255),
	ID_Karyawan VARCHAR(255),
	OrderDate DATE,
	TotalHarga BIGINT,
	ID_Produk VARCHAR(255), 
	PRIMARY KEY (ID_Customer, ID_Karyawan, ID_Produk),
	FOREIGN KEY (ID_Customer) REFERENCES Pembeli(ID_Customer),
	FOREIGN KEY (ID_Karyawan) REFERENCES Karyawan(ID_Karyawan),
	FOREIGN KEY (ID_Produk) REFERENCES Produk(ID_Produk)
);

/* Populating Tables */
INSERT INTO Pembeli VALUES
('C0001', 'Gina', 'Sari', '1990-01-01', 'Jl. Melati No. 1', '12345', 'Jakarta', 'Ibu Rumah Tangga'),
('C0002', 'Budi', 'Santoso', '1985-05-05', 'Jl. Kenanga No. 2', '54321', 'Bandung', 'Karyawan'),
('C0003', 'Siti', 'Aisyah', '1992-03-03', 'Jl. Mawar No. 3', '67890', 'Tangerang', 'Pengusaha');

INSERT INTO PhonePembeli VALUES
('C0001', '081234567890'),
('C0002', '082345678901'),
('C0003', '083456789012');

INSERT INTO Job VALUES
('J0001', 'Manager', 8000000),
('J0002', 'Sales', 4000000),
('J0003', 'Staff', 3000000);

INSERT INTO Karyawan VALUES
('K0001', 'Rina', 'Putri', 'rina.putri@example.com', 'Jakarta', '12345', 'Jl. Melati No. 1', 'J0001', NULL),
('K0002', 'Andi', 'Prasetyo', 'andi.prasetyo@example.com', 'Bandung', '54321', 'Jl. Kenanga No. 2', 'J0002', NULL);

INSERT INTO Produk VALUES
('P0001', 'Kursi', 'Furniture', 1500000, 10),
('P0002', 'Meja', 'Furniture', 2500000, 5),
('P0003', 'Lemari', 'Furniture', 3000000, 3);

INSERT INTO Supplier VALUES
('S0001', 'PT. Furniture Sejahtera', 'Jl. Raya No. 1', '021-1234567'),
('S0002', 'CV. Perlengkapan Rumah', 'Jl. Kebon No. 2', '021-7654321');

INSERT INTO PenyediaanProduk VALUES
('S0001', 'P0001', '2023-01-01', 15000000),
('S0001', 'P0002', '2023-01-01', 25000000),
('S0002', 'P0003', '2023-01-01', 9000000);

INSERT INTO OrderProduk VALUES
('C0001', 'K0001', '2023-02-01', 1500000, 'P0001'),
('C0002', 'K0002', '2023-02-02', 2500000, 'P0002'),
('C0003', 'K0001', '2023-02-03', 3000000, 'P0003');

/* Select Statement / Query */
/* Query 1 - Display the managers and their employees. */
SELECT CONCAT(e.NamaDepan, " ", e.NamaBelakang) AS Manager,
GROUP_CONCAT(f.NamaDepan, " ", f.NamaBelakang SEPARATOR ', ') AS Karyawan
FROM Karyawan AS e
JOIN Karyawan AS f ON (f.ID_Manager = e.ID_Karyawan)
GROUP BY 1;

/* Query 2 - Total harga produk yang dipesan. */
SELECT o.ID_Customer, SUM(o.TotalHarga) AS 'Total Harga'
FROM OrderProduk AS o
GROUP BY o.ID_Customer;

/* Query 3 - Display Email */
SELECT k.NamaDepan, k.NamaBelakang, j.JobDesc, j.Salary
FROM Karyawan AS k
JOIN Job AS j ON k.JobID = j.JobID
WHERE k.Email LIKE '%@example.com'
ORDER BY j.Salary DESC;

/* Query 4 - Informasi Produk */
SELECT p.NamaProduk, p.Harga, s.NamaSupplier
FROM Produk AS p
JOIN PenyediaanProduk AS pp ON p.ID_Produk = pp.ID_Produk
JOIN Supplier AS s ON pp.ID_Supplier = s.ID_Supplier;

/* Query 5 - Cek Stok Produk */
SELECT ID_Produk, NamaProduk, Qty
FROM Produk
WHERE Qty < 5;

/* Stored Procedure */
/* Procedure 1 - Cek Pembelian Produk */
DROP PROCEDURE IF EXISTS cekPembelian;
DELIMITER //

CREATE PROCEDURE cekPembelian(IN idPembeli VARCHAR(255))
BEGIN
	SELECT CONCAT(c.NamaDepan, ' ', c.NamaBelakang) AS 'Nama Pembeli', 
		p.NamaProduk AS 'Produk', 
		o.OrderDate AS 'Tanggal Pembelian', 
		o.TotalHarga AS 'Total Harga'
	FROM OrderProduk AS o
	JOIN Pembeli AS c ON o.ID_Customer = c.ID_Customer
	JOIN Produk AS p ON o.ID_Produk = p.ID_Produk
	WHERE o.ID_Customer = idPembeli;
END//
DELIMITER ;

/* Lihat Procedure 1 */
CALL cekPembelian('C0001');
CALL cekPembelian('C0002');

/* Function - Hitung Diskon */
DROP FUNCTION IF EXISTS hitungDiskon;
DELIMITER //
CREATE FUNCTION hitungDiskon(harga BIGINT) RETURNS BIGINT
BEGIN
	RETURN harga * 0.9; -- Diskon 10%
END//
DELIMITER ;

/* Lihat Function */
SELECT hitungDiskon(1500000) AS 'Harga Setelah Diskon';

/* Trigger - Update Stok Produk */
DROP TRIGGER IF EXISTS updateStok;
DELIMITER //
CREATE TRIGGER updateStok AFTER INSERT ON OrderProduk
FOR EACH ROW
BEGIN
	UPDATE Produk
	SET Qty = Qty - 1
	WHERE ID_Produk = NEW.ID_Produk;
END//
DELIMITER ;
