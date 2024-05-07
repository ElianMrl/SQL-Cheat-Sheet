USE BaseBall_Summer_2023;
GO
---Basic Select Clause to figure out if the following two foreign keys has duplicates records
SELECT YearID, lgID, COUNT(*) AS 'Count of Duplicates'
FROM Teams
GROUP BY YearID, lgID
HAVING COUNT(*) > 1
ORDER BY COUNT(*);

-- Note: if a primary key or compound primary keys contains duplicates rows, then I believe that 
-- those primary keys can not be used as foreign keys in other tables
-- NOTE: A foreign key in one table points to a primary key (or a unique key) in another table. 


-- Table       Foreign     Keys Foreign    Key Table Data Cleanup Needed
-- Leagues     None                        You need to create a leagues table and
--                                         insert the distinct LGID from the
--                                         Teams table into the Leagues table.
--                                         The table needs a single column (lgid)
--                                         which is also the primary key

-- create a leagues table
CREATE TABLE Leagues (
    lgid VARCHAR(255) PRIMARY KEY
);

-- insert the distinct LGID (which is also the primary key) from the Teams table into the Leagues table.
INSERT INTO Leagues (lgid)
SELECT DISTINCT lgID
FROM Teams
WHERE lgID IS NOT NULL;

-- checking the above query 
SELECT * from Leagues;

-- Table       Foreign      Keys Foreign            Key Table Data Cleanup Needed
-- Teams       FranchID     TeamsFranchises
--             LgID         Leagues

-- Adding the foreign keys to the Teams table
ALTER TABLE Teams
ADD CONSTRAINT fk_teams_franchises
FOREIGN KEY (FranchID)
REFERENCES TeamsFranchises(FranchID);

-- Dropping the Primary Key constrain from the Leagues table on the LgID column to change data type
ALTER TABLE Leagues DROP CONSTRAINT PK__Leagues__A5E791700F996640;

-- chaning the data type so that it is similar to the column from the Teams table 
ALTER TABLE Leagues
ALTER COLUMN LgID VARCHAR(25) NOT NULL; -- make sure that it is NOT NULL because this will be a primary key

-- creating the primary key constraint
ALTER TABLE Leagues
ADD CONSTRAINT PK_Leagues PRIMARY KEY (lgid);

-- Adding the foreign keys to the Teams table
ALTER TABLE Teams
ADD CONSTRAINT fk_leagues
FOREIGN KEY (LgID)
REFERENCES Leagues(lgid);

-- Table            Foreign         Keys Foreign            Key Table Data Cleanup Needed
-- AllStarFull      PlayerID        People

--                  YearID          Teams                   Change the LGID for teamid = SLN to
--                  LgID                                    NL. You will also need to address the
--                  Teamid                                  duplicate primary keys this causes.
--                                                          Either code the information from the
--                                                          error message in the where statement
--                                                          or use the ROW_NUMBER aggregate
--                                                          on page 5.7 of the Chapter 5
--                                                          Presentation

-- SELECT *
-- FROM AllstarFull

-- Adding the foreign keys to the AllstarFull table
ALTER TABLE AllstarFull
ADD CONSTRAINT fk_people
FOREIGN KEY (PlayerID)
REFERENCES People(PlayerID);

-- Change the LGID for teamid = SLN to NL.
UPDATE Teams
SET lgID = 'NL'
WHERE teamID = 'SLN';


-- HINT: Use the following query to identify the rows in the referencing table
-- that are causing the problems when performing the data cleanup in the table below. The
-- example shows the problem rows in the Allstarfull table that are preventing the creation of a
-- foreign key that references the Teams table. Remember a LEFT JOIN fills in the data for the
-- right-hand table with nulls when there is not a match for the ON parameter(s)

SELECT DISTINCT a.yearid AS 'allstarfull_yearid', 
    a.lgid AS 'allstarfull_lgid', 
    a.teamid AS 'allstarfull_teamid', 
    t.teamid AS 'teams_teamid', 
    t.lgid AS 'teams_lgid', 
    t.yearid AS 'teams_lgid'
FROM allstarfull a LEFT JOIN teams t ON a.yearid = t.yearid
    AND a.lgid = t.lgid AND a.teamid = t.teamid
WHERE t.yearid IS NULL OR
    t.lgid IS NULL OR
    t.teamid IS NULL
