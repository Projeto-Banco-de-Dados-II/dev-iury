# Projeto Acadêmico — Banco de Dados II (CCO072)

## Sistema de Matrícula Acadêmica — IESB 2026/2

Projeto desenvolvido para a disciplina de **Banco de Dados II (CCO072)**, contemplando a implementação de um sistema de matrícula acadêmica em PostgreSQL, com foco em integridade, consultas avançadas, desempenho, concorrência, segurança e operação/recovery.

## Objetivo

Implementar o modelo relacional proposto para o sistema acadêmico, contemplando:

* Modelagem e implementação do banco de dados;
* Integridade e restrições;
* Tipos ENUM, domains e tipos range;
* Chaves e relacionamentos;
* Colunas geradas;
* Consultas SQL de diferentes níveis de complexidade;
* Views e materialized views;
* Índices e análise de desempenho;
* Controle de concorrência;
* Segurança e controle de acesso;
* Row Level Security (RLS);
* Backup e restauração;
* Procedimentos de operação e recuperação.

## Tecnologias

* PostgreSQL 17
* Docker
* Docker Compose
* pgAdmin

O banco de dados PostgreSQL 17 é executado em contêiner Docker.

## Configuração do ambiente

### Subir o banco

No PowerShell, dentro da pasta do projeto:

```powershell
docker compose up -d
docker compose ps
```

### Acesso ao banco

* **Host:** `localhost`
* **Porta:** `5432`
* **Database:** `matricula`
* **Usuário:** `bd2`
* **Senha:** `bd2`

### pgAdmin

O pgAdmin está disponível em:

`http://localhost:8080`

## Estrutura do projeto

A execução dos scripts segue a seguinte ordem:

```text
1. initdb/01_modelo.sql
2. initdb/02_dados.sql
3. sql/03_consultas.sql
4. sql/04_views.sql
5. sql/05_indices.sql
6. sql/06_concorrencia.sql
7. sql/07_seguranca.sql
8. sql/08_operacao.sql
```

Os scripts de criação do modelo e carga inicial são executados automaticamente pelo PostgreSQL na primeira criação do volume.

## Marco 1

O projeto possui a implementação completa do modelo relacional, incluindo:

* DDL completo;
* Tipos ENUM;
* Domains;
* Tipo range;
* Chaves primárias e estrangeiras;
* Restrições de integridade;
* Colunas geradas;
* 120 alunos;
* 6 turmas;
* 300 matrículas;
* 10 consultas SQL de complexidade crescente.

As consultas incluem recursos avançados do PostgreSQL, como:

* Junções externas com agregação;
* Consultas recursivas;
* Ranking;
* Percentis;
* Função `LAG`;
* Agregações e análises sobre os dados acadêmicos.

As dez consultas estão apresentadas individualmente no arquivo `sql/03_consultas.sql`.

## Marco 2

O projeto também contempla recursos avançados de banco de dados, incluindo:

### Views

Foram implementadas três views:

* `vw_oferta`
* `vw_vagas`
* `vw_historico`

### Materialized View

Foi criada a materialized view:

```text
mv_indicadores_curso
```

Ela consolida indicadores por curso e período, utilizando um índice único que permite atualização concorrente.

A atualização é realizada com:

```sql
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_indicadores_curso;
```

quando o índice único necessário está disponível.

### Índices

O projeto utiliza diferentes estratégias de indexação, incluindo:

* Índices convencionais;
* Índices parciais;
* Índices BRIN;
* Índices GIN.

Também foi implementado um índice GIN sobre o campo JSONB da tabela `log_matricula`:

```text
log_matricula.detalhe
```

### Análise de desempenho

Foram incluídas evidências de análise utilizando `EXPLAIN` e recursos de otimização do PostgreSQL.

## Concorrência

O projeto apresenta duas estratégias para controle de concorrência durante o processo de matrícula.

### Situação de disputa

A turma 1 é preparada com:

* 41 vagas;
* 40 matrículas ativas.

O cenário permite reproduzir uma disputa entre duas transações tentando realizar matrículas simultaneamente.

### Bloqueio explícito

A primeira solução utiliza `FOR UPDATE`, realizando o bloqueio explícito do registro da turma durante a operação.

Arquivos envolvidos:

```text
sql/06_for_update_setup.sql
sql/06_for_update_A.sql
sql/06_for_update_B.sql
```

### Isolamento SERIALIZABLE

A segunda solução utiliza o nível de isolamento:

```sql
SERIALIZABLE
```

Arquivos envolvidos:

```text
sql/06_serializable_setup.sql
sql/06_serializable_A.sql
sql/06_serializable_B.sql
```

A comparação entre as estratégias considera:

* Contenção;
* Custo;
* Comportamento dos bloqueios;
* Concorrência entre transações;
* Possibilidade de retentativa em casos de `serialization failure`.

## Segurança

O projeto implementa diferentes mecanismos de segurança e controle de acesso.

Foram criadas as roles:

```text
aluno
secretaria
coordenacao
```

As roles são configuradas como `NOLOGIN`.

O acesso do aluno é demonstrado utilizando:

```sql
SET ROLE aluno;
SET app.aluno_id;
```

### Row Level Security

A tabela `historico` utiliza:

```text
ROW LEVEL SECURITY
```

com:

```text
FORCE ROW LEVEL SECURITY
```

A view `vw_historico` utiliza:

```text
security_invoker = true
```

permitindo que as políticas de segurança da tabela sejam respeitadas durante a consulta através da view.

Também foram implementados mecanismos de:

* `GRANT`;
* `REVOKE`;
* Controle de privilégios;
* Isolamento das informações acadêmicas.

## Backup e restauração

O projeto possui scripts automatizados para backup e restauração.

### Backup

```powershell
.\backup\backup.ps1
```

### Restauração

```powershell
.\backup\restore.ps1
```

A restauração utiliza um dump em formato custom do PostgreSQL e cria o banco:

```text
matricula_restauracao
```

## Validação

O arquivo:

```text
sql/08_operacao.sql
```

contém as rotinas de validação e operação do projeto.

Entre os itens verificados estão:

* 120 alunos;
* 6 turmas;
* 300 matrículas;
* Registros de histórico;
* Views;
* Índices;
* Controle de vagas;
* Materialized view;
* Estruturas de segurança;
* Operações de backup e restauração.

## Evidências

A pasta:

```text
evidencias
```

contém os registros relacionados às funcionalidades e validações realizadas no projeto, incluindo evidências de consultas, desempenho, concorrência, segurança e operação.

## Reset do ambiente

Para remover completamente o banco e recriar o ambiente:

```powershell
docker compose down -v
docker compose up -d
```

Esse procedimento recria o banco a partir dos scripts de inicialização.

## Execução completa

Para executar o projeto em um ambiente limpo:

```powershell
docker compose up -d
docker compose ps
```

Após a inicialização do PostgreSQL, os scripts do projeto são executados na sequência definida na estrutura do projeto.

O banco estará disponível em:

```text
localhost:5432
```

com:

```text
Database: matricula
Usuário: bd2
Senha: bd2
```

## Conclusão

O projeto implementa um sistema de matrícula acadêmica completo em PostgreSQL 17, contemplando desde a modelagem e carga de dados até consultas avançadas, otimização, controle de concorrência, segurança, backup, restauração e procedimentos de operação.

A solução utiliza recursos nativos do PostgreSQL para garantir integridade, desempenho, segurança e consistência das operações acadêmicas.
