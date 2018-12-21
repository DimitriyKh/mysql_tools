DROP procedure IF EXISTS `mv_tbls`;

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `mv_tbls`(old_schema varchar(255), new_schema varchar(255))
    DETERMINISTIC
    COMMENT 'The procedure to emulate rename database. \n		   It moves tables from old schema to new one. \n           Make sure both schemas exist before launch'
BEGIN

declare tbl_name varchar(255);
declare done tinyint(1) default false;
declare stmt text;

drop temporary table if exists tbls ;
create temporary table tbls (name varchar(255));

set @s = concat("insert into tbls select table_name from information_schema.tables where table_schema = '", old_schema,"'"); 
prepare stmt from @s;
execute stmt;
deallocate prepare stmt;

begin
DECLARE cur CURSOR FOR SELECT name  FROM tbls;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

open cur;

read_loop: loop
fetch cur into tbl_name;
if done then
  leave read_loop;
end if;
set @s = concat('rename table ',old_schema,'.',tbl_name,' to ',new_schema,'.',tbl_name);
prepare stmt from @s;
execute stmt;
deallocate prepare stmt; 

end loop;
close cur;

end;
END$$

DELIMITER ;
