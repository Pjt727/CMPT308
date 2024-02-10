-- 1. Get all the People data for people who are customers.
SELECT *
FROM People
WHERE pid in (
    SELECT pid
    FROM Customers
);
-- 2. Get all the People data for people who are agents.
SELECT *
FROM People
WHERE pid in (
    SELECT pid
    FROM Agents
);

-- 3. Get all of People data for people who are both customers 
--    and agents.
SELECT *
FROM People
WHERE 
    pid in (
        SELECT pid
        FROM Customers
    ) AND 
    pid in (
        SELECT pid
        FROM Agents
    )
;

-- 4. Get all of People data for people who are neither customers
--    nor agents.
SELECT  *
FROM People
WHERE 
    pid not in (
        SELECT pid
        FROM Customers
    ) AND 
    pid not in (
        SELECT pid
        FROM Agents
    )
;
-- 5. Get the ID of customers who ordered either product p01 
--    or p03 (or both). List the IDs in order from lowest 
--    to highest. Include each ID only once.
SELECT pid
FROM Customers
WHERE
    pid in (
        SELECT custId
        FROM Orders
        WHERE prodId = 'p01' OR
            prodId = 'p03'
    ) 
ORDER BY pid DESC;

-- 6. Get the ID of customers who ordered both products p01 
--     and p03. List the IDs in order from highest to lowest. 
--    Include each ID only once.
SELECT DISTINCT pid
FROM Customers
WHERE 
    pid in (
        SELECT custId
        FROM Orders
        WHERE prodId = 'p01'
    ) AND
    pid in (
        SELECT custId
        FROM Orders
        WHERE prodId = 'p03'
    )
ORDER BY pid DESC;

-- 7. Get the first and last names of agents who sold products 
--    p05 or p07 in order by last name from A to Z.
SELECT firstName, lastName
FROM People
WHERE pid in (
    SELECT agentId
    FROM Orders
    WHERE prodId = 'p05' OR
        prodId =  'p07'
)
ORDER BY lastName ASC;

-- 8. Get the home city and birthday of agents booking an order
--    for the customer whose pid is 008, sorted by home 
--    city from Z to A.
SELECT homeCity, DOB
FROM People
WHERE pid in (
    SELECT agentId
    FROM Orders
    WHERE custId = '8'
)
ORDER BY homeCity DESC;

-- 9. Get the unique ids of products ordered through any agent who 
--    takes at least one order from a customer in Montreal, 
--    sorted by id from highest to lowest. (This is not the 
--    same as asking for ids of products ordered by customers in 
--    Montreal.)
SELECT DISTINCT prodid
FROM Products
WHERE prodid in (
    SELECT prodid
    FROM Orders
    WHERE agentId in (
        SELECT agentId
        FROM Orders
        WHERE custId in (
            SELECT pid
            FROM People
            WHERE homeCity = 'Montreal'
        )
    )
)
ORDER BY prodid DESC;

-- 10. Get the last name and home city for all customers who 
--     place orders through agents in Chilliwack or Oslo in 
--     order by last name from A to Z.
SELECT lastName, homeCity
FROM People
WHERE pid in (
    -- custId is the same as pid so do not need to
    -- go through customer table
    SELECT custId
    FROM Orders
    WHERE agentId in (
        -- agentId is the same as pid and unique so do 
        -- not need to go through agents table 
        SELECT pid
        FROM People
        WHERE homeCity = 'Chilliwack' OR
            homeCity = 'Oslo'
    )
)
ORDER BY lastName ASC; 

