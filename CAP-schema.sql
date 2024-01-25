------------------------------------------------------------------------------------------------------
-- PostgreSQL create, load, and query script for CAP v008.
--
-- Derived long ago from the CAP examples in _Database Principles, Programming, and Performance_,
--                                           Second Edition by Patrick O'Neil and Elizabeth O'Neil
--
-- Drastically modified and perverted for many years by Alan G. Labouseur
--
-- Tested on Postgres 14 (For versions < 10 you may need
-- to remove the "if exists" clause from the DROP TABLE commands.)
------------------------------------------------------------------------------------------------------

-- Connect to your Postgres server and set the active database to CAP ("\connect CAP" in psql). Then ...

DROP VIEW IF EXISTS PeopleCustomers;
DROP VIEW IF EXISTS PeopleAgents;

DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Agents;
DROP TABLE IF EXISTS People;

-- People --
CREATE TABLE People (
   pid         int not null,
   prefix      text,
   firstName   text,
   lastName    text,
   suffix      text,
   homeCity    text,
   DOB         date,
 primary key(pid)
);

-- Customers --
CREATE TABLE Customers (
   pid          int not null references People(pid),
   paymentTerms text,
   discountPct  decimal(5,2),
 primary key(pid)
);

-- Agents --
CREATE TABLE Agents (
   pid            int not null references People(pid),
   paymentTerms   text,
   commissionPct  decimal(5,2),
 primary key(pid)
);

-- Products --
CREATE TABLE Products (
  prodId    text not null,
  name      text,
  city      text,
  qtyOnHand int,
  priceUSD  numeric(10,2),
 primary key(prodId)
);

-- Orders --
CREATE TABLE Orders (
  orderNum        int     not null,
  dateOrdered     date    not null,
  custId          int     not null references Customers(pid),
  agentId         int     not null references Agents(pid),
  prodId          char(3) not null references Products(prodId),
  quantityOrdered integer,
  totalUSD        numeric(12,2),
 primary key(orderNum)
);


-- SQL statements for loading example data

-- People --
INSERT INTO People (pid, prefix,      firstName, lastName,     suffix,  homeCity,      DOB)
VALUES             (001, 'Dr. (Hon)', 'Maynard', 'Ferguson',   '',      'Montreal',    '1928-05-04'),
                   (002, 'Ms.',       'Bria',    'Skonberg',   NULL,    'Chilliwack',  '1987-12-29'),
                   (003, 'Mr.',       'Miles',   'Davis',      'Esq.',  'Alton',       '1926-05-26'),
                   (004, 'Mr.',       'Doc',     'Severinsen', NULL,    'Arlington',   '1927-07-07'),
                   (005, 'Mr.',       'Louis',   'Armstrong',  NULL,    'New Orleans', '1901-08-04'),
                   (006, 'Ms.',       'Tine',    'Helseth',    'Esq.',  'Oslo',        '1987-08-18'),
                   (007, 'Dr.',       'Cynthia', 'Robinson',   'MD',    'Sacramento',  '1944-01-12'),
                   (008, 'Dr.',       'James',   'Morrison',   'Ph.D.', 'Oslo',        '1962-11-11'),
                   (010, 'Mr.',       'Dizzy',   'Gillespie',  'III',   'Montreal',    '1917-10-21');

-- Customers --
INSERT INTO Customers (pid, paymentTerms, discountPct)
VALUES                (001, 'Net 30'    , 21.12),
                      (004, 'Net 15'    ,  2.47),
                      (005, 'In Advance',  5.05),
                      (007, 'On Receipt',  2.00),
                      (008, 'Net 30'    , 10.01);

INSERT INTO Agents (pid, paymentTerms, commissionPct)
VALUES             (002, 'Quarterly',   5.00),
                   (003, 'Annually',   10.00),
                   (005, 'Monthly',     1.00),
                   (006, 'Weekly',      2.00);

-- Products --
INSERT INTO Products(prodId, name,                    city,     qtyOnHand, priceUSD)
VALUES              ('p01', 'Heisenberg Compensator', 'Dallas',        47,    67.76),
                    ('p02', 'Universal Translator',   'Newark',      2399,    51.50),
                    ('p03', 'Apple //+',              'Duluth',      1979,    65.02),
                    ('p04', 'LCARS module',           'Duluth',         3,    17.01),
                    ('p05', 'Denis Wick Valve Oil',   'Dallas',   8675309,    16.61),
                    ('p06', 'PDP-11 operator panel',  'Beijing',       88,    88.00),
                    ('p07', 'Flux Capacitor',         'Newark',      1007,     1.00),
                    ('p08', 'HAL 9000 memory chip',   'Newark',       200,     1.25),
                    ('p09', 'Bach Stradivarius 37',   'Montreal',       1, 37900.42);

-- Orders --
INSERT INTO Orders(orderNum, dateOrdered,  custId, agentId, prodId, quantityOrdered,  totalUSD)
VALUES            (1011,     '2024-01-22',    001,     002, 'p01',             1100,  58794.00),
                  (1012,     '2023-01-23',    004,     003, 'p03',             1200,  76096.81),
                  (1015,     '2022-01-23',    005,     003, 'p05',             1000,  15771.20),
                  (1016,     '2021-01-23',    008,     003, 'p01',             1000,  60977.22),
                  (1017,     '2023-02-14',    001,     003, 'p03',              500,  25643.98),
                  (1018,     '2023-02-14',    001,     003, 'p04',              600,   8050.49),
                  (1019,     '2023-02-14',    001,     002, 'p02',              400,  16249.28),
                  (1020,     '2023-02-14',    004,     005, 'p07',              600,    585.18),
                  (1021,     '2023-02-14',    004,     005, 'p01',             1000,  66086.33),
                  (1022,     '2023-03-15',    001,     003, 'p06',              450,  31236.48),
                  (1023,     '2023-03-15',    001,     002, 'p05',              500,   6550.98),
                  (1024,     '2023-03-15',    005,     002, 'p01',              880,  56671.55),
                  (1025,     '2022-04-01',    008,     003, 'p07',              888,    799.11),
                  (1026,     '2022-05-04',    008,     005, 'p03',              808,  47277.29);


-- SQL statements for displaying this example data:
select *
from People;

select *
from Customers;

select *
from Agents;

select *
from Products;

select *
from Orders;
