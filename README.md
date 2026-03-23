# 🎬 Movie Ticket Booking System - MySQL 🍿

### 📌 Project Objective
The goal of this project is to design and implement a robust relational database for a cinema hall. It automates the process of managing movies, theaters, showtimes, and seat reservations, ensuring high data integrity and real-time availability tracking.

### 🛠️ Tools Used
* **MySQL Workbench:** For database modeling, writing complex queries, and ER diagramming.
* **SQL Language:** Used DDL for schema creation and DML for data manipulation.
* **Stored Procedures:** For automating the seat booking logic.
* **SQL Views:** For generating real-time availability and sales reports.

### 💡 Major Technical Highlights
* **Automated Booking:** Developed a `BookSeat` Stored Procedure that validates seat status and processes bookings in a single transaction.
* **Smart Reporting:** Created `SeatAvailability` and `MostBookedMovies` views for instant business insights.
* **Relational Design:** Implemented 6+ interconnected tables using Primary and Foreign keys to prevent data redundancy.
* **Error Handling:** Included checks to prevent double-booking of seats.

### 📊 Database Schema (ER Diagram)
![ER Diagram](./Screenshot%20(ER%20Diagram).png)

### 💻 Sample Output & Queries
![Output Screen](./Screenshot%20(Sample%20Output).png)

*To run this project, simply import the `.sql` file into your MySQL Workbench and execute the script.*
