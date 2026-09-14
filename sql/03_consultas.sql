SET search_path TO academico, public;

SELECT
    t.id AS turma_id,
    d.codigo AS disciplina,
    d.nome AS disciplina_nome,
    pl.ano,
    pl.semestre,
    t.turno,
    p.nome AS professor,
    c.nome AS campus,
    s.codigo AS sala,
    th.dia_semana,
    lower(th.faixa) AS inicio,
    upper(th.faixa) AS fim
FROM turma t
JOIN disciplina d
    ON d.id = t.disciplina_id
JOIN periodo_letivo pl
    ON pl.id = t.periodo_letivo_id
LEFT JOIN professor p
    ON p.id = t.professor_id
LEFT JOIN turma_horario th
    ON th.turma_id = t.id
LEFT JOIN sala s
    ON s.id = th.sala_id
LEFT JOIN campus c
    ON c.id = s.campus_id
ORDER BY
    pl.ano,
    pl.semestre,
    d.codigo,
    t.id;


SELECT
    c.codigo,
    c.nome,
    COUNT(m.id) FILTER (
        WHERE m.status = 'MATRICULADO'
    ) AS matriculas_ativas,
    COUNT(DISTINCT a.id) AS alunos_com_registro
FROM curso c
LEFT JOIN aluno a
    ON a.curso_id = c.id
LEFT JOIN matricula m
    ON m.aluno_id = a.id
GROUP BY
    c.id,
    c.codigo,
    c.nome
ORDER BY
    matriculas_ativas DESC,
    c.codigo;


WITH RECURSIVE arvore AS (
    SELECT
        pr.disciplina_id,
        pr.requisito_id,
        1 AS nivel,
        ARRAY[
            pr.disciplina_id,
            pr.requisito_id
        ] AS caminho
    FROM pre_requisito pr
    JOIN disciplina d
        ON d.id = pr.disciplina_id
    WHERE d.codigo = 'CCO072'
      AND pr.vinculo = 'PRE_REQUISITO'

    UNION ALL

    SELECT
        a.disciplina_id,
        pr.requisito_id,
        a.nivel + 1,
        a.caminho || pr.requisito_id
    FROM arvore a
    JOIN pre_requisito pr
        ON pr.disciplina_id = a.requisito_id
    WHERE pr.vinculo = 'PRE_REQUISITO'
      AND NOT pr.requisito_id = ANY(a.caminho)
)
SELECT
    a.nivel,
    d.codigo AS disciplina,
    d.nome AS disciplina_nome,
    r.codigo AS requisito,
    r.nome AS requisito_nome,
    a.caminho
FROM arvore a
JOIN disciplina d
    ON d.id = a.disciplina_id
JOIN disciplina r
    ON r.id = a.requisito_id
ORDER BY
    a.nivel,
    r.codigo;


WITH RECURSIVE
alvo AS (
    SELECT 1::INTEGER AS aluno_id
),
passadas AS (
    SELECT DISTINCT
        t.disciplina_id
    FROM matricula m
    JOIN historico h
        ON h.matricula_id = m.id
    JOIN turma t
        ON t.id = m.turma_id
    WHERE m.aluno_id = (SELECT aluno_id FROM alvo)
      AND h.situacao = 'APROVADO'
),
cadeia AS (
    SELECT
        cd.disciplina_id,
        pr.requisito_id
    FROM aluno a
    JOIN curriculo_disciplina cd
        ON cd.curriculo_id = a.curriculo_id
    JOIN pre_requisito pr
        ON pr.disciplina_id = cd.disciplina_id
       AND pr.vinculo = 'PRE_REQUISITO'
    WHERE a.id = (SELECT aluno_id FROM alvo)

    UNION

    SELECT
        c.disciplina_id,
        pr.requisito_id
    FROM cadeia c
    JOIN pre_requisito pr
        ON pr.disciplina_id = c.requisito_id
       AND pr.vinculo = 'PRE_REQUISITO'
),
necessarias AS (
    SELECT DISTINCT
        disciplina_id,
        requisito_id
    FROM cadeia
)
SELECT
    d.codigo,
    d.nome,
    cd.periodo,
    cd.tipo
FROM aluno a
JOIN curriculo_disciplina cd
    ON cd.curriculo_id = a.curriculo_id
JOIN disciplina d
    ON d.id = cd.disciplina_id
WHERE a.id = (SELECT aluno_id FROM alvo)
  AND d.id NOT IN (
      SELECT disciplina_id
      FROM passadas
  )
  AND NOT EXISTS (
      SELECT 1
      FROM necessarias n
      WHERE n.disciplina_id = d.id
        AND n.requisito_id NOT IN (
            SELECT disciplina_id
            FROM passadas
        )
  )
ORDER BY
    cd.periodo,
    d.codigo;


SELECT
    a.id AS aluno_id,
    a.nome,
    pl.ano,
    pl.semestre,
    ROUND(AVG(h.media_final), 2) AS media_periodo,
    COUNT(h.id) AS disciplinas_avaliadas
FROM aluno a
JOIN matricula m
    ON m.aluno_id = a.id
