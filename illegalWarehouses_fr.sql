CREATE TABLE IF NOT EXISTS illegal_warehouses
(
    warehouse VARCHAR(20) PRIMARY KEY NOT NULL,
    label VARCHAR(20),
    owner CHAR(20)
);

INSERT INTO illegal_warehouses (warehouse, label)
 VALUES
 ('Storage1', 'Entrepôt 1'),
 ('Storage2', 'Entrepôt 2'),
 ('Storage3', 'Entrepôt 3'),
 ('Storage4', 'Entrepôt 4'),
 ('Storage5', 'Entrepôt 5'),
 ('Storage6', 'Entrepôt 6');

INSERT INTO addon_inventory (name, label, shared)
 VALUES
 ('Storage1', 'Entrepôt 1', 1),
 ('Storage2', 'Entrepôt 2', 1),
 ('Storage3', 'Entrepôt 3', 1),
 ('Storage4', 'Entrepôt 4', 1),
 ('Storage5', 'Entrepôt 5', 1),
 ('Storage6', 'Entrepôt 6', 1);

 INSERT INTO datastore (name, label, shared)
 VALUES
 ('Storage1', 'Entrepôt 1', 1),
 ('Storage2', 'Entrepôt 2', 1),
 ('Storage3', 'Entrepôt 3', 1),
 ('Storage4', 'Entrepôt 4', 1),
 ('Storage5', 'Entrepôt 5', 1),
 ('Storage6', 'Entrepôt 6', 1);