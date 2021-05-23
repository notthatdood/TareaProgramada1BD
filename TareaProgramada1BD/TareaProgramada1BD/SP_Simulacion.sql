--SELECT EOMONTH( @mydate, -1 ) Último del mes anterior
--SELECT EOMONTH( '2021-02-04') Último del mes
--SELECT EOMONTH( @mydate, 1 ) Último del mes siguiente
--SELECT DATEADD(d,1,EOMONTH(getdate(),-1)) Primero del mes actual
--SELECT DATEDIFF(day, '2036-03-01', '2036-02-28') Diferencia de dos fechas en días

USE TareaProgramada
GO

CREATE PROCEDURE InsertarMes
	@InFechaInicio DATE,
	@OutIdMes INT OUTPUT,
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SELECT
				@OutResultCode=0;
			DECLARE
				@InFechaFinal DATE,
				@InFechaTemporal DATE,
				@Bandera BIT;
			SET @InFechaInicio=DATEADD(DAY,1,@InFechaInicio);
			SELECT
				@InFechaFinal=DATEADD(DAY,7,@InFechaInicio),  @InFechaTemporal=EOMONTH(@InFechaFinal), @Bandera='0';
				--@FechaFinal=DATEADD(DAY,7,'2021-02-04'), @FechaTemporal=EOMONTH(@FechaFinal), @Bandera='0';
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
			--PRINT(@InFechaFinal)
			INSERT INTO PlanillaMensual VALUES (@InFechaInicio, @InFechaFinal);
			SELECT TOP 1
				@OutIdMes=PM.Id
			FROM
				PlanillaMensual PM
			ORDER BY PM.Id DESC;
		END TRY
		BEGIN CATCH
			INSERT INTO DBErrores VALUES (
			SUSER_SNAME(),
			ERROR_NUMBER(),
			ERROR_STATE(),
			ERROR_SEVERITY(),
			ERROR_LINE(),
			ERROR_PROCEDURE(),
			ERROR_MESSAGE(),
			GETDATE()
			)
		
			SET @OutResultCode=50005;
		END CATCH
		SET NOCOUNT OFF;
	END
GO

CREATE PROCEDURE AsociarEmpleadoConMes
	@InPuestoId INT,
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SET @OutResultCode=0;
			
		END TRY
		BEGIN CATCH
			INSERT INTO DBErrores VALUES (
			SUSER_SNAME(),
			ERROR_NUMBER(),
			ERROR_STATE(),
			ERROR_SEVERITY(),
			ERROR_LINE(),
			ERROR_PROCEDURE(),
			ERROR_MESSAGE(),
			GETDATE()
			)
		
			SET @OutResultCode=50005;
		END CATCH
		SET NOCOUNT OFF;
	END
GO

/*DECLARE @ResultCode INT
EXECUTE InsertarMes '2021-02-05', @ResultCode OUTPUT
SELECT @ResultCode
SELECT * FROM PlanillaMensual*/

CREATE PROCEDURE InsertarSemana
	@InIdMes INT,
	@InFechaInicio DATE,
	@OutIdSemana INT OUTPUT,
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SELECT
				@OutResultCode=0;
			DECLARE
				@InFechaFinal DATE,
				@InFechaTemporal DATE,
				@Bandera BIT;
			SET @InFechaInicio=DATEADD(DAY,1,@InFechaInicio);
			SELECT
				@InFechaFinal=DATEADD(DAY,6,@InFechaInicio),  @InFechaTemporal=EOMONTH(@InFechaFinal), @Bandera='0';
				--@FechaFinal=DATEADD(DAY,7,'2021-02-04'), @FechaTemporal=EOMONTH(@FechaFinal), @Bandera='0';
			--PRINT(@InFechaFinal)
			INSERT INTO PlanillaSemanal VALUES (@InIdMes, @InFechaInicio, @InFechaFinal);
			SELECT TOP 1
				@OutIdSemana=PS.Id
			FROM
				PlanillaSemanal PS
			ORDER BY PS.Id DESC;
			--PRINT(@OutIdSemana)
		END TRY
		BEGIN CATCH
			INSERT INTO DBErrores VALUES (
			SUSER_SNAME(),
			ERROR_NUMBER(),
			ERROR_STATE(),
			ERROR_SEVERITY(),
			ERROR_LINE(),
			ERROR_PROCEDURE(),
			ERROR_MESSAGE(),
			GETDATE()
			)
		
			SET @OutResultCode=50005;
		END CATCH
		SET NOCOUNT OFF;
	END
