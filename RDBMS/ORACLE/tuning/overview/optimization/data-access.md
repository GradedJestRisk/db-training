# Data access

> The most efficient access path is able to process the data by consuming the least amount of resources. Therefore, to recognize whether an access path is efficient, you have to recognize whether the amount of resources used for its processing is acceptable. 
> To do so, it’s necessary to define both 
> - how to measure the utilization of resources 
> - what “acceptable” means
> - how much effort is needed to implement a check

> Keep in mind that this section focuses on efficiency, not on speed alone. It’s essential to understand that the most efficient access path isn’t always the fastest one. With parallel processing, it’s sometimes possible to achieve a better response time even though the amount of resources used is higher. Of course, when you consider the whole system, the fewer resources used by SQL statements (in other words, the higher their efficiency is), the more scalable, and faster, the system is. This is true because, by definition, resources are limited.

> As a first approximation, the amount of resources used by an access path is acceptable when it’s proportional to the amount of returned rows (that is, the number of rows that are returned to the parent operation in the execution plan). In other words, when few rows are returned, the expected utilization of resources is low, and when lots of rows are returned, the expected utilization of resources is high. Consequently, the check should be based on the amount of resources used to return a single row.