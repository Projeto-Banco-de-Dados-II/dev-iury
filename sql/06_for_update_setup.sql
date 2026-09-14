SET search_path TO academico, public;

CREATE OR REPLACE FUNCTION fn_valida_vaga() RETURNS trigger AS $$
DECLARE
    v_vagas smallint;
    v_ocupadas integer;
BEGIN
    SELECT vagas INTO v_vagas FROM turma WHERE id=NEW.turma_id FOR UPDATE;
    SELECT count(*) INTO v_ocupadas FROM matricula WHERE turma_id=NEW.turma_id AND status='MATRICULADO' AND id<>COALESCE(NEW.id,-1);
    IF v_ocupadas >= v_vagas THEN
        RAISE EXCEPTION 'Turma % sem vagas (% de %)',NEW.turma_id,v_ocupadas,v_vagas USING ERRCODE='check_violation';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_valida_vaga
BEFORE INSERT OR UPDATE ON matricula
FOR EACH ROW EXECUTE FUNCTION fn_valida_vaga;
