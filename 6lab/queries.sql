-- 1. Display the cities that makes the most different kinds of products. Experiment with 
-- the rank() function.

SELECT RANK() OVER (ORDER by Count(p.prodid) DESC) AS rank,
    p.city, Count(p.prodid) as productCount
FROM Products p
GROUP BY p.city;

-- 2. Display the names of products whose priceUSD is less than 1% of the average 
-- priceUSD, in alphabetical order. from A to Z.

SELECT p.name
FROM Products p
WHERE p.priceUSD < .01 * (
    SELECT AVG(p.priceUSD)
    FROM Products p
)
ORDER BY p.name ASC;

-- 3. Display the customer last name, product id ordered, and the totalUSD for all orders 
-- made in March of any year, sorted by totalUSD from low to high.

SELECT pe.lastName, o.prodId, o.totalUSD
FROM Orders o
INNER JOIN People pe ON o.custId = pe.pid
WHERE EXTRACT(MONTH FROM o.dateOrdered) = 3
ORDER BY o.totalUSD ASC; 

-- 4. Display the last name of all customers (in reverse alphabetical order) and their total 
-- ordered by customer, and nothing more. Use coalesce to avoid showing NULL totals.

-- Their total what? Total usd spent over every order? Total amount of orders? 
--   Total amount quantity ordered?
-- We're gonna go with total usd spent over every order.
SELECT p.pid, p.lastName, COALESCE(SUM(o.totalUSD), 0) as allOrdersTotalUSD
FROM Customers c
LEFT JOIN Orders o ON c.pid = o.custId
INNER JOIN People p ON c.pid = p.pid
GROUP BY p.pid, p.lastName
ORDER BY p.lastName DESC;

-- 5. Display the names of all customers who bought products from agents based in 
-- Chilliwack along with the names of the products they ordered, and the names of the 
-- agents who sold it to them.

-- I'm gonna assume that you use "name" instead of firstname/ lastname
--    on purpose.
-- I'm also not sure whether you want us to aggregate the names of products/ agents
--    or just have multiple rows. I'm gonna aggregate the product names but you could argue that's not
--    great bc the feilds may have my separator in them screwing with the output but whatever.

SELECT cPeople.lastName || ', ' || cPeople.firstName as customerName,
    aPeople.lastName || ', ' || aPeople.firstName as agentName,
    STRING_AGG( p.name, ' | ' ) productNames
FROM Orders o
INNER JOIN People cPeople ON o.custId = cPeople.pid
INNER JOIN People aPeople ON o.agentId = aPeople.pid
INNER JOIN Products p ON o.prodID = p.prodid
WHERE aPeople.homeCity = 'Chilliwack'
GROUP BY cPeople.pid, customerName, aPeople.pid, agentName;

-- 6. Write a query to check the accuracy of the totalUSD column in the Orders table. This 
-- means calculating  Orders.totalUSD from data in other tables and comparing those 
-- values to the values in Orders.totalUSD. Display all rows in Orders where 
-- Orders.totalUSD is incorrect, if any. If there are any incorrect  values, explain why they 
-- are wrong. Round to exactly two decimal places.

-- The database does not store past price and discount so i'd assume any differences
--    are because the current price is not the same as the price when they are purchased
--    and or the past discountPct is not the same as that was applied
-- I also assume priceUSD is the unit price (I would agrue that's a better name btw)
--    and not the price of everything on hand which in practice would terrible to implement.
--    The results also seem to validate my assumption.
SELECT orderNum, pastUnitPriceBeforeDiscount, currentUnitPriceBeforeDiscount
FROM (
    -- I do this weird query thing bc I dont want to write the calculations twice
    -- ogPrice * (1 - discountRate) = finalPrice
    -- ogPrice = finalPrice / (1 - discountRate)
    SELECT ROUND((o.totalUSD / o.quantityOrdered) / (1 - c.discountPct / 100), 2) as pastUnitPriceBeforeDiscount,
           ROUND(p.priceUSD, 2) as currentUnitPriceBeforeDiscount,
           o.orderNum as orderNum
    -- I know that casing does not matter but I've been following your casing to keep
    --    reminding you that you were inconsistent :)
    FROM Orders o
    INNER JOIN Products p ON o.prodId = p.prodId
    INNER JOIN Customers c ON o.custId = c.pid
)
WHERE pastUnitPriceBeforeDiscount != currentUnitPriceBeforeDiscount;

-- 7. Display the first and last name of all customers who are also agents.

-- What is this question doing here this is like the same as #3 from lab4 and others I think

SELECT p.firstName, p.lastName
FROM People p
INNER JOIN Customers c ON p.pid = c.pid
INNER JOIN Agents a ON a.pid = c.pid;

-- 8. Create a VIEW of all Customer and People data called PeopleCustomers. Then another 
-- VIEW of all Agent and People data called PeopleAgents. Then select * from each of 
-- them to test them.



-- 9. Display the first and last name of all customers who are also agents, this time using 
-- the views you created.

-- 10. Compare your SQL in #7 (no views) and #9 (using views). The output is the same. 
-- How does that work? What is the database server doing internally when it processes 
-- the #9 query?

-- 11. [Bonus] What’s the difference between a LEFT OUTER JOIN and a RIGHT OUTER 
-- JOIN? Give example queries in SQL to demonstrate. (Feel free to use the CAP database 
-- to make your points here.)
