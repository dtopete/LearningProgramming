-- Drop existing indexes to ensure a clean run
DROP INDEX IF EXISTS idx_nyc_on_hand;
DROP INDEX IF EXISTS idx_sfo_on_hand;
DROP INDEX IF EXISTS idx_nyc_color;
DROP INDEX IF EXISTS idx_sfo_color;
DROP INDEX IF EXISTS idx_nyc_supplier;
DROP INDEX IF EXISTS idx_sfo_supplier;

-- 1. Index on 'on_hand' for range queries (e.g., WHERE on_hand > 70)
CREATE INDEX idx_nyc_on_hand ON part_nyc USING BTREE (on_hand);
CREATE INDEX idx_sfo_on_hand ON part_sfo USING BTREE (on_hand);

-- 2. Index on 'color' for joins with the color table
CREATE INDEX idx_nyc_color ON part_nyc USING BTREE (color);
CREATE INDEX idx_sfo_color ON part_sfo USING BTREE (color);

-- 3. Index on 'supplier' for the subqueries and joins in Q3 and Q4
CREATE INDEX idx_nyc_supplier ON part_nyc USING BTREE (supplier);
CREATE INDEX idx_sfo_supplier ON part_sfo USING BTREE (supplier);