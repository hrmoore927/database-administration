-- This exercise will work with the Projects database that you have been using. 

-- These are the steps to be accomplished
-- 1. Use an ALTER command to add a field called numEmployeesAssigned (INT) to the Project table. 
-- 2. Use the UPDATE command to insert values into the field to correspond to the current information in the Assign table.
--       NOTE: This means that you will use an aggregate function to get the information from the Assign table. 
-- 3. Then write a trigger that will update the field correctly whenever an assignment is made, dropped, or updated. 
--      The easiest way to accomplish this will be to add 3 triggers ... one for AFTER INSERT, one for AFTER DELETE, and
--      one for AFTER UPDATE.   

-- Here are some resources to help you remember how to write a trigger:  
-- https://dev.mysql.com/doc/refman/5.7/en/triggers.html
-- Databases Illuminated  Page 216 - 221  (this is geared for Oracle and not MySQL)
-- http://www.mysqltutorial.org/mysql-triggers.aspx
-- https://www.sitepoint.com/how-to-create-mysql-triggers/
-- https://www.w3resource.com/mysql/mysql-triggers.php

-- Please number and include the code here for the 
-- 1) ALTER

MariaDB [Projects_moore]> ALTER TABLE Project
    -> ADD numEmployeesAssigned INT;
Query OK, 0 rows affected (0.04 sec)
Records: 0  Duplicates: 0  Warnings: 0

-- 1a) desc Project (to show the added field) 

MariaDB [Projects_moore]> desc Project;
+-----------------------+--------------+------+-----+---------+-------+
| Field                 | Type         | Null | Key | Default | Extra |
+-----------------------+--------------+------+-----+---------+-------+
| projNo                | int(11)      | NO   | PRI | NULL    |       |
| projName              | varchar(20)  | YES  |     | NULL    |       |
| projMgrId             | int(11)      | YES  | MUL | NULL    |       |
| budget                | decimal(8,2) | YES  |     | NULL    |       |
| startDate             | date         | YES  |     | NULL    |       |
| expectedDurationWeeks | int(11)      | YES  |     | NULL    |       |
| numEmployeesAssigned  | int(11)      | YES  |     | NULL    |       |
+-----------------------+--------------+------+-----+---------+-------+
7 rows in set (0.00 sec)

-- 2) UPDATE

MariaDB [Projects_moore]> UPDATE Project p
    -> SET numEmployeesAssigned =
    -> (SELECT COUNT(empId)
    -> FROM Assign a
    -> WHERE p.projNo = a.projNo
    -> GROUP BY projNo);
Query OK, 5 rows affected (0.00 sec)
Rows matched: 5  Changed: 5  Warnings: 0

-- 2a) SELECT * from Project;  (to show the updated data) 

MariaDB [Projects_moore]> SELECT * FROM Project;
+--------+----------+-----------+-----------+------------+-----------------------+----------------------+
| projNo | projName | projMgrId | budget    | startDate  | expectedDurationWeeks | numEmployeesAssigned |
+--------+----------+-----------+-----------+------------+-----------------------+----------------------+
|   1001 | Jupiter  |       101 | 300000.00 | 2014-02-01 |                    50 |                    4 |
|   1005 | Saturn   |       101 | 400000.00 | 2014-06-01 |                    35 |                    1 |
|   1019 | Mercury  |       110 | 350000.00 | 2014-02-15 |                    40 |                    2 |
|   1025 | Neptune  |       110 | 600000.00 | 2015-02-01 |                    45 |                    1 |
|   1030 | Pluto    |       110 | 380000.00 | 2014-09-15 |                    50 |                    1 |
+--------+----------+-----------+-----------+------------+-----------------------+----------------------+
5 rows in set (0.00 sec)

-- 3) CREATE TRIGGER(s) statement.
-- 3a) Also you should have code to test the trigger(s) once they are created, so you should show the information before
-- and after if appropriate.

--***EXAMPLE 1
--The following SQL statement adds a new Assign record which should kick off the trigger for insert and add 1 to the 
--numEmployeesAssigned column for project 1030.  You should select projNO, numEmployeesAssigned from Project before and after
--the insert statement to ensure that it works properly.   
INSERT INTO Assign VALUES('1030', '103', '10', NULL);

-- BEFORE THE TRIGGER
MariaDB [Projects_moore]> SELECT projNo, numEmployeesAssigned FROM Project;
+--------+----------------------+
| projNo | numEmployeesAssigned |
+--------+----------------------+
|   1001 |                    4 |
|   1005 |                    1 |
|   1019 |                    2 |
|   1025 |                    1 |
|   1030 |                    1 |
+--------+----------------------+
5 rows in set (0.00 sec)

