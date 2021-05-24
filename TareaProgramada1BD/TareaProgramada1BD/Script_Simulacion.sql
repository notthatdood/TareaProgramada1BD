USE TareaProgramada;
GO

--Inicio de la simulación, abriendo el documento con los datos e iniciando la variable FechaActual la
--cual será usada como cursos para ir iterando entre las fechas
DECLARE @doc XML
	SELECT @doc=BulkColumn
	FROM OPENROWSET(
				BULK 'C:\Datos_Tarea2.xml', SINGLE_CLOB
				) AS xmlData
DECLARE @FechaActual DATE, @CantDias INT, @OutResultCode INT, @IdSemanaActual INT, @IdMesActual INT;
SET @FechaActual=@doc.value('(/Datos/Operacion/@Fecha)[1]','date')
SET @CantDias=1;
SET @IdMesActual=0;
SET NOCOUNT ON;
WHILE(@CantDias<=92) --92
BEGIN

	
	--Este IF revisa si se trata o no de un viernes
	IF(DATEPART(dw, @FechaActual)=5)
	BEGIN
		---------------------Este segmento crea las PlanillaXEmpleado y genera los movimientos---------------
		IF(DATEDIFF(day, DATEADD(d,1,EOMONTH(@FechaActual,-1)), @FechaActual)<=7)
		BEGIN
			EXECUTE InsertarMesXEmpleado @IdMesActual, @OutResultCode OUTPUT
			--SELECT @OutResultCode
		END;
		EXECUTE InsertarSemanaXEmpleado @IdSemanaActual, @OutResultCode OUTPUT
	END


	-----------------Segmento encargado de marcar la asistencia----------------------------------
	CREATE TABLE #TempAsistencia(Id INT IDENTITY(1,1) PRIMARY KEY,
				    FechaEntrada DATETIME,
					FechaSalida DATETIME,
					ValorDocumentoIdentidad INT)
	INSERT INTO #TempAsistencia
	SELECT
		Marca.value('@FechaEntrada','datetime') AS FechaEntrada,
		Marca.value('@FechaSalida','datetime') AS FechaSalida,
		Marca.value('@ValorDocumentoIdentidad','int') AS ValorDocumentoIdentidad
	FROM 
		@doc.nodes('/Datos') AS A(Datos)
	CROSS APPLY A.Datos.nodes('./Operacion') AS B(Operacion)
	CROSS APPLY B.Operacion.nodes('./MarcaDeAsistencia ') AS C(Marca)
	WHERE Operacion.value('@Fecha', 'date')=@FechaActual
	DECLARE
		@Cont INT, @LargoTabla INT,
		@InFechaEntrada DATETIME, @InFechaSalida DATETIME,
		@InMarcaValorDocumentoIdentificacion INT, @IdMarcaAsistencia INT, @Auxiliar INT;
	SELECT @Cont=1, @LargoTabla=COUNT(*) FROM #TempAsistencia
	WHILE(@Cont<=@LargoTabla)
	BEGIN
		SELECT 
			@InFechaEntrada=T.FechaEntrada, @InFechaSalida=T.FechaSalida,
			@InMarcaValorDocumentoIdentificacion=T.ValorDocumentoIdentidad
		FROM #TempAsistencia T
		WHERE T.Id=@Cont;
		--SELECT @InFechaEntrada, @InFechaSalida;
		EXECUTE MarcarAsistencia @InFechaEntrada, @InFechaSalida,
		@InMarcaValorDocumentoIdentificacion, @IdMarcaAsistencia OUTPUT, @OutResultCode OUTPUT
		--SELECT @OutResultCode;
		EXECUTE CrearMovimientoCreditoDia @FechaActual, @IdSemanaActual, @InFechaEntrada, @InFechaSalida,
		@InMarcaValorDocumentoIdentificacion, @IdMarcaAsistencia, @Auxiliar OUTPUT, @OutResultCode OUTPUT;
		--SELECT @OutResultCode;
		--SELECT @FechaActual, @IdSemanaActual, @InFechaEntrada, @InFechaSalida,
		--@InMarcaValorDocumentoIdentificacion, @IdMarcaAsistencia
		--SELECT AAA=@Auxiliar;
		SET @Cont=@Cont+1;
	END
	DROP TABLE #TempAsistencia
	


	-----------------Segmento encargado de eliminar empleados----------------------------------
	CREATE TABLE #TempEliminar(Id INT IDENTITY(1,1) PRIMARY KEY,
				    ValorDocumentoIdentidad INT)
	INSERT INTO #TempEliminar
	SELECT
		Eliminar.value('@ValorDocumentoIdentidad','int') AS ValorDocumentoIdentidad
	FROM 
		@doc.nodes('/Datos') AS A(Datos)
	CROSS APPLY A.Datos.nodes('./Operacion') AS B(Operacion)
	CROSS APPLY B.Operacion.nodes('./EliminarEmpleado  ') AS C(Eliminar)
	WHERE Operacion.value('@Fecha', 'date')=@FechaActual
	DECLARE
		@InEliminarValorDocumentoIdentificacion INT;
	SELECT @Cont=1, @LargoTabla=COUNT(*) FROM #TempEliminar
	WHILE(@Cont<=@LargoTabla)
	BEGIN
		SELECT 
			@InEliminarValorDocumentoIdentificacion=T.ValorDocumentoIdentidad
		FROM #TempEliminar T
		WHERE T.Id=@Cont;
		EXECUTE EliminarEmpleados @InEliminarValorDocumentoIdentificacion, @OutResultCode OUTPUT
		--SELECT @OutResultCode;
		SET @Cont=@Cont+1;
	END
	DROP TABLE #TempEliminar



	--Este IF revisa si se trata o no de un jueves-----------------------------------------------------
	IF(DATEPART(dw, @FechaActual)=4)
	BEGIN
		---------------------Este segmento crea los movimientos deduccion------------------------------
		IF(@IdMesActual>0)
		BEGIN
			--------Este segmento analiza los datos del mes si ha finalizado---------------------------
			IF(DATEDIFF(day, DATEADD(d,1,EOMONTH(@FechaActual,-1)), @FechaActual)<=7)
			BEGIN
				--EXECUTE InsertarMesXEmpleado @IdMesActual, @OutResultCode OUTPUT
				SELECT @OutResultCode
			END;
			DECLARE @IdSemanaXEmpleadoTemp INT, @IdSemanaXEmpleadoIndice INT;
			SELECT TOP 1 @IdSemanaXEmpleadoTemp=PSX.Id
			FROM PlanillaSemanalXEmpleado PSX WHERE PSX.IdSemana=@IdSemanaActual ORDER BY PSX.Id DESC;
			SELECT TOP 1 @IdSemanaXEmpleadoIndice=PSX.Id
			FROM PlanillaSemanalXEmpleado PSX WHERE PSX.IdSemana=@IdSemanaActual ORDER BY PSX.Id ASC;
			WHILE(@IdSemanaXEmpleadoIndice<=@IdSemanaXEmpleadoTemp)
			BEGIN
				/*DECLARE @IdDeduccionXEmpleadoTemp INT, @IdDeduccionXEmpleadoIndice INT;
				SELECT TOP 1 @IdDeduccionXEmpleadoTemp=DXE.Id
				FROM DeduccionXEmpleado DXE, PlanillaSemanalXEmpleado PSX
				WHERE DXE.IdEmpleado=PSX.IdEmpleado AND PSX.Id=@IdSemanaXEmpleadoIndice
				ORDER BY DXE.Id DESC;

				SELECT TOP 1 @IdDeduccionXEmpleadoIndice=DXE.Id
				FROM DeduccionXEmpleado DXE, PlanillaSemanalXEmpleado PSX
				WHERE DXE.IdEmpleado=PSX.IdEmpleado AND PSX.Id=@IdSemanaXEmpleadoIndice
				ORDER BY DXE.Id ASC;*/
				CREATE TABLE #TempDXE(Id INT IDENTITY(1,1) PRIMARY KEY,
						IdDXE INT,
						IdEmpleado INT,
						IdTipoDeduccion INT,)
				INSERT INTO #TempDXE SELECT DXE.Id, DXE.IdEmpleado, DXE.IdTipoDeduccion
				FROM DeduccionXEmpleado DXE, PlanillaSemanalXEmpleado PSX
				WHERE DXE.IdEmpleado=PSX.IdEmpleado AND PSX.Id=@IdSemanaXEmpleadoIndice;
				SELECT @Cont=1, @LargoTabla=COUNT(*) FROM #TempDXE
				WHILE(@Cont<=@LargoTabla)
				BEGIN
					DECLARE @IdDeduccionXEmpleadoIndice INT;
					SELECT @IdDeduccionXEmpleadoIndice=T.IdDXE FROM #TempDXE T WHERE T.Id=@Cont;
					EXECUTE CrearMovimientoDebito @FechaActual, @IdSemanaXEmpleadoIndice,
					@IdDeduccionXEmpleadoIndice, @OutResultCode OUTPUT
					SET @Cont=@Cont+1;
					--SELECT AAA=@IdDeduccionXEmpleadoIndice, BBB=@IdDeduccionXEmpleadoTemp;
				END
				DROP TABLE #TempDXE
				SET @IdSemanaXEmpleadoIndice=@IdSemanaXEmpleadoIndice+1;
			END
		END


