-- MySQL Assignment: Stored Procedures and User Defined Functions
-- Product and Order Management System

-- Create Database

CREATE DATABASE ProductManagement;
USE ProductManagement;

-- Create Tables

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    UnitPrice DECIMAL(10,2),
    StockQty INT
);

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    City VARCHAR(50)
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Insert Data

INSERT INTO Products VALUES
(101,'Laptop','Electronics',55000,50),
(102,'Mouse','Electronics',800,150),
(103,'Keyboard','Electronics',1200,100),
(104,'Monitor','Electronics',15000,40),
(105,'Printer','Electronics',12000,30);

INSERT INTO Customers VALUES
(1,'Ravi','Chennai'),
(2,'Priya','Bangalore'),
(3,'Arun','Hyderabad'),
(4,'Sneha','Mumbai');

INSERT INTO Orders VALUES
(1001,1,'2026-01-10'),
(1002,2,'2026-01-15'),
(1003,3,'2026-01-20'),
(1004,1,'2026-02-05');

INSERT INTO OrderDetails VALUES
(1,1001,101,2),
(2,1001,102,3),
(3,1002,103,5),
(4,1003,104,1),
(5,1004,105,2);

-- Question 1:
-- Create Procedure to Display Products by Category

DELIMITER $$

CREATE PROCEDURE GetProductsByCategory(
    IN p_category VARCHAR(50)
)
BEGIN
    SELECT *
    FROM Products
    WHERE Category = p_category;
END $$

DELIMITER ;

-- Execute
CALL GetProductsByCategory('Electronics');

-- Question 2:
-- Create Procedure to Delete an Order

DELIMITER $$

CREATE PROCEDURE DeleteOrder(
    IN p_OrderID INT
)
BEGIN
    DELETE FROM OrderDetails
    WHERE OrderID = p_OrderID;

    DELETE FROM Orders
    WHERE OrderID = p_OrderID;
END $$

DELIMITER ;

-- Execute
CALL DeleteOrder(1004);

-- Question 3:
-- Create Function to Calculate Average Order Value

DELIMITER $$

CREATE FUNCTION AvgOrderValue()
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN

    DECLARE avg_value DECIMAL(12,2);

    SELECT AVG(OrderTotal)
    INTO avg_value
    FROM
    (
        SELECT
            o.OrderID,
            SUM(od.Quantity * p.UnitPrice) AS OrderTotal
        FROM Orders o
        JOIN OrderDetails od
            ON o.OrderID = od.OrderID
        JOIN Products p
            ON od.ProductID = p.ProductID
        GROUP BY o.OrderID
    ) AS OrderSummary;

    RETURN avg_value;

END $$

DELIMITER ;

-- Execute
SELECT AvgOrderValue() AS Average_Order_Value;

-- Question 4:
-- Create Function to Count Customer Orders

DELIMITER $$

CREATE FUNCTION CustomerOrderCount(
    p_CustomerID INT
)
RETURNS INT
DETERMINISTIC
BEGIN

    DECLARE total_orders INT;

    SELECT COUNT(*)
    INTO total_orders
    FROM Orders
    WHERE CustomerID = p_CustomerID;

    RETURN total_orders;

END $$

DELIMITER ;

-- Execute
SELECT CustomerOrderCount(1) AS Total_Orders;

-- Question 5:
-- Create Procedure to Display Top-Selling Products

DELIMITER $$

CREATE PROCEDURE TopSellingProducts()
BEGIN

    SELECT
        p.ProductID,
        p.ProductName,
        SUM(od.Quantity) AS TotalSold
    FROM Products p
    JOIN OrderDetails od
        ON p.ProductID = od.ProductID
    GROUP BY p.ProductID, p.ProductName
    ORDER BY TotalSold DESC;

END $$

DELIMITER ;

-- Execute
CALL TopSellingProducts();