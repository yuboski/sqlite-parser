-- original: where.test
-- credit:   http://www.sqlite.org/src/tree?ci=trunk&name=test

CREATE TABLE t1(w int, x int, y int);
    CREATE TABLE t2(p int, q int, r int, s int)
;INSERT INTO t1 VALUES(sub_w,sub_x,sub_y)
;INSERT INTO t2 SELECT 101-w, x, (SELECT max(y) FROM t1)+1-y, y FROM t1
;select max(y) from t1
;CREATE INDEX i1w ON t1("w");  -- Verify quoted identifier names
    CREATE INDEX i1xy ON t1(`x`,'y' ASC); -- Old MySQL compatibility
    CREATE INDEX i2p ON t2(p);
    CREATE INDEX i2r ON t2(r);
    CREATE INDEX i2qs ON t2(q, s)
;SELECT x, y, w FROM t1 WHERE w=10
;SELECT x, y, w FROM t1 WHERE w IS 10
;SELECT x, y, w FROM t1 WHERE +w=10
;SELECT x, y, w FROM t1 WHERE +w=10
;SELECT x, y, w AS abc FROM t1 WHERE abc=10
;SELECT w, x, y FROM t1 WHERE 11=w AND x>2
;SELECT w, x, y FROM t1 WHERE 11 IS w AND x>2
;SELECT w AS a, x AS b, y FROM t1 WHERE 11=a AND b>2
;SELECT x, y FROM t1 WHERE y<200 AND w=11 AND x>2
;SELECT x, y FROM t1 WHERE w>10 AND y=144 AND x=3
;SELECT x, y FROM t1 WHERE y=144 AND x=3
;SELECT 99 WHERE 0
;SELECT 99 WHERE 1
;SELECT 99 WHERE 0.1
;SELECT 99 WHERE 0.0
;SELECT count(*) FROM t1 WHERE t1.w
;SELECT w, x, y FROM t1 WHERE x IN (1,5) AND y IN (9,8,3025,1000,3969)
       ORDER BY x, y
;SELECT w, x, y FROM t1 WHERE x IN (1,5) AND y IN (9,8,3025,1000,3969)
       ORDER BY x DESC, y DESC
;SELECT w, x, y FROM t1 WHERE x IN (1,5) AND y IN (9,8,3025,1000,3969)
       ORDER BY x DESC, y
;SELECT w, x, y FROM t1 WHERE x IN (1,5) AND y IN (9,8,3025,1000,3969)
       ORDER BY x, y DESC
;CREATE TABLE t3(a,b,c);
    CREATE INDEX t3a ON t3(a);
    CREATE INDEX t3bc ON t3(b,c);
    CREATE INDEX t3acb ON t3(a,c,b);
    INSERT INTO t3 SELECT w, 101-w, y FROM t1;
    SELECT count(*), sum(a), sum(b), sum(c) FROM t3
;CREATE TABLE t4 AS SELECT * FROM t1;
    CREATE INDEX i4xy ON t4(x,y)
;DELETE FROM t4
;CREATE TABLE t5(x PRIMARY KEY);
    SELECT * FROM t5 WHERE x<10
;SELECT * FROM t5 WHERE x<10 ORDER BY x DESC
;SELECT * FROM t5 WHERE x=10
;SELECT 1 WHERE abs(random())<0
;SELECT count(*) FROM t1 WHERE tclvar('v1')
;SELECT count(*) FROM t1 WHERE tclvar('v1')
;SELECT count(*) FROM t1 WHERE tclvar('v1')
;CREATE TABLE t99(Dte INT, X INT);
   DELETE FROM t99 WHERE (Dte = 2451337) OR (Dte = 2451339) OR
     (Dte BETWEEN 2451345 AND 2451347) OR (Dte = 2451351) OR 
     (Dte BETWEEN 2451355 AND 2451356) OR (Dte = 2451358) OR
     (Dte = 2451362) OR (Dte = 2451365) OR (Dte = 2451367) OR
     (Dte BETWEEN 2451372 AND 2451376) OR (Dte BETWEEN 2451382 AND 2451384) OR
     (Dte = 2451387) OR (Dte BETWEEN 2451389 AND 2451391) OR 
     (Dte BETWEEN 2451393 AND 2451395) OR (Dte = 2451400) OR 
     (Dte = 2451402) OR (Dte = 2451404) OR (Dte BETWEEN 2451416 AND 2451418) OR 
     (Dte = 2451422) OR (Dte = 2451426) OR (Dte BETWEEN 2451445 AND 2451446) OR
     (Dte = 2451456) OR (Dte = 2451458) OR (Dte BETWEEN 2451465 AND 2451467) OR
     (Dte BETWEEN 2451469 AND 2451471) OR (Dte = 2451474) OR
     (Dte BETWEEN 2451477 AND 2451501) OR (Dte BETWEEN 2451503 AND 2451509) OR
     (Dte BETWEEN 2451511 AND 2451514) OR (Dte BETWEEN 2451518 AND 2451521) OR
     (Dte BETWEEN 2451523 AND 2451531) OR (Dte BETWEEN 2451533 AND 2451537) OR
     (Dte BETWEEN 2451539 AND 2451544) OR (Dte BETWEEN 2451546 AND 2451551) OR
     (Dte BETWEEN 2451553 AND 2451555) OR (Dte = 2451557) OR
     (Dte BETWEEN 2451559 AND 2451561) OR (Dte = 2451563) OR
     (Dte BETWEEN 2451565 AND 2451566) OR (Dte BETWEEN 2451569 AND 2451571) OR 
     (Dte = 2451573) OR (Dte = 2451575) OR (Dte = 2451577) OR (Dte = 2451581) OR
     (Dte BETWEEN 2451583 AND 2451586) OR (Dte BETWEEN 2451588 AND 2451592) OR 
     (Dte BETWEEN 2451596 AND 2451598) OR (Dte = 2451600) OR
     (Dte BETWEEN 2451602 AND 2451603) OR (Dte = 2451606) OR (Dte = 2451611)
