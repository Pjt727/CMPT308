-- Queries by Patrick Tyler
-- Feb 6, 2024
-- 1.
SELECT orderNum, totalUSD
FROM Orders;
-- 2.
SELECT lastName, homeCity
FROM People
WHERE prefix = 'Ms.';
-- 3.
SELECT prodid, name, qtyOnHand
FROM Products
WHERE qtyOnHand > 1007;
-- 4.
SELECT firstName, homeCity
FROM People
WHERE EXTRACT(YEAR FROM dob) BETWEEN 1920 AND 1929;
-- 5.
SELECT prefix, lastName
FROM People
WHERE prefix != 'Mr.';
-- 6.
SELECT *
FROM Products
WHERE 
   (city != 'Dallas' and city != 'Duluth') AND
   -- DEMORGANS
   -- NOT (city = 'Dallas' or city = 'Duluth' ) AND
   priceUSD <= '17'
;
-- 7.
SELECT *
FROM Orders
WHERE (EXTRACT(MONTH FROM dateOrdered) = 1)
;
-- 8.
SELECT *
FROM Orders
WHERE 
  (EXTRACT(MONTH FROM dateOrdered) = 2) AND
  (totalUSD >= 23000)
;
-- 9.
SELECT *
FROM Orders
WHERE custId = '007';
-- 10.
SELECT *
FROM ORDERS
WHERE custId = '005';

