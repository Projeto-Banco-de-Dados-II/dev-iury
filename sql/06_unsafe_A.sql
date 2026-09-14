SET search_path TO academico, public;
BEGIN;
INSERT INTO matricula (aluno_id,turma_id,status) VALUES (101,1,'MATRICULADO');
SELECT pg_sleep(5);
COMMIT;
