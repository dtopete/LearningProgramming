#set text(
  font: "Times New Roman",
  size: 12pt
)

#set par(
  justify: true,
  leading: 0.55em
)

#set align(center)

= Homework 3: SQL
Danny Topete - dtope004\ CS166 - Spring 2026

#set align(left)

== Problem 1: 
Given the following relational database: \
employee (#underline[employee-name], street, city) \
works (#underline[employee-name], company-name, salary) \
company (#underline[company-name], city) \
manages (#underline[employee-name], manager-name) \

Write the following Queries in SQL:
+ Find the names of employees who work in a city different from the city where their company is located.
  ```SQL
  SELECT e.employee-name
  FROM employee e, works w, company c
  WHERE e.employee-name = w.employee-name
  AND w.company-name = c.company-name
  -- Below outputs employees who work in the same city as their company, so we use NOT EXISTS to get those who work in a different city
  WHERE NOT EXISTS (
    SELECT *
    FROM employee e2, works w2, company c2
    WHERE e2.employee-name = w2.employee-name
    AND w2.company-name = c2.company-name
    AND e2.employee-name = e.employee-name
    AND c2.city = c.city
  )
  ```
+ Find the name of employees who earn less than the average salary of their company.
  ```SQL
  SELECT e.employee-name
  FROM employee e, works w
  WHERE e.employee-name = w.employee-name
  AND w.salary < (
    SELECT AVG(salary)
    FROM works
    WHERE company-name = w.company-name
  )
  ```
#pagebreak()
== Problem 2: Write the following queries in SQL on database shown below.
#figure(
  image("schema2.png"),
  caption: [Database Schema for Problem 2]
)

1. For departments with an average salary greater than \$50,000, list the department name and the average salary of employees in each department.
```SQL
SELECT d.dname, AVG(w.salary) AS average_salary
FROM department d, employee e, works w
WHERE d.DNUMBER = e.DNUM
AND e.SSN = w.ESSN
GROUP BY d.dname
HAVING AVG(w.salary) > 50000
```
2. Find the first and last names of employees who do not work on any project.
```SQL
SELECT e.fname, e.lname
FROM employee e
WHERE NOT EXISTS (
  SELECT *
  FROM project p, works_on w, department d
  WHERE e.SSN = w.ESSN
  AND d.dnumber = p.dnum
  AND p.pnumber = w.pnum
)
```
3. Retrieve the last names of employees who share a birthday with at least one of their dependents.
```SQL
SELECT DISTINCT e.lname
FROM employee e, dependent d
WHERE e.SSN = d.ESSN
AND e.BDATE = d.BDATE 
```
// Enforce the: At least one employee has a dependent with the same birthday constraint
// I believe DISTINCT is sufficient to ensure that we only get unique last names of employees who share a birthday with at least one of their dependents.

#pagebreak()

4. Find the first and last names of employees who work on every project in the "Houston" location.
```SQL
SELECT e.fname, e.lname
FROM employee e
-- Below outputs employees who do not work on any project in Houston, so we use NOT EXISTS to get those who work on every project in Houston
WHERE NOT EXISTS (
  SELECT *
  FROM project p, department d, works_on w
  WHERE p.pnumber = w.pnum
  AND w.ESSN = e.SSN
  AND d.dnumber = p.dnum
  AND d.dlocation = 'Houston'
)
```
5. For each department, list the department name and the number of employees who work in that department.
```SQL
SELECT d.dname, COUNT(e.SSN) AS num_employees
FROM department d, employee e
WHERE d.DNUMBER = e.DNUM
GROUP BY d.dname
```
6. List the last names of all employees who have no dependents
```SQL
-- No need for DISTINCT because E with no D only appear once
SELECT e.lname
FROM employee e
WHERE NOT EXISTS (
  SELECT *
  FROM dependent d
  WHERE e.SSN = d.ESSN
)
```

#pagebreak()
== Problem 3: Consider the following relational university database: \

STUDENT (Name, #underline[StudentNumber], Class, Major) \
COURSE (CourseName, #underline[CourseNumber], CreditHours, Department)\
PREREQUISITE (#underline[CourseNumber, PrerequisiteNumber])\
SECTION (#underline[SectionIdentifier], CourseNumber, Semester, Year, Instructor)\
GRADE_REPORT (#underline[StudentNumber], #underline[SectionIdentifier], Grade)\

1. Retrieve the names and majors of all ‘A’ students (i.e., students who have a grade of ‘A’ in all their courses).
2. Retrieve the names and majors of all students who do not have a grade of ‘A’ in any of their courses