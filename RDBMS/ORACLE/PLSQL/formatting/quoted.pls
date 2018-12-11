create or replace function fap.quoted(unquotedString VARCHAR2) return varchar2 IS
  quotedString  varchar2(500);
begin
  quotedString :=  CHR(39) || (unquotedString) || CHR(39);
  return quotedString;
end quoted;
/
