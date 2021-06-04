-- Dumping structure for table essentialmode.MysteryCryptoMining

--Suppression de la table
DROP TABLE IF EXISTS `MysteryCryptoMining`;

--Création de la table
CREATE TABLE IF NOT EXISTS `MysteryCryptoMining` (
  `owner` longtext DEFAULT '',
  `machine` longtext DEFAULT NULL,
  `coins` double DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


--Supprimer les datas de la table
DELETE FROM `MysteryCryptoMining`;
