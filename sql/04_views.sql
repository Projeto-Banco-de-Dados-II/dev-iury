SET search_path TO academico, public;

CREATE OR REPLACE VIEW vw_oferta AS
SELECT pl.ano,pl.semestre,d.codigo AS disciplina,d.nome,
       t.codigo AS turma,t.turno,p.nome AS professor,
       s.codigo AS sala,th.dia_semana,
       lower(th.faixa) AS inicio,upper(th.faixa) AS fim,t.vagas
FROM turma t
JOIN disciplina d ON d.id=t.disciplina_id
JOIN periodo_letivo pl ON pl.id=t.periodo_letivo_id
LEFT JOIN professor p ON p.id=t.professor_id
LEFT JOIN turma_horario th ON th.turma_id=t.id
LEFT JOIN sala s ON s.id=th.sala_id;

CREATE OR REPLACE VIEW vw_vagas AS
SELECT t.id AS turma_id,t.codigo,d.codigo AS disciplina,t.vagas,
       count(m.id) FILTER (WHERE m.status='MATRICULADO') AS ocupadas,
       t.vagas-count(m.id) FILTER (WHERE m.status='MATRICULADO') AS restantes
FROM turma t
JOIN disciplina d ON d.id=t.disciplina_id
LEFT JOIN matricula m ON m.turma_id=t.id
GROUP BY t.id,t.codigo,d.codigo,t.vagas;

DROP VIEW IF EXISTS vw_historico;
CREATE VIEW vw_historico WITH (security_invoker=true) AS
SELECT a.matricula AS ra,a.nome AS aluno,d.codigo AS disciplina,d.ch_total,
       pl.ano,pl.semestre,h.nota_a1,h.nota_a2,h.nota_p3,h.frequencia,
       h.media_final,
       CASE
         WHEN h.frequencia < 75 THEN 'SR'
         WHEN h.media_final IS NULL THEN NULL
         WHEN h.media_final >= 9 THEN 'SS'
         WHEN h.media_final >= 7 THEN 'MS'
         WHEN h.media_final >= 5 THEN 'MM'
         WHEN h.media_final >= 3 THEN 'MI'
         WHEN h.media_final > 0 THEN 'II'
         ELSE 'SR'
       END AS mencao
FROM historico h
JOIN matricula m ON m.id=h.matricula_id
JOIN aluno a ON a.id=m.aluno_id
JOIN turma t ON t.id=m.turma_id
JOIN disciplina d ON d.id=t.disciplina_id
JOIN periodo_letivo pl ON pl.id=t.periodo_letivo_id;

DROP MATERIALIZED VIEW IF EXISTS mv_indicadores_curso;
CREATE MATERIALIZED VIEW mv_indicadores_curso AS
SELECT c.codigo AS curso,pl.ano,pl.semestre,
       count(*) AS matriculas,
       round(avg(h.media_final),2) AS media_geral,
       round(
         100.0*count(*) FILTER (WHERE h.situacao='APROVADO')
         / NULLIF(count(*) FILTER (WHERE h.situacao<>'CURSANDO'),0),1
       ) AS taxa_aprovacao
FROM historico h
JOIN matricula m ON m.id=h.matricula_id
JOIN aluno a ON a.id=m.aluno_id
JOIN curso c ON c.id=a.curso_id
JOIN turma t ON t.id=m.turma_id
JOIN periodo_letivo pl ON pl.id=t.periodo_letivo_id
GROUP BY c.codigo,pl.ano,pl.semestre
WITH NO DATA;

CREATE UNIQUE INDEX uq_mv_indicadores
ON mv_indicadores_curso(curso,ano,semestre);

REFRESH MATERIALIZED VIEW mv_indicadores_curso;
