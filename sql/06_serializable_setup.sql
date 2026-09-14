SET search_path TO academico, public;

CREATE OR REPLACE TRIGGER tg_valida_vaga
BEFORE INSERT OR UPDATE ON matricula
FOR EACH ROW EXECUTE FUNCTION fn_valida_vaga_unsafe;