----------------------------Crea nuevo mes en caso de iniciar el mes----------------------------------
		IF(DATEDIFF(day, DATEADD(d,1,EOMONTH(@FechaActual,-1)), @FechaActual)<=7)
		BEGIN
			EXECUTE InsertarMes @FechaActual, @IdMesActual OUTPUT, @OutResultCode OUTPUT
			--SELECT @OutResultCode
		END;
		EXECUTE InsertarSemana @IdMesActual, @FechaActual, @IdSemanaActual OUTPUT, @OutResultCode OUTPUT
		--SELECT @IdSemanaActual


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
			@InEmpleadoPwd VARCHAR(30);
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
			--SELECT @OutResultCode;
			SET @Cont=@Cont+1;
		END
		DROP TABLE #TempJornada
	END



	

	-----------------Segmento encargado de asociar empleados a deducciones----------------------------------
	CREATE TABLE #TempAsocia(Id INT IDENTITY(1,1) PRIMARY KEY,
				    IdDeduccion INT,
					Monto INT,
					ValorDocumentoIdentidad INT)
	INSERT INTO #TempAsocia
	SELECT
		Asocia.value('@IdDeduccion','int') AS IdDeduccion,
		CASE WHEN
			TRY_CAST(Asocia.value('@Monto','decimal(10,5)') AS INT) IS NULL THEN 0
			ELSE CAST(Asocia.value('@Monto','decimal(10,5)') AS INT)
		END
		AS Monto,
		Asocia.value('@ValorDocumentoIdentidad','int') AS ValorDocumentoIdentidad
	FROM 
		@doc.nodes('/Datos') AS A(Datos)
	CROSS APPLY A.Datos.nodes('./Operacion') AS B(Operacion)
	CROSS APPLY B.Operacion.nodes('./AsociaEmpleadoConDeduccion  ') AS C(Asocia)
	WHERE Operacion.value('@Fecha', 'date')=@FechaActual
	--SELECT @FechaActual;
	--SELECT * FROM #TempAsocia;
	DECLARE
		@InAsociaIdDeduccion INT, @InAsociaMonto INT,
		@InAsociaValorDocumentoIdentificacion INT;
	SELECT @Cont=1, @LargoTabla=COUNT(*) FROM #TempAsocia
	WHILE(@Cont<=@LargoTabla)
	BEGIN
		SELECT 
			@InAsociaIdDeduccion=T.IdDeduccion, @InAsociaMonto=T.Monto,
			@InAsociaValorDocumentoIdentificacion=T.ValorDocumentoIdentidad
		FROM #TempAsocia T
		WHERE T.Id=@Cont;
		IF(@InAsociaMonto=0)
		BEGIN
			EXECUTE AsociarEmpleadoConPorcentualNoObligatoria @InAsociaIdDeduccion,
			@InAsociaValorDocumentoIdentificacion, @OutResultCode OUTPUT
			--SELECT @OutResultCode;
			SET @InAsociaMonto=@InAsociaMonto;
		END
		ELSE IF(@InAsociaMonto>0)
		BEGIN
			EXECUTE AsociarEmpleadoConFijaNoObligatoria @InAsociaIdDeduccion, @InAsociaMonto,
			@InAsociaValorDocumentoIdentificacion, @OutResultCode OUTPUT
			--SELECT @OutResultCode;
		END
		SET @Cont=@Cont+1;
	END
	DROP TABLE #TempAsocia



	-----------------Segmento encargado de deasociar empleados con deducciones----------------------------------
	CREATE TABLE #TempDeasocia(Id INT IDENTITY(1,1) PRIMARY KEY,
				    IdDeduccion INT,
					ValorDocumentoIdentidad INT)
	INSERT INTO #TempDeasocia
	SELECT
		Deasocia.value('@IdDeduccion','int') AS IdDeduccion,
		Deasocia.value('@ValorDocumentoIdentidad','int') AS ValorDocumentoIdentidad
	FROM 
		@doc.nodes('/Datos') AS A(Datos)
	CROSS APPLY A.Datos.nodes('./Operacion') AS B(Operacion)
	CROSS APPLY B.Operacion.nodes('./DesasociaEmpleadoConDeduccion  ') AS C(Deasocia)
	WHERE Operacion.value('@Fecha', 'date')=@FechaActual
	DECLARE
		@InDesIdDeduccion int, @InDesValorDocumentoIdentificacion INT;
	SELECT @Cont=1, @LargoTabla=COUNT(*) FROM #TempDeasocia
	WHILE(@Cont<=@LargoTabla)
	BEGIN
		SELECT 
			@InDesIdDeduccion=T.IdDeduccion,
			@InDesValorDocumentoIdentificacion=T.ValorDocumentoIdentidad
		FROM #TempDeasocia T
		WHERE T.Id=@Cont;
		EXECUTE DesasociarEmpleadoConDeduccion @InDesIdDeduccion,
		@InDesValorDocumentoIdentificacion, @OutResultCode OUTPUT
		--SELECT @OutResultCode;
		SET @Cont=@Cont+1;
	END
	DROP TABLE #TempDeasocia


	--Se incrementa el día para continuar leyendo el XML
	SET @FechaActual=DATEADD(DAY,1,@FechaActual)
	SET @CantDias=@CantDias+1;
END;
SET NOCOUNT OFF;