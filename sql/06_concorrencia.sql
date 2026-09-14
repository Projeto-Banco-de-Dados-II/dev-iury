SET search_path TO academico, public;

UPDATE turma
SET vagas=41
WHERE id=1;

DELETE FROM matricula
WHERE turma_id=1
  AND aluno_id IN (101,102);

CREATE OR REPLACE FUNCTION fn_valida_vaga_unsafe() RETURNS trigger AS $$
DECLARE
    v_vagas smallint;
    v_ocupadas integer;
BEGIN
    SELECT vagas INTO v_vagas
    FROM turma
    WHERE id=NEW.turma_id;

    SELECT count(*) INTO v_ocupadas
    FROM matricula
    WHERE turma_id=NEW.turma_id
      AND status='MATRICULADO'
      AND id<>COALESCE(NEW.id,-1);

    IF v_ocupadas >= v_vagas THEN
        RAISE EXCEPTION 'Turma % sem vagas (% de %)',NEW.turma_id,v_ocupadas,v_vagas USING ERRCODE='check_violation';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_valida_vaga_unsafe
BEFORE INSERT OR UPDATE ON matricula
FOR EACH ROW EXECUTE FUNCTION fn_valida_vaga_unsafe();

SELECT t.id,t.codigo,t.vagas,
       count(m.id) FILTER (WHERE m.status='MATRICULADO') AS ocupadas,
       t.vagas-count(m.id) FILTER (WHERE m.status='MATRICULADO') AS restantes
FROM turma t
LEFT JOIN matricula m ON m.turma_id=t.id
WHERE t.id=1
GROUP BY t.id,t.codigo,t.vagas;
