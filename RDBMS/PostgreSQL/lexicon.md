# Lexicon

## block or page ?
> https://dba.stackexchange.com/questions/254843/trying-to-understand-tid-definition-from-postgresql-documentation
One tends to use the term “block” when speaking of disk storage and “page” when the data reside in memory, but it is the same.


## row, tuple, item

tuple is logical model and mathematical  

row is SQL physical model 

item is PG physical PG layout in block
strictly speaking, several item can refer to several versions of the same row


## clog

commit log
even if it contains transaction status, which may not be "commit"
 

