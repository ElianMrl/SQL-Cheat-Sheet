--- After looking at the 07 - AwardsPlayer_Data.sql the AwardsPlayers contains 6 columns
-- 2.18 AwardsPlayers table
-- playerID     Player ID code
-- awardID      Name of award won
-- yearID       Year
-- lgID         League
-- tie          Award was a tie (Y or N)
-- notes        Notes about the award

USE BaseBall_Summer_2023;
GO

--- Select all columns from the PEOPLE table to make sure that we are connected to the Database
SELECT * FROM People;

--- Creating AwardsPlayers Table 
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AwardsPlayers' AND type = 'U')
BEGIN
    CREATE TABLE AwardsPlayers (
        [playerID] VARCHAR(255) NULL,
        [awardID] VARCHAR(255) NULL,
        [yearID] INT NULL,
        [lgID] VARCHAR(25) NULL,
        [tie] VARCHAR(255) NULL,
        [notes] VARCHAR(255) NULL
    )
END;

--- Making sure that the table was created
SELECT * FROM AwardsPlayers;

-- After loading the data to the table write the SQL using ATLER statements to create:
-- 1. The appropriate primary key. It needs to be a compound primary key using 4 columns)
--- I have to change the columns to NOT NULL
ALTER TABLE AwardsPlayers
ALTER COLUMN playerID VARCHAR(255) NOT NULL;

ALTER TABLE AwardsPlayers
ALTER COLUMN awardID VARCHAR(255) NOT NULL;

ALTER TABLE AwardsPlayers
ALTER COLUMN yearID INT NOT NULL;

ALTER TABLE AwardsPlayers
ALTER COLUMN lgID VARCHAR(25) NOT NULL;

ALTER TABLE AwardsPlayers
ADD CONSTRAINT PK_AwardsPlayers PRIMARY KEY (playerID, awardID, yearID, lgID);

-- 2. The appropriate foreign key for the playerid to reference the PEOPLE table
ALTER TABLE AwardsPlayers
ADD CONSTRAINT FK_AwardsPlayers_People FOREIGN KEY (playerID)
REFERENCES People (playerID);

-- 3. A check statement to check that the awardid column contains one of these values: 
ALTER TABLE AwardsPlayers
ADD CONSTRAINT Check_awardID CHECK (awardID IN ('Triple Crown', 'TSN Reliever of the Year', 'TSN Major League Player of the Year', 'Branch Rickey Award', 'Comeback Player of the Year',
'Rookie of the Year', 'Baseball Magazine All-Star', 'World Series MVP', 'TSN Fireman of the Year', 'TSN Pitcher of the Year', 'Hank Aaron Award',
'Pitching Triple Crown', 'All-Star Game MVP', 'Gold Glove', 'Babe Ruth Award', 'Hutch Award', 'TSN All-Star', 'ALCS MVP',
'Outstanding DH Award', 'NLCS MVPTSN Guide MVP', 'Reliever of the Year Award', 'Lou Gehrig Memorial Award', 'TSN Player of the Year',
'Cy Young Award', 'Roberto Clemente Award', 'Most Valuable Player', 'Rolaids Relief Man Award', 'Silver Slugger', 'NLCS MVP',
'TSN Guide MVP'));

--- Making sure that the table was created
SELECT * FROM AwardsPlayers;