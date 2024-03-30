-- Database data:
-- Actor	Data
--    name,	address,	birth	date,	hair	color,	eye	color,	height	in	inches,	weight,	spouse	name,	
--    favorite	color,	screen	actors	guild	anniversary	date
-- Movie	Data
--    name,	year	released,	MPAA	number,	domestic	box	office	sales,	foreign	box	office	sales,	
--    DVD/Blu-ray	sales
-- Director	Data
--    name,	address,	spouse	name,	film	school	attended,	directors	guild	anniversary	date,	
--    favorite	lens	maker

DROP TABLE IF EXISTS MovieCasts;
DROP TABLE IF EXISTS MovieSales;
DROP TABLE IF EXISTS Movies;
DROP TABLE IF EXISTS Directors;
DROP TABLE IF EXISTS Actors;
DROP TABLE IF EXISTS People;
DROP TYPE IF EXISTS hairColor;
DROP TYPE IF EXISTS eyeColor;
DROP TYPE IF EXISTS movieSaleType;

CREATE TABLE People (
    id int not null,
    firstName VARCHAR(50),
    lastName VARCHAR(50),
    country VARCHAR(50),
    state VARCHAR(20),
    city VARCHAR(50),
    zipcode VARCHAR(20), -- for other countries
    spouseName VARCHAR(50),
    primary key(id)
);

CREATE TYPE hairColor AS ENUM('blonde', 'brunette', 'red', 'black', 'gray', 'other');
CREATE TYPE eyeColor AS ENUM('blue', 'brown', 'green', 'hazel', 'amber', 'gray', 'black', 'other');
CREATE TABLE Actors (
    pid int not null references People(id),
    birthDate DATE,
    hairColor hairColor,
    eyeColor eyeColor,
    favoriteColor VARCHAR(20),
     -- Freedom units
    heightInInches FLOAT,
    weightInPounds FLOAT,
    -- I interpret this as the Actor's own guild anniversy of joining even though you might
    --    mean the anniversy of the guild they are in but tbf the naming is unclear
    --    and implementing a guild create anniversy would require more tables/ work
    dateJoinedGuild DATE,
    primary key(pid)
);

CREATE TABLE Directors (
    pid int not null references People(id),
    -- if more information of school is needed then could more this to another table
    --    or if school names just be a validate set from the database instead of 
    --    some other input
    filmSchoolAttended VARCHAR(50),
    favoriteLensMaker VARCHAR(50),
    -- I interpret this as the Director's own guild anniversy of joining even though you might
    --    mean the anniversy of the guild they are in but tbf the naming is unclear
    --    and implementing a guild create anniversy would require more tables/ work
    dateJoinedGuild DATE,
    primary key(pid)
);

CREATE TABLE Movies (
    -- Many movies do not have MPAA_Numbers but Im going to assume this database
    --    only wants to store movies that do since
    MPAA_Number int NOT NULL,
    name VARCHAR(100) NOT NULL,
    yearReleased INTEGER,
    primary key(MPAA_Number)
);

                                
-- This structure only works for movies where every director has some actors
--     under them and every actor has at least on director over them
-- Otherwise when actors directors etc were deleted we could lose the information
--     of a director / actor being involved in the movie, but you could argue that
--     if a actor does not have a director / a director has not actors then they
--     actaully aren't in the movie so think that this is fine.
CREATE TABLE MovieCasts (
    director int not null references Directors(pid),
    actor int not null references Actors(pid),
    MPAA_Number int not null references Movies(MPAA_Number),
    primary key(director, actor, MPAA_Number)
);


CREATE TYPE movieSaleType AS ENUM('DVD Blu Ray', 'DVD Blu Ray Rental', 'Theater', 'Digital Copy', 'Digital Rental');
-- Movie sales provide a view to get domestic/ foreign box office sales
--    as well as DVD blu ray sales
CREATE TABLE MovieSales (
    id int not null,
    MPAA_Number int not null references Movies(MPAA_Number),
    isDomestic BOOLEAN, 
    -- might want more specific types in depending on what the data is used for
    type movieSaleType,
    primary key(id)
);

-- Some sample data
INSERT INTO People (id, firstName, lastName, country, state, city, zipcode, spouseName)
VALUES
(1, 'Roger', 'Moore', 'United Kingdom', NULL, 'London', 'SW1A 1AA', 'Kiki Tholstrup'),
(2, 'Tom', 'Hanks', 'United States', 'California', 'Los Angeles', '90001', 'Rita Wilson'),
(3, 'Meryl', 'Streep', 'United States', 'New Jersey', 'Summit', '07901', 'Don Gummer'),
(4, 'Steven', 'Spielberg', 'United States', 'California', 'Los Angeles', '90049', 'Kate Capshaw'),
(5, 'James', 'Cameron', 'Canada', NULL, 'Kapuskasing', 'P5N', 'Suzy Amis'),
(6, 'John', 'Tyler', 'Canada', NULL, 'Kapuskasing', 'P5N', 'Dava Amis');

INSERT INTO Actors (pid, birthDate, hairColor, eyeColor, favoriteColor, heightInInches, weightInPounds, dateJoinedGuild)
VALUES
(1, '1927-10-14', 'brunette', 'blue', 'navy', 72.5, 175, '1981-02-13'),
(2, '1956-07-09', 'brunette', 'blue', 'green', 74.0, 180, '1969-01-9'),
(3, '1949-06-22', 'blonde', 'blue', 'red', 67.0, 135, '1978-01-17');

INSERT INTO Directors (pid, filmSchoolAttended, favoriteLensMaker, dateJoinedGuild)
VALUES
(4, 'California State University, Long Beach', 'Panavision', '1975-03-14'),
(5, 'New York University', 'ARRI', '1981-06-22'),
(6, 'New York University', 'ARRI', '1981-06-22');

INSERT INTO Movies (MPAA_Number, name, yearReleased)
VALUES
(1234, 'Forrest Gump', 1994),
(5678, 'The Terminator', 1984),
(9012, 'A View to a Kill', 1985);

INSERT INTO MovieCasts (director, actor, MPAA_Number)
VALUES
(4, 1, 1234),
(5, 1, 5678),
(4, 2, 9012),
(6, 2, 9012);

INSERT INTO MovieSales (id, MPAA_Number, isDomestic, type)
VALUES
(1, 1234, true, 'Theater'),
(2, 1234, false, 'Theater'),
(3, 1234, true, 'DVD Blu Ray'),
(4, 5678, true, 'Theater'),
(5, 5678, false, 'Theater'),
(6, 5678, true, 'Digital Rental'),
(7, 9012, true, 'Theater'),
(8, 9012, false, 'Theater'),
(9, 9012, true, 'DVD Blu Ray Rental');

-- Select which gets the names of all direcotrs who have worked with Roger
--     Moore on any movie
SELECT directorP.firstName, directorP.lastName
FROM People directorP
INNER JOIN Directors d ON directorP.id=d.pid
INNER JOIN MovieCasts m ON d.pid = m.director
INNER JOIN People actorP ON actorP.id = m.actor
WHERE actorP.firstName = 'Roger' AND
      actorP.lastName  = 'Moore'
;

