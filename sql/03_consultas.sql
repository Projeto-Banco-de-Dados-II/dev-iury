SET search_path TO academico, public;

-- Consulta 1 — oferta acadêmica com junções entre turma, disciplina, período, professor e sala.
SELECT pl.ano, pl.semestre, d.codigo AS disciplina, d.nome,
       t.codigo AS turma, t.turno, p.nome AS professor,
       s.codigo AS sala, th.dia_semana,
       lower(th.faixa) AS inicio, upper(th.faixa) AS fim
FROM turma t
JOIN disciplina d ON d.id=t.disciplina_id
JOIN periodo_letivo pl ON pl.id=t.periodo_letivo_id
LEFT JOIN professor p ON p.id=t.professor_id
LEFT JOIN turma_horario th ON th.turma_id=t.id
LEFT JOIN sala s ON s.id=th.sala_id
ORDER BY pl.ano, pl.semestre, d.codigo, t.codigo;

-- Consulta 2 — junção externa com agregação para identificar matrículas por curso.
SELECT c.codigo, c.nome,
       count(m.id) FILTER (WHERE m.status='MATRICULADO') AS matriculas_ativas,
       count(DISTINCT a.id) AS alunos_com_registro
FROM curso c
LEFT JOIN aluno a ON a.curso_id=c.id
LEFT JOIN matricula m ON m.aluno_id=a.id
GROUP BY c.id,c.codigo,c.nome
ORDER BY matriculas_ativas DESC;

-- Consulta 3 — consulta recursiva da árvore de pré-requisitos de Banco de Dados II.
WITH RECURSIVE arvore AS (
    SELECT pr.disciplina_id, pr.requisito_id, 1 AS nivel,
           ARRAY[pr.disciplina_id,pr.requisito_id] AS caminho
    FROM pre_requisito pr
    WHERE pr.disciplina_id = (SELECT id FROM disciplina WHERE codigo='CCO072')
    UNION ALL
    SELECT a.disciplina_id, pr.requisito_id, a.nivel+1,
           a.caminho || pr.requisito_id
    FROM arvore a
    JOIN pre_requisito pr ON pr.disciplina_id=a.requisito_id
    WHERE NOT pr.requisito_id = ANY(a.caminho)
)
-- Consulta 4 — consulta recursiva para identificar disciplinas que o aluno pode cursar.
SELECT a.nivel,
       d.codigo AS disciplina,
       r.codigo AS requisito
FROM arvore a
JOIN disciplina d ON d.id=a.disciplina_id
JOIN disciplina r ON r.id=a.requisito_id
ORDER BY a.nivel,r.codigo;

-- Consulta 5 — função de janela com RANK e PERCENT_RANK para classificação dos alunos.
WITH RECURSIVE
alvo AS (SELECT 1::integer AS aluno_id),
passadas AS (
    SELECT DISTINCT t.disciplina_id
    FROM matricula m
    JOIN historico h ON h.matricula_id=m.id
    JOIN turma t ON t.id=m.turma_id
    WHERE m.aluno_id=(SELECT aluno_id FROM alvo)
      AND h.situacao='APROVADO'
),
cadeia AS (
    SELECT cd.disciplina_id, pr.requisito_id
    FROM curriculo_disciplina cd
    JOIN aluno a ON a.curriculo_id=cd.curriculo_id
    JOIN pre_requisito pr ON pr.disciplina_id=cd.disciplina_id
    WHERE a.id=(SELECT aluno_id FROM alvo)
    UNION ALL
    SELECT c.disciplina_id, pr.requisito_id
    FROM cadeia c
    JOIN pre_requisito pr ON pr.disciplina_id=c.requisito_id
),
necessarias AS (
    SELECT DISTINCT disciplina_id, requisito_id FROM cadeia
)
-- Consulta 6 — função de janela LAG para evolução do rendimento por período.
SELECT d.codigo,d.nome,cd.periodo,cd.tipo
FROM aluno a
JOIN curriculo_disciplina cd ON cd.curriculo_id=a.curriculo_id
JOIN disciplina d ON d.id=cd.disciplina_id
WHERE a.id=(SELECT aluno_id FROM alvo)
  AND d.id NOT IN (SELECT disciplina_id FROM passadas)
  AND NOT EXISTS (
      SELECT 1
      FROM necessarias n
      WHERE n.disciplina_id=d.id
        AND n.requisito_id NOT IN (SELECT disciplina_id FROM passadas)
  )
