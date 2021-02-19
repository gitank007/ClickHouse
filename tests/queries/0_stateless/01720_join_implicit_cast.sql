DROP TABLE IF EXISTS t1;
DROP TABLE IF EXISTS t2;

CREATE TABLE t1 (a UInt16, b UInt16) ENGINE = TinyLog;
CREATE TABLE t2 (a Int16, b Nullable(Int64)) ENGINE = TinyLog;

INSERT INTO t1 SELECT number as a, 100 + number as b FROM system.numbers LIMIT 1, 10;
INSERT INTO t2 SELECT number - 5 as a, 200 + number - 5 as b FROM system.numbers LIMIT 1, 10;

SELECT '=== hash ===';
SET join_algorithm = 'hash';

SELECT '= full =';
SELECT a, b, t2.b FROM t1 FULL JOIN t2 USING (a) ORDER BY (a);
SELECT '= left =';
SELECT a, b, t2.b FROM t1 LEFT JOIN t2 USING (a) ORDER BY (a);
SELECT '= right =';
SELECT a, b, t2.b FROM t1 RIGHT JOIN t2 USING (a) ORDER BY (a);
SELECT '= inner =';
SELECT a, b, t2.b FROM t1 INNER JOIN t2 USING (a) ORDER BY (a);

SELECT '= full =';
SELECT a, t1.a, t2.a FROM t1 FULL JOIN t2 USING (a) ORDER BY (t1.a, t2.a);
SELECT '= left =';
SELECT a, t1.a, t2.a FROM t1 LEFT JOIN t2 USING (a) ORDER BY (t1.a, t2.a);
SELECT '= right =';
SELECT a, t1.a, t2.a FROM t1 RIGHT JOIN t2 USING (a) ORDER BY (t1.a, t2.a);
SELECT '= inner =';
SELECT a, t1.a, t2.a FROM t1 INNER JOIN t2 USING (a) ORDER BY (t1.a, t2.a);

SELECT '= join on =';
SELECT '= full =';
SELECT a, b, t2.a, t2.b FROM t1 FULL JOIN t2 ON (t1.a == t2.a) ORDER BY (t1.a, t2.a);
SELECT '= left =';
SELECT a, b, t2.a, t2.b FROM t1 LEFT JOIN t2 ON (t1.a == t2.a) ORDER BY (t1.a, t2.a);
SELECT '= right =';
SELECT a, b, t2.a, t2.b FROM t1 RIGHT JOIN t2 ON (t1.a == t2.a) ORDER BY (t1.a, t2.a);
SELECT '= inner =';
SELECT a, b, t2.a, t2.b FROM t1 INNER JOIN t2 ON (t1.a == t2.a) ORDER BY (t1.a, t2.a);

SELECT '= full =';
SELECT * FROM t1 FULL JOIN t2 ON (t1.a + t1.b = t2.a + t2.b - 100) ORDER BY (t1.a, t2.a);
SELECT '= left =';
SELECT * FROM t1 LEFT JOIN t2 ON (t1.a + t1.b = t2.a + t2.b - 100) ORDER BY (t1.a, t2.a);
SELECT '= right =';
SELECT * FROM t1 RIGHT JOIN t2 ON (t1.a + t1.b = t2.a + t2.b - 100) ORDER BY (t1.a, t2.a);
SELECT '= inner =';
SELECT * FROM t1 INNER JOIN t2 ON (t1.a + t1.b = t2.a + t2.b - 100) ORDER BY (t1.a, t2.a);

-- Int64 and UInt64 has no supertype
SELECT * FROM t1 FULL JOIN t2 ON (t1.a + t1.b + 100 = t2.a + t2.b) ORDER BY (t1.a, t2.a); -- { serverError 53 }
SELECT * FROM t1 LEFT JOIN t2 ON (t1.a + t1.b + 100 = t2.a + t2.b) ORDER BY (t1.a, t2.a); -- { serverError 53 }
SELECT * FROM t1 RIGHT JOIN t2 ON (t1.a + t1.b + 100 = t2.a + t2.b) ORDER BY (t1.a, t2.a); -- { serverError 53 }
SELECT * FROM t1 INNER JOIN t2 ON (t1.a + t1.b + 100 = t2.a + t2.b) ORDER BY (t1.a, t2.a); -- { serverError 53 }

