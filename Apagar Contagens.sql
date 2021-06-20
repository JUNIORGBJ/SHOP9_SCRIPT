USE [S9_Real]
GO

--Tabelas que serão apagado as informações
DELETE FROM [dbo].[Contagem_Estoque]
DELETE FROM [dbo].[Contagem_Estoque_Itens]
DELETE FROM [dbo].[Contagem_Estoque_Itens_Lotes]
DELETE FROM [dbo].[Contagem_Estoque_Itens_Series]
DELETE FROM [dbo].[Contagem_Estoque_Itens_Series_Excluidas]
DELETE FROM [dbo].[Contagem_Estoque_Movimentos_Gerados]

--Remove os espaços em branco S9_Real
DBCC SHRINKDATABASE(N'S9_Real' )
GO


