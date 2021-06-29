USE TareaProgramada;
GO

CREATE PROCEDURE dbo.InsertarCatalogos AS

	INSERT INTO Puesto

	SELECT 

		A.CatalogoXML.value('@Id','int') AS Id,
		A.CatalogoXML.value('@Nombre','varchar(40)') AS Nombre,
		A.CatalogoXML.value('@SalarioXHora','int') AS SalarioXHora,
		'1' AS Activo

	FROM
		(
		SELECT cast(CatalogoXML AS xml) FROM
		OPENROWSET(BULK 'C:\Datos_Tarea3.xml', Single_Blob) T(CatalogoXML)
		) AS S(CatalogoXML)

	CROSS APPLY CatalogoXML.nodes('Datos/Catalogos/Puestos/Puesto') AS A(CatalogoXML)

	INSERT INTO TipoDocuIdentidad

	SELECT 

		A.CatalogoXML.value('@Id','int') AS Id,
		A.CatalogoXML.value('@Nombre','varchar(40)') AS Nombre
	FROM
		(
		SELECT cast(CatalogoXML AS xml) FROM
		OPENROWSET(BULK 'C:\Datos_Tarea3.xml', Single_Blob) T(CatalogoXML)
		) AS S(CatalogoXML)

	CROSS APPLY CatalogoXML.nodes('Datos/Catalogos/Tipos_de_Documento_de_Identificacion/TipoIdDoc') as A(CatalogoXML)

	INSERT INTO Departamento

	SELECT 

		A.CatalogoXML.value('@Id','int') AS Id,
		A.CatalogoXML.value('@Nombre','varchar(40)') AS Nombre
	FROM
		(
		SELECT cast(CatalogoXML AS xml) FROM
		OPENROWSET(BULK 'C:\Datos_Tarea3.xml', Single_Blob) T(CatalogoXML)
		) AS S(CatalogoXML)

	CROSS APPLY CatalogoXML.nodes('Datos/Catalogos/Departamentos/Departamento') as A(CatalogoXML)

	INSERT INTO TiposDeJornada

	SELECT 

		A.CatalogoXML.value('@Id','int') AS Id,
		A.CatalogoXML.value('@Nombre','varchar(50)') AS Nombre,
		A.CatalogoXML.value('@HoraEntrada','time') AS HoraEntrada,
		A.CatalogoXML.value('@HoraSalida','time') AS HoraSalida
	FROM
		(
		SELECT cast(CatalogoXML AS xml) FROM
		OPENROWSET(BULK 'C:\Datos_Tarea3.xml', Single_Blob) T(CatalogoXML)
		) AS S(CatalogoXML)

	CROSS APPLY CatalogoXML.nodes('Datos/Catalogos/TiposDeJornada/TipoDeJornada') as A(CatalogoXML)

	INSERT INTO TipoMovimiento

	SELECT 

		A.CatalogoXML.value('@Id','int') AS Id,
		A.CatalogoXML.value('@Nombre','varchar(50)') AS Nombre
	FROM
		(
		SELECT cast(CatalogoXML AS xml) FROM
		OPENROWSET(BULK 'C:\Datos_Tarea3.xml', Single_Blob) T(CatalogoXML)
		) AS S(CatalogoXML)

	CROSS APPLY CatalogoXML.nodes('Datos/Catalogos/TiposDeMovimiento/TipoDeMovimiento') as A(CatalogoXML)

	INSERT INTO Feriados

	SELECT 

		A.CatalogoXML.value('@Fecha','date') AS Fecha,
		A.CatalogoXML.value('@Nombre','varchar(50)') AS Nombre
	FROM
		(
		SELECT cast(CatalogoXML AS xml) FROM
		OPENROWSET(BULK 'C:\Datos_Tarea3.xml', Single_Blob) T(CatalogoXML)
		) AS S(CatalogoXML)

	CROSS APPLY CatalogoXML.nodes('Datos/Catalogos/Feriados/Feriado') as A(CatalogoXML)

	INSERT INTO TipoDeduccion

	SELECT 

		A.CatalogoXML.value('@Id','int') AS Id,
		A.CatalogoXML.value('@Nombre','varchar(50)') AS Nombre,
		CASE A.CatalogoXML.value('@Obligatorio','varchar(10)')
		WHEN  'Si' THEN 1 ELSE 0 END AS Obligatorio,
		CASE A.CatalogoXML.value('@Porcentual' ,'varchar(10)')
		WHEN  'Si' THEN 1 ELSE 0 END AS Porcentual,
		A.CatalogoXML.value('@Valor','decimal(3,3)') AS Valor
	FROM
		(
		SELECT cast(CatalogoXML AS xml) FROM
		OPENROWSET(BULK 'C:\Datos_Tarea3.xml', Single_Blob) T(CatalogoXML)
		) AS S(CatalogoXML)

	CROSS APPLY CatalogoXML.nodes('Datos/Catalogos/Deducciones/TipoDeDeduccion') as A(CatalogoXML)

	INSERT INTO PorcentualSiObligatoria
	SELECT
		TD.Id, TD.Valor
	FROM
		TipoDeduccion TD WHERE TD.Obligatorio=1;

	CREATE TABLE #Temp(Id INT IDENTITY(1,1) PRIMARY KEY, IdDeduccion INT, Obligatorio INT)
	INSERT INTO #Temp SELECT TD.Id, TD.Obligatorio FROM TipoDeduccion TD;
	DECLARE @Cont INT, @LargoTabla INT, @Aux BIT;
	SELECT @Cont=1, @LargoTabla=COUNT(*) FROM #Temp
		WHILE(@Cont<=@LargoTabla)
		BEGIN
			SELECT @Aux=T.Obligatorio FROM #Temp T WHERE T.Id=@Cont;
			IF(@Aux=1)
			BEGIN
				INSERT INTO TipoMovimientoDeduccion VALUES('4', @Cont)
			END
			ELSE
			BEGIN
				INSERT INTO TipoMovimientoDeduccion VALUES('5', @Cont)
			END
			SET @Cont=@Cont+1;
		END
	DROP TABLE #Temp
