USE TareaProgramada;
GO

--Inicio de la simulación, abriendo el documento con los datos e iniciando la variable FechaActual la
--cual será usada como cursos para ir iterando entre las fechas
DECLARE @doc XML
	SELECT @doc=BulkColumn
	FROM OPENROWSET(
				BULK 'C:\Datos_Tarea3.xml', SINGLE_CLOB
				) AS xmlData
DECLARE @FechaActual DATE
	, @CantDias INT
	, @OutResultCode INT
	, @IdSemanaActual INT
	, @IdMesActual INT
	, @Cont INT
	, @LargoTabla INT
	, @SecItera INT
	, @SecFinal INT
	, @InFechaEntrada DATETIME
	, @InFechaSalida DATETIME
	, @InMarcaValorDocumentoIdentificacion INT
	, @IdMarcaAsistencia INT
	, @Auxiliar INT
	, @InEliminarValorDocumentoIdentificacion INT
	, @IdSemanaXEmpleadoTemp INT
	, @IdSemanaXEmpleadoIndice INT
	, @IdDeduccionXEmpleadoIndice INT
	, @InEmpleadoNombre VARCHAR(50)
	, @InEmpleadoIdTipoIdentificacion INT
	, @InEmpleadoValorDocumentoIdentificacion INT
	, @InEmpleadoFechaNacimiento DATE
	, @InEmpleadoIdPuesto INT
	, @InEmpleadoIdDepartamento INT
	, @InEmpleadoUsername VARCHAR(30)
	, @InEmpleadoPwd VARCHAR(30)
	, @InIdJornada INT
	, @InJornadaValorDocumentoIdentificacion INT
	, @InAsociaIdDeduccion INT
	, @InAsociaMonto INT
	, @InAsociaValorDocumentoIdentificacion INT
	, @InDesIdDeduccion INT
	, @InDesValorDocumentoIdentificacion INT
	,@EsFeriado BIT
	,@IdSXECont INT

	,@FechaItera INT
	,@FechaFinal INT
	---Variables para crédito día
	,@IdSemanaXEmpleado INT
	,@Monto INT
	,@HorasLaboradas INT
	,@HorasEsperadas INT
	,@IdMovimiento INT
	,@IdE INT
	,@IdMes INT
	---Variables par insertar mes
	,@InFechaFinal DATE
	,@InFechaTemporal DATE
	,@Bandera BIT
	,@Terminar INT
	,@IdUltimaCorrida INT
	,@IdUltimoDetalleCorrida INT
	,@ProduceError INT;

	--SELECT @FechaItera=Min(FechaOperacion), @FechaFinal=max(FechaOperacion) FROM @doc.nodes('/FechaOperacion');
	SELECT
		@FechaFinal= COUNT(Operacion.value('@Fecha','datetime'))
	FROM 
		@doc.nodes('/Datos') AS A(Datos)
	CROSS APPLY A.Datos.nodes('./Operacion') AS B(Operacion)
	--Select @FechaFinal

		--SELECT @FechaItera=@doc.value('(/Datos/Operacion/@Fecha)[1]','date')
		--SELECT @FechaItera
SET @FechaActual=@doc.value('(/Datos/Operacion/@Fecha)[1]','date')
SET @CantDias=1;
SET @IdMesActual=0;
SET @IdUltimoDetalleCorrida=1;
SET NOCOUNT ON;
WHILE(@CantDias<@FechaFinal)
BEGIN
	IF(DATEPART(dw, @FechaActual)=4)--KEYLOR
	BEGIN----------------Crea nuevo mes en caso de iniciar el mes----------------------------------
		IF(DATEDIFF(day, DATEADD(d,1,EOMONTH(@FechaActual,-1)), @FechaActual)<=7)
		BEGIN
			--SET @FechaActual=DATEADD(DAY,1,@FechaActual);
			SELECT
				@InFechaFinal=DATEADD(DAY,8,@FechaActual), 
				@InFechaTemporal=EOMONTH(@InFechaFinal),
				@Bandera='0';
			WHILE(@Bandera='0') BEGIN
			--PRINT(@FechaFinal)
				IF(@InFechaFinal>@InFechaTemporal) BEGIN
					SELECT
						@InFechaFinal=DATEADD(DAY,-1,@InFechaFinal),
						@Bandera='1';
				END
				IF(@Bandera='0') BEGIN
					SELECT
						@InFechaFinal=DATEADD(DAY,7,@InFechaFinal);
				END
			END
			EXECUTE InsertarMes @FechaActual,---AKASA
								@InFechaFinal,
								@IdMesActual OUTPUT,
								@OutResultCode OUTPUT
			--SELECT @OutResultCode
		END;
		EXECUTE InsertarSemana @IdMesActual, @FechaActual, @IdSemanaActual OUTPUT, @OutResultCode OUTPUT
	END;
	SET @FechaActual=DATEADD(DAY,1,@FechaActual)
	SET @CantDias=@CantDias+1;
