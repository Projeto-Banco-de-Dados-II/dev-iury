# Checklist de conferência — Projeto BD2

## Marco 1

- [x] DDL das 16 tabelas do modelo lógico
- [x] Tipos ENUM: turno_t, tipo_disc_t, vinculo_t, status_mat_t, situacao_t, tipo_sala_t
- [x] Domains nota_t e pct_t
- [x] Tipo range timerange
- [x] PK, FK, UNIQUE e CHECK
- [x] Colunas geradas em disciplina.ch_total e historico.media_final
- [x] Restrição EXCLUDE para conflito de sala/horário
- [x] Índice parcial uq_curriculo_ativo para currículo ativo por curso
- [x] 120 alunos
- [x] 6 turmas
- [x] 300 matrículas
- [x] 10 consultas comentadas
- [x] Junção externa com agregação
- [x] Recursão da árvore de pré-requisitos
- [x] Recursão das disciplinas que o aluno pode cursar
- [x] RANK e PERCENT_RANK
- [x] LAG

## Marco 2

- [x] 3 views: oferta, vagas, histórico
- [x] vw_historico com security_invoker=true para respeitar RLS
- [x] 1 materialized view de indicadores
- [x] Índice único da materialized view para REFRESH CONCURRENTLY
- [x] Política de atualização documentada
- [x] Índice parcial de matrículas ativas
- [x] Índice por aluno
- [x] Índice por período/disciplina
- [x] Índice parcial por situação do histórico
- [x] BRIN em ocorrido_em
- [x] GIN em texto de ementa
- [x] Bônus: GIN sobre JSONB de log_matricula.detalhe
- [x] EXPLAIN (ANALYZE, BUFFERS) antes/depois dos quatro índices principais
- [x] Anomalia de última vaga preparada em duas sessões
- [x] Correção por FOR UPDATE
- [x] Correção por SERIALIZABLE
- [x] Comparação técnica prevista na documentação
- [x] Roles aluno, secretaria e coordenacao
- [x] GRANT/REVOKE
- [x] RLS com FORCE ROW LEVEL SECURITY
- [x] Testes de aluno 1 e aluno 2
- [x] Backup em formato custom
- [x] Restore em banco separado
- [x] Validação operacional

## Entrega

- [x] Scripts numerados
- [x] README desde o zero
- [x] Pasta de evidências
- [x] AUTORES.md
- [ ] Gerar e salvar EXPLAIN real
- [ ] Preencher comparação com tempos reais
- [ ] Registrar concorrência real
- [ ] Registrar RLS real
- [ ] Executar backup e restore reais



