-- Using chapter5.sql schema

-- Find total number of parts supplied by each supplier
SELECT s.sname, COUNT(p.pid) AS total_parts
FROM suppliers s
JOIN catalog cat ON s.sid = cat.sid
JOIN parts p ON cat.pid = p.pid
GROUP BY s.sname;

-- Find the total number of parts supplied by each supplier who supplies at least 3 parts.
SELECT s.sname, COUNT(cat.pid) AS total_parts
FROM suppliers s
JOIN catalog cat ON s.sid = cat.sid
GROUP BY s.sname
HAVING COUNT(cat.pid) >= 3;

-- For every supplier that supplies only green parts, print the name of the supplier and the total number of parts that they supply
-- Outputs nothing because no suppliers supplies only green parts.
SELECT s.sname, COUNT(*) AS total_parts
FROM suppliers s
JOIN catalog cat ON s.sid = cat.sid
JOIN parts p ON cat.pid = p.pid
GROUP BY s.sname
HAVING COUNT(*) = COUNT(*) FILTER (WHERE TRIM(p.color) = 'Green');

-- For every supplier that supplies a green part and a red part, print the name of the supplier and
-- the highest cost among parts they supply (catalog.cost stores supplier-part pricing)
SELECT s.sname, MAX(cat.cost) AS max_price
FROM suppliers s
JOIN catalog cat ON s.sid = cat.sid
JOIN parts p ON cat.pid = p.pid
GROUP BY s.sname
HAVING COUNT(*) FILTER (WHERE TRIM(p.color) = 'Green') > 0 
    AND COUNT(*) FILTER (WHERE TRIM(p.color) = 'Red') > 0;