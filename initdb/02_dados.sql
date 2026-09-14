SET search_path TO academico, public;

INSERT INTO campus (nome, cidade)
VALUES
    ('Campus Brasília', 'Brasília'),
    ('Campus Goiás', 'Goiânia');

INSERT INTO curso (codigo, nome, grau, ch_total, campus_id)
SELECT
    'CCO',
    'Ciência da Computação',
    'BACHARELADO',
    3200,
    id
FROM campus
WHERE nome = 'Campus Brasília';

INSERT INTO curso (codigo, nome, grau, ch_total, campus_id)
SELECT
    'ADS',
    'Análise e Desenvolvimento de Sistemas',
    'TECNOLOGO',
    2400,
    id
FROM campus
WHERE nome = 'Campus Brasília';

INSERT INTO curso (codigo, nome, grau, ch_total, campus_id)
SELECT
    'SI',
    'Sistemas de Informação',
    'BACHARELADO',
    3200,
    id
FROM campus
WHERE nome = 'Campus Goiás';

INSERT INTO curriculo (curso_id, ano_vigencia, ativo)
SELECT id, 2026, TRUE
FROM curso
WHERE codigo IN ('CCO', 'ADS', 'SI');

INSERT INTO curriculo (curso_id, ano_vigencia, ativo)
SELECT id, 2025, FALSE
FROM curso
WHERE codigo = 'CCO';

INSERT INTO disciplina
    (codigo, nome, ch_teorica, ch_pratica, ementa)
VALUES
    ('CCO001', 'Algoritmos e Programação', 60, 30,
     'Fundamentos de algoritmos e programação.'),
    ('CCO002', 'Estruturas de Dados', 60, 30,
     'Estruturas de dados e algoritmos.'),
    ('CCO003', 'Banco de Dados I', 60, 30,
     'Fundamentos de bancos de dados relacionais.'),
    ('CCO072', 'Banco de Dados II', 60, 30,
     'Projeto e implementação de bancos de dados.'),
    ('CCO005', 'Engenharia de Software', 60, 30,
     'Processos e práticas de engenharia de software.'),
    ('CCO006', 'Matemática Discreta', 60, 0,
     'Fundamentos matemáticos para computação.'),
    ('CCO007', 'Programação Orientada a Objetos', 60, 30,
     'Programação orientada a objetos.');

INSERT INTO curriculo_disciplina
    (curriculo_id, disciplina_id, periodo, tipo)
SELECT
    cur.id,
    d.id,
    CASE d.codigo
        WHEN 'CCO006' THEN 1
        WHEN 'CCO001' THEN 1
        WHEN 'CCO007' THEN 2
        WHEN 'CCO002' THEN 3
        WHEN 'CCO003' THEN 3
        WHEN 'CCO072' THEN 4
        WHEN 'CCO005' THEN 5
    END,
    'OBRIGATORIA'
FROM curriculo cur
JOIN curso c
    ON c.id = cur.curso_id
CROSS JOIN disciplina d
WHERE c.codigo = 'CCO'
  AND cur.ano_vigencia = 2026
  AND cur.ativo = TRUE
  AND d.codigo IN (
      'CCO001',
      'CCO002',
      'CCO003',
      'CCO005',
      'CCO006',
      'CCO007',
      'CCO072'
  );

INSERT INTO pre_requisito
    (disciplina_id, requisito_id, vinculo)
SELECT
    d.id,
    r.id,
    'PRE_REQUISITO'
FROM (
    VALUES
        ('CCO001', 'CCO006'),
        ('CCO002', 'CCO001'),
        ('CCO003', 'CCO006'),
        ('CCO072', 'CCO003'),
        ('CCO072', 'CCO007')
) AS x(disciplina, requisito)
JOIN disciplina d
    ON d.codigo = x.disciplina
JOIN disciplina r
    ON r.codigo = x.requisito;

INSERT INTO professor
    (matricula, nome, email, titulacao)
VALUES
    ('PROF001', 'Ana Carolina Silva',
     'ana.silva@iesb.edu.br', 'DOUTOR'),
    ('PROF002', 'Bruno Henrique Costa',
     'bruno.costa@iesb.edu.br', 'MESTRE'),
    ('PROF003', 'Carlos Eduardo Mendes',
     'carlos.mendes@iesb.edu.br', 'DOUTOR');