SELECT '= agg =';
SELECT sum(a) == 7 FROM t1 FULL JOIN t2 USING (a) WHERE b > 102 AND t2.b <= 204;
SELECT sum(a) == 7 FROM t1 INNER JOIN t2 USING (a) WHERE b > 102 AND t2.b <= 204;

SELECT sum(b) = 103 FROM t1 LEFT JOIN t2 USING (a) WHERE b > 102 AND t2.b < 204;
SELECT sum(t2.b) = 203 FROM t1 RIGHT JOIN t2 USING (a) WHERE b > 102 AND t2.b < 204;

SELECT sum(a) == 2 + 3 + 4 FROM t1 FULL JOIN t2 ON (t1.a + t1.b = t2.a + t2.b - 100) WHERE t1.b < 105 AND t2.b > 201;

SELECT a > 0, sum(a), sum(b) FROM t1 FULL JOIN t2 USING (a) GROUP BY (a > 0) ORDER BY a > 0;
SELECT a > 0, sum(a), sum(t2.a), sum(b), sum(t2.b) FROM t1 FULL JOIN t2 ON (t1.a == t2.a) GROUP BY (a > 0) ORDER BY a > 0;

SELECT '= types =';
SELECT any(toTypeName(a)) == 'Int32' AND any(toTypeName(t2.a)) == 'Int32' FROM t1 FULL JOIN t2 USING (a);
SELECT any(toTypeName(a)) == 'Int32' AND any(toTypeName(t2.a)) == 'Int32' FROM t1 LEFT JOIN t2 USING (a);
SELECT any(toTypeName(a)) == 'Int32' AND any(toTypeName(t2.a)) == 'Int32' FROM t1 RIGHT JOIN t2 USING (a);
SELECT any(toTypeName(a)) == 'Int32' AND any(toTypeName(t2.a)) == 'Int32' FROM t1 INNER JOIN t2 USING (a);

SELECT toTypeName(any(a)) == 'Int32' AND toTypeName(any(t2.a)) == 'Int32' FROM t1 FULL JOIN t2 USING (a);
SELECT min(toTypeName(a) == 'Int32' AND toTypeName(t2.a) == 'Int32') FROM t1 FULL JOIN t2 USING (a);

SELECT any(toTypeName(a)) == 'UInt16' AND any(toTypeName(t2.a)) == 'Int16' FROM t1 FULL JOIN t2 ON (t1.a == t2.a);
SELECT any(toTypeName(a)) == 'UInt16' AND any(toTypeName(t2.a)) == 'Int16' FROM t1 LEFT JOIN t2 ON (t1.a == t2.a);
SELECT any(toTypeName(a)) == 'UInt16' AND any(toTypeName(t2.a)) == 'Int16' FROM t1 RIGHT JOIN t2 ON (t1.a == t2.a);
SELECT any(toTypeName(a)) == 'UInt16' AND any(toTypeName(t2.a)) == 'Int16' FROM t1 INNER JOIN t2 ON (t1.a == t2.a);
SELECT toTypeName(any(a)) == 'UInt16' AND toTypeName(any(t2.a)) == 'Int16' FROM t1 FULL JOIN t2 ON (t1.a == t2.a);

SELECT '=== partial_merge ===';

SET join_algorithm = 'partial_merge';

