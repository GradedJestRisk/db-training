CREATE function getFirstDayOfWeek(y in binary_integer, w in binary_integer) return date
IS
   td date;
BEGIN

-- usage
/*   SELECT 
      getFirstDayOfWeek( y => 2018, w=> 25)          week_start, 
      getFirstDayOfWeek( y => 2018, w=> 25 + 1) - 1  week_end
   FROM 
      dual
   ;
*/
    td:=TO_DATE(TO_CHAR(y)||'0101', 'YYYYMMDD');

    for c in 0..52
    loop
        if TO_NUMBER(TO_CHAR(td, 'IW'))=w then
            return TRUNC(td, 'IW');
        end if;
        td:=td+7;
    end loop;
    return null;



END getFirstDayOfWeek;