CREATE TABLE IF NOT EXISTS illegal_warehouses
(
    warehouse VARCHAR(20) PRIMARY KEY NOT NULL,
    label VARCHAR(20),
    owner CHAR(20)
);

INSERT INTO illegal_warehouses (warehouse, label)
 VALUES
 ('Storage1', 'Warehouse 1'),
 ('Storage2', 'Warehouse 2'),
 ('Storage3', 'Warehouse 3'),
 ('Storage4', 'Warehouse 4'),
 ('Storage5', 'Warehouse 5'),
 ('Storage6', 'Warehouse 6');

INSERT INTO addon_inventory (name, label, shared)
 VALUES
 ('Storage1', 'Warehouse 1', 1),
 ('Storage2', 'Warehouse 2', 1),
 ('Storage3', 'Warehouse 3', 1),
 ('Storage4', 'Warehouse 4', 1),
 ('Storage5', 'Warehouse 5', 1),
 ('Storage6', 'Warehouse 6', 1);

 INSERT INTO datastore (name, label, shared)
 VALUES
 ('Storage1', 'Warehouse 1', 1),
 ('Storage2', 'Warehouse 2', 1),
 ('Storage3', 'Warehouse 3', 1),
 ('Storage4', 'Warehouse 4', 1),
 ('Storage5', 'Warehouse 5', 1),
 ('Storage6', 'Warehouse 6', 1);