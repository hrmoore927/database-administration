-- Please write queries to solve the following questions.  After each question, please include
-- the SQL statement(s) and the query results. 

-- Remember - to paste the query results if you are using PuTTY as your terminal emulator then you simply
-- highlight the lines you wish to copy and then use the paste command in this document to place them here. 

--Here is an example of how that will look: 

--Example Question: Find the details of any project with the word “urn” anywhere in its name.

SELECT *
FROM Project
WHERE projName LIKE '%urn%';

+--------+----------+-----------+-----------+------------+-----------------------+
| projNo | projName | projMgrId | budget    | startDate  | expectedDurationWeeks |
+--------+----------+-----------+-----------+------------+-----------------------+
|   1005 | Saturn   |       101 | 400000.00 | 2014-06-01 |                    35 |
+--------+----------+-----------+-----------+------------+-----------------------+
1 row in set (0.00 sec)

--***************************************************************************************************************

-- 1. Get the names of all workers in the Accounting department.

MariaDB [Projects_moore]> SELECT lastName, firstName FROM Worker WHERE deptName LIKE 'Accounting';
+----------+-----------+
| lastName | firstName |
+----------+-----------+
| Smith    | Tom       |
| Jones    | Mary      |
| Burns    | Jane      |
+----------+-----------+
3 rows in set (0.00 sec)

--2. Get an alphabetical list of names of all workers assigned to project 1001.

MariaDB [Projects_moore]> SELECT lastName, firstName FROM Worker
    -> JOIN Assign USING (empId)
    -> WHERE projNo = 1001
    -> ORDER BY lastName;
+----------+-----------+
| lastName | firstName |
+----------+-----------+
| Burns    | Jane      |
| Chin     | Amanda    |
| Jones    | Mary      |
| Smith    | Tom       |
+----------+-----------+
4 rows in set (0.00 sec)

--3. Get the name of the employee in the Research department who has the lowest salary.

MariaDB [Projects_moore]> SELECT lastName, firstName, salary FROM Worker
    -> WHERE deptName LIKE 'Research'
    -> ORDER BY salary ASC LIMIT 1;
+----------+-----------+----------+
| lastName | firstName | salary   |
+----------+-----------+----------+
| Chin     | Amanda    | 60000.00 |
+----------+-----------+----------+
1 row in set (0.00 sec)

--4. Get details of the project with the highest budget.

MariaDB [Projects_moore]> SELECT * FROM Project
    -> ORDER BY budget DESC LIMIT 1;
+--------+----------+-----------+-----------+------------+-----------------------+
| projNo | projName | projMgrId | budget    | startDate  | expectedDurationWeeks |
+--------+----------+-----------+-----------+------------+-----------------------+
|   1025 | Neptune  |       110 | 600000.00 | 2015-02-01 |                    45 |
+--------+----------+-----------+-----------+------------+-----------------------+
1 row in set (0.00 sec)

--5. Get the names and departments of all workers on project 1019.

MariaDB [Projects_moore]> SELECT lastName, firstName, deptName FROM Worker
    -> JOIN Assign USING (empId) WHERE projNo = 1019;
+----------+-----------+----------+
| lastName | firstName | deptName |
+----------+-----------+----------+
| Burns    | Michael   | Research |
| Chin     | Amanda    | Research |
+----------+-----------+----------+
2 rows in set (0.00 sec)

--6. Get an alphabetical list of names and corresponding ratings of all workers 
--   on any project which is managed by Michael Burns using JOIN 

MariaDB [Projects_moore]> SELECT lastName, firstName, rating FROM Worker
    -> JOIN Assign USING (empId)
    -> JOIN Project USING (projNo)
    -> WHERE projMgrId = 110
    -> ORDER BY lastName;
+----------+-----------+--------+
| lastName | firstName | rating |
+----------+-----------+--------+
| Burns    | Michael   |      5 |
| Burns    | Michael   |   NULL |
| Burns    | Michael   |   NULL |
| Chin     | Amanda    |      4 |
+----------+-----------+--------+
4 rows in set (0.00 sec)

--7. Get an alphabetical list of names and corresponding ratings of all workers 
--   on any project which is managed by Michael Burns using subqueries.

MariaDB [Projects_moore]> SELECT lastName, firstName, rating
    -> FROM Worker JOIN Assign USING (empId)
    -> JOIN Project USING (projNo)
    -> WHERE projMgrId IN
    -> (SELECT projMgrId FROM Project WHERE projMgrId = 110);
+----------+-----------+--------+
| lastName | firstName | rating |
+----------+-----------+--------+
| Burns    | Michael   |      5 |
| Chin     | Amanda    |      4 |
| Burns    | Michael   |   NULL |
| Burns    | Michael   |   NULL |
+----------+-----------+--------+
4 rows in set (0.00 sec)

--8. Create a view that has project number and manager name of each project, 
--    along with the IDs and names of all workers assigned to it.

