-- Script de Manutenção de Índices Inteligente v2.0
-- Baseado em boas práticas da Microsoft para SQL Server

USE [S9_Real]
GO

SET NOCOUNT ON;

DECLARE @TableName NVARCHAR(255);
DECLARE @IndexName NVARCHAR(255);
DECLARE @SchemaName NVARCHAR(255);
DECLARE @Fragmentation FLOAT;
DECLARE @Command NVARCHAR(MAX);

PRINT 'Iniciando manutenção inteligente de índices...';
PRINT '--------------------------------------------------';

-- Cursor para buscar índices fragmentados
DECLARE IndexCursor CURSOR FOR
SELECT 
    t.name AS TableName,
    i.name AS IndexName,
    s.name AS SchemaName,
    ps.avg_fragmentation_in_percent
FROM 
    sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ps
INNER JOIN 
    sys.indexes i ON ps.object_id = i.object_id AND ps.index_id = i.index_id
INNER JOIN 
    sys.tables t ON i.object_id = t.object_id
INNER JOIN 
    sys.schemas s ON t.schema_id = s.schema_id
WHERE 
    i.index_id > 0 -- Ignora heaps
    AND ps.page_count > 100 -- Ignora tabelas muito pequenas (opcional, mas recomendado)
    AND ps.avg_fragmentation_in_percent > 5 -- Apenas índices com alguma fragmentação
ORDER BY 
    ps.avg_fragmentation_in_percent DESC;

OPEN IndexCursor;

FETCH NEXT FROM IndexCursor INTO @TableName, @IndexName, @SchemaName, @Fragmentation;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @Command = '';

    IF @Fragmentation >= 30
    BEGIN
        -- Fragmentação alta: REBUILD
        SET @Command = 'ALTER INDEX [' + @IndexName + '] ON [' + @SchemaName + '].[' + @TableName + '] REBUILD WITH (ONLINE = ON, MAXDOP = 1);';

        -- Vou usar o comando padrão seguro para todas as edições:
        SET @Command = 'ALTER INDEX [' + @IndexName + '] ON [' + @SchemaName + '].[' + @TableName + '] REBUILD;';
        
        PRINT 'REBUILD: Tabela ' + @TableName + ' | Índice ' + @IndexName + ' | Fragmentação: ' + CAST(@Fragmentation AS NVARCHAR(20)) + '%';
    END
    ELSE IF @Fragmentation >= 5 AND @Fragmentation < 30
    BEGIN
        -- Fragmentação média: REORGANIZE
        SET @Command = 'ALTER INDEX [' + @IndexName + '] ON [' + @SchemaName + '].[' + @TableName + '] REORGANIZE;';
        PRINT 'REORGANIZE: Tabela ' + @TableName + ' | Índice ' + @IndexName + ' | Fragmentação: ' + CAST(@Fragmentation AS NVARCHAR(20)) + '%';
    END

    -- Executa o comando
    IF @Command <> ''
    BEGIN
        BEGIN TRY
            EXEC sp_executesql @Command;
        END TRY
        BEGIN CATCH
            PRINT 'Erro ao executar: ' + @Command;
            PRINT 'Mensagem: ' + ERROR_MESSAGE();
        END CATCH
    END

    FETCH NEXT FROM IndexCursor INTO @TableName, @IndexName, @SchemaName, @Fragmentation;
END

CLOSE IndexCursor;
DEALLOCATE IndexCursor;

PRINT '--------------------------------------------------';
PRINT 'Manutenção concluída com sucesso.';
GO