ORDER BY cd.periodo,d.codigo;

-- Consulta 7 — ocupação e percentual de vagas das turmas.
SELECT c.codigo AS curso, a.nome AS aluno,
       round(avg(h.media_final),2) AS media,
       rank() OVER (
         PARTITION BY c.id ORDER BY avg(h.media_final) DESC
       ) AS ranking,
       round(percent_rank() OVER (
         PARTITION BY c.id ORDER BY avg(h.media_final)
       )::numeric,4) AS percentil
FROM aluno a
JOIN curso c ON c.id=a.curso_id
JOIN matricula m ON m.aluno_id=a.id
JOIN historico h ON h.matricula_id=m.id
WHERE h.media_final IS NOT NULL
GROUP BY c.id,c.codigo,a.id,a.nome
ORDER BY c.codigo,ranking;

-- Consulta 8 — alunos sem qualquer matrícula.
WITH notas AS (
    SELECT a.id AS aluno_id,a.nome,pl.ano,pl.semestre,
           round(avg(h.media_final),2) AS media
    FROM aluno a
    JOIN matricula m ON m.aluno_id=a.id
    JOIN turma t ON t.id=m.turma_id
    JOIN periodo_letivo pl ON pl.id=t.periodo_letivo_id
    JOIN historico h ON h.matricula_id=m.id
    WHERE h.media_final IS NOT NULL
    GROUP BY a.id,a.nome,pl.ano,pl.semestre
)
-- Consulta 9 — carga de turmas e matrículas por professor.
SELECT aluno_id,nome,ano,semestre,media,
       lag(media) OVER (
         PARTITION BY aluno_id ORDER BY ano,semestre
       ) AS media_anterior,
       round((media-lag(media) OVER (
         PARTITION BY aluno_id ORDER BY ano,semestre
       ))::numeric,2) AS variacao
FROM notas
ORDER BY aluno_id,ano,semestre;

-- Consulta 10 — desempenho médio e taxa de aprovação por disciplina.
SELECT t.codigo,d.codigo AS disciplina,t.vagas,
       count(m.id) FILTER (WHERE m.status='MATRICULADO') AS ocupadas,
       round(
         100.0*count(m.id) FILTER (WHERE m.status='MATRICULADO')/t.vagas,2
       ) AS ocupacao_pct
FROM turma t
JOIN disciplina d ON d.id=t.disciplina_id
LEFT JOIN matricula m ON m.turma_id=t.id
GROUP BY t.id,t.codigo,d.codigo,t.vagas
ORDER BY ocupacao_pct DESC;

SELECT a.id,a.matricula,a.nome
FROM aluno a
LEFT JOIN matricula m ON m.aluno_id=a.id
WHERE m.id IS NULL
ORDER BY a.id;

SELECT p.nome,p.titulacao,
       count(DISTINCT t.id) AS turmas,
       count(m.id) FILTER (WHERE m.status='MATRICULADO') AS matriculas
FROM professor p
LEFT JOIN turma t ON t.professor_id=p.id
LEFT JOIN matricula m ON m.turma_id=t.id
GROUP BY p.id,p.nome,p.titulacao
ORDER BY matriculas DESC;

SELECT d.codigo,d.nome,
       count(h.id) AS registros,
       round(avg(h.media_final),2) AS media,
       round(avg(h.frequencia),2) AS frequencia_media,
       round(100.0*count(*) FILTER (WHERE h.situacao='APROVADO')
             / NULLIF(count(*) FILTER (WHERE h.situacao<>'CURSANDO'),0),2)
             AS taxa_aprovacao
FROM disciplina d
JOIN turma t ON t.disciplina_id=d.id
JOIN matricula m ON m.turma_id=t.id
JOIN historico h ON h.matricula_id=m.id
GROUP BY d.id,d.codigo,d.nome
ORDER BY taxa_aprovacao DESC NULLS LAST;
