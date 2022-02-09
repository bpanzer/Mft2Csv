CREATE TABLE IF NOT EXISTS `mft_hardlinkssplit` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `MftId` int(11) NOT NULL,
  `FilePath` varchar(1024) NOT NULL,			-- inserts seem faster than with column size 516
  PRIMARY KEY (`Id`)
);