GO

CREATE PROCEDURE InsertarEmpleados
	@InEmpleadoNombre VARCHAR(50),
	@InEmpleadoIdTipoIdentificacion INT,
	@InEmpleadoValorDocumentoIdentificacion INT,
	@InEmpleadoFechaNacimiento DATE,
	@InEmpleadoIdPuesto INT,
	@InEmpleadoIdDepartamento INT,
	@InEmpleadoUsername VARCHAR(30),
	@InEmpleadoPwd VARCHAR(30),
	@OutResultCode INT OUTPUT
	
	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SET @OutResultCode=0;
			INSERT INTO Empleado
			VALUES(@InEmpleadoNombre, @InEmpleadoIdTipoIdentificacion, @InEmpleadoValorDocumentoIdentificacion,
			@InEmpleadoIdDepartamento, @InEmpleadoIdPuesto, @InEmpleadoFechaNacimiento, @InEmpleadoUsername,
			@InEmpleadoPwd,'1')
		END TRY
		BEGIN CATCH
			INSERT INTO DBErrores VALUES (
			SUSER_SNAME(),
			ERROR_NUMBER(),
			ERROR_STATE(),
			ERROR_SEVERITY(),
			ERROR_LINE(),
			ERROR_PROCEDURE(),
			ERROR_MESSAGE(),
			GETDATE()
			)
		
			SET @OutResultCode=50005;
		END CATCH
		SET NOCOUNT OFF;
	END
GO
--DECLARE @ResultCode INT
--EXECUTE InsertarEmpleado 'Nombre', 'TipoIdentificacion',
--'ValorDocIdentificacion', 'FechaNacimiento', 'IdPuesto', 'IdDepartamento', @ResultCode OUTPUT
--SELECT @ResultCode

CREATE PROCEDURE InsertarJornada
	@InIdJornada INT,
	@InValorDocumentoIdentificacion INT,
	@InIdSemana INT,
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SET @OutResultCode=0;
			DECLARE @IdEmpleado INT;
			SELECT @IdEmpleado=E.Id FROM Empleado E WHERE E.ValorDocumentoIdentificacion=@InValorDocumentoIdentificacion;
			--PRINT(@IdEmpleado)
			INSERT INTO Jornada VALUES(@IdEmpleado, @InIdJornada, @InIdSemana);
			
		END TRY
		BEGIN CATCH
			INSERT INTO DBErrores VALUES (
			SUSER_SNAME(),
			ERROR_NUMBER(),
			ERROR_STATE(),
			ERROR_SEVERITY(),
			ERROR_LINE(),
			ERROR_PROCEDURE(),
			ERROR_MESSAGE(),
			GETDATE()
			)
		
			SET @OutResultCode=50005;
		END CATCH
		SET NOCOUNT OFF;
	END
GO

CREATE PROCEDURE MarcarAsistencia
	@InFechaEntrada DATETIME,
	@InFechaSalida DATETIME,
	@InValorDocumentoIdentidad INT,
	@OutId INT OUTPUT,
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SET @OutResultCode=0;
			DECLARE @IdJornada INT;
			SELECT @IdJornada=J.Id FROM Empleado E, Jornada J
			WHERE E.ValorDocumentoIdentificacion=@InValorDocumentoIdentidad
			AND E.Id=J.IdEmpleado;
			--PRINT(@IdJornada)
			INSERT INTO MarcaAsistencia VALUES(@IdJornada, @InFechaEntrada, @InFechaSalida);
			SELECT TOP 1 @OutId=MA.Id FROM MarcaAsistencia MA ORDER BY MA.Id DESC;
		END TRY
		BEGIN CATCH
			INSERT INTO DBErrores VALUES (
			SUSER_SNAME(),
			ERROR_NUMBER(),
			ERROR_STATE(),
			ERROR_SEVERITY(),
			ERROR_LINE(),
			ERROR_PROCEDURE(),
			ERROR_MESSAGE(),
			GETDATE()
			)
		
			SET @OutResultCode=50005;
		END CATCH
		SET NOCOUNT OFF;
	END
