USE [S9_Real]
GO

--Tabelas que serão apagado as informações
TRUNCATE TABLE Log_V2

--Remove os espaços em branco S9_Real
DBCC SHRINKDATABASE(N'S9_Real' )
GO


