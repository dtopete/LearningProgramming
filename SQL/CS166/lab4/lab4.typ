#set align(center)
= CS166 Lab4 Assignment \ The Relational Algebra \& SQL


#set align(left)
Danny Topete,
dtope004

CS166 - Spring 2026

April 24, 2026

Assuming the following relations:
```SQL
BOOKS(DocID, Title, Publisher, Year)
STUDENTS(StId, StName, Major, Age)
AUTHORS(AName, Address)
borrows(DocId, StId, Date)
has-writter(DocId, AName)
describes(DocId, Keyword)
```

Write the follwing quiries in relational algebra and the equivalent SQL Queries.

+ List the year and title of each book
  - Relational Algebra: $pi$#sub[Year, Title] (BOOKS)
  - SQL: `SELECT B.Year, B.Title 
  FROM BOOKS B`
+ List all information about students whose major is CS
  - Relational Algebra: $sigma$#sub[Major = 'CS'] (STUDENTS)
  - SQL: `SELECT * 
  FROM STUDENTS S
  WHERE S.Major = 'CS'`
3. List all students with books they can borrow
  - Relational Algebra: STUDENTS $join$ borrows
  - SQL: `SELECT * 
  FROM STUDENTS S 
  JOIN borrows B 
  WHERE S.StId = B.StId`
4. List all books published by McGraw-Hill before 1990
  - Relational Algebra: $sigma$#sub[Publisher = McGraw-Hill'] AND $sigma$#sub[Year < 1990] (BOOKS)
  - SQL: `SELECT * 
  FROM BOOKS B 
  WHERE B.Publisher = 'McGraw-Hill' AND B.Year < 1990`
5. List the name of those authors who are living in Davis
  - Relational Algebra: $pi$#sub[AName] ($sigma$#sub[Address = 'Davis'] (AUTHORS))
  - SQL: `SELECT A.AName 
  FROM AUTHORS A
  WHERE A.Address = 'Davis'`
6. List the name of students who are older than 30 and who are not studying CS
  - Relational Algebra: $pi$#sub[StName] ($sigma$#sub[Age > 30] AND $sigma$#sub[Major != 'CS'] (STUDENTS))
  - SQL: `SELECT S.StName 
  FROM STUDENTS S 
  WHERE S.Age > 30 AND S.Major != 'CS'`

#pagebreak()
7. Rename AName in the relation AUTHORS to Name
  - Relational Algebra: $rho$#sub[Name/AName] (AUTHORS)
  - SQL: `ALTER TABLE AUTHORS 
  RENAME COLUMN AName TO Name`
8. List the names of all students who have borrowed a book and who are CS majors
  - Relational Algebra: $pi$#sub[StName] ($sigma$#sub[Major] = #sub['CS'] (STUDENTS) $join$ borrows)
  - SQL: `SELECT DISTINCT S.StName 
  FROM STUDENTS S 
  JOIN borrows B 
  WHERE S.StId = B.StId AND S.Major = 'CS'`
9. List the title of books written by the author “Jones”
  - Relational Algebra: $pi$#sub[Title] ($sigma$#sub[AName] = #sub['Jones'] (AUTHORS) $join$ has-writter $join$ BOOKS)
  - SQL: `SELECT B.Title 
  FROM BOOKS B
  JOIN has-writter HW WHERE B.DocID = HW.DocId
  JOIN AUTHORS A WHERE HW.AName = A.AName
  WHERE A.AName = 'Jones'`

10. As previous, but not books that have the keyword “database”
  - Relational Algebra: $pi$#sub[Title] ($sigma$#sub[AName = 'Jones'] (AUTHORS) $join$ has-writter $join$ BOOKS) / $pi$#sub[Title] ($sigma$#sub[Keyword = 'database'] (describes) $join$ BOOKS)
  - SQL: `SELECT B.Title 
  FROM BOOKS B
  JOIN has-writter HW ON B.DocID = HW.DocId
  JOIN AUTHORS A ON HW.AName = A.AName
  WHERE A.AName = 'Jones' AND B.DocID NOT IN (SELECT D.DocId 
  FROM describes D 
  WHERE D.Keyword = 'database')`
11. Find the name of the youngest student
  - Relational Algebra: $pi$#sub[StName] ($sigma$#sub[Age = MIN(Age)] (STUDENTS))
  temp = $pi$#sub[Age] (STUDENTS) / $pi$#sub[Age] ($sigma$#sub[Age1 < Age] (STUDENTS $join$ $rho$#sub[Age/Age1] (STUDENTS)))

  $pi$#sub[StName] ($sigma$#sub[Age = temp] (STUDENTS))
  - SQL: `SELECT S.StName 
  FROM STUDENTS S 
  WHERE S.Age = (SELECT MIN(Age) FROM STUDENTS)`