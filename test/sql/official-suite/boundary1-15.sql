-- original: boundary1.test
-- credit:   http://www.sqlite.org/src/tree?ci=trunk&name=test

SELECT a FROM t1 WHERE rowid <= 36028797018963968 ORDER BY rowid DESC
;SELECT a FROM t1 WHERE rowid <= 36028797018963968 ORDER BY x
;SELECT * FROM t1 WHERE rowid=-2147483649
;SELECT rowid, a FROM t1 WHERE x='ffffffff7fffffff'
;SELECT rowid, x FROM t1 WHERE a=47
;SELECT a FROM t1 WHERE rowid > -2147483649 ORDER BY a
;SELECT a FROM t1 WHERE rowid > -2147483649 ORDER BY a DESC
;SELECT a FROM t1 WHERE rowid > -2147483649 ORDER BY rowid
;SELECT a FROM t1 WHERE rowid > -2147483649 ORDER BY rowid DESC
;SELECT a FROM t1 WHERE rowid > -2147483649 ORDER BY x
;SELECT a FROM t1 WHERE rowid >= -2147483649 ORDER BY a
;SELECT a FROM t1 WHERE rowid >= -2147483649 ORDER BY a DESC
;SELECT a FROM t1 WHERE rowid >= -2147483649 ORDER BY rowid
;SELECT a FROM t1 WHERE rowid >= -2147483649 ORDER BY rowid DESC
;SELECT a FROM t1 WHERE rowid >= -2147483649 ORDER BY x
;SELECT a FROM t1 WHERE rowid < -2147483649 ORDER BY a
;SELECT a FROM t1 WHERE rowid < -2147483649 ORDER BY a DESC
;SELECT a FROM t1 WHERE rowid < -2147483649 ORDER BY rowid
;SELECT a FROM t1 WHERE rowid < -2147483649 ORDER BY rowid DESC
;SELECT a FROM t1 WHERE rowid < -2147483649 ORDER BY x
;SELECT a FROM t1 WHERE rowid <= -2147483649 ORDER BY a
;SELECT a FROM t1 WHERE rowid <= -2147483649 ORDER BY a DESC
;SELECT a FROM t1 WHERE rowid <= -2147483649 ORDER BY rowid
;SELECT a FROM t1 WHERE rowid <= -2147483649 ORDER BY rowid DESC
;SELECT a FROM t1 WHERE rowid <= -2147483649 ORDER BY x
;SELECT * FROM t1 WHERE rowid=-36028797018963969
;SELECT rowid, a FROM t1 WHERE x='ff7fffffffffffff'
;SELECT rowid, x FROM t1 WHERE a=2
;SELECT a FROM t1 WHERE rowid > -36028797018963969 ORDER BY a
;SELECT a FROM t1 WHERE rowid > -36028797018963969 ORDER BY a DESC
;SELECT a FROM t1 WHERE rowid > -36028797018963969 ORDER BY rowid
;SELECT a FROM t1 WHERE rowid > -36028797018963969 ORDER BY rowid DESC
;SELECT a FROM t1 WHERE rowid > -36028797018963969 ORDER BY x
;SELECT a FROM t1 WHERE rowid >= -36028797018963969 ORDER BY a
;SELECT a FROM t1 WHERE rowid >= -36028797018963969 ORDER BY a DESC
;SELECT a FROM t1 WHERE rowid >= -36028797018963969 ORDER BY rowid
;SELECT a FROM t1 WHERE rowid >= -36028797018963969 ORDER BY rowid DESC
;SELECT a FROM t1 WHERE rowid >= -36028797018963969 ORDER BY x
;SELECT a FROM t1 WHERE rowid < -36028797018963969 ORDER BY a
;SELECT a FROM t1 WHERE rowid < -36028797018963969 ORDER BY a DESC
;SELECT a FROM t1 WHERE rowid < -36028797018963969 ORDER BY rowid
;SELECT a FROM t1 WHERE rowid < -36028797018963969 ORDER BY rowid DESC
;SELECT a FROM t1 WHERE rowid < -36028797018963969 ORDER BY x
;SELECT a FROM t1 WHERE rowid <= -36028797018963969 ORDER BY a
;SELECT a FROM t1 WHERE rowid <= -36028797018963969 ORDER BY a DESC
;SELECT a FROM t1 WHERE rowid <= -36028797018963969 ORDER BY rowid
;SELECT a FROM t1 WHERE rowid <= -36028797018963969 ORDER BY rowid DESC
;SELECT a FROM t1 WHERE rowid <= -36028797018963969 ORDER BY x
;SELECT * FROM t1 WHERE rowid=3
;SELECT rowid, a FROM t1 WHERE x='0000000000000003'
;SELECT rowid, x FROM t1 WHERE a=5
;SELECT a FROM t1 WHERE rowid > 3 ORDER BY a
;SELECT a FROM t1 WHERE rowid > 3 ORDER BY a DESC
;SELECT a FROM t1 WHERE rowid > 3 ORDER BY rowid
;SELECT a FROM t1 WHERE rowid > 3 ORDER BY rowid DESC
;SELECT a FROM t1 WHERE rowid > 3 ORDER BY x
;SELECT a FROM t1 WHERE rowid >= 3 ORDER BY a
;SELECT a FROM t1 WHERE rowid >= 3 ORDER BY a DESC
;SELECT a FROM t1 WHERE rowid >= 3 ORDER BY rowid
;SELECT a FROM t1 WHERE rowid >= 3 ORDER BY rowid DESC
;SELECT a FROM t1 WHERE rowid >= 3 ORDER BY x
;SELECT a FROM t1 WHERE rowid < 3 ORDER BY a
;SELECT a FROM t1 WHERE rowid < 3 ORDER BY a DESC
;SELECT a FROM t1 WHERE rowid < 3 ORDER BY rowid
;SELECT a FROM t1 WHERE rowid < 3 ORDER BY rowid DESC
;SELECT a FROM t1 WHERE rowid < 3 ORDER BY x
;SELECT a FROM t1 WHERE rowid <= 3 ORDER BY a
;SELECT a FROM t1 WHERE rowid <= 3 ORDER BY a DESC
;SELECT a FROM t1 WHERE rowid <= 3 ORDER BY rowid
;SELECT a FROM t1 WHERE rowid <= 3 ORDER BY rowid DESC
;SELECT a FROM t1 WHERE rowid <= 3 ORDER BY x
;SELECT a FROM t1 WHERE rowid > 9.22337303685477580800e+18 ORDER BY a
;SELECT a FROM t1 WHERE rowid > 9.22337303685477580800e+18 ORDER BY a DESC
;SELECT a FROM t1 WHERE rowid > 9.22337303685477580800e+18 ORDER BY rowid
;SELECT a FROM t1 WHERE rowid > 9.22337303685477580800e+18 ORDER BY rowid DESC
;SELECT a FROM t1 WHERE rowid > 9.22337303685477580800e+18 ORDER BY x
;SELECT a FROM t1 WHERE rowid >= 9.22337303685477580800e+18 ORDER BY a
;SELECT a FROM t1 WHERE rowid >= 9.22337303685477580800e+18 ORDER BY a DESC
;SELECT a FROM t1 WHERE rowid >= 9.22337303685477580800e+18 ORDER BY rowid
;SELECT a FROM t1 WHERE rowid >= 9.22337303685477580800e+18 ORDER BY rowid DESC
;SELECT a FROM t1 WHERE rowid >= 9.22337303685477580800e+18 ORDER BY x
;SELECT a FROM t1 WHERE rowid < 9.22337303685477580800e+18 ORDER BY a
;SELECT a FROM t1 WHERE rowid < 9.22337303685477580800e+18 ORDER BY a DESC
;SELECT a FROM t1 WHERE rowid < 9.22337303685477580800e+18 ORDER BY rowid
;SELECT a FROM t1 WHERE rowid < 9.22337303685477580800e+18 ORDER BY rowid DESC
;SELECT a FROM t1 WHERE rowid < 9.22337303685477580800e+18 ORDER BY x
;SELECT a FROM t1 WHERE rowid <= 9.22337303685477580800e+18 ORDER BY a
;SELECT a FROM t1 WHERE rowid <= 9.22337303685477580800e+18 ORDER BY a DESC
;SELECT a FROM t1 WHERE rowid <= 9.22337303685477580800e+18 ORDER BY rowid
;SELECT a FROM t1 WHERE rowid <= 9.22337303685477580800e+18 ORDER BY rowid DESC
;SELECT a FROM t1 WHERE rowid <= 9.22337303685477580800e+18 ORDER BY x
;SELECT a FROM t1 WHERE rowid > -9.22337303685477580800e+18 ORDER BY a
;SELECT a FROM t1 WHERE rowid > -9.22337303685477580800e+18 ORDER BY a DESC
;SELECT a FROM t1 WHERE rowid > -9.22337303685477580800e+18 ORDER BY rowid
;SELECT a FROM t1 WHERE rowid > -9.22337303685477580800e+18 ORDER BY rowid DESC
;SELECT a FROM t1 WHERE rowid > -9.22337303685477580800e+18 ORDER BY x
;SELECT a FROM t1 WHERE rowid >= -9.22337303685477580800e+18 ORDER BY a
;SELECT a FROM t1 WHERE rowid >= -9.22337303685477580800e+18 ORDER BY a DESC
;SELECT a FROM t1 WHERE rowid >= -9.22337303685477580800e+18 ORDER BY rowid
;SELECT a FROM t1 WHERE rowid >= -9.22337303685477580800e+18 ORDER BY rowid DESC;