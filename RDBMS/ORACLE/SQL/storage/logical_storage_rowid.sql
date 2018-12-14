SELECT
    'ROWID=>'  rpr_cnt
   ,fil.ROWID  row_dtf
   ,SUBSTR(fil.ROWID,  1, 6)  data_object_number
   ,SUBSTR(fil.ROWID,  7, 3)  relative_file_number
   ,SUBSTR(fil.ROWID, 10, 6)  block_number
   ,SUBSTR(fil.ROWID, 17, 3)  data_object_number
   ,fil.*
FROM 
   filiere fil
;