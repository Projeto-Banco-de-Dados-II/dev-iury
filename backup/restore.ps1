$ErrorActionPreference = "Stop"
$env:PGPASSWORD = "bd2"
docker cp .\backup\arquivos\matricula_bd2.dump bd2_postgres:/tmp/matricula_bd2.dump
docker exec bd2_postgres dropdb -U bd2 --if-exists matricula_restauracao
docker exec bd2_postgres createdb -U bd2 matricula_restauracao
docker exec bd2_postgres pg_restore -U bd2 -d matricula_restauracao --clean --if-exists /tmp/matricula_bd2.dump
docker exec bd2_postgres psql -U bd2 -d matricula_restauracao -c "SELECT count(*) AS alunos FROM academico.aluno; SELECT count(*) AS matriculas FROM academico.matricula;"
Remove-Item Env:PGPASSWORD