ORDER BY a.teamid, a.lgid, a.yearid

-- thanks to the above rows I notices that the allstarfull table contains the following record:
-- yearid=2012, lgid='AL', and teamid='SLN' and this record is not present in the Teams table thus
-- Preventing the creation of the foreign key constraint. To solve this issue I should either add 
-- a row on the Teams table with similar records or I should delete the records from the allstarfull
-- It seems like the easier solution for this proble is to delete the records from the allstarfull

-- Notes from HW instructions: do not delete any rows from the TEAMS or PEOPLE
-- tables to fix issues.

-- Deleting the rows that prevents the creation of the foreign key constraint
DELETE FROM AllstarFull
WHERE yearID = 2012 AND lgID = 'AL' AND teamID = 'SLN';

-- Adding the foreign keys to the AllstarFull table 
ALTER TABLE AllstarFull
ADD CONSTRAINT fk_teams_yearid_lgID_teamID
FOREIGN KEY (yearID, lgID, teamID)
REFERENCES Teams(yearID, lgID, teamID);


-- Table           Foreign         Keys Foreign            Key Table Data Cleanup Needed
-- Appearances     Playerid        People                  Remove the one (1) invalid playerid in
--                                                         the appearances table. Use a query
--                 Yearid          Teams                   similar to the one in the HINTS to find
--                 Teamid                                  the invalid playerid
--                 lgid                                    

SELECT DISTINCT A.playerID AS 'Appearances_playerID', 
    P.playerID AS 'People_playerID'
FROM Appearances A LEFT JOIN People P ON A.playerID = P.playerID
WHERE P.playerID IS NULL
ORDER BY A.playerID;

-- According to the above query, the record from Appearances playerID='thompan01' does not exist in the 
-- People table column playerID; therefore, I should either add this record to the People column or delete 
-- this record from the Appearances table. The easier choice is to Delete this record from the Appearances.
DELETE FROM Appearances
WHERE playerID = 'thompan01';

SELECT DISTINCT a.yearid AS 'Appearances_yearid', 
    a.lgid AS 'Appearances_lgid', 
    a.teamid AS 'Appearances_teamid', 
    t.teamid AS 'teams_teamid', 
    t.lgid AS 'teams_lgid', 
    t.yearid AS 'teams_lgid'
FROM Appearances a LEFT JOIN teams t ON a.yearid = t.yearid
    AND a.lgid = t.lgid AND a.teamid = t.teamid
WHERE t.yearid IS NULL OR
    t.lgid IS NULL OR
    t.teamid IS NULL
ORDER BY a.teamid, a.lgid, a.yearid

-- The following query fails because when you are creating a compound foreign key. You will get this
-- message if the order you have the columns in the foreign key are different than the order they
-- occur in the compound primary key of the referenced table. To find the correct order, expand
-- the keys section in the ADS explorer for the referenced table and after right clicking the
-- appropriate key or index, tell ADS to generate the CREATE SQL using the SCRIPT AS option as
-- shown below

-- ALTER TABLE Appearances
-- ADD CONSTRAINT fk_teams
-- FOREIGN KEY (YearID, TeamID, lgID) -- this is not good, the correct order should be (yearID, lgID, teamID)
-- REFERENCES Teams(YearID, TeamID, lgID);

-- Adding the foreign keys to the Appearances table
ALTER TABLE Appearances
ADD CONSTRAINT fk_teams
FOREIGN KEY (yearID, lgID, teamID)
REFERENCES Teams(yearID, lgID, teamID);



-- Table           Foreign         Keys Foreign            Key Table Data Cleanup Needed
-- HomeGames       YearID          Teams
--                 LgID
--                 Teamid

--                 Park Key        Parks                   Since the Parks table already has a
--                                                         primary key of park_name, you need
--                                                         to create a unique constraint on the
--                                                         Park_Key column to resolve the no
--                                                         primary or candidate keys error. Modify
--                                                         column lengths and null constraints as
--                                                         needed. Add missing Park Data with
--                                                         minimum data needed (4 rows) using a
--                                                         query similar to the one in the HINTS
--                                                         to find the missing Park data. The
--                                                         insert needs a DISTINCT parameter and
--                                                         you’ll need to create a park_name by
--                                                         concatenating the park_id with a
--                                                         constant of your choice. You can use
--                                                         US for the country column data

