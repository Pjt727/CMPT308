-- 1. Show all the People data (and only people data) for people who are customers. 
-- Use joins this time; no subqueries.

SELECT p.*
FROM People p
INNER JOIN Customers c ON p.pid = c.pid;

-- 2. Show all the People data (and only the people data) for people who are agents. 
-- Use joins this time; no subqueries.

SELECT p.*
FROM People p
INNER JOIN Agents a ON p.pid = a.pid;

-- 3. Show all People and Agent data for people who are both customers and agents. 
-- Use joins this time; no subqueries.

SELECT p.*, a.*
FROM People p
INNER JOIN Agents a ON p.pid = a.pid
INNER JOIN Customers c ON p.pid = c.pid;

-- 4. Show the first name of customers who have never placed an order. Use subqueries.

SELECT firstName
FROM People p
WHERE p.pid not in (
    SELECT o.custId
    FROM Orders o
    ) AND p.pid in (
    SELECT c.pid
    FROM Customers c
); 

-- 5. Show the first name of customers who have never placed an order. Use one inner and 
-- one outer join.

SELECT p.firstName
FROM Customers c
INNER JOIN People p ON c.pid = p.pid
LEFT JOIN Orders o ON o.custId = c.pid
-- any order field would work for null check
WHERE o.orderNum is NULL;
-- Do not need a group by p.pid here bc Orders will only appear once
--    row will only appear once for customers without orders

-- 6. Show the id and commission percent of Agents who booked an order for the 
-- Customer whose id is 008, sorted by commission percent from high to low. Use joins; 
-- no subqueries.

-- Such a missed opportunity to not have 007 as an agent btw
-- need distinct because orders may have multiple hits

SELECT DISTINCT a.pid, a.commissionPct
FROM Agents a
INNER JOIN Orders o ON a.pid = o.agentId
WHERE o.custId = '008';

-- 7. Show the last name, home city, and commission percent of Agents who booked an 
-- order for the customer whose id is 001, sorted by commission percent from high to 
-- low. Use joins.

SELECT p.lastName, p.homeCity, a.commissionPct
FROM Agents a
INNER JOIN People p ON a.pid = p.pid
INNER JOIN Orders o ON a.pid = o.agentId and o.custId = '001'
-- Need a group by instead of a distinct because it is possible that
--   lastName, homeCity, commissionPct is not unique
GROUP BY a.pid, p.lastName, p.homeCity, a.commissionPct
ORDER BY a.commissionPct DESC;

-- 8. Show the last name and home city of customers who live in the city that makes the 
-- fewest different kinds of products.  (Hint: Use count and group by on the Products 
-- table. You may need limit as well.)

-- I assume we can use subqueries here idrk how to do it without
SELECT p.lastName, p.homeCity
FROM People p
INNER JOIN Customers c ON p.pid = c.pid
WHERE p.homeCity in (
    SELECT p.city
    FROM Products p
    GROUP BY p.city
    ORDER BY Count(p.prodid)
    LIMIT 1
);


-- 9. Show the name and id of all Products ordered through any Agent who booked at least 
-- one order for a Customer in Arlington, sorted by product name from A to Z. You can 
-- use joins or subqueries. Better yet, impress me by doing it both ways.
-- I tried and I feel like it is not really possible only using subqueries

SELECT DISTINCT pr.name, pr.prodid
FROM Orders o
INNER JOIN Products pr ON o.prodId = pr.prodid 
WHERE o.agentId in (
    -- Agents who booked for 'Arglington'
    SELECT o.agentId
    FROM Orders o
    INNER JOIN Customers c ON o.custId = c.pid
    INNER JOIN People p ON o.custId = p.pid
    WHERE p.homeCity = 'Arlington'
)
ORDER BY pr.name ASC;

-- 10. Show the first and last name of customers and agents living in the same city, along 
-- with the name of their shared city. (Living in a city with yourself does not count, so 
-- exclude those from your results.)

-- Such a reasonable thing to ask which lends itself very nicely to
--    to an inner join on subqueries
SELECT cData.firstName as customerFirstName, cData.lastName as customerLastName,
       aData.firstName as agentFirstName, aData.lastName as agentLastName
FROM
(
    SELECT p.firstName as firstName, p.lastName as lastName,
        p.pid as pid, p.homeCity as homeCity
    FROM People p
    INNER JOIN Customers c ON p.pid = c.pid
) cData
INNER JOIN
(
    SELECT p.firstName as firstName, p.lastName as lastName,
        p.pid as pid, p.homeCity as homeCity
    FROM People p
    INNER JOIN Agents a ON p.pid = a.pid
) aData
ON cData.homeCity = aData.homeCity
WHERE cData.pid != aData.pid;
