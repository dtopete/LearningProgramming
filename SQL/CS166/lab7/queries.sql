-- Things to note: Some notes about the data model and the questions:
-- ● part_number is the primary key for each part table. But it is not unique across both tables.
-- ● If a part has the same number in NYC and SFO it is the same part, regardless of color,
-- etc.
-- ● If I say, e.g. “Red parts”, I mean color_name = “Red” not color = 0.
-- ● Different suppliers may supply the same part in NYC and SFO

--1. Count how many parts in NYC have more than 70 parts on_hand
SELECT count(*)
FROM part_nyc
WHERE on_hand > 70;

--2. Count how many total parts on_hand, in both NYC and SFO, are Red
SELECT sum(on_hand)
FROM part_nyc p, color c
WHERE p.color = c.color_id AND c.color_name = 'Red'
UNION ALL
SELECT sum(on_hand)
FROM part_sfo p, color c
WHERE p.color = c.color_id AND c.color_name = 'Red';

--3. List all the suppliers that have more total on_hand parts in NYC than they do in SFO.
SELECT s.supplier_name
FROM supplier s
WHERE (SELECT sum(on_hand) 
FROM part_nyc p 
WHERE p.supplier = s.supplier_id) 
> (SELECT sum(on_hand) FROM part_sfo p WHERE p.supplier = s.supplier_id);

--4. List all suppliers that supply parts in NYC that aren’t supplied by anyone in SFO.
SELECT s.supplier_name
FROM supplier s
WHERE s.supplier_id IN (SELECT supplier FROM part_nyc)
AND s.supplier_id NOT IN (SELECT supplier FROM part_sfo);
--5. Update all of the NYC on_hand values to on_hand - 10.
UPDATE part_nyc
SET on_hand = on_hand - 10;
--6. Delete all parts from NYC which have less than 30 parts on_hand.
DELETE FROM part_nyc
WHERE on_hand < 30;