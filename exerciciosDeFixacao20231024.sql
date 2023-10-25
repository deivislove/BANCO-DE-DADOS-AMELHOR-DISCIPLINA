DELIMITER //
CREATE TRIGGER insere_cliente_auditoria
AFTER INSERT ON Clientes
FOR EACH ROW
BEGIN
    INSERT INTO Auditoria (mensagem)
    SELECT CONCAT('Novo cliente inserido: ', NEW.nome, '. Data e hora: ', NOW());
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER tentativa_exclusao_auditoria
BEFORE DELETE ON Clientes
FOR EACH ROW
BEGIN
    INSERT INTO Auditoria (mensagem)
    SELECT CONCAT('Tentativa de exclusão do cliente com ID ', OLD.id, '. Data e hora: ', NOW());
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER atualiza_nome_auditoria
AFTER UPDATE ON Clientes
FOR EACH ROW
BEGIN
    IF OLD.nome != NEW.nome THEN
        INSERT INTO Auditoria (mensagem)
        SELECT CONCAT('Nome do cliente com ID ', NEW.id, ' atualizado de "', OLD.nome, '" para "', NEW.nome, '". Data e hora: ', NOW());
    END IF;
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER impede_nome_vazio_nulo
BEFORE UPDATE ON Clientes
FOR EACH ROW
BEGIN
    IF NEW.nome IS NULL OR NEW.nome = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Atualização do nome para vazio ou NULL não permitida.';
    END IF;
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER atualiza_estoque_pedido
AFTER INSERT ON Pedidos
FOR EACH ROW
BEGIN
    DECLARE novo_estoque INT;
    SELECT estoque - NEW.quantidade INTO novo_estoque FROM Produtos WHERE id = NEW.produto_id;
    
    IF novo_estoque < 5 THEN
        INSERT INTO Auditoria (mensagem)
        SELECT CONCAT('Estoque baixo para o produto com ID ', NEW.produto_id, '. Estoque atual: ', novo_estoque, '. Data e hora: ', NOW());
    END IF;

    UPDATE Produtos SET estoque = novo_estoque WHERE id = NEW.produto_id;
END;
//
DELIMITER ;
