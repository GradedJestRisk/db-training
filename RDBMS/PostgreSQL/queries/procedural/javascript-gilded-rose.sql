DROP TABLE IF EXISTS item;

CREATE TABLE item
  (
    name    character varying(100) NOT NULL,
    sell_in numeric(6) NOT NULL,
    quality numeric(6) NOT NULL
  );

INSERT INTO item VALUES ('+5 Dexterity Vest', 10, 20);
INSERT INTO item VALUES ('Aged Brie', 2, 0);
INSERT INTO item VALUES ('Elixir of the Mongoose', 5, 7);
INSERT INTO item VALUES ('Sulfuras, Hand of Ragnaros', 0, 80);
INSERT INTO item VALUES ('Sulfuras, Hand of Ragnaros', -1, 80);
INSERT INTO item VALUES  ('Backstage passes to a TAFKAL80ETC concert', 15, 20);
INSERT INTO item VALUES  ('Backstage passes to a TAFKAL80ETC concert', 10, 49);
INSERT INTO item VALUES  ('Backstage passes to a TAFKAL80ETC concert', 5, 49);
INSERT INTO item VALUES  ('Conjured Mana Cake', 3, 6);

-- Check we can read from database
CREATE OR REPLACE FUNCTION read_items()
RETURNS JSON
AS $$
    const items = plv8.execute('SELECT * FROM item');
    return items;
$$ LANGUAGE plv8 IMMUTABLE STRICT;

SELECT jsonb_pretty(read_items()::jsonb);


-- Actually create component
DROP FUNCTION IF EXISTS updateAllItems;

CREATE OR REPLACE FUNCTION updateAllItems()
RETURNS TEXT
AS $$

    const items = plv8.execute('SELECT * FROM item');

    for (let i = 0; i < items.length; i++) {
      if (items[i].name != 'Aged Brie' && items[i].name != 'Backstage passes to a TAFKAL80ETC concert') {
        if (items[i].quality > 0) {
          if (items[i].name != 'Sulfuras, Hand of Ragnaros') {
            items[i].quality = items[i].quality - 1
          }
        }
      } else {
        if (items[i].quality < 50) {
          items[i].quality = items[i].quality + 1
          if (items[i].name == 'Backstage passes to a TAFKAL80ETC concert') {
            if (items[i].sell_in < 11) {
              if (items[i].quality < 50) {
                items[i].quality = items[i].quality + 1
              }
            }
            if (items[i].sell_in < 6) {
              if (items[i].quality < 50) {
                items[i].quality = items[i].quality + 1
              }
            }
          }
        }
      }
      if (items[i].name != 'Sulfuras, Hand of Ragnaros') {
        items[i].sell_in = items[i].sell_in - 1;
      }
      if (items[i].sell_in < 0) {
        if (items[i].name != 'Aged Brie') {
          if (items[i].name != 'Backstage passes to a TAFKAL80ETC concert') {
            if (items[i].quality > 0) {
              if (items[i].name != 'Sulfuras, Hand of Ragnaros') {
                items[i].quality = items[i].quality - 1
              }
            }
          } else {
            items[i].quality = items[i].quality - items[i].quality
          }
        } else {
          if (items[i].quality < 50) {
            items[i].quality = items[i].quality + 1
          }
        }
      }
    }

    items.map( (item) => {
       const values = [ item.quality, item.sell_in, item.name ];
       const query = 'UPDATE item SET quality = $1, sell_in = $2 WHERE name = $3';
       const updatedItem = plv8.execute(query, values);
    });

    const message = items.length + ' items successfully updated';
    return message;

$$ LANGUAGE plv8 VOLATILE STRICT;


SELECT * FROM item
WHERE 1=1
AND name = 'Elixir of the Mongoose';

SELECT updateAllItems();

SELECT * FROM item
WHERE 1=1
AND name = 'Elixir of the Mongoose';