GO

/*Create procedure insertarEmpleado as

Insert into Empleado

Select 

A.EmpleadoXML.value('@Nombre','varchar(30)') as Nombre,
A.EmpleadoXML.value('@idTipoDocumentacionIdentidad','int') as IdTipoIdentificacion,
A.EmpleadoXML.value('@ValorDocumentoIdentidad','int') as ValorDocumentoIdentifacion,
A.EmpleadoXML.value('@IdDepartamento','int') as IdDepartamento,
A.EmpleadoXML.value('@idPuesto','int') as IdPuesto,
A.EmpleadoXML.value('@FechaNacimiento','date') as FechaNacimiento,
'1' as Activo
From
(
Select cast(EmpleadosXML as xml) from
Openrowset(Bulk 'C:\Datos_Tarea3.xml', Single_Blob) T(EmpleadosXML)
) as S(EmpleadosXML)

Cross apply EmpleadosXML.nodes('Datos/Empleados/Empleado') as A(EmpleadoXML)

GO*/

CREATE PROCEDURE dbo.InsertarUsuario AS

	INSERT INTO Usuario

	SELECT 

		A.UsuarioXML.value('@username','varchar(30)') AS Username,
		A.UsuarioXML.value('@pwd','varchar(30)') AS Pwd,
		A.UsuarioXML.value('@tipo','int') AS Tipo

	FROM
		(
		SELECT cast(UsuariosXML AS xml) FROM
		OPENROWSET(BULK 'C:\Datos_Tarea3.xml', Single_Blob) T(UsuariosXML)
		) AS S(UsuariosXML)

	CROSS APPLY UsuariosXML.nodes('Datos/Usuarios/Usuario') as A(UsuarioXML)

GO

CREATE PROCEDURE dbo.InsertarTipoOperacion AS

	INSERT INTO TipoOperacion (Nombre)
	VALUES('Agregar Empleado'),
		  ('Eliminar Empleado'),
		  ('Asociar Deducción'),
		  ('Desasociar Deducción'),
		  ('Asociar Jornada'),
		  ('Procesar Asistencia')

GO

CREATE PROCEDURE dbo.InsertarBitacora AS

	INSERT INTO TipoBitacora (Nombre)
	VALUES('Inicio de corrida'),
		  ('Error en la corrida'),
		  ('Finalización de la corrida')

GO

EXECUTE InsertarCatalogos
--Execute insertarEmpleado
EXECUTE InsertarUsuario
EXECUTE InsertarTipoOperacion
EXECUTE InsertarBitacora