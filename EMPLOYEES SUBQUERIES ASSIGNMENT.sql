-- EMPLOYEES SUBQUERIES ASSIGNMENT

-- 1. CREATE DATABASE

CREATE DATABASE EmployeeDB;

USE EmployeeDB;

-- 2. CREATE TABLE

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(100),
    Department VARCHAR(50),
    Salary DECIMAL(10,2),
    ManagerID INT,
    HireDate DATE
);

-- 3. INSERT MANAGERS DATA

INSERT INTO Employees
(EmployeeID, EmployeeName, Department, Salary, ManagerID, HireDate)
VALUES
(201, 'Robert',   'Sales',   85000, NULL, '2015-01-01'),
(202, 'Linda',    'HR',      82000, NULL, '2014-06-15'),
(203, 'William',  'IT',      95000, NULL, '2013-09-20'),
(204, 'Patricia', 'Finance', 100000, NULL, '2012-12-10');

-- 4. INSERT EMPLOYEE DATA

INSERT INTO Employees
(EmployeeID, EmployeeName, Department, Salary, ManagerID, HireDate)
VALUES
(101, 'John',    'Sales',   50000, 201, '2021-01-10'),
(102, 'Mary',    'Sales',   65000, 201, '2020-03-15'),
(103, 'David',   'HR',      55000, 202, '2022-05-20'),
(104, 'Sophia',  'HR',      70000, 202, '2019-07-18'),
(105, 'James',   'IT',      80000, 203, '2018-11-01'),
(106, 'Emma',    'IT',      75000, 203, '2021-09-25'),
(107, 'Michael', 'Finance', 90000, 204, '2017-06-12'),
(108, 'Olivia',  'Finance', 60000, 204, '2023-02-01');

-- 5. VERIFY DATA

SELECT * FROM Employees;

-- 1. Find employees earning more than the average salary.
-- Single Row Subquery

SELECT *
FROM Employees
WHERE Salary > (
    SELECT AVG(Salary)
    FROM Employees
);


-- 2. Find employees earning the highest salary.
-- Single Row Subquery

SELECT *
FROM Employees
WHERE Salary = (
    SELECT MAX(Salary)
    FROM Employees
);


-- 3. Find employees earning the second highest salary.
-- Single Row Subquery

SELECT *
FROM Employees
WHERE Salary = (
    SELECT MAX(Salary)
    FROM Employees
    WHERE Salary < (
        SELECT MAX(Salary)
        FROM Employees
    )
);


-- 4. List employees whose salary is less than the maximum salary.
-- Single Row Subquery

SELECT *
FROM Employees
WHERE Salary < (
    SELECT MAX(Salary)
    FROM Employees
);


-- 5. Find employees working in the same department as the employee with the highest salary.
-- Single Row Subquery

SELECT *
FROM Employees
WHERE Department = (
    SELECT Department
    FROM Employees
    WHERE Salary = (
        SELECT MAX(Salary)
        FROM Employees
    )
);


-- 6. Find departments having employees with salary greater than 70,000.
-- Multi Row Subquery (IN)

SELECT DISTINCT Department
FROM Employees
WHERE Department IN (
    SELECT Department
    FROM Employees
    WHERE Salary > 70000
);


-- 7. Find employees whose salary is above their department average salary.
-- Correlated Subquery

SELECT *
FROM Employees e
WHERE Salary > (
    SELECT AVG(Salary)
    FROM Employees
    WHERE Department = e.Department
);


-- 8. Find employees who earn more than all employees in the HR department.
-- Multi Row Subquery (ALL)

SELECT *
FROM Employees
WHERE Salary > ALL (
    SELECT Salary
    FROM Employees
    WHERE Department = 'HR'
);


-- 9. Find employees whose salary matches any salary in the Sales department.
-- Multi Row Subquery (ANY)

SELECT *
FROM Employees
WHERE Salary = ANY (
    SELECT Salary
    FROM Employees
    WHERE Department = 'Sales'
);


-- 10. Find employees hired after the employee with the lowest salary.
-- Single Row Subquery

SELECT *
FROM Employees
WHERE HireDate > (
    SELECT HireDate
    FROM Employees
    WHERE Salary = (
        SELECT MIN(Salary)
        FROM Employees
    )
);


-- 11. Find the department with the highest average salary.
-- Subquery with GROUP BY

SELECT Department
FROM (
    SELECT Department,
           AVG(Salary) AS AvgSalary
    FROM Employees
    GROUP BY Department
) DeptAvg
WHERE AvgSalary = (
    SELECT MAX(AvgSalary)
    FROM (
        SELECT AVG(Salary) AS AvgSalary
        FROM Employees
        GROUP BY Department
    ) X
);


-- 12. Find employees who earn the minimum salary in their department.
-- Correlated Subquery

SELECT *
FROM Employees e
WHERE Salary = (
    SELECT MIN(Salary)
    FROM Employees
    WHERE Department = e.Department
);


-- 13. Display managers who manage employees earning more than 75,000.
-- Multi Row Subquery (IN)

SELECT *
FROM Employees
WHERE EmployeeID IN (
    SELECT DISTINCT ManagerID
    FROM Employees
    WHERE Salary > 75000
);


-- 14. Find employees whose salary is greater than their manager's salary.
-- Correlated Subquery (Self-Reference)

SELECT *
FROM Employees e
WHERE Salary > (
    SELECT m.Salary
    FROM Employees m
    WHERE m.EmployeeID = e.ManagerID
);


-- 15. Find the top 3 highest paid employees using a subquery.
-- Correlated Subquery

SELECT *
FROM Employees e1
WHERE 3 > (
    SELECT COUNT(DISTINCT e2.Salary)
    FROM Employees e2
    WHERE e2.Salary > e1.Salary
);