GO

/*DECLARE @ResultCode INT
EXECUTE MarcarAsistencia '2021-02-05 03:37 PM', '2021-02-05 11:39 PM',
'71731275', @ResultCode OUTPUT
SELECT @ResultCode*/

CREATE PROCEDURE AsociarEmpleadoConFijaNoObligatoria
	@InIdDeduccion INT,
	@InMonto INT,
	@InValorDocumentoIdentificacion INT,
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SET @OutResultCode=0;
			DECLARE @IdDeduccionXEmpleado INT;
			BEGIN TRANSACTION AsociarDeduccion
			INSERT INTO DeduccionXEmpleado SELECT E.Id, TD.Id
			FROM Empleado E, TipoDeduccion TD WHERE TD.Id=@InIdDeduccion AND
			E.ValorDocumentoIdentificacion=@InValorDocumentoIdentificacion;
			SELECT TOP 1 @IdDeduccionXEmpleado=DXE.Id FROM DeduccionXEmpleado DXE ORDER BY DXE.Id DESC;
			INSERT INTO FijaNoObligatoria VALUES(@IdDeduccionXEmpleado, @InMonto);
			COMMIT TRANSACTION AsociarDeduccion;
		END TRY 
		BEGIN CATCH
			IF @@Trancount>0 
				ROLLBACK TRANSACTION AsociarDeduccion;
			INSERT INTO DBErrores VALUES (
			SUSER_SNAME(),
			ERROR_NUMBER(),
			ERROR_STATE(),
			ERROR_SEVERITY(),
			ERROR_LINE(),
			ERROR_PROCEDURE(),
			ERROR_MESSAGE(),
			GETDATE()
			)
		
			SET @OutResultCode=50005;
		END CATCH
		SET NOCOUNT OFF;
	END
GO

CREATE PROCEDURE AsociarEmpleadoConPorcentualNoObligatoria
	@InIdDeduccion INT,
	@InValorDocumentoIdentificacion INT,
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SET @OutResultCode=0;
			DECLARE @IdDeduccionXEmpleado INT, @Monto DECIMAL(3,3);
			BEGIN TRANSACTION AsociarDeduccion
			INSERT INTO DeduccionXEmpleado SELECT E.Id, TD.Id
			FROM Empleado E, TipoDeduccion TD WHERE TD.Id=@InIdDeduccion AND
			E.ValorDocumentoIdentificacion=@InValorDocumentoIdentificacion;
			SELECT TOP 1 @IdDeduccionXEmpleado=DXE.Id FROM DeduccionXEmpleado DXE ORDER BY DXE.Id DESC;
			SELECT @Monto=TD.Valor FROM TipoDeduccion TD WHERE TD.Id=@InIdDeduccion;
			INSERT INTO PorcentualNoObligatoria VALUES(@IdDeduccionXEmpleado, @Monto);
			COMMIT TRANSACTION AsociarDeduccion;
		END TRY
		BEGIN CATCH
			IF @@Trancount>0 
				ROLLBACK TRANSACTION AsociarDeduccion;
			INSERT INTO DBErrores VALUES (
			SUSER_SNAME(),
			ERROR_NUMBER(),
			ERROR_STATE(),
			ERROR_SEVERITY(),
			ERROR_LINE(),
			ERROR_PROCEDURE(),
			ERROR_MESSAGE(),
			GETDATE()
			)
		
			SET @OutResultCode=50005;
		END CATCH
		SET NOCOUNT OFF;
	END
GO

/*DECLARE @ResultCode INT
EXECUTE AsociarEmpleadoConFijaNoObligatoria'2', '10000','15442171', @ResultCode OUTPUT
SELECT @ResultCode*/