JOIN historico h
    ON h.matricula_id = m.id
JOIN turma t
    ON t.id = m.turma_id
JOIN periodo_letivo pl
    ON pl.id = t.periodo_letivo_id
GROUP BY
    a.id,
    a.nome,
    pl.ano,
    pl.semestre
ORDER BY
    a.id,
    pl.ano,
    pl.semestre;


WITH medias AS (
    SELECT
        a.id AS aluno_id,
        a.nome,
        ROUND(AVG(h.media_final), 2) AS media_final
    FROM aluno a
    JOIN matricula m
        ON m.aluno_id = a.id
    JOIN historico h
        ON h.matricula_id = m.id
    WHERE h.media_final IS NOT NULL
    GROUP BY
        a.id,
        a.nome
)
SELECT
    aluno_id,
    nome,
    media_final,
    RANK() OVER (
        ORDER BY media_final DESC
    ) AS ranking,
    ROUND(
        PERCENT_RANK() OVER (
            ORDER BY media_final DESC
        )::NUMERIC,
        4
    ) AS percentil
FROM medias
ORDER BY
    ranking,
    aluno_id;


WITH rendimento AS (
    SELECT
        a.id AS aluno_id,
        a.nome,
        pl.ano,
        pl.semestre,
        ROUND(AVG(h.media_final), 2) AS media_periodo
    FROM aluno a
    JOIN matricula m
        ON m.aluno_id = a.id
    JOIN historico h
        ON h.matricula_id = m.id
    JOIN turma t
        ON t.id = m.turma_id
    JOIN periodo_letivo pl
        ON pl.id = t.periodo_letivo_id
    GROUP BY
        a.id,
        a.nome,
        pl.ano,
        pl.semestre
),
com_anterior AS (
    SELECT
        aluno_id,
        nome,
        ano,
        semestre,
        media_periodo,
        LAG(media_periodo) OVER (
            PARTITION BY aluno_id
            ORDER BY ano, semestre
        ) AS media_periodo_anterior
    FROM rendimento
)
SELECT
    aluno_id,
    nome,
    ano,
    semestre,
    media_periodo,
    media_periodo_anterior,
    ROUND(
        media_periodo - media_periodo_anterior,
        2
    ) AS variacao_media
FROM com_anterior
ORDER BY
    aluno_id,
    ano,
    semestre;


SELECT
    t.id AS turma_id,
    d.codigo AS disciplina,
    t.vagas,
    COUNT(m.id) FILTER (
        WHERE m.status = 'MATRICULADO'
    ) AS matriculas_ativas,
    t.vagas -
        COUNT(m.id) FILTER (
            WHERE m.status = 'MATRICULADO'
        ) AS vagas_disponiveis,
    ROUND(
        (
            COUNT(m.id) FILTER (
                WHERE m.status = 'MATRICULADO'
            )::NUMERIC
            / NULLIF(t.vagas, 0)
        ) * 100,
        2
    ) AS percentual_ocupacao
FROM turma t
JOIN disciplina d
    ON d.id = t.disciplina_id
LEFT JOIN matricula m
    ON m.turma_id = t.id
GROUP BY
    t.id,
    d.codigo,
    t.vagas
ORDER BY
    percentual_ocupacao DESC,
    t.id;


SELECT
    a.id,
    a.nome,
    a.matricula
FROM aluno a
LEFT JOIN matricula m
    ON m.aluno_id = a.id
WHERE m.id IS NULL
ORDER BY
    a.nome;


SELECT
    d.codigo,
    d.nome,
    COUNT(DISTINCT m.aluno_id) AS alunos_avaliados,
    ROUND(AVG(h.media_final), 2) AS media_disciplina,
    COUNT(*) FILTER (
        WHERE h.situacao = 'APROVADO'
    ) AS aprovados,
    COUNT(*) FILTER (
        WHERE h.situacao IN (
            'REPROVADO_NOTA',
            'REPROVADO_FALTA'
        )
    ) AS reprovados,
    ROUND(
        (
            COUNT(*) FILTER (
                WHERE h.situacao = 'APROVADO'
            )::NUMERIC
            /
            NULLIF(
                COUNT(*) FILTER (
                    WHERE h.situacao <> 'CURSANDO'
                ),
                0
            )
        ) * 100,
        2
    ) AS taxa_aprovacao
FROM disciplina d
LEFT JOIN turma t
    ON t.disciplina_id = d.id
LEFT JOIN matricula m
    ON m.turma_id = t.id
LEFT JOIN historico h
    ON h.matricula_id = m.id
GROUP BY
    d.id,
    d.codigo,
    d.nome
ORDER BY
    taxa_aprovacao DESC NULLS LAST,
    d.codigo;


SELECT *
FROM vw_oferta
ORDER BY
    ano,
    semestre,
    disciplina;


SELECT *
FROM vw_vagas
ORDER BY
    turma_id;


SELECT *
FROM vw_historico
ORDER BY
    ra,
    ano,
    semestre,
    disciplina;


SELECT *
FROM mv_indicadores_curso
ORDER BY
    curso,
    ano,
    semestre;