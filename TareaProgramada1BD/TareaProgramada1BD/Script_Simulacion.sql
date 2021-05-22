/*SELECT

A.CatalogoXML.value('@Fecha','date') as Fecha
FROM
(
SELECT CAST(CatalogoXML AS XML) FROM
OPENROWSET(BULK 'C:\Datos_Tarea2.xml', SINGLE_BLOB) T(CatalogoXML)
) as S(CatalogoXML)

CROSS APPLY CatalogoXML.nodes('Datos/Operacion') AS A(CatalogoXML)*/

DECLARE @doc XML
	SELECT @doc=BulkColumn
	FROM OPENROWSET(
				BULK 'C:\Datos_Tarea2.xml', SINGLE_CLOB
				) AS xmlData
DECLARE @FechaA DATE
SET @FechaA=@doc.value('(/Datos/Operacion/@Fecha)[1]','date')
--SET @FechaA=DATEADD(DAY,7,@FechaA)
--Print(@FechaA)
SELECT * FROM(
	SELECT  
		---Operacion.value('@Fecha', 'date') AS Fecha,
		NuevoEmpleado.value('@FechaNacimiento', 'date') AS FechaNacimiento
	FROM 
		@doc.nodes('/Datos') AS A(Datos)
	CROSS APPLY A.Datos.nodes('./Operacion') AS B(Operacion)
	CROSS APPLY B.Operacion.nodes('./NuevoEmpleado') AS C(NuevoEmpleado)
	WHERE Operacion.value('@Fecha', 'date')=@FechaA
) AS Result --WHERE Fecha='2021-02-04'
