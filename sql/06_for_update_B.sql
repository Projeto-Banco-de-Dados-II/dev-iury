SET search_path TO academico, public;
BEGIN;
INSERT INTO matricula (aluno_id,turma_id,status) VALUES (102,1,'MATRICULADO');
COMMIT;
