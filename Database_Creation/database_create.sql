---------------------------------------------------------------------------
--
-- database_create.sql :-
--	File which creates Schema of Placement Portal in Postgresql
--
---------------------------------------------------------------------------


---------------------------------------------------------------------------
--
--	General Tables
--
---------------------------------------------------------------------------
CREATE TABLE Country(
	Country_Code SMALLINT PRIMARY KEY ,
	Country_Name VARCHAR(30) NOT NULL
);

CREATE TABLE Sector(
	Sector_Id INT PRIMARY KEY,
	Sector_Name VARCHAR(50) NOT NULL
);

CREATE TYPE _LOC_ AS ENUM ('Hostel','Class Room', 'Lecture Theature', 'Auditorium', 'Interview Room', 'Office Room', 'Computer Center');

CREATE TABLE Institute_Location(
	Location_Id INT PRIMARY KEY,
	Location_Name VARCHAR(50) NOT NULL,
	Location_Type _LOC_ NOT NULL
);


---------------------------------------------------------------------------
--
--	Branch Table & Program Table
--
---------------------------------------------------------------------------

--CREATE TABLE Program_Type(
--	Program_Type_Id INT PRIMARY KEY,
--	Program_Type_Name VARCHAR(50) NOT NULL
--	Program_Type_Duration FLOAT VARCHAR(50) NOT NULL
--);

CREATE TYPE _PROG_ AS ENUM ('B.Tech.', 'M.Tech', 'M.Sc.', 'Dual Degree', 'PhD');