END

SET @FechaActual=@doc.value('(/Datos/Operacion/@Fecha)[1]','date')
SET @CantDias=1;
SET @IdMesActual=0;
SET @IdSemanaActual=0;
WHILE(@CantDias<=@FechaFinal) --92
BEGIN
	--Busca si el día es feriado/domingo
	IF EXISTS(SELECT F.Fecha FROM Feriados F WHERE @FechaActual=F.Fecha)
	BEGIN
		SET @EsFeriado=1;
	END
	--ELSE IF(DATEPART(dw, @InFechaActual)=1)--ANDRES
	ELSE IF(DATEPART(dw, @FechaActual)=7)--KEYLOR
	BEGIN
		SET @EsFeriado=1;
	END
	ELSE
	BEGIN
		SET @EsFeriado=0;
	END
	---------Se inserta en corrida--------------
	INSERT INTO Corrida (FechaOperacion,
						 TipoRegistro,
						 PostTime)
	VALUES(@FechaActual,
		   1,
		   GETDATE())
	SET @IdUltimaCorrida=SCOPE_IDENTITY();


		--Este IF revisa si se trata o no de un jueves-----------------------------------------------------
	--IF(DATEPART(dw, @FechaActual)=5)--ANDRES
	IF(DATEPART(dw, @FechaActual)=4)--KEYLOR
	BEGIN
		---------------------Este segmento crea los movimientos deduccion------------------------------
		IF(@IdMesActual>0)
		BEGIN
			--------Este segmento analiza los datos del mes si ha finalizado---------------------------
			/*IF(DATEDIFF(day, DATEADD(d,1,EOMONTH(@FechaActual,-1)), @FechaActual)<=7)
			BEGIN
				--EXECUTE InsertarMesXEmpleado @IdMesActual, @OutResultCode OUTPUT
				SELECT @OutResultCode
			END;*/
			CREATE TABLE #TempSXE(Id INT IDENTITY(1,1) PRIMARY KEY,
							  IdSemanaXEmpleado INT)
			INSERT INTO #TempSXE(IdSemanaXEmpleado)
			SELECT
				PSX.Id AS IdSemanaXEmpleado
			FROM
				dbo.PlanillaSemanalXEmpleado PSX
			WHERE
				PSX.IdSemana=@IdSemanaActual

			SELECT
				@IdSXECont=1,
				@IdSemanaXEmpleadoTemp=Count(#TempSXE.IdSemanaXEmpleado)
			FROM
				#TempSXE;

			WHILE(@IdSXECont<=@IdSemanaXEmpleadoTemp)
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
				INSERT INTO #TempDXE(IdDXE,
									 IdEmpleado,
									 IdTipoDeduccion)
				SELECT
					DXE.Id,
					DXE.IdEmpleado,
					DXE.IdTipoDeduccion
				FROM
					DeduccionXEmpleado DXE,
					PlanillaSemanalXEmpleado PSX
				WHERE
					DXE.IdEmpleado=PSX.IdEmpleado AND
					PSX.Id=@IdSemanaXEmpleadoIndice AND
					DXE.Activo='1';
				SELECT
					@Cont=1,
					@LargoTabla=COUNT(*)
				FROM
					#TempDXE

				SELECT
					@IdSemanaXEmpleadoIndice=TSXE.IdSemanaXEmpleado
				FROM
					#TempSXE TSXE
				WHERE
					TSXE.Id=@IdSXECont;

				WHILE(@Cont<=@LargoTabla)
				BEGIN
					SELECT
						@IdDeduccionXEmpleadoIndice=T.IdDXE
					FROM
						#TempDXE T
					WHERE
						T.Id=@Cont;
					EXECUTE CrearMovimientoDebito @FechaActual,
												  @IdSemanaXEmpleadoIndice,
												  @IdDeduccionXEmpleadoIndice,
												  @OutResultCode OUTPUT
					Print('Debito')
					SET @Cont=@Cont+1;
					--SELECT AAA=@IdDeduccionXEmpleadoIndice, BBB=@IdDeduccionXEmpleadoTemp;
				END
				DROP TABLE #TempDXE
				SET @IdSXECont=@IdSXECont+1;
			END
			DROP TABLE #TempSXE;
		END
		IF(@IdMesActual=0)
		BEGIN
			SET @IdMesActual=1;
		END