ALTER TABLE HomeGames
ADD CONSTRAINT fk_homegames_teams
FOREIGN KEY (YearID, lgID, Teamid)
REFERENCES Teams(YearID, lgID, Teamid);

-- It looks like parkID from HomeGames is the same thing as park_key from Parks
SELECT * 
FROM HomeGames
ORDER BY parkID

SELECT * 
FROM Parks
ORDER BY park_key

-- Adding modifications to Parks table column park_key:
ALTER TABLE Parks
ALTER COLUMN Park_Key VARCHAR(255) NOT NULL;

-- Since the Parks table already has a primary key of park_name, you need to create a unique constraint 
-- on the Park_Key column to resolve the no primary or candidate keys error.
ALTER TABLE Parks
ADD CONSTRAINT UNIQUE_Park_Key UNIQUE (Park_Key);

-- The following is to find the records from HomeGames that are not present in the Parl columns 
SELECT DISTINCT H.parkID AS 'H.parkID', 
    P.park_key AS 'P.park_key'
FROM HomeGames H LEFT JOIN Parks P ON H.parkID = P.park_key
WHERE P.park_key IS NULL 
ORDER BY H.parkID;

-- Adding new data to the Park table:
INSERT INTO Parks (park_key, park_name, country)
SELECT DISTINCT 'ARL03', 'ARL03_Park', 'US';

INSERT INTO Parks (park_key, park_name, country)
SELECT DISTINCT 'BUF05', 'BUF05_Park', 'US';

INSERT INTO Parks (park_key, park_name, country)
SELECT DISTINCT 'DUN01', 'DUN01_Park', 'US';

INSERT INTO Parks (park_key, park_name, country)
SELECT DISTINCT 'DYE01', 'DYE01_Park', 'US';

-- Adding the foreign keys to the HomeGames table
ALTER TABLE HomeGames
ADD CONSTRAINT fk_homegames_parkkey
FOREIGN KEY (parkID)
REFERENCES Parks(park_key);


-- Table           Foreign         Keys Foreign            Key Table Data Cleanup Needed
-- Managers        Playerid        People

--                 Yearid          Teams
--                 Teamid
--                 lgid

-- Adding the foreign keys to the Managers table from People table
ALTER TABLE Managers
ADD CONSTRAINT fk_managers_people
FOREIGN KEY (playerID)
REFERENCES People(playerID);

-- Adding the foreign keys to the Managers table from Teams table
ALTER TABLE Managers
ADD CONSTRAINT fk_managers_teams
FOREIGN KEY (YearID, lgID, TeamID)
REFERENCES Teams(YearID, lgID, TeamID);


-- Table               Foreign         Keys Foreign            Key Table Data Cleanup Needed
-- AwardsManagers      Playerid        People

--                     Lgid            Leagues                 Correct LGID problems. Use a
--                                                             query similar to the one in the
--                                                             HINTS to find the missing LGID and
--                                                             insert it into the Leagues table

-- Adding the foreign keys to the AwardsManagers table from People table
ALTER TABLE AwardsManagers
ADD CONSTRAINT fk_awardsmanagers_people
FOREIGN KEY (PlayerID)
REFERENCES People(PlayerID);

-- The following is to find the records from AwardsManagers that are not present in the Leagues columns 
SELECT DISTINCT A.lgID AS 'A.lgID', 
    L.lgID AS 'L.lgID'
FROM AwardsManagers A LEFT JOIN Leagues L ON A.lgID = L.lgID
WHERE L.lgID IS NULL 
ORDER BY A.lgID;

-- insert missing value into the Leagues table
INSERT INTO Leagues (lgID)
VALUES ('ML');

-- Adding the foreign keys to the AwardsManagers table from Leagues table
ALTER TABLE AwardsManagers
ADD CONSTRAINT fk_awardsmanagers_leagues
FOREIGN KEY (lgID)
REFERENCES Leagues(lgID);


-- Table               Foreign         Keys Foreign            Key Table Data Cleanup Needed
-- AwardsPlayers       lgId            Leagues
--                                                             Note FK for PEOPLE table was
--                                                             created in the Missing Table
--                                                             Assignment

-- Adding the foreign keys to the AwardsPlayers table from Leagues table
ALTER TABLE AwardsPlayers
ADD CONSTRAINT fk_awardsplayers_leagues
FOREIGN KEY (lgID)
REFERENCES Leagues(lgID);