SELECT '= full =';
SELECT a, b, t2.b FROM t1 FULL JOIN t2 USING (a) ORDER BY (a);
SELECT '= left =';
SELECT a, b, t2.b FROM t1 LEFT JOIN t2 USING (a) ORDER BY (a);
SELECT '= right =';
SELECT a, b, t2.b FROM t1 RIGHT JOIN t2 USING (a) ORDER BY (a);
SELECT '= inner =';
SELECT a, b, t2.b FROM t1 INNER JOIN t2 USING (a) ORDER BY (a);

SELECT '= full =';
SELECT a, t1.a, t2.a FROM t1 FULL JOIN t2 USING (a) ORDER BY (t1.a, t2.a);
SELECT '= left =';
SELECT a, t1.a, t2.a FROM t1 LEFT JOIN t2 USING (a) ORDER BY (t1.a, t2.a);
SELECT '= right =';
SELECT a, t1.a, t2.a FROM t1 RIGHT JOIN t2 USING (a) ORDER BY (t1.a, t2.a);
SELECT '= inner =';
SELECT a, t1.a, t2.a FROM t1 INNER JOIN t2 USING (a) ORDER BY (t1.a, t2.a);

SELECT '= join on =';
SELECT '= full =';
SELECT a, b, t2.a, t2.b FROM t1 FULL JOIN t2 ON (t1.a == t2.a) ORDER BY (t1.a, t2.a);
SELECT '= left =';
SELECT a, b, t2.a, t2.b FROM t1 LEFT JOIN t2 ON (t1.a == t2.a) ORDER BY (t1.a, t2.a);
SELECT '= right =';
SELECT a, b, t2.a, t2.b FROM t1 RIGHT JOIN t2 ON (t1.a == t2.a) ORDER BY (t1.a, t2.a);
SELECT '= inner =';
SELECT a, b, t2.a, t2.b FROM t1 INNER JOIN t2 ON (t1.a == t2.a) ORDER BY (t1.a, t2.a);

SELECT '= full =';
SELECT * FROM t1 FULL JOIN t2 ON (t1.a + t1.b = t2.a + t2.b - 100) ORDER BY (t1.a, t2.a);
SELECT '= left =';
SELECT * FROM t1 LEFT JOIN t2 ON (t1.a + t1.b = t2.a + t2.b - 100) ORDER BY (t1.a, t2.a);
SELECT '= right =';
SELECT * FROM t1 RIGHT JOIN t2 ON (t1.a + t1.b = t2.a + t2.b - 100) ORDER BY (t1.a, t2.a);
SELECT '= inner =';
SELECT * FROM t1 INNER JOIN t2 ON (t1.a + t1.b = t2.a + t2.b - 100) ORDER BY (t1.a, t2.a);

-- Int64 and UInt64 has no supertype
SELECT * FROM t1 FULL JOIN t2 ON (t1.a + t1.b + 100 = t2.a + t2.b) ORDER BY (t1.a, t2.a); -- { serverError 53 }
SELECT * FROM t1 LEFT JOIN t2 ON (t1.a + t1.b + 100 = t2.a + t2.b) ORDER BY (t1.a, t2.a); -- { serverError 53 }
SELECT * FROM t1 RIGHT JOIN t2 ON (t1.a + t1.b + 100 = t2.a + t2.b) ORDER BY (t1.a, t2.a); -- { serverError 53 }
SELECT * FROM t1 INNER JOIN t2 ON (t1.a + t1.b + 100 = t2.a + t2.b) ORDER BY (t1.a, t2.a); -- { serverError 53 }

SELECT '= agg =';
SELECT sum(a) == 7 FROM t1 FULL JOIN t2 USING (a) WHERE b > 102 AND t2.b <= 204;
SELECT sum(a) == 7 FROM t1 INNER JOIN t2 USING (a) WHERE b > 102 AND t2.b <= 204;

SELECT sum(b) = 103 FROM t1 LEFT JOIN t2 USING (a) WHERE b > 102 AND t2.b < 204;
SELECT sum(t2.b) = 203 FROM t1 RIGHT JOIN t2 USING (a) WHERE b > 102 AND t2.b < 204;

