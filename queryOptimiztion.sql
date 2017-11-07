/* This is my original query without optimization. I'm not sure why I'm only getting 10 rows but just wanted to show that I am getting the same results with optimization that I started with */

MariaDB [heatherrmoore]> SELECT d1.word, d2.word, d3.word
    -> FROM dict AS d1 JOIN dict AS d2
    -> ON d1.word=reverse(d2.word)
    -> JOIN dict AS d3
    -> ON d1.word=right(d3.word,6)
    -> WHERE length(d1.word)=6 AND length(d3.word)>6;
+--------+--------+-------------+
| word   | word   | word        |
+--------+--------+-------------+
| dialer | relaid | autodialer  |
| warder | redraw | awarder     |
| warder | redraw | forwarder   |
| repaid | diaper | prepaid     |
| redder | redder | shredder    |
| spoons | snoops | tablespoons |
| spoons | snoops | teaspoons   |
| drawer | reward | top-drawer  |
| reined | denier | unreined    |
| repaid | diaper | unrepaid    |
+--------+--------+-------------+
10 rows in set (1 min 21.04 sec)

/* Change #1
    Added a length condition for d2.word in the where clause
*/
MariaDB [heatherrmoore]> SELECT d1.word, d2.word, d3.word
    -> FROM dict AS d1 JOIN dict AS d2
    -> ON d1.word=reverse(d2.word)
    -> JOIN dict AS d3
    -> ON d1.word=right(d3.word,6)
    -> WHERE length(d1.word)=6 AND length(d2.word)=6 AND length(d3.word)>6;
+--------+--------+-------------+
| word   | word   | word        |
+--------+--------+-------------+
| dialer | relaid | autodialer  |
| warder | redraw | awarder     |
| warder | redraw | forwarder   |
| repaid | diaper | prepaid     |
| redder | redder | shredder    |
| spoons | snoops | tablespoons |
| spoons | snoops | teaspoons   |
| drawer | reward | top-drawer  |
| reined | denier | unreined    |
| repaid | diaper | unrepaid    |
+--------+--------+-------------+
10 rows in set (8.85 sec)

/* Change #2
    Created an index for the word field
*/
MariaDB [heatherrmoore]> CREATE INDEX words ON dict (word);
Query OK, 0 rows affected (0.50 sec)                
Records: 0  Duplicates: 0  Warnings: 0

MariaDB [heatherrmoore]> SELECT d1.word, d2.word, d3.word
    -> FROM dict AS d1 JOIN dict AS d2
    -> ON d1.word=reverse(d2.word)
    -> JOIN dict AS d3
    -> ON d1.word=right(d3.word,6)
    -> WHERE length(d1.word)=6 AND length(d2.word)=6 AND length(d3.word)>6;
+--------+--------+-------------+
| word   | word   | word        |
+--------+--------+-------------+
| dialer | relaid | autodialer  |
| warder | redraw | awarder     |
| warder | redraw | forwarder   |
| repaid | diaper | prepaid     |
| redder | redder | shredder    |
| spoons | snoops | tablespoons |
| spoons | snoops | teaspoons   |
| drawer | reward | top-drawer  |
| reined | denier | unreined    |
| repaid | diaper | unrepaid    |
+--------+--------+-------------+
10 rows in set (0.30 sec)

/* The first change I made was to add a condition in the WHERE clause to limit the length of d2.word to 6. It would have to be the same length as d1.word since that one is equal to the reverse of d2.word. That took the time down to almost 8.85 seconds.

The second change was adding an index on word. That took the time down to .3 seconds. The index really helps speed up the query. For searching through over 76,000 items, I think that's pretty fast. */