CREATE PROCEDURE DesasociarEmpleadoConDeduccion
	@InIdDeduccion INT,
	@InValorDocumentoIdentificacion INT,
	@OutResultCode INT OUTPUT
	
	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SET @OutResultCode=0;
			DECLARE @EsPorcentual BIT, @IdDeduccionXEmpleado INT;
			SELECT @EsPorcentual=TD.Porcentual FROM TipoDeduccion TD WHERE TD.Id=@InIdDeduccion;
			BEGIN TRANSACTION DesasociarDeduccion
			IF(@EsPorcentual=1)
			BEGIN
				SELECT @IdDeduccionXEmpleado=DXE.Id FROM PorcentualNoObligatoria PNO,
				DeduccionXEmpleado DXE, Empleado E
				WHERE PNO.IdDeduccionXEmpleado=DXE.Id AND
					DXE.IdEmpleado=E.Id AND
					E.ValorDocumentoIdentificacion=@InValorDocumentoIdentificacion;
				DELETE FROM PorcentualNoObligatoria
				WHERE PorcentualNoObligatoria.IdDeduccionXEmpleado=@IdDeduccionXEmpleado;
			END
			ELSE
			BEGIN
				SELECT @IdDeduccionXEmpleado=DXE.Id FROM FijaNoObligatoria FNO,
				DeduccionXEmpleado DXE, Empleado E
				WHERE FNO.IdDeduccionXEmpleado=DXE.Id AND
					DXE.IdEmpleado=E.Id AND
					E.ValorDocumentoIdentificacion=@InValorDocumentoIdentificacion;
				DELETE FROM FijaNoObligatoria
				WHERE FijaNoObligatoria.IdDeduccionXEmpleado=@IdDeduccionXEmpleado;
			END
			DELETE FROM DeduccionXEmpleado WHERE DeduccionXEmpleado.Id=@IdDeduccionXEmpleado;

			COMMIT TRANSACTION DesasociarDeduccion;
		END TRY
		BEGIN CATCH
			IF @@Trancount>0 
				ROLLBACK TRANSACTION DesasociarDeduccion;
			INSERT INTO DBErrores VALUES (
			SUSER_SNAME(),
			ERROR_NUMBER(),
			ERROR_STATE(),
			ERROR_SEVERITY(),
			ERROR_LINE(),
			ERROR_PROCEDURE(),
			ERROR_MESSAGE(),
			GETDATE()
			)
		
			SET @OutResultCode=50005;
		END CATCH
		SET NOCOUNT OFF;
	END
GO

CREATE PROCEDURE EliminarEmpleados
	@InValorDocumentoIdentificacion INT,
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SELECT
				@OutResultCode=0;
			IF NOT EXISTS(SELECT 1 FROM Empleado C WHERE C.ValorDocumentoIdentificacion=@InValorDocumentoIdentificacion)
			OR EXISTS(SELECT 1 FROM Empleado C WHERE C.ValorDocumentoIdentificacion=@InValorDocumentoIdentificacion AND Activo='0')
				BEGIN
					SET @OutResultCode=50001; --El empleado no existe
					RETURN
				END;
			UPDATE Empleado
			SET Activo='0'
			WHERE ValorDocumentoIdentificacion=@InValorDocumentoIdentificacion
		END TRY
		BEGIN CATCH
			INSERT INTO DBErrores VALUES (
			SUSER_SNAME(),
			ERROR_NUMBER(),
			ERROR_STATE(),
			ERROR_SEVERITY(),
			ERROR_LINE(),
			ERROR_PROCEDURE(),
			ERROR_MESSAGE(),
			GETDATE()
			)

			SET @OutResultCode=50005;
		END CATCH
		SET NOCOUNT OFF;
	END
GO

/*DECLARE @ResultCode INT
EXECUTE EliminarEmpleados '15442171', @ResultCode OUTPUT
SELECT @ResultCode*/

/*DECLARE @ResultCode INT
EXECUTE DesasociarEmpleadoConDeduccion '4', '15442171', @ResultCode OUTPUT
SELECT @ResultCode*/


