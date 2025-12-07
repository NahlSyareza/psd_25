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
| Column 1 | Column 2 | Column 3 | Column 4 |
| -------- | -------- | -------- | -------- |
| b0       | b4       | b8       | b12      |
| b5       | b9       | b13      | b1       |
| b10      | b14      | b2       | b6       |
| b15      | b3       | b7       | b11      |

### 3. Mix Columns

Nah ini bagian yang agak tricky. Setiap kolom dari state matrix dikalikan dengan fixed polynomial matrix dalam Galois Field (GF 2^8). Intinya kita melakukan operasi perkalian matriks, tapi bukan perkalian biasa, melainkan dalam finite field.

Matriks yang dipakai untuk enkripsi:

|     |     |     |     |
| --- | --- | --- | --- |
| 02  | 03  | 01  | 01  |
| 01  | 02  | 03  | 01  |
| 01  | 01  | 02  | 03  |
| 03  | 01  | 01  | 02  |

Cara kerjanya, setiap kolom dari state dikalikan dengan matriks di atas. Perkalian dengan 02 itu shift left 1 bit terus XOR dengan 0x1B kalau bit paling kiri adalah 1. Perkalian dengan 03 itu hasil dari (02 * byte) XOR byte. Lumayan ribet tapi intinya buat diffusion, jadi perubahan 1 byte bakal mempengaruhi seluruh kolom.

### 4. Add Round Key

Setelah Mix Columns, hasil state di-XOR lagi dengan round key. Round key ini bukan key asli, tapi key yang sudah di-expand. Dari 1 key 128 bit, kita generate 11 round keys (round 0 sampe round 10).

Proses key expansion itu pake:
- RotWord: rotate 1 byte ke kiri
- SubWord: substitusi pake S-Box
- XOR dengan Rcon (round constant)

Jadi total ada 10 round untuk AES-128. Round 1-9 itu full (SubBytes, ShiftRows, MixColumns, AddRoundKey), tapi round terakhir (round 10) ga pake MixColumns.

---

## Decryption

Decryption itu basically kebalikan dari encryption. Urutan operasinya dibalik dan beberapa operasi pake inverse-nya.

### 0. Add Round Key

Sama kayak encryption, pertama kita XOR ciphertext dengan round key terakhir (round 10).

### 1. Inverse Shift Rows

Kebalikan dari Shift Rows. Kalo encryption shift ke kiri, decryption shift ke kanan.

- Row pertama tetap
- Row kedua shift kanan 1x
- Row ketiga shift kanan 2x  
- Row keempat shift kanan 3x

### 2. Inverse Sub Bytes

Pake inverse S-Box. Jadi ada tabel lookup lain yang merupakan kebalikan dari S-Box biasa. Setiap byte di-substitute balik ke nilai aslinya.

### 3. Add Round Key

XOR dengan round key yang sesuai (dari round 9 ke bawah).

### 4. Inverse Mix Columns

Ini juga pake matriks yang berbeda dari encryption:

|     |     |     |     |
| --- | --- | --- | --- |
| 0E  | 0B  | 0D  | 09  |
| 09  | 0E  | 0B  | 0D  |
| 0D  | 09  | 0E  | 0B  |
| 0B  | 0D  | 09  | 0E  |

Operasinya sama kayak Mix Columns tapi dengan matriks inverse ini. Lebih kompleks karena ada perkalian dengan 09, 0B, 0D, dan 0E.

### Urutan Round Decryption

Jadi untuk decryption, setiap round (dari round 9 ke 1) urutannya:
1. Inverse Shift Rows
2. Inverse Sub Bytes
3. Add Round Key
4. Inverse Mix Columns

Round terakhir (round 0) sama kayak encryption, ga pake Inverse Mix Columns.

---

## Summary

Intinya AES itu symmetric encryption, key yang dipake buat encrypt sama dengan yang dipake buat decrypt. Bedanya cuma di urutan operasi dan pake inverse functions. Setiap round itu nge-scramble data makin kompleks, makanya susah di-crack tanpa tau key-nya.
