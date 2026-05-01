#set align(center)
= CS166 Lab5 Assignment \ Working With PSQL Queries


#set align(left)
Danny Topete,
dtope004

CS166 - Spring 2026

May 1, 2026


#figure(
  image("output.png"),
  caption: [
    Running queries.sql on the CS166 server
  ],
)

#pagebreak()
`queries.sql` contains the following SQL queries:
```SQL
-- Find the pid of parts with cost lower than 10
SELECT DISTINCT pid
FROM catalog
WHERE cost < 10;

-- Find the name of parts with cost lower than 10
SELECT DISTINCT parts.pname
FROM parts
JOIN catalog ON parts.pid = catalog.pid
WHERE catalog.cost < 10;

-- Find the address of the supplier who supply "Fire Hydrant Cap"
SELECT DISTINCT suppliers.address
FROM suppliers
JOIN catalog ON suppliers.sid = catalog.sid
JOIN parts ON catalog.pid = parts.pid
WHERE parts.pname = 'Fire Hydrant Cap';

-- Find the name of the suppliers who supply green parts
SELECT DISTINCT suppliers.sname
FROM suppliers
JOIN catalog ON suppliers.sid = catalog.sid
JOIN parts ON catalog.pid = parts.pid
WHERE parts.color = 'Green';

-- For each supplier, list the supplier's name along with all parts' name that it supply.
SELECT suppliers.sname, parts.pname
FROM suppliers
JOIN catalog ON suppliers.sid = catalog.sid
JOIN parts ON catalog.pid = parts.pid
ORDER BY suppliers.sname, parts.pname;

```