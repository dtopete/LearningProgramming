#set align(center)
= CS166 HW1

#set align(left)
Danny Topete,
dtope004,
CS166 - Spring 2026,
April 17

= Problem 1) Exercise 2.8 from the textbook
#figure(
  image("ArtBase.png"),
  caption: [
    ArtBase database schema from the textbook, used in Exercise 2.8
  ],
)

#pagebreak()
= Problem 2) Exercise 3.9; Q: 2-5
Questions are based off the following schema:
```SQL
Emp(eid: integer, ename: string, age: integer, salary: real)
Works(eid: integer, did: integer, pcttime: integer)
Dept(did: integer, dname: string, budget: real, managerid: integer)
```
2. SQL to create proceding relations, including appropriate version of all primary and foreign key integrity constraints.  
```SQL
CREATE TABLE Emp (
  eid INTEGER PRIMARY KEY, -- Primary key is Employee ID
  ename STRING, -- employee name
  age INTEGER, -- employee age
  salary REAL -- employee salary
);
```

3. Define the Dept relationship in SQL so that every department is guaranteed a manage.

```SQL
CREATE TABLE Dept (
  did INTEGER PRIMARY KEY, // Primary key is Department ID 
  dname STRING, -- department name
  budget REAL, -- department budget
  managerid INTEGER, -- manager ID
  FOREIGN KEY (managerid) REFERENCES Emp(eid) /* Assigning managerid as a foreign key referencing Emp relation */
);
```

4. SQL to add John Doe as an employee with `eid = 101`, `age = 32`, and `salary = 15,000` to the `Employee` relation, and to assign him to the `Sales` department.
```SQL
INSERT INTO Emp VALUES (101, 'John Doe', 32, 15000);
```

5. SQL to give every employee a 10% raise.
```SQL
UPDATE Emp SET salary = salary * 1.10;
```

#pagebreak()
== SQL commands for Problem 3
```SQL
CREATE TABLE Airplane(
  Company CHAR(20),
  reg_no CHAR(20) PRIMARY KEY,
);

CREATE TABLE Model(
  model_no CHAR(20) PRIMARY KEY,
  Seat-capacity INTEGER,
  weight INTEGER,
  fuel INTEGER
);

-- Relationship between Airplane and Model, Type. Every airplane is a model
CREATE TABLE Type(
  reg_no CHAR(20) PRIMARY KEY,
  model_no CHAR(20),
  FOREIGN KEY (reg_no) REFERENCES Airplane(reg_no),
  FOREIGN KEY (model_no) REFERENCES Model(model_no)
);

CREATE TABLE Technician(
  ssn CHAR(15) PRIMARY KEY,
  salary INTEGER,
  Last-name CHAR(20),
  address CHAR(30),
  Phone_num CHAR(15),
  FOREIGN KEY (ssn) REFERENCES Employee(ssn)
);

-- Relationship between Airplane and Technician, Can-Fix, 1-1 relationship
CREATE TABLE Can_Fix(
  reg_no CHAR(20) PRIMARY KEY NOT NULL,
  ssn CHAR(15) NOT NULL,
  FOREIGN KEY (reg_no) REFERENCES Airplane(reg_no),
  FOREIGN KEY (ssn) REFERENCES Technician(ssn)
);

CREATE TABLE Employee(
  ssn CHAR(11) PRIMARY KEY,
  union_mem_no INTEGER
);

-- Have a foreign key of level
CREATE TABLE Traffic-Controller(
  age INTEGER,
  Years-exp INTEGER
);

-- ISA relationship bettween Technician, employee and Traffic Controller
CREATE TABLE Technician_ISA(
  ssn CHAR(11) PRIMARY KEY,
  FOREIGN KEY (ssn) REFERENCES Employee(ssn)
);
```
#pagebreak()

```SQL
CREATE Table Exam(
  duration INTEGER,
  date DATE,
  level CHAR(20) NOT NULL
);

-- Relationship bettween traffic controller and exam, must pass exam to be a traffic controller
CREATE TABLE Passed(
  ssn CHAR(11) PRIMARY KEY NOT NULL,
  level CHAR(20) NOT NULL,
  FOREIGN KEY (ssn) REFERENCES Traffic-Controller(ssn),
  FOREIGN KEY (level) REFERENCES Exam(level)
);

CREATE TABLE Test(
  name CHAR(20),
  FAA_no CHAR(20) PRIMARY KEY,
  Max-score INTEGER
);  

-- Test_info is a relationship between Technician, Airplane, and Test with attribute hours, date, score
CREATE TABLE Test_info(
  ssn CHAR(11),
  reg_no CHAR(20),
  FAA_no CHAR(20),
  hours INTEGER,
  date DATE,
  score INTEGER,
  PRIMARY KEY (ssn, reg_no, FAA_no),
  FOREIGN KEY (ssn) REFERENCES Technician(ssn),
  FOREIGN KEY (reg_no) REFERENCES Airplane(reg_no),
  FOREIGN KEY (FAA_no) REFERENCES Test(FAA_no)
);
```