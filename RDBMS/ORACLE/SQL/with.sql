WITH dept_count AS (
  SELECT deptno, COUNT(*) AS dept_count
  FROM   emp
  GROUP BY deptno)
SELECT e.ename AS employee_name,
       dc1.dept_count AS emp_dept_count,
       m.ename AS manager_name,
       dc2.dept_count AS mgr_dept_count
FROM   emp e
       JOIN dept_count dc1 ON e.deptno = dc1.deptno
       JOIN emp m ON e.mgr = m.empno
       JOIN dept_count dc2 ON m.deptno = dc2.deptno;