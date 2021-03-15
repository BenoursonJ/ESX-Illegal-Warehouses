CREATE TABLE IF NOT EXISTS illegal_warehouses
(
    warehouse VARCHAR(200) PRIMARY KEY NOT NULL,
    label VARCHAR(200) NOT NULL,
    owner VARCHAR(200) NOT NULL,
    ownerDisplayName VARCHAR(200) NOT NULL
);

INSERT INTO illegal_warehouses
VALUES
('Storage1', 'Entrepôt 1', ' ', ' '),
('Storage2', 'Entrepôt 2', ' ', ' '),
('Storage3', 'Entrepôt 3', ' ', ' '),
('Storage4', 'Entrepôt 4', ' ', ' '),
('Storage5', 'Entrepôt 5', ' ', ' '),
('Storage6', 'Entrepôt 6', ' ', ' ');

INSERT INTO addon_inventory (name, label, shared)
 VALUES
 ('storage1', 'Entrepôt 1', 1),
 ('storage2', 'Entrepôt 2', 1),
 ('storage3', 'Entrepôt 3', 1),
 ('storage4', 'Entrepôt 4', 1),
 ('storage5', 'Entrepôt 5', 1),
 ('storage6', 'Entrepôt 6', 1);

 INSERT INTO datastore (name, label, shared)
 VALUES
 ('storage1', 'Entrepôt 1', 1),
 ('storage2', 'Entrepôt 2', 1),
 ('storage3', 'Entrepôt 3', 1),
 ('storage4', 'Entrepôt 4', 1),
 ('storage5', 'Entrepôt 5', 1),
 ('storage6', 'Entrepôt 6', 1);