MariaDB [Projects_moore]> CREATE VIEW projInfo AS
    -> SELECT projNo, projMgrId, lastName, firstName, empId
    -> FROM Project JOIN Assign USING (projNo)
    -> JOIN Worker USING (empId);
Query OK, 0 rows affected (0.00 sec)

--9. Using the view created in Exercise 8, find the project number and project manager 
--   of all projects to which employee 110 is assigned.

MariaDB [Projects_moore]> SELECT projNo, CONCAT(lastName, ', ', firstName) AS 'Project Manager' FROM projInfo
    -> WHERE empId = 110;
+--------+-----------------+
| projNo | Project Manager |
+--------+-----------------+
|   1019 | Burns, Michael  |
|   1025 | Burns, Michael  |
|   1030 | Burns, Michael  |
+--------+-----------------+
3 rows in set (0.00 sec)

--10. Add a new worker named Jack Smith with ID of 1999 to the Research department.

MariaDB [Projects_moore]> INSERT INTO Worker (lastName, firstName, empId, deptName) VALUES
    -> ('Smith', 'Jack', 1999, 'Research');
Query OK, 1 row affected (0.01 sec)

--11. Change the hours that employee 110 is assigned to project 1019 from 20 to 10.

MariaDB [Projects_moore]> UPDATE Assign SET hoursAssigned = 20
    -> WHERE empId = 110 AND projNo = 1019;
Query OK, 0 rows affected (0.00 sec)
Rows matched: 1  Changed: 0  Warnings: 0

--12. For all projects starting after May 1, 2004, find the project number, the ID's, and names 
--    of all workers assigned to them.

MariaDB [Projects_moore]> SELECT projNo, empId, lastName, firstName FROM Project
    -> JOIN Assign USING (projNo) JOIN Worker USING (empId)
    -> WHERE startDate > '2004-05-01';
+--------+-------+----------+-----------+
| projNo | empId | lastName | firstName |
+--------+-------+----------+-----------+
|   1001 |   101 | Smith    | Tom       |
|   1001 |   103 | Jones    | Mary      |
|   1001 |   105 | Burns    | Jane      |
|   1001 |   115 | Chin     | Amanda    |
|   1005 |   103 | Jones    | Mary      |
|   1019 |   110 | Burns    | Michael   |
|   1019 |   115 | Chin     | Amanda    |
|   1025 |   110 | Burns    | Michael   |
|   1030 |   110 | Burns    | Michael   |
+--------+-------+----------+-----------+
9 rows in set (0.00 sec)

--13. For each project, list the project number and how many workers are assigned to it.

MariaDB [Projects_moore]> SELECT projNo, COUNT(empId)
    -> FROM Project JOIN Assign USING (projNo)
    -> GROUP BY projNo;
+--------+--------------+
| projNo | COUNT(empId) |
+--------+--------------+
|   1001 |            4 |
|   1005 |            1 |
|   1019 |            2 |
|   1025 |            1 |
|   1030 |            1 |
+--------+--------------+
5 rows in set (0.00 sec)

--14. Find the employee names and department manager names of all workers who are not assigned to any project.

MariaDB [Projects_moore]> SELECT lastName, firstName
    -> FROM Worker w JOIN Dept d USING (deptName)
    -> WHERE NOT EXISTS (SELECT empId FROM Assign a
    -> WHERE a.empId = w.empId);
+----------+-----------+
| lastName | firstName |
+----------+-----------+
| Smith    | Jack      |
+----------+-----------+
1 row in set (0.00 sec)

--15. Get a list of project numbers and names and starting dates of all projects that have the same starting date.

MariaDB [Projects_moore]> SELECT p1.projNo, p1.projName, p1.startDate, p2.projNo, p2.projName
    -> FROM Project p1 JOIN Project p2
    -> ON p1.startDate=p2.startDate
    -> AND p1.projNo<p2.projNo;
Empty set (0.00 sec)

--16. Get the employee ID and project number of all employees who have no ratings.

MariaDB [Projects_moore]> SELECT empId, projNo FROM Assign
    -> WHERE rating IS NULL;
+-------+--------+
| empId | projNo |
+-------+--------+
|   101 |   1001 |
|   105 |   1001 |
|   103 |   1005 |
|   110 |   1025 |
|   110 |   1030 |
+-------+--------+
5 rows in set (0.01 sec)

--17. Assuming that salary now contains annual salary, find each worker's ID, name, and monthly salary.

MariaDB [Projects_moore]> SELECT empId, lastName, firstName, ROUND((salary / 12), 2) AS monthlySalary
    -> FROM Worker;
+-------+----------+-----------+---------------+
| empId | lastName | firstName | monthlySalary |
+-------+----------+-----------+---------------+
|   101 | Smith    | Tom       | 4166.67       |
|   103 | Jones    | Mary      | 4000.00       |
|   105 | Burns    | Jane      | 3250.00       |
|   110 | Burns    | Michael   | 5833.33       |
|   115 | Chin     | Amanda    | 5000.00       |
|  1999 | Smith    | Jack      | NULL          |
+-------+----------+-----------+---------------+
6 rows in set (0.00 sec)
