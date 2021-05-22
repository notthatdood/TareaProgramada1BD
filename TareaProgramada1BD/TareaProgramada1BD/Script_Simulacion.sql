USE TareaProgramada;
GO

--Inicio de la simulación, abriendo el documento con los datos e iniciando la variable FechaActual la
--cual será usada como cursos para ir iterando entre las fechas
DECLARE @doc XML
	SELECT @doc=BulkColumn
	FROM OPENROWSET(
				BULK 'C:\Datos_Tarea2.xml', SINGLE_CLOB
				) AS xmlData
DECLARE @FechaActual DATE, @Nombre VARCHAR(50);
SET @FechaActual=@doc.value('(/Datos/Operacion/@Fecha)[1]','date')
--WHILE(1=1) BEGIN

--Segmento encargado de insertar empleados nuevos
		CREATE TABLE #TempEmpleados(Id INT IDENTITY(1,1) PRIMARY KEY, Nombre VARCHAR(50),
					    IdTipoIdentificacion INT,
						ValorDocumentoIdentificacion INT, 
						IdDepartamento INT, IdPuesto INT,
						FechaNacimiento DATE, Username VARCHAR(30),
						Pwd VARCHAR(30))
		SET NOCOUNT ON;
		INSERT INTO #TempEmpleados
		SELECT
			NuevoEmpleado.value('@Nombre','varchar(50)') AS Nombre,
			NuevoEmpleado.value('@idTipoDocumentacionIdentidad','int') AS IdTipoIdentificacion,
			NuevoEmpleado.value('@ValorDocumentoIdentidad','int') AS ValorDocumentoIdentificacion,
			NuevoEmpleado.value('@idDepartamento','int') AS IdDepartamento,
			NuevoEmpleado.value('@idPuesto','int') AS IdPuesto,
			NuevoEmpleado.value('@FechaNacimiento','date') AS FechaNacimiento,
			NuevoEmpleado.value('@Username','varchar(30)') AS Username,
			NuevoEmpleado.value('@Password','varchar(30)') AS Pwd
		FROM 
			@doc.nodes('/Datos') AS A(Datos)
		CROSS APPLY A.Datos.nodes('./Operacion') AS B(Operacion)
		CROSS APPLY B.Operacion.nodes('./NuevoEmpleado') AS C(NuevoEmpleado)
		WHERE Operacion.value('@Fecha', 'date')=@FechaActual
		DECLARE
			@InEmpleadoNombre VARCHAR(50), @InEmpleadoIdTipoIdentificacion INT,
			@InEmpleadoValorDocumentoIdentificacion INT, @InEmpleadoFechaNacimiento DATE,
			@InEmpleadoIdPuesto INT, @InEmpleadoIdDepartamento INT, @InEmpleadoUsername VARCHAR(30),
			@InEmpleadoPwd VARCHAR(30), @OutResultCode INT, @Cont INT, @LargoTabla INT;
		SELECT @Cont=1, @LargoTabla=COUNT(*) FROM #TempEmpleados
		WHILE(@Cont<=@LargoTabla)
		BEGIN
			SELECT 
				@InEmpleadoNombre=T.Nombre,
				@InEmpleadoIdTipoIdentificacion=T.IdTipoIdentificacion,
				@InEmpleadoValorDocumentoIdentificacion=T.ValorDocumentoIdentificacion,
				@InEmpleadoFechaNacimiento=T.FechaNacimiento,
				@InEmpleadoIdPuesto=T.IdPuesto,
				@InEmpleadoIdDepartamento=T.IdDepartamento,
				@InEmpleadoUsername=T.Username,
				@InEmpleadoPwd=T.Pwd
			FROM #TempEmpleados T
			WHERE T.Id=@Cont;
			EXECUTE InsertarEmpleados @InEmpleadoNombre, @InEmpleadoIdTipoIdentificacion,
				@InEmpleadoValorDocumentoIdentificacion, @InEmpleadoFechaNacimiento, @InEmpleadoIdPuesto,
				@InEmpleadoIdDepartamento, @InEmpleadoUsername, @InEmpleadoPwd, @OutResultCode OUTPUT
			--SELECT @OutResultCode;
			SET @Cont=@Cont+1;
		END
		DROP TABLE #TempEmpleados
		SET NOCOUNT OFF;



	--Se incrementa el día para continuar leyendo el XML
	SET @FechaActual=DATEADD(DAY,1,@FechaActual)
END;