$ErrorActionPreference = "Stop"
$env:PGPASSWORD = "bd2"
New-Item -ItemType Directory -Force -Path .\backup\arquivos | Out-Null
docker exec bd2_postgres pg_dump -U bd2 -d matricula -Fc -f /tmp/matricula_bd2.dump
docker cp bd2_postgres:/tmp/matricula_bd2.dump .\backup\arquivos\matricula_bd2.dump
Remove-Item Env:PGPASSWORD
