-- Version 1.0, 29.01.2022
-- DELETE FROM mft_hardlinkssplit;

SET sql_mode = 'TRADITIONAL';
SET GLOBAL sql_mode = 'TRADITIONAL';

DELIMITER //

CREATE OR REPLACE PROCEDURE splitHardLinks()
BEGIN
   DECLARE counter INT DEFAULT -1; -- 
   DECLARE MaxId INT DEFAULT 0;
   DECLARE MftId INT DEFAULT 0;
   DECLARE PosStar INT DEFAULT 0; 
   DECLARE LastPosStar INT DEFAULT 0; 
   DECLARE AllFilePaths MEDIUMTEXT;
   DECLARE SingleFilePath VARCHAR(1024); -- 260 is too short
   SELECT MAX(id) INTO MaxId FROM mft;
   REPEAT 
      SELECT id INTO MftId FROM mft WHERE id>counter ORDER BY id LIMIT 1; 
      SELECT FilePath INTO AllFilePaths FROM mft WHERE id>counter ORDER BY id LIMIT 1; 
      SELECT Locate('*',AllFilePaths) INTO PosStar;
      IF PosStar > 0 THEN
         WHILE PosStar > 0 DO
            SELECT SUBSTRING(SUBSTRING(AllFilePaths,LastPosStar+1,PosStar-LastPosStar-1),1,255) INTO SingleFilePath;
            INSERT INTO mft_hardlinkssplit (MftId, FilePath) VALUES (MftId, SingleFilePath);
            SET LastPosStar = PosStar;
            SELECT Locate('*',AllFilePaths,PosStar+1) INTO PosStar;
         END WHILE;
         SELECT SUBSTRING(SUBSTRING(AllFilePaths,LastPosStar+1),1,255) INTO SingleFilePath;
         INSERT INTO mft_hardlinkssplit (MftId, FilePath) VALUES (MftId, SingleFilePath);
		 SET LastPosStar = 0;
      ELSE
         INSERT INTO mft_hardlinkssplit (MftId, FilePath) VALUES (MftId, AllFilePaths);
      END IF;
      
      SET counter = MftId; -- counter++ does not work due to gaps in id numbers
    UNTIL counter >= 1000 -- 1000	MaxId
    END REPEAT;
END
//

DELIMITER ;

CALL splitHardLinks();
ALTER TABLE `mft_hardlinkssplit` ADD INDEX `FilePath` (`FilePath`); -- creating index afterwards speeds up inserting data