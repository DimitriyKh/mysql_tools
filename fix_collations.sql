CREATE PROCEDURE `fix_collation`()
BEGIN

DECLARE schema_n varchar(255);
DECLARE table_n varchar(255);
DECLARE column_n varchar(255);
DECLARE column_t varchar(255);
DECLARE done INT DEFAULT FALSE;

BEGIN
  DECLARE schema_cursor CURSOR FOR select `schema_name` from information_schema.schemata 
						where `schema_name` not in ('mysql','information_schema', 'performance_schema', 'sys')
						and (default_character_set_name != 'utf8' OR default_collation_name != 'utf8_unicode_ci');
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
SET done = FALSE;
OPEN schema_cursor;

schema_loop: LOOP

FETCH schema_cursor INTO schema_n;

IF done THEN 
	LEAVE schema_loop;
END IF;

SET @sql = concat('ALTER SCHEMA ',schema_n,' DEFAULT CHARACTER SET utf8  DEFAULT COLLATE utf8_unicode_ci');

PREPARE stmt1 FROM @sql;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

END LOOP;

END;

BEGIN

  DECLARE table_cursor CURSOR FOR SELECT `TABLE_SCHEMA`,`TABLE_NAME` FROM information_schema.TABLES
			where `table_schema` not in ('mysql','information_schema', 'performance_schema', 'sys')
			and (table_collation != 'utf8_unicode_ci' and table_collation != 'utf8mb4_unicode_ci');
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
SET done = FALSE;
OPEN table_cursor;

table_loop: LOOP

FETCH table_cursor INTO schema_n, table_n;

IF done THEN 
	LEAVE table_loop;
END IF;

SET @sql = concat('ALTER TABLE ',schema_n,'.',table_n,' DEFAULT CHARACTER SET utf8  DEFAULT COLLATE utf8_unicode_ci');

PREPARE stmt1 FROM @sql;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

END LOOP;

END;

BEGIN

  DECLARE column_cursor CURSOR FOR SELECT `TABLE_SCHEMA`, `TABLE_NAME`, `COLUMN_NAME`, `COLUMN_TYPE` FROM information_schema.COLUMNS
									where `table_schema` not in ('mysql','information_schema', 'performance_schema', 'sys')
									and  `collation_name` not in ('utf8_unicode_ci','utf8mb4_unicode_ci');
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
SET done = FALSE;
OPEN column_cursor;

column_loop: LOOP

FETCH column_cursor INTO schema_n, table_n, column_n, column_t;

IF done THEN 
	LEAVE column_loop;
END IF;

-- SET COLUMN COLLATE TO TABLE'S DEFAULT
SET @sql = concat('ALTER TABLE ',schema_n,'.',table_n,' CHANGE COLUMN `',column_n,'` `',column_n,'` ',column_t);

PREPARE stmt1 FROM @sql;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

END LOOP;

END;

END