;CREATE TABLE t6(a INTEGER PRIMARY KEY, b TEXT);
    INSERT INTO t6 VALUES(1,'one');
    INSERT INTO t6 VALUES(4,'four');
    CREATE INDEX t6i1 ON t6(b)
;CREATE TABLE t7(a INTEGER PRIMARY KEY, b TEXT);
    INSERT INTO t7 VALUES(1,'one');
    INSERT INTO t7 VALUES(4,'four');
    CREATE INDEX t7i1 ON t7(b)
;CREATE TABLE t8(a INTEGER PRIMARY KEY, b TEXT UNIQUE, c CHAR(100));
    INSERT INTO t8(a,b) VALUES(1,'one');
    INSERT INTO t8(a,b) VALUES(4,'four')
;CREATE TEMP TABLE t1 (a, b, c, d, e);
    CREATE TEMP TABLE t2 (f);
    SELECT t1.e AS alias FROM t2, t1 WHERE alias = 1 
;CREATE TABLE a1(id INTEGER PRIMARY KEY, v);
    CREATE TABLE a2(id INTEGER PRIMARY KEY, v);
    INSERT INTO a1 VALUES(1, 'one');
    INSERT INTO a1 VALUES(2, 'two');
    INSERT INTO a2 VALUES(1, 'one');
    INSERT INTO a2 VALUES(2, 'two')
;SELECT * FROM a2 CROSS JOIN a1 WHERE a1.id=1 AND a1.v='one'
;CREATE TEMP TABLE foo(idx INTEGER);
    INSERT INTO foo VALUES(1);
    INSERT INTO foo VALUES(1);
    INSERT INTO foo VALUES(1);
    INSERT INTO foo VALUES(2);
    INSERT INTO foo VALUES(2);
    CREATE TEMP TABLE bar(stuff INTEGER);
    INSERT INTO bar VALUES(100);
    INSERT INTO bar VALUES(200);
    INSERT INTO bar VALUES(300)
;SELECT bar.RowID id FROM foo, bar WHERE foo.idx = bar.RowID AND id = 2
;CREATE TABLE tbooking (
      id INTEGER PRIMARY KEY,
      eventtype INTEGER NOT NULL
    );
    INSERT INTO tbooking VALUES(42, 3);
    INSERT INTO tbooking VALUES(43, 4)
;SELECT a.id
    FROM tbooking AS a
    WHERE a.eventtype=3
;SELECT a.id, (SELECT b.id FROM tbooking AS b WHERE b.id>a.id)
    FROM tbooking AS a
    WHERE a.eventtype=3
;SELECT a.id, (SELECT b.id FROM tbooking AS b WHERE b.id>a.id)
    FROM (SELECT 1.5 AS id) AS a
;CREATE TABLE tother(a, b);
    INSERT INTO tother VALUES(1, 3.7);
    SELECT id, a FROM tbooking, tother WHERE id>a
;CREATE TABLE t181(a);
  CREATE TABLE t182(b,c);
  INSERT INTO t181 VALUES(1);
  SELECT DISTINCT a FROM t181 LEFT JOIN t182 ON a=b ORDER BY c IS NULL
;SELECT DISTINCT a FROM t181 LEFT JOIN t182 ON a=b ORDER BY +c
;SELECT DISTINCT a FROM t181 LEFT JOIN t182 ON a=b ORDER BY c
;INSERT INTO t181 VALUES(1),(1),(1),(1);
  SELECT DISTINCT a FROM t181 LEFT JOIN t182 ON a=b ORDER BY +c
;INSERT INTO t181 VALUES(2);
  SELECT DISTINCT a FROM t181 LEFT JOIN t182 ON a=b ORDER BY c IS NULL, +a
;INSERT INTO t181 VALUES(2);
  SELECT DISTINCT a FROM t181 LEFT JOIN t182 ON a=b ORDER BY +a, +c IS NULL;