INSERT INTO sala
    (campus_id, codigo, capacidade, tipo)
SELECT
    c.id,
    x.codigo,
    x.capacidade,
    x.tipo::tipo_sala_t
FROM (
    VALUES
        ('Campus Brasília', 'A101', 50, 'TEORICA'),
        ('Campus Brasília', 'A102', 40, 'TEORICA'),
        ('Campus Brasília', 'A201', 35, 'LABORATORIO'),
        ('Campus Brasília', 'B101', 40, 'TEORICA'),
        ('Campus Brasília', 'B202', 35, 'LABORATORIO'),
        ('Campus Goiás', 'C301', 50, 'TEORICA')
) AS x(campus, codigo, capacidade, tipo)
JOIN campus c
    ON c.nome = x.campus;

INSERT INTO periodo_letivo
    (ano, semestre, data_inicio, data_fim)
VALUES
    (2026, 1, DATE '2026-02-02', DATE '2026-06-30'),
    (2026, 2, DATE '2026-08-03', DATE '2026-12-18');

INSERT INTO feriado
    (data, descricao, campus_id)
VALUES
    (DATE '2026-04-03', 'Sexta-feira Santa', NULL),
    (DATE '2026-04-21', 'Tiradentes', NULL),
    (DATE '2026-05-01', 'Dia do Trabalho', NULL),
    (DATE '2026-09-07', 'Independência do Brasil', NULL),
    (DATE '2026-10-12', 'Nossa Senhora Aparecida', NULL),
    (DATE '2026-11-02', 'Finados', NULL),
    (DATE '2026-11-15', 'Proclamação da República', NULL),
    (DATE '2026-11-20', 'Consciência Negra', NULL);

INSERT INTO turma
    (codigo, disciplina_id, periodo_letivo_id, professor_id, turno, vagas)
SELECT
    x.codigo,
    d.id,
    pl.id,
    p.id,
    x.turno::turno_t,
    x.vagas
FROM (
    VALUES
        ('CCO001-A', 'CCO001', 2026, 1, 'MATUTINO', 40, 'PROF001'),
        ('CCO002-A', 'CCO002', 2026, 1, 'VESPERTINO', 24, 'PROF002'),
        ('CCO003-A', 'CCO003', 2026, 1, 'NOTURNO', 30, 'PROF003'),
        ('CCO072-A', 'CCO072', 2026, 2, 'NOTURNO', 30, 'PROF001'),
        ('CCO005-A', 'CCO005', 2026, 2, 'VESPERTINO', 36, 'PROF002'),
        ('CCO007-A', 'CCO007', 2026, 2, 'MATUTINO', 36, 'PROF003')
) AS x(codigo, disciplina, ano, semestre, turno, vagas, professor)
JOIN disciplina d
    ON d.codigo = x.disciplina
JOIN periodo_letivo pl
    ON pl.ano = x.ano
   AND pl.semestre = x.semestre
JOIN professor p
    ON p.matricula = x.professor;

INSERT INTO turma_horario
    (turma_id, sala_id, dia_semana, faixa)
SELECT
    t.id,
    s.id,
    x.dia_semana,
    x.faixa::timerange
FROM (
    VALUES
        ('CCO001-A', 'Campus Brasília', 'A101', 2, '[08:00,10:00)'),
        ('CCO002-A', 'Campus Brasília', 'A102', 3, '[14:00,16:00)'),
        ('CCO003-A', 'Campus Brasília', 'A201', 4, '[19:00,21:00)'),
        ('CCO072-A', 'Campus Brasília', 'B101', 5, '[19:00,21:00)'),
        ('CCO005-A', 'Campus Brasília', 'B202', 2, '[21:00,23:00)'),
        ('CCO007-A', 'Campus Brasília', 'A101', 4, '[21:00,23:00)')
) AS x(turma, campus, sala, dia_semana, faixa)
JOIN turma t
    ON t.codigo = x.turma
JOIN campus c
    ON c.nome = x.campus
JOIN sala s
    ON s.codigo = x.sala
   AND s.campus_id = c.id;

INSERT INTO aluno
    (matricula, nome, cpf, email, nascimento,
     curso_id, curriculo_id, ingresso)
