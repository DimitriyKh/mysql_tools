DROP FUNCTION IF EXISTS `new_passowrd`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `new_passowrd`(length int,low tinyint, up tinyint, dig tinyint, spec tinyint) RETURNS varchar(255) CHARSET utf8
BEGIN

declare pass varchar(255);
declare seed varchar(255);

set pass = '';

# generate password characters collection
set seed = '';
if low then
    set seed = concat(seed,'abcdefghijklmnopqrstuvwxyz');
end if;
if up then 
    set seed = concat(seed,'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
end if;
if dig then 
    set seed = concat(seed,'0123456789');
end if;
if spec then 
    set seed = concat(seed,'!@#$%^&*_=');
end if;

# generate password
while LENGTH(pass) < length do
set pass = concat(pass,ifnull(mid(seed,(1+FLOOR(RAND() * 100)),1),''));

end while;

RETURN pass;
END$$

DELIMITER ;
