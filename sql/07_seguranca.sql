SET search_path TO academico, public;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='aluno') THEN
    CREATE ROLE aluno NOLOGIN;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='secretaria') THEN
    CREATE ROLE secretaria NOLOGIN;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='coordenacao') THEN
    CREATE ROLE coordenacao NOLOGIN;
  END IF;
END $$;

GRANT USAGE ON SCHEMA academico TO aluno,secretaria,coordenacao;

GRANT SELECT ON historico,matricula,aluno,disciplina,turma,periodo_letivo
TO aluno;

GRANT SELECT ON vw_oferta,vw_vagas,vw_historico TO aluno;

GRANT SELECT,INSERT,UPDATE ON aluno,matricula,historico TO secretaria;
GRANT SELECT,INSERT,UPDATE,DELETE ON aluno,matricula,historico,turma,turma_horario TO coordenacao;
GRANT SELECT ON ALL TABLES IN SCHEMA academico TO coordenacao;

ALTER TABLE historico ENABLE ROW LEVEL SECURITY;
ALTER TABLE historico FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS historico_aluno ON historico;
CREATE POLICY historico_aluno ON historico
FOR SELECT TO aluno
USING (
  EXISTS (
    SELECT 1
    FROM matricula m
    WHERE m.id=historico.matricula_id
      AND m.aluno_id=(
        NULLIF(current_setting('app.aluno_id',true),'')
      )::integer
  )
);

DROP POLICY IF EXISTS historico_secretaria ON historico;
CREATE POLICY historico_secretaria ON historico
FOR ALL TO secretaria
USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS historico_coordenacao ON historico;
CREATE POLICY historico_coordenacao ON historico
FOR ALL TO coordenacao
USING (true) WITH CHECK (true);

REVOKE INSERT,UPDATE,DELETE ON historico FROM aluno;
REVOKE INSERT,UPDATE,DELETE ON matricula FROM aluno;
REVOKE INSERT,UPDATE,DELETE ON aluno FROM aluno;

REVOKE ALL ON vw_historico FROM PUBLIC;