CREATE TABLE Branch(
	Branch_Code INT PRIMARY KEY,
	Branch_Name VARCHAR(50) NOT NULL,
	Website_URL VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE Program(
	Program_Type _PROG_ NOT NULL DEFAULT 'B.Tech.' ,
	Branch_Code INT NOT NULL REFERENCES Branch(Branch_Code) ON DELETE CASCADE ON UPDATE CASCADE,
	Website_URL VARCHAR(50) UNIQUE NOT NULL ,
	Brochure VARCHAR(500),
	Placement_Sec_Roll_No CHAR(10),
	Faculty_Advisor_Name VARCHAR(50) NOT NULL,
	Faculty_Advisor_Contact VARCHAR(20) NOT NULL,
	
	PRIMARY KEY (Program_Type, Branch_Code)
);


--------------------------------------------------------------------------
--
--	Student Table and Related Attribute Tables
--
---------------------------------------------------------------------------

CREATE TYPE _GENDER_ AS ENUM ('M', 'F');
CREATE TYPE _CATEGORY_ AS ENUM ('GEN', 'SC', 'ST', 'OBC');

CREATE TABLE Student(
	Roll_No CHAR(10) PRIMARY KEY,
	Name VARCHAR(50) NOT NULL,
	Dob DATE NOT NULL,
	Gender _GENDER_ NOT NULL,
	Institute_email VARCHAR(50) UNIQUE NOT NULL,
	Other_email VARCHAR(50) UNIQUE NOT NULL,
	Category _CATEGORY_ NOT NULL,
	JEE_GATE_AIR INT,
	CurAddr_Room_No VARCHAR(10) NOT NULL,
	CurAddr_Hostel INT NOT NULL REFERENCES Institute_Location(Location_Id) ON DELETE CASCADE ON UPDATE CASCADE,
	PerAddr_House_No VARCHAR(100),
	PerAddr_Street VARCHAR(100),
	PerAddr_City VARCHAR(30),
	PerAddr_State VARCHAR(30),
	PerAddr_Country_Code SMALLINT REFERENCES Country(Country_Code) ON DELETE CASCADE ON UPDATE CASCADE,
	PerAddr_Pincode VARCHAR(30),
	Dream_Company VARCHAR(50) NOT NULL,

	Program_Type _PROG_ NOT NULL,
	Branch_Code INT NOT NULL,
     	FOREIGN KEY (Program_Type, Branch_Code) REFERENCES Program(Program_Type, Branch_Code) ON DELETE CASCADE ON UPDATE CASCADE,

	CHECK(Roll_No ~ '^[\d]{7,10}$'),
	CHECK(Institute_email ~ '^[A-Za-z0-9._%-]+@iitg\.ernet\.in$'),
	CHECK(Other_email ~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$')

);

ALTER TABLE Program ADD FOREIGN KEY(Placement_Sec_Roll_No) REFERENCES Student(Roll_No) ON UPDATE CASCADE;

CREATE TABLE Photograph(
	Roll_No CHAR(10) REFERENCES Student(Roll_No) ON DELETE CASCADE ON UPDATE CASCADE,
	Image OID NOT NULL,
	PRIMARY KEY(Roll_No)
);


CREATE TABLE Student_Contact(
	Roll_No CHAR(10) REFERENCES Student(Roll_No) ON DELETE CASCADE ON UPDATE CASCADE,
	Country_Code SMALLINT REFERENCES Country(Country_Code) ON DELETE CASCADE ON UPDATE CASCADE,
	Telephone VARCHAR(20),
	PRIMARY KEY (Roll_No, Country_Code, Telephone),
	
	CHECK(Telephone ~ '^[\d]+$')
);


CREATE TABLE Student_Password(
	Roll_No CHAR(10) REFERENCES Student(Roll_No) ON DELETE CASCADE ON UPDATE CASCADE,
	Password VARCHAR(128) NOT NULL,
	PRIMARY KEY(Roll_No)
);


CREATE TABLE Prefered_Job(
	Roll_No CHAR(10) REFERENCES Student(Roll_No) ON DELETE CASCADE ON UPDATE CASCADE,
	Sector_Id INT NOT NULL REFERENCES Sector(Sector_Id) ON DELETE CASCADE ON UPDATE CASCADE,
	Priority INT NOT NULL,
	PRIMARY KEY (Roll_No, Sector_Id)
);

CREATE TYPE _LEVEL_ AS ENUM ('X_STD' , 'XII_STD', 'Undergraduate', 'Postgraduate', 'Docterate');

CREATE TABLE Academic_Details(
	Roll_No CHAR(10) REFERENCES Student(Roll_No) ON DELETE CASCADE ON UPDATE CASCADE,
	_Level _LEVEL_ NOT NULL,
	Board_Degree VARCHAR(10) NOT NULL,
	Stream VARCHAR(100) NOT NULL,
	Institute VARCHAR(100) NOT NULL,
	Year_of_Passing SMALLINT NOT NULL,
	Cgpa_Per NUMERIC(5, 2) NOT NULL,

	PRIMARY KEY (Roll_No, _Level),
	
	CHECK(Cgpa_Per <= 100 AND Cgpa_Per >= 0),
);


CREATE TABLE BTech_SPI(
	Roll_No CHAR(10) REFERENCES Student(Roll_No) ON DELETE CASCADE ON UPDATE CASCADE,
	CPI NUMERIC(4, 2) NOT NULL,
	Backlog_No INT NOT NULL DEFAULT 0,
	Sem1 NUMERIC(4, 2) NOT NULL,
	Sem2 NUMERIC(4, 2) NOT NULL,
	Sem3 NUMERIC(4, 2) NOT NULL,
	Sem4 NUMERIC(4, 2) NOT NULL,
	Sem5 NUMERIC(4, 2) NOT NULL,
	Sem6 NUMERIC(4, 2) NOT NULL,
	Sem7 NUMERIC(4, 2),

	PRIMARY KEY (Roll_No),
	
	CHECK(CPI <= 10 AND CPI >= 0),
	CHECK(Sem1 <= 10 AND Sem1 >= 0),
	CHECK(Sem2 <= 10 AND Sem2 >= 0),
	CHECK(Sem3 <= 10 AND Sem3 >= 0),
	CHECK(Sem4 <= 10 AND Sem4 >= 0),
	CHECK(Sem5 <= 10 AND Sem5 >= 0),
	CHECK(Sem6 <= 10 AND Sem6 >= 0),
	CHECK((Sem7 IS NULL) OR (Sem7 <= 10 AND Sem7 >= 0))
);


CREATE TABLE Master_SPI(
	Roll_No CHAR(10) REFERENCES Student(Roll_No) ON DELETE CASCADE ON UPDATE CASCADE,
	CPI NUMERIC(4, 2) NOT NULL,
	Backlog_No INT NOT NULL DEFAULT 0,
	Sem1 NUMERIC(4, 2) NOT NULL,
	Sem2 NUMERIC(4, 2) NOT NULL,
	Sem3 NUMERIC(4, 2),

	PRIMARY KEY (Roll_No),
	
	CHECK(CPI <= 10 AND CPI >= 0),
	CHECK(Sem1 <= 10 AND Sem1 >= 0),
	CHECK(Sem2 <= 10 AND Sem2 >= 0),
	CHECK((Sem3 IS NULL) OR (Sem3 <= 10 AND Sem3 >= 0))
);


CREATE TABLE Dual_Degree_SPI(
	Roll_No CHAR(10) REFERENCES Student(Roll_No) ON DELETE CASCADE ON UPDATE CASCADE,
	CPI NUMERIC(4, 2) NOT NULL,
	Backlog_No INT NOT NULL DEFAULT 0,
	Sem1 NUMERIC(4, 2) NOT NULL,
	Sem2 NUMERIC(4, 2) NOT NULL,
	Sem3 NUMERIC(4, 2) NOT NULL,
	Sem4 NUMERIC(4, 2) NOT NULL,
	Sem5 NUMERIC(4, 2) NOT NULL,
	Sem6 NUMERIC(4, 2) NOT NULL,
	Sem7 NUMERIC(4, 2) NOT NULL,
	Sem8 NUMERIC(4, 2) NOT NULL,
	Sem9 NUMERIC(4, 2),

	PRIMARY KEY (Roll_No),
	
	CHECK(CPI <= 10 AND CPI >= 0),
	CHECK(Sem1 <= 10 AND Sem1 >= 0),
	CHECK(Sem2 <= 10 AND Sem2 >= 0),
	CHECK(Sem3 <= 10 AND Sem3 >= 0),
	CHECK(Sem4 <= 10 AND Sem4 >= 0),
	CHECK(Sem5 <= 10 AND Sem5 >= 0),
	CHECK(Sem6 <= 10 AND Sem6 >= 0),
	CHECK(Sem7 <= 10 AND Sem7 >= 0),
	CHECK(Sem8 <= 10 AND Sem8 >= 0),
	CHECK((Sem9 IS NULL) OR (Sem9 <= 10 AND Sem9 >= 0))
);


---------------------------------------------------------------------------
--
--	Company Table
--
--	SQL Queries :
--		* Show all details of Company (incl. Pts. of Contact)
--
---------------------------------------------------------------------------

CREATE TABLE Nature_of_Company(
	Nature_Id INT PRIMARY KEY,
	Nature_Name VARCHAR(50) NOT NULL
);

CREATE TABLE Company(
	Company_Id INT PRIMARY KEY,
	Company_Name VARCHAR(50) NOT NULL,
	Nature_Id INT NOT NULL REFERENCES Nature_of_Company(Nature_Id) ON DELETE CASCADE ON UPDATE CASCADE,
	Sector_Id INT NOT NULL REFERENCES Sector(Sector_Id) ON DELETE CASCADE ON UPDATE CASCADE,
	Website_URL VARCHAR(50) UNIQUE NOT NULL,
	Company_email VARCHAR(50) UNIQUE NOT NULL,
	Company_Description VARCHAR(500),
	Priority INT,
	
	CHECK(Company_email ~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$')
	--Check Website URL in PHP
);

CREATE TABLE Comapny_Contact(
	Company_Id INT REFERENCES Company(Company_Id) ON DELETE CASCADE ON UPDATE CASCADE,
	Country_Code SMALLINT REFERENCES Country(Country_Code) ON DELETE CASCADE ON UPDATE CASCADE,
	Telephone VARCHAR(20),

	PRIMARY KEY (Company_Id, Country_Code, Telephone),
	
	CHECK(Telephone ~ '^[\d]+$')
);

CREATE TABLE Point_of_Contact(
	Company_Id INT REFERENCES Company(Company_Id) ON DELETE CASCADE ON UPDATE CASCADE,
	Roll_No CHAR(10) REFERENCES Student(Roll_No) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (Company_Id, Roll_No)
);


---------------------------------------------------------------------------
--
--	Position Table
--
--	SQL Queries :
--		* Show all details of Company (incl. Pts. of Contact)
--
---------------------------------------------------------------------------

-- Not Required: Convvertion done in PHP
--CREATE TABLE Denomination(
--	Denomination_Type CHAR(10) PRIMARY KEY,
--	Denomination_conversion_factor VARCHAR(50) NOT NULL
--	CHECK(Telephone ~ '^[\d]+$')
--);

CREATE TABLE Position(
	Position_Id INT PRIMARY KEY,
	Position_Name VARCHAR(50) NOT NULL,
	Place_of_Posting VARCHAR(50) NOT NULL,
	Profile_Description VARCHAR(50),
	Apply_Deadline TIMESTAMP,
	Min_CPI NUMERIC(4, 2) NOT NULL DEFAULT 0,
	Min_X NUMERIC(5, 2) NOT NULL DEFAULT 0,
	Min_XII NUMERIC(4, 2) NOT NULL DEFAULT 0,
	Number_of_offers INT NOT NULL DEFAULT 1,
	Bond_time INTERVAL NOT NULL DEFAULT '0',
	Accomodation_time INTERVAL NOT NULL DEFAULT '0' ,
	Ctc_Value NUMERIC(19,4) NOT NULL, -- Convertion to INR to be done in PHP
	-- Denomination_Type CHAR(10) NOT NULL REFERENCES Denomination(Denomination_Type),
	
	Company_Id INT NOT NULL REFERENCES Company(Company_Id) ON DELETE CASCADE ON UPDATE CASCADE,
	
	CHECK(Min_CPI <= 10 AND Min_CPI >= 0),
	CHECK(Min_X <= 100 AND Min_X >= 0),
	CHECK(Min_XII <= 100 AND Min_XII >= 0)
);


---------------------------------------------------------------------------
--
--	Room Table
--
--	SQL Queries :
--		* Give 	all details of a particular room_no.
--			(including inchagre and his contacts)
--
---------------------------------------------------------------------------

CREATE TABLE Room_Incharge(
	Incharge_Id INT PRIMARY KEY,
	Incharge_Name VARCHAR(50) NOT NULL
);


CREATE TABLE Room_Incharge_Contact(
	Incharge_Id INT REFERENCES Room_Incharge(Incharge_Id),
	Country_Code SMALLINT REFERENCES Country(Country_Code),
	Telephone VARCHAR(20) NOT NULL,
	PRIMARY KEY (Incharge_Id, Country_Code, Telephone),
	CHECK(Telephone ~ '^[\d]+$')
);


CREATE TABLE Room(
	Room_No VARCHAR(10) PRIMARY KEY,
	Location_Id INT NOT NULL REFERENCES Institute_Location(Location_Id) ON DELETE CASCADE ON UPDATE CASCADE,
	Incharge_Id INT NOT NULL REFERENCES Room_Incharge(Incharge_Id) ON DELETE CASCADE ON UPDATE CASCADE
);


---------------------------------------------------------------------------
--
--	Apply Relation Table
--
--	SQL Queries :
--		* Give 	all details of a particular room_no.
--			(including inchagre and his contacts)
--
---------------------------------------------------------------------------

CREATE TYPE _STATUS_ AS ENUM ('Apply' , 'Pending', 'Accepted', 'Rejected');

CREATE TABLE Apply(
	Roll_No CHAR(10) REFERENCES Student(Roll_No) ON DELETE CASCADE ON UPDATE CASCADE,
	Position_Id INT REFERENCES Position(Position_Id) ON DELETE CASCADE ON UPDATE CASCADE,
	Status _STATUS_ NOT NULL DEFAULT 'Apply',
	CV VARCHAR(500) NOT NULL ,
	
	PRIMARY KEY (Roll_No, Position_Id)
);

---------------------------------------------------------------------------
--
--	Position_For Relation Table
--
--	SQL Queries :
--		* Give 	all details of a particular room_no.
--			(including inchagre and his contacts)
--
---------------------------------------------------------------------------

CREATE TABLE Position_For(
	Position_Id INT REFERENCES Position(Position_Id) ON DELETE CASCADE ON UPDATE CASCADE,
	Program_Type _PROG_ NOT NULL,
	Branch_Code INT NOT NULL,
	
	PRIMARY KEY (Position_Id, Program_Type, Branch_Code),
     	FOREIGN KEY (Program_Type, Branch_Code) REFERENCES Program(Program_Type, Branch_Code) ON DELETE CASCADE ON UPDATE CASCADE

);


---------------------------------------------------------------------------
--
--	Schedule Relation Table
--
--	SQL Queries :
--		* Give 	all details of a particular room_no.
--			(including inchagre and his contacts)
--
---------------------------------------------------------------------------

CREATE TYPE _ROUND_ AS ENUM ('GD' , 'Written Test', 'Programming Test', 'Interview');

CREATE TABLE Schedule(
	Position_Id INT REFERENCES Position(Position_Id) ON DELETE CASCADE ON UPDATE CASCADE,
	Room_No VARCHAR(10) REFERENCES Room(Room_No) ON DELETE CASCADE ON UPDATE CASCADE,
	Round_Number INT NOT NULL,
	Round_Type _ROUND_ NOT NULL,
	StartTime TIMESTAMP,
	EndTime TIMESTAMP,

	PRIMARY KEY (Position_Id, Room_No, Round_Number)
);

