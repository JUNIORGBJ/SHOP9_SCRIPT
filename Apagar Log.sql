USE [S9_Real]
GO

--Tabelas que serão apagado as informações
DELETE FROM [dbo].[Log_V2]
      WHERE Data_Sistema Between '2000-01-01' and '2021-06-18'; --Padrão da Data: Ano-mês-dia

--Remove os espaços em branco S9_Real
DBCC SHRINKDATABASE(N'S9_Real' )
GO


