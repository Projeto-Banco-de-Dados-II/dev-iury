SET search_path TO academico, public;

SELECT count(*) AS total_alunos FROM aluno;
SELECT count(*) AS total_turmas FROM turma;
SELECT count(*) AS total_matriculas FROM matricula;
SELECT count(*) AS total_matriculas_ativas FROM matricula WHERE status='MATRICULADO';
SELECT count(*) AS total_historicos FROM historico;
SELECT count(*) AS total_views FROM information_schema.views WHERE table_schema='academico' AND table_name IN ('vw_oferta','vw_vagas','vw_historico');
SELECT count(*) AS total_indices FROM pg_indexes WHERE schemaname='academico';
SELECT t.codigo,t.vagas,count(m.id) FILTER (WHERE m.status='MATRICULADO') AS ocupadas,t.vagas-count(m.id) FILTER (WHERE m.status='MATRICULADO') AS restantes FROM turma t LEFT JOIN matricula m ON m.turma_id=t.id GROUP BY t.id,t.codigo,t.vagas ORDER BY t.id;
SELECT d.codigo,pr.codigo AS requisito FROM pre_requisito p JOIN disciplina d ON d.id=p.disciplina_id JOIN disciplina pr ON pr.id=p.requisito_id ORDER BY d.codigo,pr.codigo;
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_indicadores_curso;
SELECT * FROM mv_indicadores_curso ORDER BY curso,ano,semestre;
