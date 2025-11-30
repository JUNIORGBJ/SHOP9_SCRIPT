USE [S9_Real];
GO

PRINT '⚠ INICIANDO LIMPEZA DAS TABELAS DE CONTAGEM DE ESTOQUE ⚠';

BEGIN TRY
    BEGIN TRANSACTION;

    -- Limpando tabelas FILHAS primeiro
    PRINT 'Limpando Contagem_Estoque_Itens_Series_Excluidas...';
    DELETE FROM [dbo].[Contagem_Estoque_Itens_Series_Excluidas];

    PRINT 'Limpando Contagem_Estoque_Itens_Series...';
    DELETE FROM [dbo].[Contagem_Estoque_Itens_Series];

    PRINT 'Limpando Contagem_Estoque_Itens_Lotes...';
    DELETE FROM [dbo].[Contagem_Estoque_Itens_Lotes];

    PRINT 'Limpando Contagem_Estoque_Itens...';
    DELETE FROM [dbo].[Contagem_Estoque_Itens];

    PRINT 'Limpando Contagem_Estoque_Movimentos_Gerados...';
    DELETE FROM [dbo].[Contagem_Estoque_Movimentos_Gerados];

    -- Por último, a tabela PAI
    PRINT 'Limpando Contagem_Estoque...';
    DELETE FROM [dbo].[Contagem_Estoque];

    -- Confirmar tudo
    COMMIT TRANSACTION;

    PRINT '✔ Limpeza concluída com sucesso!';

END TRY
BEGIN CATCH
    PRINT '❌ ERRO DETECTADO! Realizando ROLLBACK...';
    ROLLBACK TRANSACTION;

    PRINT ERROR_MESSAGE();
END CATCH;
GO

-- Opcional: compactação
-- Não execute se o banco for grande (> 5 GB)
PRINT 'Executando SHRINK...';
DBCC SHRINKDATABASE(N'S9_Real');
GO



