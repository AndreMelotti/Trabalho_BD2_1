DROP TABLE alunos cascade;
DROP TABLE usuarios cascade;
DROP SEQUENCE seq_alunos;


-- Criando Tabela alunos

CREATE TABLE alunos 
(
    id_aluno    NUMBER  (10)   NOT NULL,
    status      VARCHAR2 (1)   DEFAULT 'N' NOT NULL,
    nome        VARCHAR2 (100)  NOT NULL,
);

-- Adicionando Constraints tabela alunos
ALTER TABLE alunos
ADD CONSTRAINT id_aluno_PK 
PRIMARY KEY (id_aluno);

ALTER TABLE alunos
ADD CONSTRAINT alunos_status_ck
CHECK   (status in ('S', 'N'));

--Criando  Sequencia
CREATE SEQUENCE seq_alunos
START WITH      1
INCREMENT BY    1
MAXVALUE        99999
MINVALUE        1
NOCACHE;


-- Criando Tabela usuarios
CREATE TABLE usuarios
(
    username    VARCHAR2    (25)   NOT NULL,
    permissao   VARCHAR2    (1)    NOT NULL,
);

--Criando Constrait Usuarios
ALTER TABLE usuarios
ADD CONSTRAINT username_usuarios_pk
PRIMARY KEY (username);

ALTER TABLE usuarios
ADD CONSTRAINT usuarios_username_ck
CHECK (username in ('HR', 'ADMIN'));

ALTER TABLE usuarios
ADD CONSTRAINT usuario_ permissao_ck
CHECK (permissao in ('C', 'A'));


-- Trigger Para sequencia de ID
CREATE OR REPLACE TRIGGER id_aluno
BEFORE INSERT ON alunos
FOR EACH ROW
BEGIN
    :new.cod := seq_alunos.nextval:
END;
/

-- Trigger pra permissões do Usuario
CREATE OR REPLACE TRIGGER status_aluno
BEFORE DELETE OR UPDATE ON  alunos
FOR EACH ROW
DECLARE
    v_permissao   VARCHAR2(1);
BEGIN
    SELECT permissao INTO v_permissao 
    FROM usuario
    WHERE upper(username) = upper(user);

    IF v_permissao = 'C' AND :old.fializado = 'S' then
        raise_application_error(-20000, 'Não é possiel alterar os dados de um Aluno que já Finalizou ');
    ELSIF v_permissao = 'A' AND :old.finalizado = 'S' AND DELETING then
        raisse_application_error(-20001, 'Não é possivel deletar os dados de um Aluno já finalizado');
    END IF;
    
END;
/

-- INSERTS

insert into usuario values ('HR', 'C');
insert into usuario values ('ADMIN', 'A');

--Criando Usuario, Conectando usuario, Updates...

DROP USER "ADMIN";
CREATE USER "ADMIN" IDENTIFIED BY "123";
GRANT SELECT, UPDATE, INSERT, DELETE ON system.alunos to ADMIN;
GRANT CREATE SESSION TO "ADMIN";

CONNECT ADMIN/123@localhost:1521/xepdb1;

insert into system.alunos (nome) values ('Andre');
insert into system.alunos (nome) values ('Varejao');

update system.alunos set finalizado = 'N' where cod=2;

delete system.alunos where cod=2;

update system.alunos set finalizado = 'S' where cod=2;

delete system.alunos where cod=2;