/*DECLARE @ResultCode INT
EXECUTE AsociarEmpleadoConFijaNoObligatoria'2', '10000','15442171', @ResultCode OUTPUT
SELECT @ResultCode*/

/*DECLARE @ResultCode INT
EXECUTE InsertarMesXEmpleado '2', @ResultCode OUTPUT
SELECT @ResultCode*/

CREATE PROCEDURE InsertarMesXEmpleado
	@InIdMesActual INT,
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SET @OutResultCode=0;
		INSERT INTO PlanillaMensualXEmpleado SELECT @InIdMesActual, E.Id, 0, 0
		FROM PlanillaMensual PM, Empleado E WHERE PM.Id=@InIdMesActual;
		END TRY
		BEGIN CATCH
			INSERT INTO DBErrores VALUES (
			SUSER_SNAME(),
			ERROR_NUMBER(),
			ERROR_STATE(),
			ERROR_SEVERITY(),
			ERROR_LINE(),
			ERROR_PROCEDURE(),
			ERROR_MESSAGE(),
			GETDATE()
			)
		
			SET @OutResultCode=50005;
		END CATCH
		SET NOCOUNT OFF;
	END
GO

/*DECLARE @ResultCode INT
EXECUTE InsertarSemanaXEmpleado '23', @ResultCode OUTPUT
SELECT @ResultCode
GO*/

CREATE PROCEDURE InsertarSemanaXEmpleado
	@InIdSemanaActual INT,
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SET @OutResultCode=0;
		INSERT INTO PlanillaSemanalXEmpleado SELECT @InIdSemanaActual, E.Id, 0
		FROM PlanillaSemanal PS, Empleado E WHERE PS.Id=@InIdSemanaActual;
		END TRY
		BEGIN CATCH
			INSERT INTO DBErrores VALUES (
			SUSER_SNAME(),
			ERROR_NUMBER(),
			ERROR_STATE(),
			ERROR_SEVERITY(),
			ERROR_LINE(),
			ERROR_PROCEDURE(),
			ERROR_MESSAGE(),
			GETDATE()
			)
		
			SET @OutResultCode=50005;
		END CATCH
		SET NOCOUNT OFF;
	END
GO

