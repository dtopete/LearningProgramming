#set align(center)
= CS166 Lab2 Introduction to SQL and CS166 Server

#set align(left)
Danny Topete,
dtope004,
CS166 - Spring 2026,
April 10


`dtope004_lab2.sql` below:
```sql
DROP TABLE IF EXISTS Students;

CREATE TABLE Students (SID numeric (9,0), Name text, Grade float);
INSERT INTO Students VALUES (860507041, 'John Anderson', 3.67);
INSERT INTO Students VALUES (860309067, 'Tom Kamber', 3.12);

SELECT SID, Name, Grade FROM Students WHERE SID = 860507041;

INSERT INTO Students VALUES (860704039, 'George Haggerty', 3.67);

SELECT SID, Name, Grade FROM Students WHERE grade = 3.67;

DROP TABLE IF EXISTS Students;

```

== Related output
#figure(
  image("fullOutput.png"),
  caption: [
   Output from following lab manual 
  ],
)

#figure(
  image("sqloutput.png"),
  caption: [
    sql output from above code snippet `dtope004_lab2.sql`
  ],
)
