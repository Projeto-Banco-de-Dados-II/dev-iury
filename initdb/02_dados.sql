SET search_path TO academico, public;

INSERT INTO campus (nome, cidade) VALUES
('Asa Sul','Brasília'),
('Ceilândia','Brasília');

INSERT INTO curso (codigo, nome, grau, ch_total, campus_id) VALUES
('CCO','Ciência da Computação','BACHARELADO',3200,1),
('ENGC','Engenharia de Computação','BACHARELADO',3600,1),
('ADS','Análise e Desenvolvimento de Sistemas','TECNOLOGO',2000,1);

INSERT INTO curriculo (curso_id, ano_vigencia, ativo) VALUES
(1,2026,true),(1,2023,false),(2,2026,true),(3,2026,true);

INSERT INTO disciplina (codigo, nome, ch_teorica, ch_pratica, ementa) VALUES
('HMDC253','Banco de Dados I',30,30,'Modelagem conceitual, modelo relacional, álgebra relacional, normalização e SQL.'),
('CCO072','Banco de Dados II',30,30,'Arquitetura de SGBD, transações, controle de concorrência, recuperação, segurança, otimização de consultas e bancos distribuídos.'),
('CCO085','Programação Paralela',45,15,'Concorrência, paralelismo, memória compartilhada e distribuída.'),
('MDC050','Inteligência Artificial',45,15,'Busca, representação do conhecimento e aprendizado de máquina.'),
('ADS033','Aprendizagem de Máquina',30,30,'Aprendizado supervisionado e não supervisionado, avaliação de modelos.'),
('MDC118','Algoritmos e Programação de Computadores I',30,30,'Lógica de programação e estruturas básicas.'),
('MDC122','Sistemas Operacionais',45,15,'Processos, escalonamento, memória e sistemas de arquivos.');

INSERT INTO curriculo_disciplina (curriculo_id, disciplina_id, periodo, tipo) VALUES
(1,1,2,'OBRIGATORIA'),(1,2,4,'OBRIGATORIA'),(1,3,6,'OBRIGATORIA'),
(1,4,4,'OBRIGATORIA'),(1,6,1,'OBRIGATORIA'),(1,7,4,'OBRIGATORIA'),
(4,5,5,'OBRIGATORIA');

INSERT INTO pre_requisito (disciplina_id, requisito_id, vinculo) VALUES
(1,6,'PRE_REQUISITO'),(2,1,'PRE_REQUISITO'),
(3,6,'PRE_REQUISITO'),(3,7,'PRE_REQUISITO'),(4,6,'PRE_REQUISITO');

INSERT INTO professor (matricula, nome, email, titulacao) VALUES
('201680','Rodrigo Gonçalves Pinto','rodrigo.pinto@iesb.edu.br','MESTRE'),
('201455','Marcelo Paiva','marcelo.paiva@iesb.edu.br','DOUTOR'),
('201322','Roger Santos','roger.santos@iesb.edu.br','MESTRE');

INSERT INTO sala (campus_id, codigo, capacidade, tipo) VALUES
(1,'JB1',55,'LABORATORIO'),(1,'JB2/4',36,'LABORATORIO'),
(1,'JB5',44,'LABORATORIO'),(1,'IA2',24,'LABORATORIO'),
(1,'IA3',30,'LABORATORIO'),(1,'JA2',32,'TEORICA');

INSERT INTO periodo_letivo (ano, semestre, data_inicio, data_fim) VALUES
(2026,2,'2026-08-03','2026-12-12'),
(2026,1,'2026-02-02','2026-06-20');

INSERT INTO feriado (data, descricao, campus_id) VALUES
('2026-09-07','Independência do Brasil',NULL),
('2026-10-12','Nossa Senhora Aparecida',NULL),
('2026-10-13','Recesso — antecipação do Dia do Professor',NULL),
('2026-11-02','Finados',NULL),
('2026-11-15','Proclamação da República',NULL),
('2026-11-20','Dia da Consciência Negra',NULL),
('2026-11-30','Dia do Evangélico',NULL),
('2026-12-25','Natal',NULL);

