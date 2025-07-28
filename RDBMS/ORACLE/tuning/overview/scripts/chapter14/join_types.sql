SET ECHO OFF
REM ***************************************************************************
REM ******************* Troubleshooting Oracle Performance ********************
REM ************************* http://top.antognini.ch *************************
REM ***************************************************************************
REM
REM File name...: join_types.sql
REM Author......: Christian Antognini
REM Date........: August 2008
REM Description.: This script provides an example for each type of join.
REM Notes.......: -
REM Parameters..: -
REM
REM You can send feedbacks or questions about this script to top@antognini.ch.
REM
REM Changes:
REM DD.MM.YYYY Description
REM ---------------------------------------------------------------------------
REM 05.03.2014 Added examples with ANY and SOME
REM 14.03.2014 Added examples with LATERAL, OUTER APPLY and CROSS APPLY
REM 30.07.2015 Added statements to insert data into the test tables
REM ***************************************************************************

SET TERMOUT ON
SET FEEDBACK OFF
SET VERIFY OFF
SET SCAN ON

@../connect.sql

SET ECHO ON

REM
REM Setup test environment
REM

DROP TABLE dept CASCADE CONSTRAINT PURGE;

CREATE TABLE dept
       (deptno NUMBER(2),
        dname VARCHAR2(14),
        loc VARCHAR2(13) );

INSERT INTO DEPT VALUES (10, 'ACCOUNTING', 'NEW YORK');
INSERT INTO DEPT VALUES (20, 'RESEARCH',   'DALLAS');
INSERT INTO DEPT VALUES (30, 'SALES',      'CHICAGO');
INSERT INTO DEPT VALUES (40, 'OPERATIONS', 'BOSTON');
COMMIT;

DROP TABLE emp CASCADE CONSTRAINT PURGE;

CREATE TABLE emp
       (empno NUMBER(4) NOT NULL,
        ename VARCHAR2(10),
        job VARCHAR2(9),
        mgr NUMBER(4),
        hiredate DATE,
        sal NUMBER(7, 2),
        comm NUMBER(7, 2),
        deptno NUMBER(2));

INSERT INTO EMP VALUES
        (7369, 'SMITH',  'CLERK',     7902,
        TO_DATE('17-DEC-1980', 'DD-MON-YYYY'),  800, NULL, 20);
INSERT INTO EMP VALUES
        (7499, 'ALLEN',  'SALESMAN',  7698,
        TO_DATE('20-FEB-1981', 'DD-MON-YYYY'), 1600,  300, 30);
INSERT INTO EMP VALUES
        (7521, 'WARD',   'SALESMAN',  7698,
        TO_DATE('22-FEB-1981', 'DD-MON-YYYY'), 1250,  500, 30);
INSERT INTO EMP VALUES
        (7566, 'JONES',  'MANAGER',   7839,
        TO_DATE('2-APR-1981', 'DD-MON-YYYY'),  2975, NULL, 20);
INSERT INTO EMP VALUES
        (7654, 'MARTIN', 'SALESMAN',  7698,
        TO_DATE('28-SEP-1981', 'DD-MON-YYYY'), 1250, 1400, 30);
INSERT INTO EMP VALUES
        (7698, 'BLAKE',  'MANAGER',   7839,
        TO_DATE('1-MAY-1981', 'DD-MON-YYYY'),  2850, NULL, 30);
INSERT INTO EMP VALUES
        (7782, 'CLARK',  'MANAGER',   7839,
        TO_DATE('9-JUN-1981', 'DD-MON-YYYY'),  2450, NULL, 10);
INSERT INTO EMP VALUES
        (7788, 'SCOTT',  'ANALYST',   7566,
        TO_DATE('09-DEC-1982', 'DD-MON-YYYY'), 3000, NULL, 20);
INSERT INTO EMP VALUES
        (7839, 'KING',   'PRESIDENT', NULL,
        TO_DATE('17-NOV-1981', 'DD-MON-YYYY'), 5000, NULL, 10);
INSERT INTO EMP VALUES
        (7844, 'TURNER', 'SALESMAN',  7698,
        TO_DATE('8-SEP-1981', 'DD-MON-YYYY'),  1500,    0, 30);
INSERT INTO EMP VALUES
        (7876, 'ADAMS',  'CLERK',     7788,
        TO_DATE('12-JAN-1983', 'DD-MON-YYYY'), 1100, NULL, 20);
INSERT INTO EMP VALUES
        (7900, 'JAMES',  'CLERK',     7698,
        TO_DATE('3-DEC-1981', 'DD-MON-YYYY'),   950, NULL, 30);
INSERT INTO EMP VALUES
        (7902, 'FORD',   'ANALYST',   7566,
        TO_DATE('3-DEC-1981', 'DD-MON-YYYY'),  3000, NULL, 20);
INSERT INTO EMP VALUES
        (7934, 'MILLER', 'CLERK',     7782,
        TO_DATE('23-JAN-1982', 'DD-MON-YYYY'), 1300, NULL, 10);
COMMIT;

DROP TABLE salgrade PURGE;

CREATE TABLE salgrade
        (GRADE NUMBER,
         LOSAL NUMBER,
         HISAL NUMBER);

