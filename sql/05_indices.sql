SET search_path TO academico, public;

DROP INDEX IF EXISTS ix_matricula_turma_ativa;
DROP INDEX IF EXISTS ix_matricula_aluno;
DROP INDEX IF EXISTS ix_turma_periodo_disc;
DROP INDEX IF EXISTS ix_historico_situacao;
DROP INDEX IF EXISTS ix_log_ocorrido;
DROP INDEX IF EXISTS ix_disciplina_ementa_fts;
DROP INDEX IF EXISTS ix_log_detalhe_gin;
ANALYZE;

EXPLAIN (ANALYZE,BUFFERS)
SELECT * FROM matricula
WHERE turma_id=1 AND status='MATRICULADO';

CREATE INDEX ix_matricula_turma_ativa
ON matricula(turma_id)
WHERE status='MATRICULADO';
ANALYZE matricula;

EXPLAIN (ANALYZE,BUFFERS)
SELECT * FROM matricula
WHERE turma_id=1 AND status='MATRICULADO';

EXPLAIN (ANALYZE,BUFFERS)
SELECT * FROM matricula WHERE aluno_id=1;

CREATE INDEX ix_matricula_aluno ON matricula(aluno_id);
ANALYZE matricula;

EXPLAIN (ANALYZE,BUFFERS)
SELECT * FROM matricula WHERE aluno_id=1;

EXPLAIN (ANALYZE,BUFFERS)
SELECT * FROM turma WHERE periodo_letivo_id=1 AND disciplina_id=2;

CREATE INDEX ix_turma_periodo_disc
ON turma(periodo_letivo_id,disciplina_id);
ANALYZE turma;

EXPLAIN (ANALYZE,BUFFERS)
SELECT * FROM turma WHERE periodo_letivo_id=1 AND disciplina_id=2;

EXPLAIN (ANALYZE,BUFFERS)
SELECT * FROM historico WHERE situacao='APROVADO';

CREATE INDEX ix_historico_situacao
ON historico(situacao)
WHERE situacao <> 'CURSANDO';
ANALYZE historico;

EXPLAIN (ANALYZE,BUFFERS)
SELECT * FROM historico WHERE situacao='APROVADO';

CREATE INDEX ix_log_ocorrido ON log_matricula USING brin(ocorrido_em);
CREATE INDEX ix_disciplina_ementa_fts
ON disciplina USING gin(to_tsvector('portuguese',coalesce(ementa,'')));
CREATE INDEX ix_log_detalhe_gin ON log_matricula USING gin(detalhe);

ANALYZE;
