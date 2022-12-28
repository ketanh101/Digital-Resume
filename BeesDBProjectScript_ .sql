#CLEANING DATA

ALTER TABLE bee_colonies_county_column_subset
MODIFY Geo_Level VARCHAR(200),
MODIFY State VARCHAR(200),
MODIFY Ag_District VARCHAR(200),
MODIFY County VARCHAR(200),
MODIFY Value VARCHAR(200);

ALTER TABLE bee_colonies_state_column_subset
MODIFY Geo_Level VARCHAR(200),
MODIFY State VARCHAR(200),
MODIFY Ag_District VARCHAR(200),
MODIFY Ag_District_Code VARCHAR(200),
MODIFY County VARCHAR(200),
MODIFY County_ANSI VARCHAR(200),
MODIFY Value VARCHAR(200);

ALTER TABLE population_estimates_trimmed
MODIFY State VARCHAR(200),
MODIFY Area_name VARCHAR(200),
MODIFY Rural_urban_code_2013 VARCHAR(200),
MODIFY Population_1990 VARCHAR(200),
MODIFY Population_2000 VARCHAR(200),
MODIFY Population_2010 VARCHAR(200),
MODIFY Population_2020 VARCHAR(200);

UPDATE population_estimates_trimmed
SET Population_1990 = REPLACE (Population_1990, ',','');
UPDATE population_estimates_trimmed
SET Population_2000 = REPLACE (Population_2000, ',','');
UPDATE population_estimates_trimmed
SET Population_2010 = REPLACE (Population_2010, ',','');
UPDATE population_estimates_trimmed
SET Population_2020 = REPLACE (Population_2020, ',','');
           
#CLEANSE tables 
UPDATE bee_colonies_county_column_subset
SET Value = NULL
WHERE Value LIKE '%(D)%';

UPDATE bee_colonies_state_column_subset
SET Value = NULL
WHERE Value LIKE '%(D)%';

UPDATE bee_colonies_state_column_subset
SET Ag_District = NULL
WHERE Ag_District = '';

UPDATE bee_colonies_state_column_subset
SET Ag_District_Code = NULL
WHERE Ag_District_Code = '';

UPDATE bee_colonies_state_column_subset
SET County = NULL
WHERE County = '';

UPDATE bee_colonies_state_column_subset
SET County_ANSI = 0
WHERE County_ANSI = '';

#Table Creation

Use Bees_DB;

DROP TABLE IF EXISTS Bee_Colonies;
DROP TABLE IF EXISTS Population;
DROP TABLE IF EXISTS Population_1;
DROP TABLE IF EXISTS Geo_Codes;
DROP TABLE IF EXISTS Geo_Code_1;
DROP TABLE IF EXISTS Ag_Codes;
DROP TABLE IF EXISTS Ag_Codes_1;


CREATE TABLE Population (
	State_ANSI VARCHAR(50),
    County_ANSI VARCHAR(50),
    Rural_Urban_Code_2013 VARCHAR(50),
    Population_1990 VARCHAR(50),
    Population_2000 VARCHAR(50),
    Population_2010 VARCHAR(50),
    Population_2020 VARCHAR(50));
    
ALTER TABLE Population
ADD Primary Key (State_ANSI, County_ANSI);

###Population: inserting into Population###

INSERT INTO Population (State_ANSI, County_ANSI, Rural_Urban_Code_2013,Population_1990, Population_2000, Population_2010, Population_2020)
SELECT FLOOR(FIPStxt/1000), FIPStxt % 1000, Rural_Urban_Code_2013,Population_1990, Population_2000, Population_2010, Population_2020
FROM population_estimates_trimmed;


            
CREATE TABLE Ag_Codes(
State_ANSI VARCHAR(50),
Ag_District_Code VARCHAR(50),
Ag_District VARCHAR(50),
PRIMARY KEY (State_ANSI, Ag_District_Code)
);


####Ag Code dummy creation and inserting into Ag Codes###

CREATE TABLE Ag_Codes_1
SELECT DISTINCT State_ANSI, Ag_District_Code, Ag_District
FROM bee_colonies_county_column_subset;


INSERT INTO Ag_Codes (State_ANSI, Ag_District_Code, Ag_District)
SELECT State_ANSI, Ag_District_Code, Ag_District
FROM Ag_Codes_1;


CREATE TABLE Geo_Codes(
Geo_Level VARCHAR(50),
    State_ANSI VARCHAR(50),
    County_ANSI VARCHAR(50),
    State VARCHAR(50),
    Area_Name VARCHAR(50),
    PRIMARY KEY (State_ANSI, County_ANSI, Area_Name)

);
ALTER TABLE Geo_Codes
 ADD  FOREIGN KEY (State_ANSI, County_ANSI) REFERENCES Population (State_ANSI, County_ANSI);


##############Geo_Code dummy creation and inserting into Geo_Code table######

CREATE TABLE Geo_Code_1
SELECT DISTINCT FLOOR(FIPStxt/1000) AS State_ANSI, FIPStxt % 1000 AS County_ANSI, State, Area_Name
FROM population_estimates_trimmed;