CREATE PROCEDURE CrearMovimientoCreditoDia
	@InFechaActual DATE,
	@InIdSemana INT,
	@InFechaEntrada DATETIME,
	@InFechaSalida DATETIME,
	@InValorDocumentoIdentificacion INT,
	@InIdMarcaAsistencia INT,
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SET @OutResultCode=0;
		DECLARE @IdSemanaXEmpleado INT, @Monto INT, @HorasLaboradas INT,
		@HorasEsperadas INT, @EsFeriado BIT, @IdMovimiento INT;
		--
		/*DECLARE @InFechaEntrada DATETIME, @InFechaSalida DATETIME, @InValorDocumentoIdentificacion INT,
		@InIdSemana INT;
		SELECT @InFechaEntrada='2021-02-07 04:09 PM', @InFechaSalida='2021-02-07 11:34 PM',
		@InValorDocumentoIdentificacion='71731275', @InIdSemana='23';*/
		--
		SELECT
			@HorasLaboradas=DATEDIFF(hh,@InFechaEntrada,@InFechaSalida);
		SELECT
			@HorasEsperadas=DATEDIFF(hh,TDJ.HoraEntrada,TDJ.HoraSalida)
		FROM
			TiposDeJornada TDJ, Jornada J, Empleado E
		WHERE
			TDJ.Id=J.TipoJornada AND J.IdEmpleado=E.Id AND
			E.ValorDocumentoIdentificacion=@InValorDocumentoIdentificacion AND J.IdSemana=@InIdSemana;
		SELECT
			@IdSemanaXEmpleado=PSXM.Id
		FROM
			PlanillaSemanalXEmpleado PSXM, Empleado E
		WHERE
			PSXM.IdSemana=@InIdSemana AND PSXM.IdEmpleado=E.Id AND E.ValorDocumentoIdentificacion=@InValorDocumentoIdentificacion;
		--PRINT(@IdSemanaXEmpleado)
		SELECT
			@Monto=P.SalarioXHora
		FROM
			Puesto P, Empleado E
		WHERE
			P.Id=E.IdPuesto AND E.ValorDocumentoIdentificacion=@InValorDocumentoIdentificacion;
		
		IF EXISTS(SELECT * FROM Feriados F WHERE @InFechaActual=F.Fecha)
		BEGIN
			SET @EsFeriado=1;
		END
		ELSE IF(DATEPART(dw, @InFechaActual)=7)
		BEGIN
			SET @EsFeriado=1;
		END
		ELSE
		BEGIN
			SET @EsFeriado=0;
		END

		BEGIN TRANSACTION Movimiento;
		IF(@HorasLaboradas<=@HorasEsperadas)
		BEGIN
			INSERT INTO MovimientoPlanilla VALUES(@InFechaActual,@Monto*@HorasLaboradas,
			@IdSemanaXEmpleado,'1');
			SELECT TOP 1
				@IdMovimiento=MP.Id
			FROM
				MovimientoPlanilla MP
			ORDER BY MP.Id DESC;
			INSERT INTO MovimientoHoras VALUES(@IdMovimiento, @InIdMarcaAsistencia)
		END
		ELSE
		BEGIN
			INSERT INTO MovimientoPlanilla VALUES(@InFechaActual,@Monto*@HorasEsperadas,
			@IdSemanaXEmpleado,'1');
			SELECT TOP 1
				@IdMovimiento=MP.Id
			FROM
				MovimientoPlanilla MP
			ORDER BY MP.Id DESC;
			INSERT INTO MovimientoHoras VALUES(@IdMovimiento, @InIdMarcaAsistencia);

			SET @HorasLaboradas=@HorasLaboradas-@HorasEsperadas;
			IF(@EsFeriado=0)
			BEGIN
				INSERT INTO MovimientoPlanilla VALUES(@InFechaActual,@Monto*@HorasLaboradas*1.5,
				@IdSemanaXEmpleado,'2');
				SELECT TOP 1
					@IdMovimiento=MP.Id
				FROM
					MovimientoPlanilla MP
				ORDER BY MP.Id DESC;
				INSERT INTO MovimientoHoras VALUES(@IdMovimiento, @InIdMarcaAsistencia)
			END
			ELSE
			BEGIN
				INSERT INTO MovimientoPlanilla VALUES(@InFechaActual,@Monto*@HorasLaboradas*2,
				@IdSemanaXEmpleado,'3');
				SELECT TOP 1
					@IdMovimiento=MP.Id
				FROM
					MovimientoPlanilla MP
				ORDER BY MP.Id DESC;
				INSERT INTO MovimientoHoras VALUES(@IdMovimiento, @InIdMarcaAsistencia)
			END
		END
		--Monto*Horas


		COMMIT TRANSACTION Movimiento;
		--PRINT(@HorasLaboradas)
		--PRINT(@HorasEsperadas)

		END TRY
		BEGIN CATCH
			IF @@Trancount>0 
				ROLLBACK TRANSACTION Movimiento;
			INSERT INTO DBErrores VALUES (
			SUSER_SNAME(),
			ERROR_NUMBER(),
			ERROR_STATE(),
			ERROR_SEVERITY(),
			ERROR_LINE(),
			ERROR_PROCEDURE(),
			ERROR_MESSAGE(),
			GETDATE()
			)
		
			SET @OutResultCode=50005;
		END CATCH
		SET NOCOUNT OFF;
	END
GO

/*CREATE PROCEDURE name
	@InPuestoId INT,
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SET @OutResultCode=0;
			
		END TRY
		BEGIN CATCH
			INSERT INTO DBErrores VALUES (
			SUSER_SNAME(),
			ERROR_NUMBER(),
			ERROR_STATE(),
			ERROR_SEVERITY(),
			ERROR_LINE(),
			ERROR_PROCEDURE(),
			ERROR_MESSAGE(),
			GETDATE()
			)
		
			SET @OutResultCode=50005;
		END CATCH
		SET NOCOUNT OFF;
	END
GO*/