SELECT sum(a) == 2 + 3 + 4 FROM t1 FULL JOIN t2 ON (t1.a + t1.b = t2.a + t2.b - 100) WHERE t1.b < 105 AND t2.b > 201;

SELECT a > 0, sum(a), sum(b) FROM t1 FULL JOIN t2 USING (a) GROUP BY (a > 0) ORDER BY a > 0;
SELECT a > 0, sum(a), sum(t2.a), sum(b), sum(t2.b) FROM t1 FULL JOIN t2 ON (t1.a == t2.a) GROUP BY (a > 0) ORDER BY a > 0;

SELECT '= types =';
SELECT any(toTypeName(a)) == 'Int32' AND any(toTypeName(t2.a)) == 'Int32' FROM t1 FULL JOIN t2 USING (a);
SELECT any(toTypeName(a)) == 'Int32' AND any(toTypeName(t2.a)) == 'Int32' FROM t1 LEFT JOIN t2 USING (a);
SELECT any(toTypeName(a)) == 'Int32' AND any(toTypeName(t2.a)) == 'Int32' FROM t1 RIGHT JOIN t2 USING (a);
SELECT any(toTypeName(a)) == 'Int32' AND any(toTypeName(t2.a)) == 'Int32' FROM t1 INNER JOIN t2 USING (a);

SELECT toTypeName(any(a)) == 'Int32' AND toTypeName(any(t2.a)) == 'Int32' FROM t1 FULL JOIN t2 USING (a);
SELECT min(toTypeName(a) == 'Int32' AND toTypeName(t2.a) == 'Int32') FROM t1 FULL JOIN t2 USING (a);

SELECT any(toTypeName(a)) == 'UInt16' AND any(toTypeName(t2.a)) == 'Int16' FROM t1 FULL JOIN t2 ON (t1.a == t2.a);
SELECT any(toTypeName(a)) == 'UInt16' AND any(toTypeName(t2.a)) == 'Int16' FROM t1 LEFT JOIN t2 ON (t1.a == t2.a);
SELECT any(toTypeName(a)) == 'UInt16' AND any(toTypeName(t2.a)) == 'Int16' FROM t1 RIGHT JOIN t2 ON (t1.a == t2.a);
SELECT any(toTypeName(a)) == 'UInt16' AND any(toTypeName(t2.a)) == 'Int16' FROM t1 INNER JOIN t2 ON (t1.a == t2.a);
SELECT toTypeName(any(a)) == 'UInt16' AND toTypeName(any(t2.a)) == 'Int16' FROM t1 FULL JOIN t2 ON (t1.a == t2.a);

SELECT '=== switch ===';

SET join_algorithm = 'auto';
SET max_bytes_in_join = 100;

SELECT '= full =';
SELECT a, b, t2.b FROM t1 FULL JOIN t2 USING (a) ORDER BY (a);
SELECT '= left =';
SELECT a, b, t2.b FROM t1 LEFT JOIN t2 USING (a) ORDER BY (a);
SELECT '= right =';
SELECT a, b, t2.b FROM t1 RIGHT JOIN t2 USING (a) ORDER BY (a);
SELECT '= inner =';
SELECT a, b, t2.b FROM t1 INNER JOIN t2 USING (a) ORDER BY (a);

SELECT '= full =';
SELECT a, t1.a, t2.a FROM t1 FULL JOIN t2 USING (a) ORDER BY (t1.a, t2.a);
SELECT '= left =';
SELECT a, t1.a, t2.a FROM t1 LEFT JOIN t2 USING (a) ORDER BY (t1.a, t2.a);
SELECT '= right =';
SELECT a, t1.a, t2.a FROM t1 RIGHT JOIN t2 USING (a) ORDER BY (t1.a, t2.a);
SELECT '= inner =';
SELECT a, t1.a, t2.a FROM t1 INNER JOIN t2 USING (a) ORDER BY (t1.a, t2.a);