----------------------------Crea nuevo mes en caso de iniciar el mes----------------------------------
		IF(DATEDIFF(day, DATEADD(d,1,EOMONTH(@FechaActual,-1)), @FechaActual)<=7)
		BEGIN
			SET @IdMesActual=@IdMesActual+1;
			--SELECT @OutResultCode
		END;
		SET @IdSemanaActual=@IdSemanaActual+1;
		--SELECT @IdSemanaActual


		-----------------Segmento encargado de insertar empleados nuevos----------------------------------
		CREATE TABLE #TempEmpleados(Id INT IDENTITY(1,1) PRIMARY KEY,
						Nombre VARCHAR(50),
					    IdTipoIdentificacion INT,
						ValorDocumentoIdentificacion INT, 
						IdDepartamento INT,
						IdPuesto INT,
						FechaNacimiento DATE,
						Username VARCHAR(30),
						Pwd VARCHAR(30),
						Secuencia INT,
						ProduceError INT)
		INSERT INTO #TempEmpleados(Nombre,
								   IdTipoIdentificacion,
								   ValorDocumentoIdentificacion,
								   IdDepartamento,
								   IdPuesto,
								   FechaNacimiento,
								   Username,
								   Pwd,
								   Secuencia,
								   ProduceError)
		SELECT
			NuevoEmpleado.value('@Nombre','varchar(50)') AS Nombre,
			NuevoEmpleado.value('@idTipoDocumentacionIdentidad','int') AS IdTipoIdentificacion,
			NuevoEmpleado.value('@ValorDocumentoIdentidad','int') AS ValorDocumentoIdentificacion,
			NuevoEmpleado.value('@idDepartamento','int') AS IdDepartamento,
			NuevoEmpleado.value('@idPuesto','int') AS IdPuesto,
			NuevoEmpleado.value('@FechaNacimiento','date') AS FechaNacimiento,
			NuevoEmpleado.value('@Username','varchar(30)') AS Username,
			NuevoEmpleado.value('@Password','varchar(30)') AS Pwd,
			NuevoEmpleado.value('@Secuencia','int') AS Secuencia,
			NuevoEmpleado.value('@ProduceError','int') AS ProduceError
		FROM 
			@doc.nodes('/Datos') AS A(Datos)
		CROSS APPLY A.Datos.nodes('./Operacion') AS B(Operacion)
		CROSS APPLY B.Operacion.nodes('./NuevoEmpleado') AS C(NuevoEmpleado)
		WHERE
			Operacion.value('@Fecha', 'date')=@FechaActual
		SELECT
			@SecItera=1,
			@SecFinal=COUNT(*),
			@Terminar=0
		FROM
			#TempEmpleados


		WHILE(@Terminar=0)
		BEGIN
			SELECT
				@SecItera=(DC.RefID)+1
			FROM
				DetalleCorrida DC,
				Corrida C
			WHERE
				@IdUltimaCorrida=DC.IdCorrida AND
				DC.Id=@IdUltimoDetalleCorrida AND
				DC.TipoOperacionXML=1;


			INSERT INTO Bitacora (IdTipoOperacion,
								  Texto,
								  Fecha)
			VALUES(1,
				   'Nueva iteracion procesando nuevos empleados inciando en '+convert(varchar, @SecItera),
				   @FechaActual)
			BEGIN TRY
				WHILE(@SecItera<=@SecFinal)
				BEGIN
				--PRINT('SecItera '+convert(varchar, @SecItera)+' SecFinal '+convert(varchar, @SecFinal));
					SELECT 
						@InEmpleadoNombre=T.Nombre,
						@InEmpleadoIdTipoIdentificacion=T.IdTipoIdentificacion,
						@InEmpleadoValorDocumentoIdentificacion=T.ValorDocumentoIdentificacion,
						@InEmpleadoFechaNacimiento=T.FechaNacimiento,
						@InEmpleadoIdPuesto=T.IdPuesto,
						@InEmpleadoIdDepartamento=T.IdDepartamento,
						@InEmpleadoUsername=T.Username,
						@InEmpleadoPwd=T.Pwd,
						@ProduceError=T.ProduceError
					FROM
						#TempEmpleados T
					WHERE
						T.Id=@SecItera;
					EXECUTE InsertarEmpleados @InEmpleadoNombre,
											  @InEmpleadoIdTipoIdentificacion,
											  @InEmpleadoValorDocumentoIdentificacion,
											  @InEmpleadoFechaNacimiento,
											  @InEmpleadoIdPuesto,
											  @InEmpleadoIdDepartamento,
											  @InEmpleadoUsername,
											  @InEmpleadoPwd,
											  @OutResultCode OUTPUT
					--SELECT @OutResultCode;
					IF(@ProduceError=1)
					BEGIN
						PRINT('ERROR------------------------------------------------------------')
						SELECT @ProduceError/0;
					END
					---------Se inserta en detalle corrida--------------
					INSERT INTO DetalleCorrida (IdCorrida,
												TipoOperacionXML,
												RefID)
					VALUES(@IdUltimaCorrida,
						   1,
						   @SecItera)
					SET @IdUltimODetalleCorrida=SCOPE_IDENTITY();
					SET @SecItera=@SecItera+1;
				END
				SET @Terminar=1;
				INSERT INTO Bitacora (IdTipoOperacion,
									  Texto,
									  Fecha)
				VALUES(1,
					   'Se finalizó procesando nuevos empleados en '+convert(varchar, @FechaActual),
					   @FechaActual)
			END TRY
			BEGIN CATCH
			-------Reiniciando corrida-----------
				INSERT INTO Corrida (FechaOperacion,
							 TipoRegistro,
							 PostTime)
				VALUES(@FechaActual,
					   1,
					   GETDATE())
				SET @IdUltimaCorrida=SCOPE_IDENTITY();

				INSERT INTO DetalleCorrida (IdCorrida,
											TipoOperacionXML,
											RefID)
				VALUES(@IdUltimaCorrida,
					   1,
					   @SecItera)
				SET @IdUltimODetalleCorrida=SCOPE_IDENTITY();

				INSERT INTO Bitacora (IdTipoOperacion,
									  Texto,
									  Fecha)
				VALUES(1,
					   'Hubo error en el registro numero '+convert(varchar, @SecItera)+
					   ' procesando nuevos empleados en '+convert(varchar, @FechaActual),
					   @FechaActual)
			END CATCH
		END
		DROP TABLE #TempEmpleados
	END
		





	--SELECT @EsFeriado AS Feriado;

	--Este IF revisa si se trata o no de un viernes
	--IF(DATEPART(dw, @FechaActual)=6) --ANDRES 
	/*IF(DATEPART(dw, @FechaActual)=5) --KEYLOR
	BEGIN
		---------------------Este segmento crea las PlanillaXEmpleado y genera los movimientos---------------
		IF(DATEDIFF(day, DATEADD(d,1,EOMONTH(@FechaActual,-1)), @FechaActual)<=7)
		BEGIN

			EXECUTE InsertarMesXEmpleado @IdMesActual,
										 @OutResultCode OUTPUT
			--SELECT @OutResultCode
		END;
		EXECUTE InsertarSemanaXEmpleado @IdSemanaActual,
										@OutResultCode OUTPUT
	END*/




	-----------------Segmento encargado de eliminar empleados----------------------------------
	CREATE TABLE #TempEliminar(Id INT IDENTITY(1,1) PRIMARY KEY,
				    ValorDocumentoIdentidad INT,
					Secuencia INT,
					ProduceError INT)
	INSERT INTO #TempEliminar(ValorDocumentoIdentidad,
							  Secuencia,
							  ProduceError)
	SELECT
		Eliminar.value('@ValorDocumentoIdentidad','int') AS ValorDocumentoIdentidad,
		Eliminar.value('@Secuencia','int') AS Secuencia,
		Eliminar.value('@ProduceError','int') AS ProduceError
	FROM 
		@doc.nodes('/Datos') AS A(Datos)
	CROSS APPLY A.Datos.nodes('./Operacion') AS B(Operacion)
	CROSS APPLY B.Operacion.nodes('./EliminarEmpleado  ') AS C(Eliminar)
	WHERE
		Operacion.value('@Fecha', 'date')=@FechaActual
	SELECT
		@Cont=1, @LargoTabla=COUNT(*)
	FROM
		#TempEliminar
	WHILE(@Cont<=@LargoTabla)
	BEGIN
		SELECT 
			@InEliminarValorDocumentoIdentificacion=T.ValorDocumentoIdentidad
		FROM
			#TempEliminar T
		WHERE
			T.Id=@Cont;
		EXECUTE EliminarEmpleados @InEliminarValorDocumentoIdentificacion, @OutResultCode OUTPUT
		Print('Eliminar empleados')
		--SELECT @OutResultCode;
		SET @Cont=@Cont+1;
	END
	DROP TABLE #TempEliminar


	-----------------Segmento encargado de asociar empleados a deducciones----------------------------------
	CREATE TABLE #TempAsocia(Id INT IDENTITY(1,1) PRIMARY KEY,
				    IdDeduccion INT,
					Monto INT,
					ValorDocumentoIdentidad INT,
					Secuencia INT,
					ProduceError INT)
	INSERT INTO #TempAsocia(IdDeduccion,
							Monto,
							ValorDocumentoIdentidad,
							Secuencia,
							ProduceError)
	SELECT
		Asocia.value('@IdDeduccion','int') AS IdDeduccion,
		CASE WHEN
			TRY_CAST(Asocia.value('@Monto','decimal(10,5)') AS INT) IS NULL THEN 0
			ELSE CAST(Asocia.value('@Monto','decimal(10,5)') AS INT)
		END
		AS Monto,
		Asocia.value('@ValorDocumentoIdentidad','int') AS ValorDocumentoIdentidad,
		Asocia.value('@Secuencia','int') AS Secuencia,
		Asocia.value('@ProduceError','int') AS ProduceError
	FROM 
		@doc.nodes('/Datos') AS A(Datos)
	CROSS APPLY A.Datos.nodes('./Operacion') AS B(Operacion)
	CROSS APPLY B.Operacion.nodes('./AsociaEmpleadoConDeduccion  ') AS C(Asocia)
	WHERE
		Operacion.value('@Fecha', 'date')=@FechaActual
	--SELECT @FechaActual;
	--SELECT * FROM #TempAsocia;
	SELECT
		@Cont=1,
		@LargoTabla=COUNT(*)
	FROM
		#TempAsocia
	WHILE(@Cont<=@LargoTabla)
	BEGIN
		SELECT 
			@InAsociaIdDeduccion=T.IdDeduccion,
			@InAsociaMonto=T.Monto,
			@InAsociaValorDocumentoIdentificacion=T.ValorDocumentoIdentidad
		FROM
			#TempAsocia T
		WHERE
			T.Id=@Cont;
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
		Print('Asociar con deduccion')
		SET @Cont=@Cont+1;
	END
	DROP TABLE #TempAsocia



	-----------------Segmento encargado de deasociar empleados con deducciones----------------------------------
	CREATE TABLE #TempDeasocia(Id INT IDENTITY(1,1) PRIMARY KEY,
				    IdDeduccion INT,
					ValorDocumentoIdentidad INT,
					Secuencia INT,
					ProduceError INT)
	INSERT INTO #TempDeasocia(IdDeduccion,
							  ValorDocumentoIdentidad,
							  Secuencia,
							  ProduceError)
	SELECT
		Deasocia.value('@IdDeduccion','int') AS IdDeduccion,
		Deasocia.value('@ValorDocumentoIdentidad','int') AS ValorDocumentoIdentidad,
		Deasocia.value('@Secuencia','int') AS Secuencia,
		Deasocia.value('@ProduceError','int') AS ProduceError
	FROM 
		@doc.nodes('/Datos') AS A(Datos)
	CROSS APPLY A.Datos.nodes('./Operacion') AS B(Operacion)
	CROSS APPLY B.Operacion.nodes('./DesasociaEmpleadoConDeduccion  ') AS C(Deasocia)
	WHERE
		Operacion.value('@Fecha', 'date')=@FechaActual
	SELECT
		@Cont=1,
		@LargoTabla=COUNT(*)
	FROM
		#TempDeasocia
	WHILE(@Cont<=@LargoTabla)
	BEGIN
		SELECT 
			@InDesIdDeduccion=T.IdDeduccion,
			@InDesValorDocumentoIdentificacion=T.ValorDocumentoIdentidad
		FROM
			#TempDeasocia T
		WHERE
			T.Id=@Cont;
		EXECUTE DesasociarEmpleadoConDeduccion @InDesIdDeduccion,
				@InDesValorDocumentoIdentificacion, @OutResultCode OUTPUT
		--SELECT @OutResultCode;
		SET @Cont=@Cont+1;
		Print('Desasociar')
	END
	DROP TABLE #TempDeasocia

	--IF(DATEPART(dw, @FechaActual)=5)--ANDRES
	IF(DATEPART(dw, @FechaActual)=4)--KEYLOR
	BEGIN
		-----------------Segmento encargado de las jornadas----------------------------------
		CREATE TABLE #TempJornada(Id INT IDENTITY(1,1) PRIMARY KEY,
					    IdJornada INT,
						ValorDocumentoIdentificacion INT,
						Secuencia INT,
						ProduceError INT)
		INSERT INTO #TempJornada(IdJornada,
								 ValorDocumentoIdentificacion,
								 Secuencia,
								 ProduceError)
		SELECT
			Jornada.value('@IdJornada','int') AS IdJornada,
			Jornada.value('@ValorDocumentoIdentidad','int') AS ValorDocumentoIdentificacion,
			Jornada.value('@Secuencia','int') AS Secuencia,
			Jornada.value('@ProduceError','int') AS ProduceError
		FROM 
			@doc.nodes('/Datos') AS A(Datos)
		CROSS APPLY A.Datos.nodes('./Operacion') AS B(Operacion)
		CROSS APPLY B.Operacion.nodes('./TipoDeJornadaProximaSemana') AS C(Jornada)
		WHERE
			Operacion.value('@Fecha', 'date')=@FechaActual
		SELECT
			@Cont=1, @LargoTabla=COUNT(*)
		FROM
			#TempJornada
		WHILE(@Cont<=@LargoTabla)
		BEGIN
			SELECT 
				@InIdJornada=T.IdJornada,
				@InJornadaValorDocumentoIdentificacion=T.ValorDocumentoIdentificacion
			FROM
				#TempJornada T
			WHERE
				T.Id=@Cont;
			EXECUTE
				InsertarJornada @InIdJornada, @InJornadaValorDocumentoIdentificacion,
				@IdSemanaActual, @OutResultCode OUTPUT
			Print('Jornada')
			--SELECT @OutResultCode;
			SET @Cont=@Cont+1;
		END
		DROP TABLE #TempJornada
	END

	
	-----------------Segmento encargado de marcar la asistencia----------------------------------
	CREATE TABLE #TempAsistencia(Id INT IDENTITY(1,1) PRIMARY KEY,
				    FechaEntrada DATETIME,
					FechaSalida DATETIME,
					ValorDocumentoIdentidad INT,
					Secuencia INT,
					ProduceError INT)
	INSERT INTO #TempAsistencia (FechaEntrada,
								 FechaSalida,
								 ValorDocumentoIdentidad,
								 Secuencia,
								 ProduceError)
	SELECT
		Marca.value('@FechaEntrada','datetime') AS FechaEntrada,
		Marca.value('@FechaSalida','datetime') AS FechaSalida,
		Marca.value('@ValorDocumentoIdentidad','int') AS ValorDocumentoIdentidad,
		Marca.value('@Secuencia','int') AS Secuencia,
		Marca.value('@ProduceError','int') AS ProduceError
	FROM 
		@doc.nodes('/Datos') AS A(Datos)
	CROSS APPLY A.Datos.nodes('./Operacion') AS B(Operacion)
	CROSS APPLY B.Operacion.nodes('./MarcaDeAsistencia ') AS C(Marca)
	WHERE
		Operacion.value('@Fecha', 'date')=@FechaActual
	SELECT
		@Cont=1,
		@LargoTabla=COUNT(*)
	FROM
		#TempAsistencia
	WHILE(@Cont<=@LargoTabla)
	BEGIN
		SELECT 
			@InFechaEntrada=T.FechaEntrada,
			@InFechaSalida=T.FechaSalida,
			@InMarcaValorDocumentoIdentificacion=T.ValorDocumentoIdentidad
		FROM
			#TempAsistencia T
		WHERE
			T.Id=@Cont;
		--SELECT @InFechaEntrada, @InFechaSalida;
		EXECUTE MarcarAsistencia @InFechaEntrada,
								 @InFechaSalida,
								 @InMarcaValorDocumentoIdentificacion,
								 @IdMarcaAsistencia OUTPUT,
								 @OutResultCode OUTPUT
		Print('Marcar asistencia')
		--SELECT @OutResultCode;
		--Pre-procensando datos necesarios para los creditos día--------------------------
		SELECT
			@HorasLaboradas=DATEDIFF(hh,@InFechaEntrada,@InFechaSalida);
		SELECT
			@HorasEsperadas=DATEDIFF(hh,TDJ.HoraEntrada,TDJ.HoraSalida)
		FROM
			dbo.TiposDeJornada TDJ,
			dbo.Jornada J,
			dbo.Empleado E
		WHERE
			TDJ.Id=J.TipoJornada AND
			J.IdEmpleado=E.Id AND
			E.ValorDocumentoIdentificacion=@InMarcaValorDocumentoIdentificacion AND
			J.IdSemana=@IdSemanaActual;
		SELECT
			@IdSemanaXEmpleado=PSXM.Id
		FROM
			dbo.PlanillaSemanalXEmpleado PSXM,
			dbo.Empleado E
		WHERE
			PSXM.IdSemana=@IdSemanaActual AND
			PSXM.IdEmpleado=E.Id AND
			E.ValorDocumentoIdentificacion=@InMarcaValorDocumentoIdentificacion;
		SET @Auxiliar=@IdSemanaXEmpleado;
		SELECT
			@Monto=P.SalarioXHora
		FROM
			dbo.Puesto P,
			dbo.Empleado E
		WHERE
			P.Id=E.IdPuesto AND
			E.ValorDocumentoIdentificacion=@InMarcaValorDocumentoIdentificacion;

		EXECUTE CrearMovimientoCreditoDia @FechaActual,
										  @IdSemanaActual,
										  @InFechaEntrada,
										  @InFechaSalida,
										  @InMarcaValorDocumentoIdentificacion,
										  @IdMarcaAsistencia,
										  @EsFeriado,
										  @IdSemanaXEmpleado,
										  @Monto,
										  @HorasLaboradas,
										  @HorasEsperadas,
										  @IdMovimiento,
										  @IdE,
										  @IdMes,
										  --@Auxiliar OUTPUT,
										  @OutResultCode OUTPUT;
		Print('Credito')
		SELECT @IdMes=PM.Id
		FROM
			dbo.PlanillaMensual PM, 
			dbo.PlanillaSemanal PS, 
			dbo.PlanillaSemanalXEmpleado PSX
		WHERE
			PM.Id=PS.IdMes AND
			PS.Id=PSX.IdSemana AND
			PSX.Id=@IdSemanaXEmpleado;
		SELECT
			@Monto=PSX.SalarioNeto
		FROM
			PlanillaSemanalXEmpleado PSX
		WHERE
			PSX.Id=@IdSemanaXEmpleado;
		SELECT
			@IdE=E.Id
		FROM
			dbo.Empleado E
		WHERE
			E.ValorDocumentoIdentificacion=@InMarcaValorDocumentoIdentificacion;

		EXECUTE ActualizarSalarioEmpleado @Monto,
										  @IdE,
										  @IdMes,
										  @OutResultCode OUTPUT;
		Print('Salario')
		--SELECT @OutResultCode;
		--SELECT @FechaActual, @IdSemanaActual, @InFechaEntrada, @InFechaSalida,
		--@InMarcaValorDocumentoIdentificacion, @IdMarcaAsistencia
		--SELECT AAA=@Auxiliar;
		SET @Cont=@Cont+1;
	END
	DROP TABLE #TempAsistencia
	
	--------------Se inserta la finalización de la corrida
	INSERT INTO Corrida (FechaOperacion,
						 TipoRegistro,
						 PostTime)
	VALUES(@FechaActual,
		   2,
		   GETDATE())

	--Se incrementa el día para continuar leyendo el XML
	SET @FechaActual=DATEADD(DAY,1,@FechaActual)
	SELECT @CantDias;
	SET @CantDias=@CantDias+1;
END;
SET NOCOUNT OFF;