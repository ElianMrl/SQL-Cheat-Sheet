use BaseBall_Summer_2023;
go
---Basic Select Clause
select * from people

-- The fullname function already existws in the Baseball database. Run the following SQL to see how it works
select playerid, dbo.fullname(playerid) 
from people;

-- In baseball statistics, fielding percentage, also known as fielding average, is a measure that
-- reflects the percentage of times a defensive player properly handles a batted or thrown ball. It is
-- calculated by the sum of putouts and assists, divided by the number of total chances (putouts +
-- assists + errors).[1] For this assignment, you must write a scalar function ( a function that returns a
-- single value) that is passed the playerid and returns the fielding percentage for the players
-- career. The career fielding percentage is the following formula using the sum of each column
-- rather than a single years value
-- FPCT = (PO + A) / (PO + A + E)

-- You will need to use the FIELDING table in your function.

-- Note that you do not need to reference the FIELDING table in your query that tests the function
-- even though it returns data from that table. Also code your function so that it returns 0 if the
-- calculated value is null.

IF OBJECT_ID (N'dbo.CalculatorFPCT', N'FN') IS NOT NULL
    DROP FUNCTION CalculatorFPCT;
GO
-- Scalar function: Calculates FPCT input: playerID
CREATE FUNCTION dbo.CalculatorFPCT(@playerID VARCHAR(255))
RETURNS FLOAT
AS
BEGIN
    DECLARE @FPCT FLOAT;
    SELECT @FPCT = SUM(PO + A) * 1.0 / NULLIF(SUM(PO + A + E), 0)
    FROM Fielding
    WHERE playerID = @playerID;
    RETURN ISNULL(@FPCT, 0); -- Check for NULL and return 0 if it is NULL, else return the FPCT
END;

-- To test your function, write a query that uses your function and the dbo.fullname function with
-- the People table in the query that calls the function and returns the playerid, the player’s full
-- name and the player’s career FPCT. The query will return 20,676 rows

SELECT playerID, dbo.fullname(playerID), dbo.CalculatorFPCT(playerID)
FROM People;

-- The second query uses the function to calculate the average FPct by team. You can do this by
-- calling the function inside an average statement and using the batting table. 

SELECT teamID,
    CONVERT(decimal(7,4), AVG(CONVERT(decimal(7,4),dbo.CalculatorFPCT(playerID)))) AS Team_FPct
FROM Batting
GROUP BY teamID
ORDER BY Team_FPct DESC;

