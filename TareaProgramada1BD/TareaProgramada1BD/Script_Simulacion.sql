USE TareaProgramada;
GO

--Inicio de la simulación, abriendo el documento con los datos e iniciando la variable FechaActual la
--cual será usada como cursos para ir iterando entre las fechas
DECLARE @doc XML
	SELECT @doc=BulkColumn
	FROM OPENROWSET(
				BULK 'C:\Datos_Tarea2.xml', SINGLE_CLOB
				) AS xmlData
DECLARE @FechaActual DATE, @CantDias INT, @OutResultCode INT, @IdSemanaActual INT;
SET @FechaActual=@doc.value('(/Datos/Operacion/@Fecha)[1]','date')
SET @CantDias=1;
SET NOCOUNT ON;
WHILE(@CantDias<=2) --92
BEGIN



	--Este IF revisa si se trata o no de un jueves-----------------------------------------------------
	IF(DATEPART(dw, @FechaActual)=4)
	BEGIN
		-----------------Crea nuevo mes en caso de iniciar el mes----------------------------------
		IF(DATEDIFF(day, DATEADD(d,1,EOMONTH(@FechaActual,-1)), @FechaActual)<=7)BEGIN
			EXECUTE InsertarMes @FechaActual, @OutResultCode OUTPUT
			SELECT @OutResultCode
		END;
		DECLARE @IdMes INT;
		SELECT @IdMes=PM.Id FROM PlanillaMensual PM
		WHERE DATEDIFF(day, PM.FechaInicio, @FechaActual)>=0
		AND DATEDIFF(day, PM.FechaFinal, @FechaActual)<0
		EXECUTE InsertarSemana @IdMes, @FechaActual, @IdSemanaActual OUTPUT, @OutResultCode OUTPUT
		SELECT @OutResultCode


		-----------------Segmento encargado de insertar empleados nuevos----------------------------------
		CREATE TABLE #TempEmpleados(Id INT IDENTITY(1,1) PRIMARY KEY, Nombre VARCHAR(50),
					    IdTipoIdentificacion INT,
						ValorDocumentoIdentificacion INT, 
						IdDepartamento INT, IdPuesto INT,
						FechaNacimiento DATE, Username VARCHAR(30),
						Pwd VARCHAR(30))
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
			@InEmpleadoPwd VARCHAR(30), @Cont INT, @LargoTabla INT;
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
			SELECT @OutResultCode;
			SET @Cont=@Cont+1;
		END
		DROP TABLE #TempEmpleados
		



		-----------------Segmento encargado de las jornadas----------------------------------
		CREATE TABLE #TempJornada(Id INT IDENTITY(1,1) PRIMARY KEY,
					    IdJornada INT,
						ValorDocumentoIdentificacion INT)
		INSERT INTO #TempJornada
		SELECT
			Jornada.value('@IdJornada','int') AS IdJornada,
			Jornada.value('@ValorDocumentoIdentidad','int') AS ValorDocumentoIdentificacion
		FROM 
			@doc.nodes('/Datos') AS A(Datos)
		CROSS APPLY A.Datos.nodes('./Operacion') AS B(Operacion)
		CROSS APPLY B.Operacion.nodes('./TipoDeJornadaProximaSemana') AS C(Jornada)
		WHERE Operacion.value('@Fecha', 'date')=@FechaActual
		DECLARE
			@InIdJornada INT,
			@InJornadaValorDocumentoIdentificacion INT;
		SELECT @Cont=1, @LargoTabla=COUNT(*) FROM #TempJornada
		WHILE(@Cont<=@LargoTabla)
		BEGIN
			SELECT 
				@InIdJornada=T.IdJornada,
				@InJornadaValorDocumentoIdentificacion=T.ValorDocumentoIdentificacion
			FROM #TempJornada T
			WHERE T.Id=@Cont;
			EXECUTE InsertarJornada @InIdJornada, @InJornadaValorDocumentoIdentificacion,
			@IdSemanaActual, @OutResultCode OUTPUT
			SELECT @OutResultCode;
			SET @Cont=@Cont+1;
		END
		DROP TABLE #TempJornada
	END



	--Este IF revisa si se trata o no de un viernes
	IF(DATEPART(dw, @FechaActual)=5)
	BEGIN
		--EXECUTE InsertarMes @FechaActual, @OutResultCode OUTPUT
		SELECT @OutResultCode
	END






	--Se incrementa el día para continuar leyendo el XML
	SET @FechaActual=DATEADD(DAY,1,@FechaActual)
	SET @CantDias=@CantDias+1;
END;
SET NOCOUNT OFF;