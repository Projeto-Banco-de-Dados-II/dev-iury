SET search_path TO academico, public;
SET ROLE aluno;
SET app.aluno_id='1';
SELECT current_user, current_setting('app.aluno_id') AS aluno_id;
SELECT ra,aluno,disciplina,media_final FROM vw_historico ORDER BY disciplina;
RESET ROLE;