SELECT '= join on =';
SELECT '= full =';
SELECT a, b, t2.a, t2.b FROM t1 FULL JOIN t2 ON (t1.a == t2.a) ORDER BY (t1.a, t2.a);
SELECT '= left =';
SELECT a, b, t2.a, t2.b FROM t1 LEFT JOIN t2 ON (t1.a == t2.a) ORDER BY (t1.a, t2.a);
SELECT '= right =';
SELECT a, b, t2.a, t2.b FROM t1 RIGHT JOIN t2 ON (t1.a == t2.a) ORDER BY (t1.a, t2.a);
SELECT '= inner =';
SELECT a, b, t2.a, t2.b FROM t1 INNER JOIN t2 ON (t1.a == t2.a) ORDER BY (t1.a, t2.a);

SELECT '= full =';
SELECT * FROM t1 FULL JOIN t2 ON (t1.a + t1.b = t2.a + t2.b - 100) ORDER BY (t1.a, t2.a);
SELECT '= left =';
SELECT * FROM t1 LEFT JOIN t2 ON (t1.a + t1.b = t2.a + t2.b - 100) ORDER BY (t1.a, t2.a);
SELECT '= right =';
SELECT * FROM t1 RIGHT JOIN t2 ON (t1.a + t1.b = t2.a + t2.b - 100) ORDER BY (t1.a, t2.a);
SELECT '= inner =';
SELECT * FROM t1 INNER JOIN t2 ON (t1.a + t1.b = t2.a + t2.b - 100) ORDER BY (t1.a, t2.a);

-- Int64 and UInt64 has no supertype
SELECT * FROM t1 FULL JOIN t2 ON (t1.a + t1.b + 100 = t2.a + t2.b) ORDER BY (t1.a, t2.a); -- { serverError 53 }
SELECT * FROM t1 LEFT JOIN t2 ON (t1.a + t1.b + 100 = t2.a + t2.b) ORDER BY (t1.a, t2.a); -- { serverError 53 }
SELECT * FROM t1 RIGHT JOIN t2 ON (t1.a + t1.b + 100 = t2.a + t2.b) ORDER BY (t1.a, t2.a); -- { serverError 53 }
SELECT * FROM t1 INNER JOIN t2 ON (t1.a + t1.b + 100 = t2.a + t2.b) ORDER BY (t1.a, t2.a); -- { serverError 53 }

SELECT '= agg =';
SELECT sum(a) == 7 FROM t1 FULL JOIN t2 USING (a) WHERE b > 102 AND t2.b <= 204;
SELECT sum(a) == 7 FROM t1 INNER JOIN t2 USING (a) WHERE b > 102 AND t2.b <= 204;

SELECT sum(b) = 103 FROM t1 LEFT JOIN t2 USING (a) WHERE b > 102 AND t2.b < 204;
SELECT sum(t2.b) = 203 FROM t1 RIGHT JOIN t2 USING (a) WHERE b > 102 AND t2.b < 204;

SELECT sum(a) == 2 + 3 + 4 FROM t1 FULL JOIN t2 ON (t1.a + t1.b = t2.a + t2.b - 100) WHERE t1.b < 105 AND t2.b > 201;

SELECT a > 0, sum(a), sum(b) FROM t1 FULL JOIN t2 USING (a) GROUP BY (a > 0) ORDER BY a > 0;
SELECT a > 0, sum(a), sum(t2.a), sum(b), sum(t2.b) FROM t1 FULL JOIN t2 ON (t1.a == t2.a) GROUP BY (a > 0) ORDER BY a > 0;