-- TRIGGER
MariaDB [Projects_moore]> DELIMITER $
MariaDB [Projects_moore]> CREATE TRIGGER after_assign_insert
    -> AFTER INSERT ON Assign
    -> FOR EACH ROW
    -> BEGIN
    -> UPDATE Project
    -> SET numEmployeesAssigned = numEmployeesAssigned + 1
    -> WHERE projNo = NEW.projNo;
    -> END $
Query OK, 0 rows affected (0.00 sec)

-- AFTER THE TRIGGER
MariaDB [Projects_moore]> Select projNo, numEmployeesAssigned FROM Project;
+--------+----------------------+
| projNo | numEmployeesAssigned |
+--------+----------------------+
|   1001 |                    4 |
|   1005 |                    1 |
|   1019 |                    2 |
|   1025 |                    1 |
|   1030 |                    2 |
+--------+----------------------+
5 rows in set (0.01 sec)

--***EXAMPLE 2
--You can now delete the record that you just added in Example 1.  That should kick off the trigger for delete and subtract
--1  from the numEmployeesAssigned column for project 1030.  You should 'SELECT projNO, numEmployeesAssigned from Project' before 
--and after the insert statement to ensure that it works properly.   
DELETE from Assign WHERE projNo = '1030' and empID = '103';

-- BEFORE THE TRIGGER
MariaDB [Projects_moore]> Select projNo, numEmployeesAssigned FROM Project;
+--------+----------------------+
| projNo | numEmployeesAssigned |
+--------+----------------------+
|   1001 |                    4 |
|   1005 |                    1 |
|   1019 |                    2 |
|   1025 |                    1 |
|   1030 |                    2 |
+--------+----------------------+
5 rows in set (0.01 sec)

-- TRIGGER
MariaDB [Projects_moore]> DELIMITER $
MariaDB [Projects_moore]> CREATE TRIGGER after_assign_delete
    -> AFTER DELETE ON Assign
    -> FOR EACH ROW
    -> BEGIN
    -> UPDATE Project
    -> SET numEmployeesAssigned = numEmployeesAssigned - 1
    -> WHERE projNo = OLD.projNo;
    -> END $
Query OK, 0 rows affected (0.00 sec)

-- AFTER THE TRIGGER
MariaDB [Projects_moore]> Select projNo, numEmployeesAssigned FROM Project;
+--------+----------------------+
| projNo | numEmployeesAssigned |
+--------+----------------------+
|   1001 |                    4 |
|   1005 |                    1 |
|   1019 |                    2 |
|   1025 |                    1 |
|   1030 |                    1 |
+--------+----------------------+
5 rows in set (0.00 sec)

--***EXAMPLE 3 
--To test the update trigger, you need to pick a record that you can change.  I added the same test record from example 1 to 
--the file for my test case. 
INSERT INTO Assign VALUES('1030', '103', '10', NULL);
--Then run the 'SELECT projNO, numEmployeesAssigned from Project' to see what the values were to start with. 
--Then run your update statement to change the project number on that record:

MariaDB [Projects_moore]> Select projNo, numEmployeesAssigned FROM Project;
+--------+----------------------+
| projNo | numEmployeesAssigned |
+--------+----------------------+
|   1001 |                    4 |
|   1005 |                    1 |
|   1019 |                    2 |
|   1025 |                    1 |
|   1030 |                    2 |
+--------+----------------------+
5 rows in set (0.00 sec)

MariaDB [Projects_moore]> DELIMITER $
MariaDB [Projects_moore]> CREATE TRIGGER after_assign_update
    -> AFTER UPDATE ON Assign
    -> FOR EACH ROW BEGIN
    -> IF projNo = NEW.projNo THEN
    -> UPDATE Project
    -> SET numEmployeesAssigned = numEmployeesAssigned + 1
    -> WHERE projNo = NEW.projNo;
    -> END IF ;
    -> END $
Query OK, 0 rows affected (0.01 sec)

-- I spent days trying to figure this out and could not get it. I couldn't find any help after many different google searches and also kept getting an error that projNo was an unknown column even though I can clearly see that it exists and I wasn't typing it incorrectly. 

UPDATE Assign set projNo = '1025' where projNo = '1030' and empId = '103';
--Now run the 'SELECT projNO, numEmployeesAssigned from Project' to see what the values are currently.  
--NOTE:  If you discover that your trigger does not update properly, you can run the update statement in #3 to set correct the 
--values on numEmployeesAssigned.  Just remember that if you need to do that, be sure to change your update statement before
--you execute it again because the data will be changed.  You can simply reverse the ProjNo's like this.
UPDATE Assign set ProjNo = '1030' where ProjNo ='1025' and empID = '103'; 

--REMEMBER that at any point in time you can source your original SQL file that creates and poplulates this entire database
--should that become necessary. 

