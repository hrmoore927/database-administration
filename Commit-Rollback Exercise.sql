
-- We are going to use the START TRANSACTION command to mimic what would happen if your 
-- code was enbeded in a program that accessed a database.  Each connection starts a transaction,
-- exactly like when we login and connect and simply use the command line.
-- With START TRANSACTION , autocommit remains disabled until you end the transaction with COMMIT 
-- or ROLLBACK.  The autocommit mode then reverts to its previous state.  You may also issue a SAVEPOINT 
-- (called a checkpoint with some other DBMS's).  Each time that happens the point is saved so that should
-- should you encounter an error condition, you may issue a ROLLBACK to the SAVEPOINT of choice rather than
-- rolling back the entire transaction. 


-- Using the database that is the same as your userid (mine is brendahmcfarland) ...
-- this is the database where you created the dict table. 

-- I am giving you the SQL statements here so that you do not have to create them,
-- you can merely copy and paste them to the command line to save you time.... trying 
-- to avoid timing out of our session. 

-- create a table with two columns 
CREATE TABLE test(key_field char(2), text_field varchar(100));

-- insert three records into that table, I put a delete here so that if I need to rerun
-- I don't have to remember to delete the records first
DELETE from test;
INSERT INTO test values ('1', 'this is record 1');
INSERT INTO test values ('2', 'this is record 2');
INSERT INTO test values ('3', 'this is record 3');

-- now select the records you have in your table 
SELECT * FROM test; 
-- do they look correct? 
-- they should look like this ....
-- +-----------+----------------------------+
-- | key_field | text_field                 |
-- +-----------+----------------------------+
-- | 1         | this is record 1           |
-- | 2         | this is record 2           |
-- | 3         | this is record 3           |
-- +-----------+----------------------------+
-- 3 rows in set (0.00 sec)

-- now lets update one of the descriptions and do it in a transaction so we 
-- have a choice of committing it or rolling it back.

START TRANSACTION;
UPDATE test SET text_field = 'this is record 2 - updated'
WHERE key_field = '2';
COMMIT;

-- now let's see what the record looks like 
SELECT * FROM test; 
-- do they look correct? 
-- they should look like this ....
-- +-----------+----------------------------+
-- | key_field | text_field                 |
-- +-----------+----------------------------+
-- | 1         | this is record 1           |
-- | 2         | this is record 2 - updated |
-- | 3         | this is record 3           |
-- +-----------+----------------------------+
-- 3 rows in set (0.00 sec)


-- what if we issue another update and this time issue a rollback ..
START TRANSACTION;
UPDATE test SET text_field = 'this is record 3 updated'
WHERE key_field = '3';
ROLLBACK;

SELECT * from test; 
-- do they look correct? 
-- they should look like this ....
-- +-----------+----------------------------+
-- | key_field | text_field                 |
-- +-----------+----------------------------+
-- | 1         | this is record 1           |
-- | 2         | this is record 2 - updated |
-- | 3         | this is record 3           |
-- +-----------+----------------------------+
-- 3 rows in set (0.00 sec)
-- the record was not updated becuase you issued a rollback command. 


-- now let's mimic what might happen if two users were online at the same time.
--  open a second session so that you have two windows connected to the server
--  at the same time.  
-- place these so that they make sense to you, I will refer to them as LEFT window
--  and RIGHT window. 

-- in the LEFT window, let's start a transaction and update a record, but don't 
--  commit yet 
START TRANSACTION;
UPDATE test SET text_field = 'this is record 3 - updated LEFT'
WHERE key_field = '3';

-- in the RIGHT window, let's start a transction and update the same record, and 
-- also do not commit yet.
start transaction;
update test set text_field = 'this is record 3 - updated RIGHT'
WHERE key_field = '3';

-- see how the RIGHT window is waiting?  It wants to lock the record for update, 
-- but the LEFT window has it locked. 

-- so let's commit the LEFT window
COMMIT;

-- see how the right window now completes? 

-- in the LEFT window 
SELECT * from test; 
-- in the RIGHT window
SELECT * from test; 
-- why are they different? 


-- now rollback the RIGHT window
ROLLBACK;

-- select from both sessions 
-- in the LEFT window 
SELECT * from test; 
-- in the RIGHT window
SELECT * from test; 
-- why are they now the same?


-- now let's try something else ... delete the existing records
DELETE from test;

-- add these new records 
INSERT INTO test values ('1', 'this is record 1');
INSERT INTO test values ('2', 'this is record 2');
INSERT INTO test values ('3', 'this is record 3');
INSERT INTO test values ('4', 'this is record 4');
INSERT INTO test values ('5', 'this is record 5');
INSERT INTO test values ('6', 'this is record 6');

-- update all records with a savepoint after each one 
-- rollback to some checkpoint, I chose 3 arbitrarily
--committ to that everthing is saved and your transaction ends
START TRANSACTION;
UPDATE test SET text_field = 'this is record 1 updated' WHERE key_field = '1';
SAVEPOINT checkpoint1;
UPDATE test SET text_field = 'this is record 2 updated' WHERE key_field = '2';
SAVEPOINT checkpoint2;
UPDATE test SET text_field = 'this is record 3 updated' WHERE key_field = '3';
SAVEPOINT checkpoint3;
UPDATE test SET text_field = 'this is record 4 updated' WHERE key_field = '4';
SAVEPOINT checkpoint4;
UPDATE test SET text_field = 'this is record 5 updated' WHERE key_field = '5';
SAVEPOINT checkpoint5;
UPDATE test SET text_field = 'this is record 6 updated' WHERE key_field = '6';
SAVEPOINT checkpoint6;
ROLLBACK to checkpoint3;
COMMIT;

-- select all the records
SELECT * from test;
-- explain what you see 