INSERT INTO SALGRADE VALUES (1,  700, 1200);
INSERT INTO SALGRADE VALUES (2, 1201, 1400);
INSERT INTO SALGRADE VALUES (3, 1401, 2000);
INSERT INTO SALGRADE VALUES (4, 2001, 3000);
INSERT INTO SALGRADE VALUES (5, 3001, 9999);
COMMIT;

BEGIN
  dbms_stats.gather_table_stats(user, 'dept');
  dbms_stats.gather_table_stats(user, 'emp');
  dbms_stats.gather_table_stats(user, 'salgrade');
END;
/

PAUSE

SET AUTOTRACE TRACEONLY EXPLAIN

REM
REM cross join
REM

SELECT emp.ename, dept.dname
FROM emp, dept;

PAUSE

SELECT emp.ename, dept.dname 
FROM emp CROSS JOIN dept;

PAUSE

REM
REM theta join
REM

SELECT emp.ename, salgrade.grade 
FROM emp, salgrade
WHERE emp.sal BETWEEN salgrade.losal AND salgrade.hisal;

PAUSE

SELECT emp.ename, salgrade.grade 
FROM emp JOIN salgrade ON emp.sal BETWEEN salgrade.losal AND salgrade.hisal;

PAUSE

SELECT emp.ename, salgrade.grade 
FROM emp INNER JOIN salgrade ON emp.sal BETWEEN salgrade.losal AND salgrade.hisal;

PAUSE

REM
REM equi join 
REM

SELECT emp.ename, dept.dname 
FROM emp, dept 
WHERE emp.deptno = dept.deptno;

PAUSE

SELECT emp.ename, dept.dname 
FROM emp JOIN dept ON emp.deptno = dept.deptno;

PAUSE

SELECT emp.ename, dept.dname 
FROM emp INNER JOIN dept ON emp.deptno = dept.deptno;

PAUSE

REM
REM self join
REM

SELECT emp.ename, mgr.ename
FROM emp, emp mgr
WHERE emp.mgr = mgr.empno;

PAUSE

SELECT emp.ename, mgr.ename
FROM emp JOIN emp mgr ON emp.mgr = mgr.empno;

PAUSE

REM
REM outer join
REM

SELECT emp.ename, mgr.ename
FROM emp, emp mgr
WHERE emp.mgr = mgr.empno(+);

PAUSE

SELECT emp.ename, mgr.ename
FROM emp LEFT JOIN emp mgr ON emp.mgr = mgr.empno;

PAUSE

SELECT emp.ename, mgr.ename
FROM emp mgr RIGHT JOIN emp ON emp.mgr = mgr.empno;

PAUSE

SELECT emp.ename, mgr.ename
FROM emp FULL OUTER JOIN emp mgr ON emp.mgr = mgr.empno;

PAUSE

SELECT emp.ename, mgr.ename
FROM emp LEFT OUTER JOIN emp mgr ON emp.mgr = mgr.empno;

PAUSE

SELECT emp.ename, mgr.ename
FROM emp mgr RIGHT OUTER JOIN emp ON emp.mgr = mgr.empno;

PAUSE

SELECT dept.dname, count(emp.empno)
FROM dept LEFT JOIN emp PARTITION BY (emp.job) ON emp.deptno = dept.deptno
WHERE emp.job = 'MANAGER'
GROUP BY dept.dname;

PAUSE

REM
REM semi join
REM

SELECT deptno, dname, loc
FROM dept 
WHERE deptno IN (SELECT deptno FROM emp);

PAUSE

SELECT deptno, dname, loc
FROM dept 
WHERE EXISTS (SELECT deptno FROM emp WHERE emp.deptno = dept.deptno);

PAUSE

SELECT deptno, dname, loc
FROM dept 
WHERE deptno = ANY (SELECT deptno FROM emp);

PAUSE

SELECT deptno, dname, loc
FROM dept 
WHERE deptno = SOME (SELECT deptno FROM emp);

PAUSE

REM
REM anti join
REM

SELECT deptno, dname, loc
FROM dept 
WHERE deptno NOT IN (SELECT deptno FROM emp);

PAUSE

SELECT deptno, dname, loc
FROM dept 
WHERE NOT EXISTS (SELECT deptno FROM emp WHERE emp.deptno = dept.deptno);

PAUSE

REM
REM Later inline views (work from 12.1 onward only)
REM

SELECT dname, ename
FROM dept, lateral(SELECT * FROM emp WHERE dept.deptno = emp.deptno);

PAUSE

REM the following raises an error

SELECT dname, empno
FROM dept, (SELECT * FROM emp WHERE dept.deptno = emp.deptno);

PAUSE

SELECT dname, ename
FROM dept CROSS APPLY (SELECT ename FROM emp WHERE dept.deptno = emp.deptno);

PAUSE

REM the following raises an error

SELECT dname, ename
FROM dept CROSS JOIN (SELECT ename FROM emp WHERE dept.deptno = emp.deptno);

PAUSE

SELECT dname, ename
FROM dept OUTER APPLY (SELECT ename FROM emp WHERE dept.deptno = emp.deptno);

PAUSE

REM
REM Cleanup
REM

DROP TABLE dept PURGE;
DROP TABLE emp PURGE;
DROP TABLE salgrade PURGE;