SELECT '= types =';
SELECT any(toTypeName(a)) == 'Int32' AND any(toTypeName(t2.a)) == 'Int32' FROM t1 FULL JOIN t2 USING (a);
SELECT any(toTypeName(a)) == 'Int32' AND any(toTypeName(t2.a)) == 'Int32' FROM t1 LEFT JOIN t2 USING (a);
SELECT any(toTypeName(a)) == 'Int32' AND any(toTypeName(t2.a)) == 'Int32' FROM t1 RIGHT JOIN t2 USING (a);
SELECT any(toTypeName(a)) == 'Int32' AND any(toTypeName(t2.a)) == 'Int32' FROM t1 INNER JOIN t2 USING (a);

SELECT toTypeName(any(a)) == 'Int32' AND toTypeName(any(t2.a)) == 'Int32' FROM t1 FULL JOIN t2 USING (a);
SELECT min(toTypeName(a) == 'Int32' AND toTypeName(t2.a) == 'Int32') FROM t1 FULL JOIN t2 USING (a);

SELECT any(toTypeName(a)) == 'UInt16' AND any(toTypeName(t2.a)) == 'Int16' FROM t1 FULL JOIN t2 ON (t1.a == t2.a);
SELECT any(toTypeName(a)) == 'UInt16' AND any(toTypeName(t2.a)) == 'Int16' FROM t1 LEFT JOIN t2 ON (t1.a == t2.a);
SELECT any(toTypeName(a)) == 'UInt16' AND any(toTypeName(t2.a)) == 'Int16' FROM t1 RIGHT JOIN t2 ON (t1.a == t2.a);
SELECT any(toTypeName(a)) == 'UInt16' AND any(toTypeName(t2.a)) == 'Int16' FROM t1 INNER JOIN t2 ON (t1.a == t2.a);
SELECT toTypeName(any(a)) == 'UInt16' AND toTypeName(any(t2.a)) == 'Int16' FROM t1 FULL JOIN t2 ON (t1.a == t2.a);

SET max_bytes_in_join = 0;

SELECT '=== join use nulls ===';

SET join_use_nulls = 1;

SELECT '= full =';
SELECT a, b, t2.b FROM t1 FULL JOIN t2 USING (a) ORDER BY (a);
SELECT '= right =';
SELECT a, b, t2.b FROM t1 RIGHT JOIN t2 USING (a) ORDER BY (a);

SET join_use_nulls = 0;

DROP TABLE IF EXISTS t1;
DROP TABLE IF EXISTS t2;

SELECT '==========';

DROP TABLE IF EXISTS t_ab1;
DROP TABLE IF EXISTS t_ab2;

CREATE TABLE t_ab1 (id Nullable(Int32), a UInt16, b UInt8) ENGINE = TinyLog;
CREATE TABLE t_ab2 (id Nullable(Int32), a Int16, b Nullable(Int64)) ENGINE = TinyLog;
INSERT INTO t_ab1 VALUES (0, 1, 1), (1, 2, 2);
INSERT INTO t_ab2 VALUES (2, -1, 1), (3, 1, NULL), (4, 1, 257), (5, 1, -1), (6, 1, 1);

SELECT '=== hash ===';

SET join_algorithm = 'hash';

SELECT '= full =';
SELECT a, b FROM t_ab1 FULL JOIN t_ab2 USING (a, b) ORDER BY ifNull(t_ab1.id, t_ab2.id);
SELECT '= left =';
SELECT a, b FROM t_ab1 LEFT JOIN t_ab2 USING (a, b) ORDER BY ifNull(t_ab1.id, t_ab2.id);
SELECT '= right =';
SELECT a, b FROM t_ab1 RIGHT JOIN t_ab2 USING (a, b) ORDER BY ifNull(t_ab1.id, t_ab2.id);
SELECT '= inner =';
SELECT a, b FROM t_ab1 INNER JOIN t_ab2 USING (a, b) ORDER BY ifNull(t_ab1.id, t_ab2.id);