INSERT INTO turma (codigo, disciplina_id, periodo_letivo_id, professor_id, turno, vagas) VALUES
('CCODM2B',2,1,1,'MATUTINO',40),
('CCONM2B',2,1,1,'NOTURNO',24),
('CCODM3B',3,1,1,'MATUTINO',30),
('CCONM3B',3,1,1,'NOTURNO',30),
('ENGCDM2B',4,1,2,'MATUTINO',36),
('ADSDM2C',5,1,3,'MATUTINO',36);

INSERT INTO turma_horario (turma_id, sala_id, dia_semana, faixa) VALUES
(1,1,2,'[08:15,11:00)'),
(2,4,2,'[19:15,22:00)'),
(3,5,5,'[08:15,11:00)'),
(4,5,5,'[19:15,22:00)'),
(5,2,4,'[08:15,11:00)'),
(6,2,6,'[08:15,11:00)');

INSERT INTO aluno (matricula,nome,cpf,email,nascimento,curso_id,curriculo_id,ingresso)
SELECT lpad(g::text,8,'0'),
       'Aluno '||g,
       lpad(g::text,11,'0'),
       'aluno'||g||'@iesb.edu.br',
       DATE '2003-01-01' + (g % 900),
       CASE WHEN g % 3 = 0 THEN 1 WHEN g % 3 = 1 THEN 2 ELSE 3 END,
       CASE WHEN g % 3 = 0 THEN 1 WHEN g % 3 = 1 THEN 3 ELSE 4 END,
       DATE '2024-02-01'
FROM generate_series(1,120) g;

INSERT INTO matricula (aluno_id,turma_id,data_matricula,status)
SELECT ((n - 1) % 110) + 1,
       t.id,
       TIMESTAMPTZ '2026-08-03 08:00:00-03'
         + ((n + t.id) % 90) * INTERVAL '1 day',
       'MATRICULADO'
FROM turma t
CROSS JOIN LATERAL generate_series(1,t.vagas) AS s(n);

INSERT INTO matricula (aluno_id,turma_id,data_matricula,status)
SELECT a.id,t.id,
       TIMESTAMPTZ '2026-02-02 08:00:00-03'
         + ((a.id+t.id) % 120) * INTERVAL '1 day',
       CASE WHEN (a.id+t.id)%2=0 THEN 'CANCELADO' ELSE 'TRANCADO' END
FROM aluno a
CROSS JOIN turma t
WHERE a.id <= 110
  AND NOT EXISTS (
      SELECT 1 FROM matricula m
      WHERE m.aluno_id=a.id AND m.turma_id=t.id
  )
ORDER BY a.id,t.id
LIMIT 104;

INSERT INTO historico (matricula_id,nota_a1,nota_a2,nota_p3,frequencia,situacao)
SELECT m.id,
       round((random()*6+4)::numeric,2),
       round((random()*6+4)::numeric,2),
       CASE WHEN m.id % 10 = 0 THEN round((random()*3+5)::numeric,2) ELSE NULL END,
       round((random()*30+70)::numeric,2),
       'CURSANDO'
FROM matricula m;

UPDATE historico
SET situacao =
  CASE
    WHEN frequencia < 75 THEN 'REPROVADO_FALTA'::situacao_t
    WHEN media_final >= 5 THEN 'APROVADO'::situacao_t
    ELSE 'REPROVADO_NOTA'::situacao_t
  END;

INSERT INTO log_matricula (matricula_id,acao,ocorrido_em,detalhe)
SELECT m.id,
       CASE WHEN m.status='MATRICULADO' THEN 'MATRICULA' ELSE lower(m.status::text) END,
       m.data_matricula,
       jsonb_build_object('turma_id',m.turma_id,'aluno_id',m.aluno_id)
FROM matricula m;

ANALYZE;
