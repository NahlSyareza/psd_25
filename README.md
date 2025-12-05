Jadi karena kita make algoritma AES buat encryption/decryption, kalian harus paham dulu bagaimana cara kerja algoritma tersebut baru bisa dibuat dalam bentuk kode.

Ingat kita make 7 modul, yaitu:

- Behavioural Style
- Testbench
- Structual Programming
- Looping Construct
- Procedure, Function, and Impure Function
- Microprogramming

Algoritma AES menggunakan input 128 bit. Untuk prosedur algoritma AES itu

## Encryption

### 0. XOR Key

Melakukan operasi XOR terhadap input dengan Key yang kita miliki. Dari 128 bit yang ada, kita buat menjadi 16 bagian 8 byte yang disusun dalam sebuah table

| Column 1 | Column 2 | Column 3 | Column 4 |
| -------- | -------- | -------- | -------- |
| b0       | b4       | b8       | b12      |
| b1       | b5       | b9       | b13      |
| b2       | b6       | b10      | b14      |
| b3       | b7       | b11      | b15      |

Contoh seperti ini

| Column 1 | Column 2 | Column 3 | Column 4 |
| -------- | -------- | -------- | -------- |
| 0x09     | 0x62     | 0xad     | 0x4a     |
| 0x00     | 0xfd     | 0x4e     | 0x22     |
| 0xff     | 0x1f     | 0x44     | 0x78     |
| 0x02     | 0xd2     | 0xa2     | 0x91     |

### 1. Sub Bytes

Mengubah byte berdasarkan table perubahan s-box. Byte tersebut adalah byte yang ada dari table yang di atas, misal untuk 0x09, kita akan mencari dari kolom X ke 0 dan kolom Y ke 9 pada s-box. Elemen yang ditunjukkan dari kolom X ke 0 dan kolom Y ke 9 adalah hasil output baru. Ini dilakukan untuk semua kolom

### 2. Shift Rows

Melakukan shifting terhadap rows yang ada. Berikut adalah urutannya

- Row pertama tidak di shift
- Row kedua di shift sekali
- Row ketiga di shift dua kali
- Row keempat di shift tiga kali

Berikut contoh ketika row berhasil di shift
|Column 1|Column 2|Column 3|Column 4|
|-|-|-|-|
|b0|b4|b8|b12|
|b5|b9|b13|b1|
|b10|b14|b2|b6|
|b15|b3|b7|b11|