SELECT '= full =';
SELECT a, b, t_ab2.a, t_ab2.b FROM t_ab1 FULL JOIN t_ab2 ON (t_ab1.a == t_ab2.a AND t_ab1.b == t_ab2.b) ORDER BY ifNull(t_ab1.id, t_ab2.id);
SELECT '= left =';
SELECT a, b, t_ab2.a, t_ab2.b FROM t_ab1 LEFT JOIN t_ab2 ON (t_ab1.a == t_ab2.a AND t_ab1.b == t_ab2.b) ORDER BY ifNull(t_ab1.id, t_ab2.id);
SELECT '= right =';
SELECT a, b, t_ab2.a, t_ab2.b FROM t_ab1 RIGHT JOIN t_ab2 ON (t_ab1.a == t_ab2.a AND t_ab1.b == t_ab2.b) ORDER BY ifNull(t_ab1.id, t_ab2.id);
SELECT '= inner =';
SELECT a, b, t_ab2.a, t_ab2.b FROM t_ab1 INNER JOIN t_ab2 ON (t_ab1.a == t_ab2.a AND t_ab1.b == t_ab2.b) ORDER BY ifNull(t_ab1.id, t_ab2.id);

SELECT '= agg =';
SELECT sum(a), sum(b) FROM t_ab1 FULL JOIN t_ab2 USING (a, b);
SELECT sum(a), sum(b) FROM t_ab1 LEFT JOIN t_ab2 USING (a, b);
SELECT sum(a), sum(b) FROM t_ab1 RIGHT JOIN t_ab2 USING (a, b);
SELECT sum(a), sum(b) FROM t_ab1 INNER JOIN t_ab2 USING (a, b);

SELECT sum(a) + sum(t_ab2.a) - 1, sum(b) + sum(t_ab2.b) - 1 FROM t_ab1 FULL JOIN t_ab2 ON (t_ab1.a == t_ab2.a AND t_ab1.b == t_ab2.b);
SELECT sum(a) + sum(t_ab2.a) - 1, sum(b) + sum(t_ab2.b) - 1 FROM t_ab1 LEFT JOIN t_ab2 ON (t_ab1.a == t_ab2.a AND t_ab1.b == t_ab2.b);
SELECT sum(a) + sum(t_ab2.a) - 1, sum(b) + sum(t_ab2.b) - 1 FROM t_ab1 RIGHT JOIN t_ab2 ON (t_ab1.a == t_ab2.a AND t_ab1.b == t_ab2.b);
SELECT sum(a) + sum(t_ab2.a) - 1, sum(b) + sum(t_ab2.b) - 1 FROM t_ab1 INNER JOIN t_ab2 ON (t_ab1.a == t_ab2.a AND t_ab1.b == t_ab2.b);

SELECT '= types =';

SELECT any(toTypeName(a)) == 'Int32' AND any(toTypeName(b)) == 'Nullable(Int64)' FROM t_ab1 FULL JOIN t_ab2 USING (a, b);
SELECT any(toTypeName(a)) == 'Int32' AND any(toTypeName(b)) == 'Nullable(Int64)' FROM t_ab1 LEFT JOIN t_ab2 USING (a, b);
SELECT any(toTypeName(a)) == 'Int32' AND any(toTypeName(b)) == 'Nullable(Int64)' FROM t_ab1 RIGHT JOIN t_ab2 USING (a, b);
SELECT any(toTypeName(a)) == 'Int32' AND any(toTypeName(b)) == 'Nullable(Int64)' FROM t_ab1 INNER JOIN t_ab2 USING (a, b);

SELECT '=== partial_merge ===';

SET join_algorithm = 'partial_merge';

SELECT '= full =';
SELECT a, b FROM t_ab1 FULL JOIN t_ab2 USING (a, b) ORDER BY ifNull(t_ab1.id, t_ab2.id);
SELECT '= left =';
SELECT a, b FROM t_ab1 LEFT JOIN t_ab2 USING (a, b) ORDER BY ifNull(t_ab1.id, t_ab2.id);
SELECT '= right =';
SELECT a, b FROM t_ab1 RIGHT JOIN t_ab2 USING (a, b) ORDER BY ifNull(t_ab1.id, t_ab2.id);
SELECT '= inner =';
SELECT a, b FROM t_ab1 INNER JOIN t_ab2 USING (a, b) ORDER BY ifNull(t_ab1.id, t_ab2.id);

