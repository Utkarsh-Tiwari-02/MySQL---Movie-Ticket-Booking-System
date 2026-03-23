-- Complete Movie Ticket Booking System
-- =========================================

-- =========================================
-- Step 0: Create Database
CREATE DATABASE IF NOT EXISTS MovieTicketBooking;
USE MovieTicketBooking;

-- Step 1: Create Tables

-- Movies Table
CREATE TABLE Movies (
    MovieID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(100) NOT NULL,
    Genre VARCHAR(50),
    DurationMinutes INT,
    ReleaseDate DATE
);

-- Theaters Table
CREATE TABLE Theaters (
    TheaterID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100),
    Location VARCHAR(100)
);

-- Showtimes Table
CREATE TABLE Showtimes (
    ShowID INT AUTO_INCREMENT PRIMARY KEY,
    MovieID INT,
    TheaterID INT,
    ShowDate DATE,
    ShowTime TIME,
    TotalSeats INT,
    SeatsAvailable INT,
    TicketPrice DECIMAL(6,2),
    FOREIGN KEY (MovieID) REFERENCES Movies(MovieID),
    FOREIGN KEY (TheaterID) REFERENCES Theaters(TheaterID)
);

-- Customers Table
CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(15)
);

-- Seats Table (seat-level selection)
CREATE TABLE Seats (
    SeatID INT AUTO_INCREMENT PRIMARY KEY,
    ShowID INT,
    SeatNumber VARCHAR(5),
    IsBooked BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (ShowID) REFERENCES Showtimes(ShowID)
);

-- Bookings Table
CREATE TABLE Bookings (
    BookingID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
    ShowID INT,
    SeatID INT,
    BookingDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    AmountPaid DECIMAL(6,2),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (ShowID) REFERENCES Showtimes(ShowID),
    FOREIGN KEY (SeatID) REFERENCES Seats(SeatID)
);

-- Step 2: Insert Sample Data

-- Movies
INSERT INTO Movies (Title, Genre, DurationMinutes, ReleaseDate)
VALUES
('Avengers: Endgame', 'Action', 181, '2019-04-26'),
('Inception', 'Sci-Fi', 148, '2010-07-16');

-- Theaters
INSERT INTO Theaters (Name, Location)
VALUES
('PVR Cinemas', 'Mumbai'),
('INOX', 'Delhi');

-- Showtimes
INSERT INTO Showtimes (MovieID, TheaterID, ShowDate, ShowTime, TotalSeats, SeatsAvailable, TicketPrice)
VALUES
(1,1,'2026-03-25','18:00:00',10,10,250.00),
(2,2,'2026-03-25','20:00:00',8,8,200.00);

-- Customers
INSERT INTO Customers (Name, Email, Phone)
VALUES
('Utkarsh Tiwari', 'utkarsh@gmail.com', '9876543210'),
('Rohit Sharma', 'rohit@gmail.com', '9123456780');

-- Seats (seat numbers for ShowID 1)
INSERT INTO Seats (ShowID, SeatNumber)
SELECT ShowID, CONCAT('A', n) 
FROM Showtimes, (SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 
                 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10) AS nums
WHERE ShowID=1;

-- Seats (seat numbers for ShowID 2)
INSERT INTO Seats (ShowID, SeatNumber)
SELECT ShowID, CONCAT('B', n)
FROM Showtimes, (SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 
                 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8) AS nums
WHERE ShowID=2;

-- Step 3: Stored Procedure for Booking Seat
DELIMITER //

