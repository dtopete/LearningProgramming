#set text(
  font: "Times New Roman",
  size: 12pt
)

#set par(
  justify: true,
  leading: 0.55em

)

#set align(center)
= Homework 2: Relational Algebra
Danny Topete - dtope004\
CS166

#set align(left)

== Problem 1 Question

Consider a database that consists of the following tables that describe a fictional
company. Each table is defined below.

=== I. EMPLOYEE: It holds data on the company employees and has the following attributes:

FNAME employee first name

LNAME employee last name

#underline[SSN] social security number

BDATE birthdate

ADDRESS address

SALARY salary

DNO department number

SUPERSSN SSN of the employee supervisor

=== II. DEPARTMENT: It holds information about the company departments. It has the attributes:

DNAME name of the department

#underline[DNUMBER] number of the department

MGRSSN SSN of manager of this department

MGRSTARTDATE the manager start date

=== III. DEPT_LOCATIONS: It holds the location of each department and has two attributes:

#underline[DNUMBER] number of the department

#underline[DLOCATION] location of the department

=== IV. PROJECT: It describes the projects of the company:

PNAME project name

#underline[PNUMBER] project number

PLOCATION location of the project

DNUM number of the corresponding department where project takes place

=== V. WORKS_ON: It describes which employee works on which project and for how many hours.

#underline[ESSN] SSN of employee

#underline[PNO] project number

HOURS number of hours per week essn works on project with number pno

=== VI. DEPENDENT: It contains the dependents of an employee:

#underline[ESSN] SSN of employee

#underline[DEPENDENT-NAME] the name of the dependent

BDATE the birthdate of the dependent


RELATIONSHIP the relationship of the dependent to the employee

The attribute(s) that create the primary key in each table are underlined. Write the following queries in *relational algebra:*

+ Find the salaries of employees who work on at least one project located in “Athens” or “Paris”

  $pi$#sub[SALARY] ($sigma$#sub[PLOCATION = "Athens"] (EMPLOYEE))  $join$ $sigma$#sub[PLOCATION = "Paris"] (EMPLOYEE))

+ Find the salaries of employees that work in all projects where “Pep Guardiola” works.

  // Salary of employees, then find the projects that Pep Guardiola works on, then find the employees that work on those projects, then find the salaries of those employees. This is a division operation.
  $pi$#sub[SALARY] ()

+ Find the last names and salaries of employees who work in some but not all projects.

+ Find the last names and salaries of employees who work on every project.

+ Find the last names of employees that do not work on any project.

+ Find the last names of department managers who have no dependents.

== Answers for Problem 1
// Make sure this works without duplicates beause it is "at least one project located in Athens or Paris"
+ $pi$#sub[SALARY] ($sigma$#sub[PLOCATION = "Athens"] (EMPLOYEE)  $join$ $sigma$#sub[PLOCATION = "Paris"] (EMPLOYEE))
// Display the salaries of employees that work in all projects where "Pep Guardiola" works. This is a division operation.
+ $pi$#sub[SALARY] ($sigma$#sub[ESSN = ($pi$#sub[SSN] ($sigma$#sub[FNAME = "Pep" AND LNAME = "Guardiola"]))] (WORKS_ON) $join$ PROJECT)
// Project last names and salaries of employees who work in some but not all projects. This is a set difference operation.
+ $pi$#sub[SALARY] ($sigma$#sub[ESSN = ($pi$#sub[ESSN] (WORKS_ON))] (WORKS_ON) $join$ PROJECT)
// Project last names and salaries of employees who work on every projecy. Division operator
+ $pi$#sub[LNAME, SALARY] ($sigma$#sub[ESSN = ($pi$#sub[SSN] (WORKS_ON))] (WORKS_ON) $join$ PROJECT)
// Project last names of employees that do not work on any project. Set difference operator.
+ $pi$#sub[LNAME] (EMPLOYEE) - $pi$#sub[LNAME] ($sigma$#sub[ESSN = ($pi$#sub[ESSN] (WORKS_ON))] (WORKS_ON) $join$ PROJECT)
// Project last names of department managers who have no dependents. Set difference operator.
+ $pi$#sub[LNAME] ($sigma$#sub[MGRSSN = SSN] (DEPARTMENT)) - $pi$#sub[LNAME] ($sigma$#sub[ESSN = ($pi$#sub[MGRSSN] (DEPARTMENT))] (DEPENDENT))

#pagebreak()
== Problem 2 Question
Consider a database consisting of following relation:

VISITS (#underline[DRINKER, BAR])

SERVES (#underline[BAR, BEER])

LIKES (#underline[DRINKER, BEER])

== Problem 2. Answer
// Find all the bars that contain the beer that Smith likes
+ Find the bars that serve a beer that drinker "Smith" likes

//  $pi$#sub[BAR] (VISITS) $join$ $sigma$#sub[DRINKER = "Smith"] (LIKES) 

  $pi$#sub[BAR] (SERVES $join$ $pi$#sub[BEER] ($sigma$#sub[DRINKER="Smith"] (LIKES)))

+ Find the bars that serve all beers that drinker "Smith likes"

// Find the bars. Find the beers that smith likes, then find the bars that serve those beers, then find the bars that serve all of those beers. This is a division operation.

//  $pi$#sub[BAR] ($pi$#sub[DRINKER = "Smith"] (LIKES) $join$ SERVES)

  SERVES $div$ $pi$#sub[BEER] ($sigma$#sub[DRINKER="Smith"] (LIKES))

+ Find the drinkers that visit all bars that serve "Amstel" beer.

// Find the drinkers, find the bars that serve "Amstel" beer, then find the drinkers that visit those bars, then find the drinkers that visit all of those bars. This is a division operation.
  //$pi$#sub[DRINKER] (VISITS INTERSECTION $pi$#sub[BAR] ($sigma$#sub[BEER = "Amstel"] (SERVES)))

  VISITS $div$ $pi$#sub[BAR] ($sigma$#sub[BEER="Amstel"] (SERVES))

// Bars that serve "Amstel" beer
//  $pi$#sub[BAR] ($sigma$#sub[BEER = "Amstel"] (SERVES))

+ Find the drinkers that visit at least one bar that serves at least one beer they like.

// Find the drinkers, find the bars that serve at least one beer they like, then find the drinkers that visit those bars. This is a set difference operation.
  $pi$#sub[DRINKER] (VISITS $join$ $pi$#sub[BAR] ($sigma$#sub[BEER] (LIKES) $join$ SERVES))

//  alt solution:

//  $pi$#sub[DRINKER] (VISITS $join$ SERVES $join$ LIKES)