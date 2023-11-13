ALTER PROCEDURE [dbo].[hello_world]
(
@NAME VARCHAR 
)

AS
BEGIN
    PRINT 'Hello, ' + @NAME + ' !';	
    RETURN 1;
	
END
go

grant execute on hello_world to usr_conf
go

