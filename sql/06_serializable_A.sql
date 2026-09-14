SET search_path TO academico, public;
BEGIN ISOLATION LEVEL SERIALIZABLE;
SELECT count(*) AS ocupadas FROM matricula WHERE turma_id=1 AND status='MATRICULADO';
SELECT vagas FROM turma WHERE id=1;
INSERT INTO matricula (aluno_id,turma_id,status) VALUES (101,1,'MATRICULADO');
SELECT pg_sleep(5);
COMMIT;
