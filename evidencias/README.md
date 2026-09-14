# Projeto Acadêmico — Banco de Dados II (CCO072)

Sistema de Matrícula Acadêmica — IESB 2026/2.

## Objetivo

Implementar o modelo relacional fornecido pelo professor com integridade, consultas avançadas, desempenho, concorrência, segurança e operação/recovery.

## Requisitos

- Docker Desktop
- Docker Compose
- PostgreSQL 17 no contêiner
- pgAdmin opcional

O enunciado oficial determina PostgreSQL 17. O guia de ambiente distribuído anteriormente menciona PostgreSQL 16; para este projeto, siga a versão indicada no enunciado oficial.

## Subir o banco

No PowerShell, dentro desta pasta:

```powershell
docker compose up -d
docker compose ps
```

Banco: `localhost:5432`
Database: `matricula`
Usuário: `bd2`
Senha: `bd2`
pgAdmin: `http://localhost:8080`

## Ordem de execução

1. `initdb/01_modelo.sql`
2. `initdb/02_dados.sql`
3. `sql/03_consultas.sql`
4. `sql/04_views.sql`
5. `sql/05_indices.sql`
6. `sql/06_concorrencia.sql`
7. `sql/07_seguranca.sql`
8. `sql/08_operacao.sql`

Os scripts 01 e 02 são executados automaticamente pelo PostgreSQL na primeira criação do volume.

## Consultas comentadas

As dez consultas estão comentadas individualmente porque o enunciado exige que cada consulta seja comentada. Os demais scripts permanecem sem comentários SQL desnecessários.

## Marco 1

O projeto contém DDL completo, tipos ENUM, domains, tipo range, chaves, restrições, colunas geradas, 120 alunos, 6 turmas, 300 matrículas e 10 consultas de complexidade crescente. As consultas incluem junção externa com agregação, duas consultas recursivas, ranking com percentil e LAG.

## Marco 2

O projeto contém três views (`vw_oferta`, `vw_vagas`, `vw_historico`), uma materialized view (`mv_indicadores_curso`) com índice único para refresh concorrente, índices parciais, BRIN, GIN, evidências de EXPLAIN, demonstrações de concorrência, roles, GRANT/REVOKE, RLS, backup e restauração. Também foi incluído como bônus um índice GIN sobre JSONB (`log_matricula.detalhe`).

## Política da materialized view

`mv_indicadores_curso` consolida indicadores por curso e período. Como é uma consulta agregada, a atualização não precisa ocorrer a cada leitura. A política adotada é atualizar após cargas/alterações relevantes e antes da demonstração, usando `REFRESH MATERIALIZED VIEW CONCURRENTLY` quando o índice único estiver disponível.

## Concorrência

`sql/06_concorrencia.sql` prepara a turma 1 com 41 vagas e 40 matrículas ativas e instala o gatilho inseguro. Os arquivos `06_unsafe_A.sql` e `06_unsafe_B.sql` reproduzem a disputa. Depois execute `06_for_update_setup.sql` e use `06_for_update_A.sql` e `06_for_update_B.sql` para a correção por bloqueio explícito. Para a correção por isolamento, execute `06_serializable_setup.sql` e use `06_serializable_A.sql` e `06_serializable_B.sql` com SERIALIZABLE.

A comparação deve abordar contenção, custo, comportamento do bloqueio e possibilidade de retentativa em caso de serialization failure.

## Segurança

As roles `aluno`, `secretaria` e `coordenacao` são criadas como NOLOGIN. O teste do aluno é feito com `SET ROLE aluno` e `SET app.aluno_id`. A tabela `historico` usa RLS com `FORCE ROW LEVEL SECURITY`, e a view `vw_historico` usa `security_invoker=true` para que as políticas da tabela sejam aplicadas ao consultar a view.

## Backup e restauração

```powershell
.\backup\backup.ps1
.\backup\restore.ps1
```

A restauração cria `matricula_restauracao` e usa o dump em formato custom do PostgreSQL.

## Evidências

A pasta `evidencias` contém apenas modelos. Os resultados finais devem ser reais e coletados durante a execução. Não use valores inventados.

## Validação

Depois de executar os scripts, rode `sql/08_operacao.sql`. A validação deve confirmar 120 alunos, 6 turmas, 300 matrículas, históricos, views, índices, vagas e materialized view.

## Reset

```powershell
docker compose down -v
docker compose up -d
```

Use o reset para repetir uma execução do zero.

## Entrega

Preencha `AUTORES.md`, mantenha os scripts numerados, inclua as evidências reais e faça commits distribuídos entre os integrantes. O enunciado informa que histórico de commits faz parte da avaliação.