CREATE PROCEDURE BookSeat(
    IN custID INT,
    IN showID INT,
    IN seatNum VARCHAR(5)
)
BEGIN
    DECLARE seatID INT;
    DECLARE seatPrice DECIMAL(6,2);

    -- Get the seat ID and check availability
    SELECT SeatID INTO seatID
    FROM Seats
    WHERE ShowID = showID AND SeatNumber = seatNum AND IsBooked = FALSE;

    IF seatID IS NOT NULL THEN
        -- Get ticket price
        SELECT TicketPrice INTO seatPrice
        FROM Showtimes
        WHERE ShowID = showID;

        -- Insert booking
        INSERT INTO Bookings (CustomerID, ShowID, SeatID, AmountPaid)
        VALUES (custID, showID, seatID, seatPrice);

        -- Mark seat as booked
        UPDATE Seats
        SET IsBooked = TRUE
        WHERE SeatID = seatID;

        -- Update seats available
        UPDATE Showtimes
        SET SeatsAvailable = SeatsAvailable - 1
        WHERE ShowID = showID;

        SELECT CONCAT('Booking Successful! Seat: ', seatNum) AS Status;
    ELSE
        SELECT CONCAT('Seat ', seatNum, ' Not Available') AS Status;
    END IF;
END //

DELIMITER ;

-- Step 4: Stored Procedure for Cancellation
DELIMITER //

CREATE PROCEDURE CancelBooking(
    IN bookingID INT
)
BEGIN
    DECLARE showID INT;
    DECLARE seatID INT;

    -- Get ShowID and SeatID
    SELECT ShowID, SeatID INTO showID, seatID
    FROM Bookings
    WHERE BookingID = bookingID;

    IF showID IS NOT NULL THEN
        -- Delete booking
        DELETE FROM Bookings WHERE BookingID = bookingID;

        -- Mark seat as available
        UPDATE Seats
        SET IsBooked = FALSE
        WHERE SeatID = seatID;

        -- Update seats available
        UPDATE Showtimes
        SET SeatsAvailable = SeatsAvailable + 1
        WHERE ShowID = showID;

        SELECT 'Booking Cancelled Successfully!' AS Status;
    ELSE
        SELECT 'Booking ID Not Found' AS Status;
    END IF;
END //

DELIMITER ;

-- Step 5: Views for Reporting

-- Most Booked Movies
CREATE VIEW MostBookedMovies AS
SELECT M.Title, COUNT(B.BookingID) AS TicketsBooked
FROM Bookings B
JOIN Showtimes S ON B.ShowID = S.ShowID
JOIN Movies M ON S.MovieID = M.MovieID
GROUP BY M.Title
ORDER BY TicketsBooked DESC;

-- Seat Availability
CREATE VIEW SeatAvailability AS
SELECT S.ShowID, M.Title, T.Name AS Theater, SE.SeatNumber, SE.IsBooked
FROM Seats SE
JOIN Showtimes S ON SE.ShowID = S.ShowID
JOIN Movies M ON S.MovieID = M.MovieID
JOIN Theaters T ON S.TheaterID = T.TheaterID;

-- Step 6: Sample Queries to Test

-- All movies with showtimes and seats
SELECT M.Title, T.Name AS Theater, S.ShowDate, S.ShowTime, S.SeatsAvailable, S.TicketPrice
FROM Showtimes S
JOIN Movies M ON S.MovieID = M.MovieID
JOIN Theaters T ON S.TheaterID = T.TheaterID;

-- Customer booking history
SELECT B.BookingID, C.Name AS Customer, M.Title AS Movie, T.Name AS Theater, S.ShowDate, S.ShowTime, SE.SeatNumber, B.AmountPaid
FROM Bookings B
JOIN Customers C ON B.CustomerID = C.CustomerID
JOIN Showtimes S ON B.ShowID = S.ShowID
JOIN Movies M ON S.MovieID = M.MovieID
JOIN Theaters T ON S.TheaterID = T.TheaterID
JOIN Seats SE ON B.SeatID = SE.SeatID;

-- Total revenue per movie
SELECT M.Title, SUM(B.AmountPaid) AS TotalRevenue
FROM Bookings B
JOIN Showtimes S ON B.ShowID = S.ShowID
JOIN Movies M ON S.MovieID = M.MovieID
GROUP BY M.Title;

-- View Most Booked Movies
SELECT * FROM MostBookedMovies;

-- View Seat Availability
SELECT * FROM SeatAvailability;

-- Example Procedure Calls:
-- CALL BookSeat(1,1,'A1');
-- CALL CancelBooking(1);