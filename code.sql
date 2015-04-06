###################Crazy functions and procedures!!!!!
###################
DELIMITER ;;
CREATE DEFINER=`timesha_user`@`localhost` FUNCTION `is_transfer_step_3_complete`(transfer_id INT(30)) RETURNS tinyint(1)
    READS SQL DATA
BEGIN
	DECLARE has_cca BOOLEAN DEFAULT FALSE;
	DECLARE has_id	BOOLEAN DEFAULT FALSE;
	DECLARE has_ptp BOOLEAN DEFAULT FALSE;

	SELECT COUNT(*) > 0 INTO has_id FROM uploads u WHERE  u.step_document_id=3 AND u.transfer_id=transfer_id;
	SELECT COUNT(*) > 0 INTO has_ptp FROM uploads u WHERE  u.step_document_id=10 AND u.transfer_id=transfer_id;
	SELECT COUNT(*) > 0 INTO has_cca FROM uploads u WHERE  u.step_document_id=2 AND u.transfer_id=transfer_id;


	RETURN has_cca=1 && has_id=1 && has_ptp=1;
END ;;
DELIMITER ;

DELIMITER ;;
CREATE DEFINER=`timesha_user`@`localhost` FUNCTION `is_transfer_step_6_complete`(transfer_id INT(30)) RETURNS tinyint(1)
    READS SQL DATA
BEGIN
    
    DECLARE is_complete BOOLEAN DEFAULT FALSE;

    DECLARE is_deeded BOOLEAN DEFAULT FALSE;
    DECLARE is_surrender BOOLEAN DEFAULT FALSE;

    SELECT (deeded=1) deeded, surrender_check INTO is_deeded, is_surrender FROM change_request cr WHERE cr.transfer_id=transfer_id;

    IF is_deeded = TRUE THEN
        SELECT  COUNT(*) > 0 INTO is_complete
        FROM    uploads u
        WHERE   u.transfer_id=transfer_id
        AND     u.step_document_id=25;

        IF is_complete THEN
            SELECT  COUNT(*) > 0 INTO is_complete 
            FROM    uploads u
            WHERE   u.transfer_id=transfer_id
            AND     u.step_document_id=26;
        END IF;
    ELSE
        SELECT  COUNT(*) > 0 INTO is_complete 
        FROM    uploads u
        WHERE   u.transfer_id=transfer_id
        AND     u.step_document_id=72;
    END IF;

    IF is_surrender = TRUE THEN
            SELECT  COUNT(*) > 0 INTO is_complete 
            FROM    uploads u
            WHERE   u.transfer_id=transfer_id
            AND     u.step_document_id=74;

        IF is_complete THEN
            SELECT  COUNT(*) > 0 INTO is_complete 
            FROM    uploads u
            WHERE   u.transfer_id=transfer_id
            AND     u.step_document_id=75;
        END IF;

    END IF;

    RETURN is_complete;

END ;;
DELIMITER ;

DELIMITER ;;
CREATE DEFINER=`timesha_user`@`localhost` PROCEDURE `create_task_for_administrator`(task_date datetime, subject varchar(50), description text, transfer_id int(30))
BEGIN
    DECLARE already_exists tinyint(1);
    DECLARE	administrator_id INT;

    SELECT COUNT(*) > 0 INTO already_exists FROM tasks t WHERE t.subject=subject;

    IF already_exists = FALSE THEN	
        SET  @administrator_id := get_administrator_id();

        INSERT INTO tasks(date, time, subject, description, user, transfer_id)
        VALUES(CURDATE(), CURTIME(), subject, description, @administrator_id, transfer_id);
    END IF;
END ;;
DELIMITER ;
