CREATE TABLE IF NOT EXISTS illegal_warehouses
(
    warehouse VARCHAR(200) PRIMARY KEY NOT NULL,
    label VARCHAR(200) NOT NULL,
    owner VARCHAR(200) NOT NULL,
    ownerDisplayName VARCHAR(200) NOT NULL
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
 ('storage1', 'Warehouse 1', 1),
 ('storage2', 'Warehouse 2', 1),
 ('storage3', 'Warehouse 3', 1),
 ('storage4', 'Warehouse 4', 1),
 ('storage5', 'Warehouse 5', 1),
 ('storage6', 'Warehouse 6', 1);

 INSERT INTO datastore (name, label, shared)
 VALUES
 ('storage1', 'Warehouse 1', 1),
 ('storage2', 'Warehouse 2', 1),
 ('storage3', 'Warehouse 3', 1),
 ('storage4', 'Warehouse 4', 1),
 ('storage5', 'Warehouse 5', 1),
 ('storage6', 'Warehouse 6', 1);