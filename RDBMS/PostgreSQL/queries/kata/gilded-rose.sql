TRUNCATE TABLE item;

--P1
do $$
begin
	call update_quality();
end
$$;


CALL update_item(p_id := rec_item.id, p_quality := rec_item.quality, p_sell_in := rec_item.sellIn);

--P2
do $$
begin
	CALL update_item(p_id := 'id2', p_quality := 2, p_sell_in := 10);
end
$$;

SELECT *
FROM item i
WHERE 1=1
 --   AND name = 'Aged Brie'
;

SELECT *
FROM item i
WHERE 1=1
    AND id = 'id2'
;


SELECT *
FROM item i
WHERE 1=1
    AND name = 'Elixir of the Mongoose'
;

SELECT *
FROM item i
WHERE 1=1
    AND name = 'Elixir of the Mongoose'
    AND sellin  = 2
    AND quality = 4
;