SELECT '= full =';
SELECT a, b, t_ab2.a, t_ab2.b FROM t_ab1 FULL JOIN t_ab2 ON (t_ab1.a == t_ab2.a AND t_ab1.b == t_ab2.b) ORDER BY ifNull(t_ab1.id, t_ab2.id);
SELECT '= left =';
SELECT a, b, t_ab2.a, t_ab2.b FROM t_ab1 LEFT JOIN t_ab2 ON (t_ab1.a == t_ab2.a AND t_ab1.b == t_ab2.b) ORDER BY ifNull(t_ab1.id, t_ab2.id);
SELECT '= right =';
SELECT a, b, t_ab2.a, t_ab2.b FROM t_ab1 RIGHT JOIN t_ab2 ON (t_ab1.a == t_ab2.a AND t_ab1.b == t_ab2.b) ORDER BY ifNull(t_ab1.id, t_ab2.id);
SELECT '= inner =';
SELECT a, b, t_ab2.a, t_ab2.b FROM t_ab1 INNER JOIN t_ab2 ON (t_ab1.a == t_ab2.a AND t_ab1.b == t_ab2.b) ORDER BY ifNull(t_ab1.id, t_ab2.id);

SELECT '= agg =';
SELECT sum(a), sum(b) FROM t_ab1 FULL JOIN t_ab2 USING (a, b);
SELECT sum(a), sum(b) FROM t_ab1 LEFT JOIN t_ab2 USING (a, b);
SELECT sum(a), sum(b) FROM t_ab1 RIGHT JOIN t_ab2 USING (a, b);
SELECT sum(a), sum(b) FROM t_ab1 INNER JOIN t_ab2 USING (a, b);

SELECT sum(a) + sum(t_ab2.a) - 1, sum(b) + sum(t_ab2.b) - 1 FROM t_ab1 FULL JOIN t_ab2 ON (t_ab1.a == t_ab2.a AND t_ab1.b == t_ab2.b);
SELECT sum(a) + sum(t_ab2.a) - 1, sum(b) + sum(t_ab2.b) - 1 FROM t_ab1 LEFT JOIN t_ab2 ON (t_ab1.a == t_ab2.a AND t_ab1.b == t_ab2.b);
SELECT sum(a) + sum(t_ab2.a) - 1, sum(b) + sum(t_ab2.b) - 1 FROM t_ab1 RIGHT JOIN t_ab2 ON (t_ab1.a == t_ab2.a AND t_ab1.b == t_ab2.b);
SELECT sum(a) + sum(t_ab2.a) - 1, sum(b) + sum(t_ab2.b) - 1 FROM t_ab1 INNER JOIN t_ab2 ON (t_ab1.a == t_ab2.a AND t_ab1.b == t_ab2.b);

SELECT '= types =';

SELECT any(toTypeName(a)) == 'Int32' AND any(toTypeName(b)) == 'Nullable(Int64)' FROM t_ab1 FULL JOIN t_ab2 USING (a, b);
SELECT any(toTypeName(a)) == 'Int32' AND any(toTypeName(b)) == 'Nullable(Int64)' FROM t_ab1 LEFT JOIN t_ab2 USING (a, b);
SELECT any(toTypeName(a)) == 'Int32' AND any(toTypeName(b)) == 'Nullable(Int64)' FROM t_ab1 RIGHT JOIN t_ab2 USING (a, b);
SELECT any(toTypeName(a)) == 'Int32' AND any(toTypeName(b)) == 'Nullable(Int64)' FROM t_ab1 INNER JOIN t_ab2 USING (a, b);

DROP TABLE IF EXISTS t_ab1;
DROP TABLE IF EXISTS t_ab2;