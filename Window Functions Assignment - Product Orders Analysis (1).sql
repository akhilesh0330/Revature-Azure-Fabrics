-- Create Database
CREATE DATABASE ProductOrdersDB;
USE ProductOrdersDB;

-- Create Table
CREATE TABLE ProductOrders (
    OrderID INT,
    OrderDate DATE,
    CustomerID INT,
    ProductID INT,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Quantity INT,
    UnitPrice DECIMAL(10,2),
    SalesAmount DECIMAL(12,2),
    PRIMARY KEY (OrderID, ProductID)
);

-- Insert Data
INSERT INTO ProductOrders VALUES
(1,'2026-01-05',1001,101,'Laptop','Electronics',2,60000,120000),
(1,'2026-01-05',1001,102,'Mobile','Electronics',1,25000,25000),
(2,'2026-01-10',1002,103,'Printer','Electronics',3,12000,36000),
(3,'2026-01-15',1003,104,'Desk','Furniture',2,8000,16000),
(3,'2026-01-15',1003,105,'Chair','Furniture',4,3000,12000),
(4,'2026-02-05',1004,101,'Laptop','Electronics',1,60000,60000),
(4,'2026-02-05',1004,103,'Printer','Electronics',2,12000,24000),
(5,'2026-02-10',1005,102,'Mobile','Electronics',3,25000,75000),
(5,'2026-02-10',1005,104,'Desk','Furniture',1,8000,8000),
(6,'2026-03-01',1006,105,'Chair','Furniture',5,3000,15000),
(7,'2026-03-05',1007,101,'Laptop','Electronics',2,60000,120000),
(8,'2026-03-12',1008,102,'Mobile','Electronics',4,25000,100000);

-- Q1. ROW_NUMBER() for products ordered by SalesAmount descending
SELECT *,
       ROW_NUMBER() OVER(ORDER BY SalesAmount DESC) AS Row_Num
FROM ProductOrders;

-- Q2. RANK() based on total sales
SELECT ProductID,
       ProductName,
       SUM(SalesAmount) AS TotalSales,
       RANK() OVER(ORDER BY SUM(SalesAmount) DESC) AS SalesRank
FROM ProductOrders
GROUP BY ProductID, ProductName;

-- Q3. DENSE_RANK() based on quantity sold
SELECT ProductID,
       ProductName,
       SUM(Quantity) AS TotalQty,
       DENSE_RANK() OVER(ORDER BY SUM(Quantity) DESC) AS DenseRankQty
FROM ProductOrders
GROUP BY ProductID, ProductName;

-- Q4. Top 3 selling products
WITH ProductSales AS (
    SELECT ProductID,
           ProductName,
           SUM(SalesAmount) AS TotalSales,
           DENSE_RANK() OVER(ORDER BY SUM(SalesAmount) DESC) AS DRank
    FROM ProductOrders
    GROUP BY ProductID, ProductName
)
SELECT *
FROM ProductSales
WHERE DRank <= 3;

-- Q5. Previous SalesAmount using LAG()
SELECT *,
       LAG(SalesAmount) OVER(ORDER BY OrderDate, OrderID) AS PreviousSales
FROM ProductOrders;

-- Q6. Next SalesAmount using LEAD()
SELECT *,
       LEAD(SalesAmount) OVER(ORDER BY OrderDate, OrderID) AS NextSales
FROM ProductOrders;

-- Q7. Running total of SalesAmount
SELECT *,
       SUM(SalesAmount) OVER(
           ORDER BY OrderDate, OrderID
       ) AS RunningTotal
FROM ProductOrders;

-- Q8. Cumulative sales for each product
SELECT *,
       SUM(SalesAmount) OVER(
           PARTITION BY ProductID
           ORDER BY OrderDate
       ) AS ProductCumulativeSales
FROM ProductOrders;

-- Q9. Highest sales in each category
SELECT *,
       FIRST_VALUE(SalesAmount) OVER(
           PARTITION BY Category
           ORDER BY SalesAmount DESC
       ) AS HighestCategorySales
