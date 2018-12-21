DROP procedure IF EXISTS `check_fk_constraints`;

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `check_fk_constraints`(IN t_schema VARCHAR(255),IN t_name VARCHAR(255))
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE _table_schema VARCHAR(255);
  DECLARE _table_name VARCHAR(255);
  DECLARE _column_name VARCHAR(255);
  DECLARE _referenced_table_schema VARCHAR(255);
  DECLARE _referenced_table_name VARCHAR(255);
  DECLARE _referenced_column_name VARCHAR(255);
  DECLARE _constraint_name VARCHAR(255);

  DROP TEMPORARY TABLE IF EXISTS results_tmp;
  CREATE TEMPORARY TABLE results_tmp (
			  table_schema VARCHAR(255),
			  table_name VARCHAR(255),
              column_name VARCHAR(255),
			  constraint_name VARCHAR(255),
              value VARCHAR(255),
              referenced_table_schema VARCHAR(255),
              referenced_table_name VARCHAR(255),
              referenced_column_name VARCHAR(255)
              );

  DROP TEMPORARY TABLE IF EXISTS keys_tmp;
  
  CREATE TEMPORARY TABLE keys_tmp (
				`constraint_name` VARCHAR(255)
				, `table_schema` VARCHAR(255)
				, `table_name` VARCHAR(255)
				, `column_name` VARCHAR(255)
				, `referenced_table_schema` VARCHAR(255)
				, `referenced_table_name` VARCHAR(255)
				, `referenced_column_name` VARCHAR(255)
              ); 
              
  SET @cr_sql = 'insert into keys_tmp
				SELECT   `constraint_name`
						, `table_schema`
						, `table_name`
						, `column_name`
						, `referenced_table_schema`
						, `referenced_table_name`
						, `referenced_column_name`
					FROM `information_schema`.`KEY_COLUMN_USAGE` 
					WHERE `referenced_table_name` IS NOT NULL';

  IF (t_name IS NOT NULL) THEN
    SET @cr_sql = CONCAT(@cr_sql,' 
					AND table_name = \'',t_name,'\'');
  END IF;
  
  IF (t_schema IS NOT NULL) THEN
    SET @cr_sql = CONCAT(@cr_sql,' 
					AND table_schema = \'',t_schema,'\'');
  END IF;

  PREPARE stmt2 FROM @cr_sql;
  EXECUTE stmt2;
  DEALLOCATE PREPARE stmt2;
  SET @cr_sql = NULL;
			
  BEGIN
  /*DECLARE cur CURSOR FOR (SELECT   `constraint_name`
								, `table_schema`
								, `table_name`
                                , `column_name`
								, `referenced_table_schema`
                                , `referenced_table_name`
                                , `referenced_column_name`
							FROM `information_schema`.`KEY_COLUMN_USAGE` 
                            WHERE `referenced_table_name` IS NOT NULL);*/
  DECLARE cur CURSOR FOR SELECT * FROM keys_tmp;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur;
  
  READ_LOOP: LOOP
    FETCH cur INTO _constraint_name, _table_schema,  _table_name, _column_name, _referenced_table_schema, _referenced_table_name, _referenced_column_name;
    IF done THEN
      LEAVE READ_LOOP;
	END IF;

	SET @sql = CONCAT(' INSERT INTO results_tmp (table_schema,table_name,column_name,constraint_name,value,referenced_table_schema,referenced_table_name,referenced_column_name)
						SELECT \'',_table_schema,'\' as table_schema,
                               \'',_table_name,'\' as table_name,
                               \'',_column_name,'\' as column_name,
                               \'',_constraint_name,'\' as constraint_name,
							   CAST(ct.',_column_name,' as char(255)) as value,
                               \'',_referenced_table_schema,'\' as referenced_table_schema,
                               \'',_referenced_table_name,'\' as referenced_table_name,
                               \'',_referenced_column_name,'\' as referenced_column_name
						FROM ',_table_schema,'.',_table_name,' ct 
                        LEFT JOIN ',_referenced_table_schema,'.',_referenced_table_name,' rt ON ct.',_column_name,' = rt.',_referenced_column_name,' 
                        WHERE rt.',_referenced_column_name,' IS NULL AND ct.',_column_name,' IS NOT NULL');
	PREPARE stmt1 FROM @sql ;
	EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;
    SET @sql = NULL;
  END LOOP;
  SELECT DISTINCT * FROM results_tmp;
END;
  DROP TEMPORARY TABLE IF EXISTS results_tmp;
END$$

DELIMITER ;
