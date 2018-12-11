CREATE OR REPLACE PACKAGE pkg_plsqlunit
IS

   FUNCTION package_name RETURN all_objects.object_name%TYPE;

   PROCEDURE who_called_me (
      owner_name    OUT all_users.username%TYPE,
      caller_name   OUT all_objects.object_name%TYPE,
      line_number   OUT all_source.line%TYPE,
      caller_type   OUT all_users.username%TYPE);


   PROCEDURE test_who_called_me (
      owner_name    OUT all_users.username%TYPE,
      caller_name   OUT all_objects.object_name%TYPE,
      line_number   OUT all_source.line%TYPE,
      caller_type   OUT all_users.username%TYPE);

   FUNCTION who_am_i return VARCHAR2;

END pkg_plsqlunit;
/
CREATE OR REPLACE PACKAGE BODY pkg_plsqlunit
IS


   FUNCTION package_name RETURN all_objects.object_name%TYPE
   IS
   BEGIN

      RETURN $$plsql_unit;

   END package_name;

   PROCEDURE who_called_me (
      owner_name    OUT all_users.username%TYPE,
      caller_name   OUT all_objects.object_name%TYPE,
      line_number   OUT all_source.line%TYPE,
      caller_type   OUT all_users.username%TYPE)
   IS

   BEGIN

      owa_util.who_called_me
            ( owner      => owner_name,
              name       => caller_name,
              lineno     => line_number,
              caller_t   => caller_type);
      
   END who_called_me;

   PROCEDURE test_who_called_me (
      owner_name    OUT all_users.username%TYPE,
      caller_name   OUT all_objects.object_name%TYPE,
      line_number   OUT all_source.line%TYPE,
      caller_type   OUT all_users.username%TYPE)
   IS

   BEGIN

      who_called_me
            ( owner_name      => owner_name,
              caller_name       => caller_name,
              line_number     => line_number,
              caller_type   => caller_type);

   
      
   END test_who_called_me;

   FUNCTION who_am_i return varchar2
   is
      l_owner        varchar2(30);
      l_name      varchar2(30);
      l_lineno    number;
      l_type      varchar2(30);
   begin
     who_called_me( l_owner, l_name, l_lineno, l_type );
     return l_owner || '.' || l_name;
   END who_am_i;

     
END pkg_plsqlunit;
/