SELECT
    '2026' || LPAD(gs::TEXT, 4, '0'),
    'Aluno ' || LPAD(gs::TEXT, 3, '0'),
    LPAD((10000000000 + gs)::TEXT, 11, '0'),
    'aluno' || gs || '@iesb.edu.br',
    DATE '2000-01-01' + ((gs * 37) % 2500),
    c.id,
    cur.id,
    DATE '2026-02-02'
FROM generate_series(1, 120) AS gs
JOIN curso c
    ON c.codigo = CASE
        WHEN gs % 3 = 1 THEN 'CCO'
        WHEN gs % 3 = 2 THEN 'ADS'
        ELSE 'SI'
    END
JOIN curriculo cur
    ON cur.curso_id = c.id
   AND cur.ano_vigencia = 2026
   AND cur.ativo = TRUE;

INSERT INTO matricula
    (aluno_id, turma_id, data_matricula, status)
SELECT
    ((n - 1) % 110) + 1,
    t.id,
    CASE
        WHEN pl.semestre = 1
        THEN TIMESTAMPTZ '2026-02-02 10:00:00-03'
        ELSE TIMESTAMPTZ '2026-08-03 10:00:00-03'
    END,
    'MATRICULADO'
FROM turma t
JOIN periodo_letivo pl
    ON pl.id = t.periodo_letivo_id
CROSS JOIN LATERAL generate_series(1, t.vagas) AS g(n);

INSERT INTO matricula
    (aluno_id, turma_id, data_matricula, status)
SELECT
    p.aluno_id,
    p.turma_id,
    CASE
        WHEN pl.semestre = 1
        THEN TIMESTAMPTZ '2026-02-02 10:00:00-03'
        ELSE TIMESTAMPTZ '2026-08-03 10:00:00-03'
    END,
    CASE
        WHEN p.ordem % 2 = 0
        THEN 'CANCELADO'
        ELSE 'TRANCADO'
    END
FROM (
    SELECT
        a.id AS aluno_id,
        t.id AS turma_id,
        ROW_NUMBER() OVER (
            ORDER BY a.id, t.id
        ) AS ordem
    FROM aluno a
    CROSS JOIN turma t
    WHERE NOT EXISTS (
        SELECT 1
        FROM matricula m
        WHERE m.aluno_id = a.id
          AND m.turma_id = t.id
    )
    ORDER BY a.id, t.id
    LIMIT 104
) AS p
JOIN turma t
    ON t.id = p.turma_id
JOIN periodo_letivo pl
    ON pl.id = t.periodo_letivo_id;

INSERT INTO historico
    (matricula_id, nota_a1, nota_a2, nota_p3, frequencia, situacao)
SELECT
    m.id,
    ROUND((3 + random() * 7)::numeric, 2),
    ROUND((3 + random() * 7)::numeric, 2),
    CASE
        WHEN m.id % 4 = 0
        THEN ROUND((3 + random() * 7)::numeric, 2)
        ELSE NULL
    END,
    CASE
        WHEN m.id % 10 = 0
        THEN ROUND((60 + random() * 14)::numeric, 2)
        WHEN m.id % 7 = 0
        THEN ROUND((70 + random() * 10)::numeric, 2)
        ELSE ROUND((80 + random() * 20)::numeric, 2)
    END,
    'CURSANDO'
FROM matricula m;

UPDATE historico
SET situacao =
    CASE
        WHEN frequencia < 75
        THEN 'REPROVADO_FALTA'
        WHEN media_final < 5
        THEN 'REPROVADO_NOTA'
        ELSE 'APROVADO'
    END;

INSERT INTO log_matricula
    (matricula_id, acao, detalhe)
SELECT
    m.id,
    'INSERCAO',
    jsonb_build_object(
        'aluno_id', m.aluno_id,
        'turma_id', m.turma_id,
        'status', m.status
    )
FROM matricula m;

ANALYZE campus;
ANALYZE curso;
ANALYZE curriculo;
ANALYZE disciplina;
ANALYZE curriculo_disciplina;
ANALYZE pre_requisito;
ANALYZE professor;
ANALYZE sala;
ANALYZE periodo_letivo;
ANALYZE feriado;
ANALYZE turma;
ANALYZE turma_horario;
ANALYZE aluno;
ANALYZE matricula;
ANALYZE historico;
ANALYZE log_matricula;

REFRESH MATERIALIZED VIEW mv_indicadores_curso;