ALTER TABLE Geo_Code_1
ADD Geo_Level VARCHAR(50);

UPDATE Geo_Code_1
SET Geo_Level = 'Country'
WHERE State_ANSI = 0 AND County_ANSI = 0;

UPDATE Geo_Code_1
SET Geo_Level = 'State'
WHERE State_ANSI > 0 AND County_ANSI = 0;

UPDATE Geo_Code_1
SET Geo_Level = 'County'
WHERE State_ANSI > 0 AND County_ANSI > 0;

INSERT INTO Geo_Codes (Geo_Level, State_ANSI, County_ANSI, State, Area_NAME)
SELECT DISTINCT Geo_Level, State_ANSI, County_ANSI, State, Area_NAME
FROM Geo_Code_1;

###Bee_Colonies

CREATE TABLE Bee_Colonies(
	State_ANSI VARCHAR(50),
    County_ANSI VARCHAR(50),
    Ag_District_Code VARCHAR(50),
    Colonies_2002 VARCHAR(50),
    Colonies_2007 VARCHAR(50),
    Colonies_2012 VARCHAR(50),
    Colonies_2017 VARCHAR(50)

);
ALTER TABLE Bee_Colonies 
ADD FOREIGN KEY (State_ANSI, County_ANSI) REFERENCES Population (State_ANSI, County_ANSI);

#INSERTING DATA INTO Bee_Colonies

INSERT INTO Bee_Colonies (State_ANSI, County_ANSI, Ag_District_Code)
SELECT DISTINCT State_ANSI, County_ANSI, Ag_District_Code
FROM bee_colonies_county_column_subset;

INSERT INTO Bee_Colonies(State_ANSI, County_ANSI)
SELECT DISTINCT State_ANSI, County_ANSI
FROM bee_colonies_state_column_subset;


#UPDATE TABLE (First County.ANSI = 0 replace with appropriate value, Second Replace NULL values with appropriate value)
UPDATE Bee_Colonies
SET Colonies_2002 = 
	(SELECT Value
    FROM bee_colonies_state_column_subset B
    WHERE Bee_Colonies.State_ANSI = B.State_ANSI
    AND   Bee_Colonies.County_ANSI = B.County_ANSI
    AND   Year = 2002)
WHERE Bee_Colonies.County_ANSI = 0;

UPDATE Bee_Colonies
SET Colonies_2002 = 
	(SELECT Value
     FROM bee_colonies_county_column_subset A
	WHERE Bee_Colonies.State_ANSI = A.State_ANSI
    AND   Bee_Colonies.County_ANSI = A.County_ANSI
    AND   Year = 2002)
WHERE Bee_Colonies.County_ANSI != 0;

UPDATE Bee_Colonies
SET Colonies_2007 = 
	(SELECT Value
    FROM bee_colonies_state_column_subset B
    WHERE Bee_Colonies.State_ANSI = B.State_ANSI
    AND   Bee_Colonies.County_ANSI = B.County_ANSI
    AND   Year = 2007)
WHERE Bee_Colonies.County_ANSI = 0;

UPDATE Bee_Colonies
SET Colonies_2007 = 
	(SELECT Value
     FROM bee_colonies_county_column_subset A
	WHERE Bee_Colonies.State_ANSI = A.State_ANSI
    AND   Bee_Colonies.County_ANSI = A.County_ANSI
    AND   Year = 2007)
WHERE Bee_Colonies.County_ANSI != 0;

UPDATE Bee_Colonies
SET Colonies_2012 = 
	(SELECT Value
    FROM bee_colonies_state_column_subset B
    WHERE Bee_Colonies.State_ANSI = B.State_ANSI
    AND   Bee_Colonies.County_ANSI = B.County_ANSI
    AND   Year = 2012)
WHERE Bee_Colonies.County_ANSI = 0;

UPDATE Bee_Colonies
SET Colonies_2012 = 
	(SELECT Value
     FROM bee_colonies_county_column_subset A
	WHERE Bee_Colonies.State_ANSI = A.State_ANSI
    AND   Bee_Colonies.County_ANSI = A.County_ANSI
    AND   Year = 2012)
WHERE Bee_Colonies.County_ANSI != 0;

UPDATE Bee_Colonies
SET Colonies_2017 = 
	(SELECT Value
    FROM bee_colonies_state_column_subset B
    WHERE Bee_Colonies.State_ANSI = B.State_ANSI
    AND   Bee_Colonies.County_ANSI = B.County_ANSI
    AND   Year = 2017)
WHERE Bee_Colonies.County_ANSI = 0;

UPDATE Bee_Colonies
SET Colonies_2017 = 
	(SELECT Value
     FROM bee_colonies_county_column_subset A
	WHERE Bee_Colonies.State_ANSI = A.State_ANSI
    AND   Bee_Colonies.County_ANSI = A.County_ANSI
    AND   Year = 2017)
WHERE Bee_Colonies.County_ANSI != 0;




            





