CREATE DATABASE Projects_moore; 
use Projects_moore;

CREATE TABLE Worker (
empId INT PRIMARY KEY, 
lastName VARCHAR(20) NOT NULL,
firstName VARCHAR(15) NOT NULL, 
deptName VARCHAR(15), 
birthDate DATE, 
hireDate DATE, 
salary DECIMAL(8,2))
ENGINE=INNODB;

CREATE TABLE Dept(
deptName VARCHAR(15),
mgrId INT,
CONSTRAINT Dept_deptName_pk PRIMARY KEY (deptName),
CONSTRAINT Dept_mgrId_fk FOREIGN KEY (mgrId) REFERENCES Worker(empId) ON DELETE SET NULL);

ALTER TABLE Worker ADD CONSTRAINT Worker_deptName_fk FOREIGN KEY (deptName) REFERENCES Dept(deptName) ON DELETE SET NULL;

CREATE TABLE Project (
projNo INT, 
projName VARCHAR(20), 
projMgrId INT,
budget DECIMAL(8,2), 
startDate DATE, 
expectedDurationWeeks INT,
CONSTRAINT Project_projNo_pk PRIMARY KEY (projNo));

ALTER TABLE Project ADD CONSTRAINT Project_projMgrId_fk FOREIGN KEY(projMgrId) REFERENCES Worker(empId) ON DELETE SET NULL;
	
CREATE TABLE Assign (
projNo INT, 
empId INT, 
hoursAssigned INT, 
rating TINYINT,
CONSTRAINT Assign_projNo_empId_pk PRIMARY KEY (projNo, empId),
CONSTRAINT Assign_projNo_fk FOREIGN KEY(projNo) REFERENCES Project(projNo) ON DELETE CASCADE,
CONSTRAINT Assign_empId_fk FOREIGN KEY(empId) REFERENCES Worker(empId) ON DELETE CASCADE);

INSERT INTO Dept VALUES ('Accounting',null);
INSERT INTO Dept VALUES ('Research',null);

INSERT INTO Worker VALUES(101,'Smith','Tom', 'Accounting', '1970-02-01', '1993-06-06',50000);
INSERT INTO Worker VALUES(103,'Jones','Mary','Accounting', '1975-06-15', '2005-09-20',48000);
INSERT INTO Worker VALUES(105,'Burns','Jane','Accounting', '1980-09-21', '2000-06-12',39000);
INSERT INTO Worker VALUES(110,'Burns','Michael', 'Research', '1977-04-05', '2010-09-10',70000);
INSERT INTO Worker VALUES(115,'Chin','Amanda', 'Research', '1980-09-22', '2014-06-19',60000);

UPDATE Dept SET mgrId = 101 WHERE deptName = 'Accounting';
UPDATE Dept SET mgrId = 110 WHERE deptName = 'Research';	

INSERT INTO Project VALUES (1001, 'Jupiter', 101, 300000, '2014-02-01', 50);
INSERT INTO Project VALUES (1005, 'Saturn', 101, 400000, '2014-06-01', 35);
INSERT INTO Project VALUES (1019, 'Mercury', 110, 350000, '2014-02-15', 40);
INSERT INTO Project VALUES (1025, 'Neptune', 110, 600000, '2015-02-01', 45);
INSERT INTO Project VALUES (1030, 'Pluto', 110, 380000, '2014-09-15', 50);

INSERT INTO Assign VALUES(1001, 101, 30,null);
INSERT INTO Assign VALUES(1001, 103, 20,5);
INSERT INTO Assign VALUES(1005, 103, 20,null);
INSERT INTO Assign VALUES(1001, 105, 30,null);
INSERT INTO Assign VALUES(1001, 115, 20,4);
INSERT INTO Assign VALUES(1019, 110, 20,5);
INSERT INTO Assign VALUES(1019, 115, 10,4);
INSERT INTO Assign VALUES(1025, 110, 10,null);
INSERT INTO Assign VALUES(1030, 110, 10,null);