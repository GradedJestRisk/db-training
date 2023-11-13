DECLARE @RC int


EXECUTE @RC = [dbo].[hello_world] 
   @NAME = 'world'
GO