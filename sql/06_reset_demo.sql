SET search_path TO academico, public;
DELETE FROM matricula WHERE turma_id=1 AND aluno_id IN (101,102);
UPDATE turma SET vagas=41 WHERE id=1;
SELECT t.id,t.codigo,t.vagas,count(m.id) FILTER (WHERE m.status='MATRICULADO') AS ocupadas,t.vagas-count(m.id) FILTER (WHERE m.status='MATRICULADO') AS restantes FROM turma t LEFT JOIN matricula m ON m.turma_id=t.id WHERE t.id=1 GROUP BY t.id,t.codigo,t.vagas;