FROM ProductOrders;

-- Q10. Lowest sales in each category
SELECT *,
       LAST_VALUE(SalesAmount) OVER(
           PARTITION BY Category
           ORDER BY SalesAmount DESC
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) AS LowestCategorySales
FROM ProductOrders;

-- Q11. Difference between current and previous sales
SELECT *,
       SalesAmount -
       LAG(SalesAmount) OVER(ORDER BY OrderDate, OrderID) AS SalesDifference
FROM ProductOrders;

-- Q12. 3-order moving average sales
SELECT *,
       AVG(SalesAmount) OVER(
           ORDER BY OrderDate, OrderID
           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ) AS MovingAvg3Orders
FROM ProductOrders;

-- Q13. Percentage contribution of each product
SELECT ProductID,
       ProductName,
       SUM(SalesAmount) AS ProductSales,
       ROUND(
           SUM(SalesAmount) * 100 /
           SUM(SUM(SalesAmount)) OVER(), 2
       ) AS ContributionPercent
FROM ProductOrders
GROUP BY ProductID, ProductName;

-- Q14. Products whose sales exceed category average
WITH AvgSales AS (
    SELECT *,
           AVG(SalesAmount) OVER(PARTITION BY Category) AS CategoryAvg
    FROM ProductOrders
)
SELECT *
FROM AvgSales
WHERE SalesAmount > CategoryAvg;

-- Q15. Divide products into quartiles
SELECT *,
       NTILE(4) OVER(ORDER BY SalesAmount DESC) AS Quartile
FROM ProductOrders;

-- Q16. Second highest selling product
WITH ProductSales AS (
    SELECT ProductID,
           ProductName,
           SUM(SalesAmount) AS TotalSales,
           DENSE_RANK() OVER(ORDER BY SUM(SalesAmount) DESC) AS DRank
    FROM ProductOrders
    GROUP BY ProductID, ProductName
)
SELECT *
FROM ProductSales
WHERE DRank = 2;

-- Q17. Compare each product with category leader
SELECT *,
       FIRST_VALUE(SalesAmount) OVER(
           PARTITION BY Category
           ORDER BY SalesAmount DESC
       ) AS CategoryLeaderSales,
       SalesAmount -
       FIRST_VALUE(SalesAmount) OVER(
           PARTITION BY Category
           ORDER BY SalesAmount DESC
       ) AS DifferenceFromLeader
FROM ProductOrders;

-- Q18. Month-over-month sales growth
WITH MonthlySales AS (
    SELECT YEAR(OrderDate) AS SalesYear,
           MONTH(OrderDate) AS SalesMonth,
           SUM(SalesAmount) AS MonthlySales
    FROM ProductOrders
    GROUP BY YEAR(OrderDate), MONTH(OrderDate)
)
SELECT *,
       LAG(MonthlySales) OVER(
           ORDER BY SalesYear, SalesMonth
       ) AS PreviousMonthSales,
       MonthlySales -
       LAG(MonthlySales) OVER(
           ORDER BY SalesYear, SalesMonth
       ) AS GrowthAmount
FROM MonthlySales;

-- Q19. Products with consecutive sales increases
WITH SalesTrend AS (
    SELECT *,
           LAG(SalesAmount) OVER(
               PARTITION BY ProductID
               ORDER BY OrderDate
           ) AS PreviousSales
    FROM ProductOrders
)
SELECT *
FROM SalesTrend
WHERE SalesAmount > PreviousSales;

-- Q20. Sales leaderboard using DENSE_RANK()
SELECT ProductID,
       ProductName,
       SUM(SalesAmount) AS TotalSales,
       DENSE_RANK() OVER(
           ORDER BY SUM(SalesAmount) DESC
       ) AS LeaderboardRank
FROM ProductOrders
GROUP BY ProductID, ProductName
ORDER BY LeaderboardRank;