--SELECT EOMONTH( @mydate, -1 ) Último del mes anterior
--SELECT EOMONTH( '2021-02-04') Último del mes
--SELECT EOMONTH( @mydate, 1 ) Último del mes siguiente
--SELECT DATEADD(d,1,EOMONTH(getdate(),-1)) Primero del mes actual
--SELECT DATEDIFF(day, '2036-03-01', '2036-02-28') Diferencia de dos fechas en días

USE TareaProgramada
GO

CREATE PROCEDURE dbo.InsertarMes
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
				@InFechaFinal=DATEADD(DAY,7,@InFechaInicio), 
				@InFechaTemporal=EOMONTH(@InFechaFinal), @Bandera='0';
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
			INSERT INTO dbo.PlanillaMensual (FechaInicio,
										 FechaFinal)
			VALUES (@InFechaInicio,
					@InFechaFinal);
			SELECT @OutIdMes=SCOPE_IDENTITY();
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

CREATE PROCEDURE dbo.AsociarEmpleadoConMes
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

CREATE PROCEDURE dbo.InsertarSemana
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
			INSERT INTO dbo.PlanillaSemanal(IdMes,
										FechaInicio,
										FechaFinal)
			VALUES (@InIdMes,
					@InFechaInicio,
					@InFechaFinal);
			SELECT @OutIdSemana=SCOPE_IDENTITY();
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

CREATE PROCEDURE dbo.InsertarEmpleados
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
			INSERT INTO dbo.Empleado(Nombre,
									 IdTipoIdentificacion,
									 ValorDocumentoIdentificacion,
									 IdDepartamento,
									 IdPuesto,
									 FechaNacimiento,
									 Username,
									 Pwd,
									 Activo)
			VALUES(@InEmpleadoNombre,
				   @InEmpleadoIdTipoIdentificacion,
				   @InEmpleadoValorDocumentoIdentificacion,
				   @InEmpleadoIdDepartamento,
				   @InEmpleadoIdPuesto,
				   @InEmpleadoFechaNacimiento, 
				   @InEmpleadoUsername,
				   @InEmpleadoPwd,
				   '1')
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

CREATE PROCEDURE dbo.InsertarJornada
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
			SELECT
				@IdEmpleado=E.Id
			FROM
				dbo.Empleado E
			WHERE
				E.ValorDocumentoIdentificacion=@InValorDocumentoIdentificacion;
			--PRINT(@IdEmpleado)
			INSERT INTO dbo.Jornada(IdEmpleado,
									TipoJornada,
									IdSemana)
			VALUES(@IdEmpleado,
				   @InIdJornada,
				   @InIdSemana);
			
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

CREATE PROCEDURE dbo.MarcarAsistencia
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
			SELECT
				@IdJornada=J.Id
			FROM
				dbo.Empleado E, dbo.Jornada J
			WHERE
				E.ValorDocumentoIdentificacion=@InValorDocumentoIdentidad AND E.Id=J.IdEmpleado;
			--PRINT(@IdJornada)
			INSERT INTO dbo.MarcaAsistencia(IdJornada,
											FechaEntrada,
											FechaSalida)
			VALUES(@IdJornada,
				   @InFechaEntrada,
				   @InFechaSalida);
			SELECT @OutId=SCOPE_IDENTITY();
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

CREATE PROCEDURE dbo.AsociarEmpleadoConFijaNoObligatoria
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
			INSERT INTO dbo.DeduccionXEmpleado(IdEmpleado,
											   IdTipoDeduccion)
			SELECT
				E.Id AS IdEmpleado,
				TD.Id AS IdTipoDeduccion
			FROM
				dbo.Empleado E,
				dbo.TipoDeduccion TD
			WHERE
				TD.Id=@InIdDeduccion AND
				E.ValorDocumentoIdentificacion=@InValorDocumentoIdentificacion;
			SELECT TOP 1
				@IdDeduccionXEmpleado=DXE.Id
			FROM
				dbo.DeduccionXEmpleado DXE
			ORDER BY
				DXE.Id DESC;----------------------------------------------
			INSERT INTO dbo.FijaNoObligatoria(IdDeduccionXEmpleado,
											  Monto)
			VALUES(@IdDeduccionXEmpleado,
				   @InMonto);
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

CREATE PROCEDURE dbo.AsociarEmpleadoConPorcentualNoObligatoria
	@InIdDeduccion INT,
	@InValorDocumentoIdentificacion INT,
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SET @OutResultCode=0;
			DECLARE @IdDeduccionXEmpleado INT,
					@Monto DECIMAL(3,3);
			BEGIN TRANSACTION AsociarDeduccion
			INSERT INTO dbo.DeduccionXEmpleado(IdEmpleado,
											   IdTipoDeduccion)
			SELECT
				E.Id AS IdEmpleado,
				TD.Id AS IdTipoDeduccion
			FROM
				dbo.Empleado E,
				dbo.TipoDeduccion TD
			WHERE
				TD.Id=@InIdDeduccion AND
				E.ValorDocumentoIdentificacion=@InValorDocumentoIdentificacion;
			SELECT TOP 1
				@IdDeduccionXEmpleado=DXE.Id
			FROM
				dbo.DeduccionXEmpleado DXE
			ORDER BY
				DXE.Id DESC;
			SELECT
				@Monto=TD.Valor
			FROM
				dbo.TipoDeduccion TD
			WHERE
				TD.Id=@InIdDeduccion;
			INSERT INTO dbo.PorcentualNoObligatoria(IdDeduccionXEmpleado,
													Porcentaje)
			VALUES(@IdDeduccionXEmpleado,
				   @Monto);
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

CREATE PROCEDURE dbo.DesasociarEmpleadoConDeduccion
	@InIdDeduccion INT,
	@InValorDocumentoIdentificacion INT,
	@OutResultCode INT OUTPUT
	
	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SET @OutResultCode=0;
			DECLARE
				@EsPorcentual BIT,
				@IdDeduccionXEmpleado INT;
			SELECT
				@EsPorcentual=TD.Porcentual
			FROM
				dbo.TipoDeduccion TD
			WHERE
				TD.Id=@InIdDeduccion;
			BEGIN TRANSACTION DesasociarDeduccion
			IF(@EsPorcentual=1)
			BEGIN
				SELECT
					@IdDeduccionXEmpleado=DXE.Id
				FROM
					dbo.PorcentualNoObligatoria PNO,
					dbo.DeduccionXEmpleado DXE,
					dbo.Empleado E
				WHERE
					PNO.IdDeduccionXEmpleado=DXE.Id AND
					DXE.IdEmpleado=E.Id AND
					E.ValorDocumentoIdentificacion=@InValorDocumentoIdentificacion;
				DELETE FROM
					dbo.PorcentualNoObligatoria
				WHERE
					PorcentualNoObligatoria.IdDeduccionXEmpleado=@IdDeduccionXEmpleado;
			END
			ELSE
			BEGIN
				SELECT
					@IdDeduccionXEmpleado=DXE.Id
				FROM
					dbo.FijaNoObligatoria FNO,
					dbo.DeduccionXEmpleado DXE,
					dbo.Empleado E
				WHERE
					FNO.IdDeduccionXEmpleado=DXE.Id AND
					DXE.IdEmpleado=E.Id AND
					E.ValorDocumentoIdentificacion=@InValorDocumentoIdentificacion;
				DELETE FROM
					dbo.FijaNoObligatoria
				WHERE
					FijaNoObligatoria.IdDeduccionXEmpleado=@IdDeduccionXEmpleado;
			END
			DELETE FROM
				dbo.DeduccionXEmpleado
			WHERE
				DeduccionXEmpleado.Id=@IdDeduccionXEmpleado;

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

CREATE PROCEDURE dbo.EliminarEmpleados
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
			WHERE
				ValorDocumentoIdentificacion=@InValorDocumentoIdentificacion
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

CREATE PROCEDURE dbo.InsertarMesXEmpleado
	@InIdMesActual INT,
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SET @OutResultCode=0;
		INSERT INTO dbo.PlanillaMensualXEmpleado(IdMes,
												 IdEmpleado,
												 SalarioNeto,
												 SalarioTotal)
		SELECT
			@InIdMesActual AS IdMes,
			E.Id AS IdEmpleado,
			0 AS SalarioNeto,
			0 AS SalarioTotal
		FROM
			dbo.PlanillaMensual PM,
			dbo.Empleado E
		WHERE
			PM.Id=@InIdMesActual;
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

CREATE PROCEDURE dbo.InsertarSemanaXEmpleado
	@InIdSemanaActual INT,
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SET @OutResultCode=0;
		INSERT INTO dbo.PlanillaSemanalXEmpleado(IdSemana,
												 IdEmpleado,
												 SalarioNeto)
		SELECT
			@InIdSemanaActual AS IdSemana,
			E.Id AS IdEmpleado,
			0 AS SalarioNeto
		FROM
			dbo.PlanillaSemanal PS,
			dbo.Empleado E
		WHERE
			PS.Id=@InIdSemanaActual;
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
EXECUTE InsertarSemanaXEmpleado '2021-02-12', '2', '2021-02-12 12:26 AM',
'2021-02-12 08:59 AM', '71731275', @ResultCode OUTPUT
SELECT @ResultCode
GO*/

CREATE PROCEDURE dbo.CrearMovimientoCreditoDia
	@InFechaActual DATE,
	@InIdSemana INT,
	@InFechaEntrada DATETIME,
	@InFechaSalida DATETIME,
	@InValorDocumentoIdentificacion INT,
	@InIdMarcaAsistencia INT,
	@OutAux INT OUTPUT,
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SET @OutResultCode=0;
		DECLARE @IdSemanaXEmpleado INT,
		@Monto INT,
		@HorasLaboradas INT,
		@HorasEsperadas INT,
		@EsFeriado BIT,
		@IdMovimiento INT,
		@IdE INT,
		@IdMes INT;
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
			dbo.TiposDeJornada TDJ,
			dbo.Jornada J,
			dbo.Empleado E
		WHERE
			TDJ.Id=J.TipoJornada AND
			J.IdEmpleado=E.Id AND
			E.ValorDocumentoIdentificacion=@InValorDocumentoIdentificacion AND
			J.IdSemana=@InIdSemana;
		SELECT
			@IdSemanaXEmpleado=PSXM.Id
		FROM
			dbo.PlanillaSemanalXEmpleado PSXM,
			dbo.Empleado E
		WHERE
			PSXM.IdSemana=@InIdSemana AND
			PSXM.IdEmpleado=E.Id AND
			E.ValorDocumentoIdentificacion=@InValorDocumentoIdentificacion;
		SET @OutAux=@IdSemanaXEmpleado;
		SELECT
			@Monto=P.SalarioXHora
		FROM
			dbo.Puesto P,
			dbo.Empleado E
		WHERE
			P.Id=E.IdPuesto AND
			E.ValorDocumentoIdentificacion=@InValorDocumentoIdentificacion;
		
		IF EXISTS(SELECT F.Fecha FROM Feriados F WHERE @InFechaActual=F.Fecha)
		BEGIN
			SET @EsFeriado=1;
		END
		--ELSE IF(DATEPART(dw, @InFechaActual)=1)--ANDRES
		ELSE IF(DATEPART(dw, @InFechaActual)=7)--KEYLOR
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
			INSERT INTO dbo.MovimientoPlanilla(Fecha,
											   Monto,
											   IdSemana,
											   TipoMovimiento)
			VALUES(@InFechaActual,
				  (@Monto*@HorasLaboradas),
				  @IdSemanaXEmpleado,
				  '1');
			SELECT @IdMovimiento=SCOPE_IDENTITY();
			INSERT INTO dbo.MovimientoHoras(Id,
											IdMarcaAsistencia)
			VALUES(@IdMovimiento,
				   @InIdMarcaAsistencia);
			UPDATE
				dbo.PlanillaSemanalXEmpleado
			SET
				SalarioNeto=SalarioNeto+(@Monto*@HorasLaboradas)
			WHERE
				PlanillaSemanalXEmpleado.Id=@IdSemanaXEmpleado;
		END
		ELSE
		BEGIN
			INSERT INTO dbo.MovimientoPlanilla(Fecha,
											   Monto,
											   IdSemana,
											   TipoMovimiento)
			VALUES(@InFechaActual,
				  (@Monto*@HorasEsperadas),
				  @IdSemanaXEmpleado,
				  '1');
			SELECT @IdMovimiento=SCOPE_IDENTITY();
			INSERT INTO dbo.MovimientoHoras(Id,
											IdMarcaAsistencia)
			VALUES(@IdMovimiento,
				   @InIdMarcaAsistencia);
			UPDATE
				dbo.PlanillaSemanalXEmpleado
			SET
				SalarioNeto=SalarioNeto+(@Monto*@HorasEsperadas)
			WHERE
				PlanillaSemanalXEmpleado.Id=@IdSemanaXEmpleado;


			SELECT @HorasLaboradas=@HorasLaboradas-@HorasEsperadas;
			IF(@EsFeriado=0)
			BEGIN
				INSERT INTO dbo.MovimientoPlanilla(Fecha,
												   Monto,
												   IdSemana,
												   TipoMovimiento)
				VALUES(@InFechaActual,
					  (@Monto*@HorasLaboradas*1.5),
					   @IdSemanaXEmpleado,'2');
				SELECT @IdMovimiento=SCOPE_IDENTITY();
				INSERT INTO dbo.MovimientoHoras(Id,
												IdMarcaAsistencia)
				VALUES(@IdMovimiento,
					   @InIdMarcaAsistencia)
				UPDATE
					dbo.PlanillaSemanalXEmpleado
				SET
					SalarioNeto=SalarioNeto+(@Monto*@HorasLaboradas*1.5)
				WHERE
					PlanillaSemanalXEmpleado.Id=@IdSemanaXEmpleado;
			END
			ELSE
			BEGIN
				INSERT INTO dbo.MovimientoPlanilla(Fecha,
												   Monto,
												   IdSemana,
												   TipoMovimiento)
				VALUES(@InFechaActual,
					  (@Monto*@HorasLaboradas*2),
					   @IdSemanaXEmpleado,
					   '3');
				SELECT @IdMovimiento=SCOPE_IDENTITY();
				INSERT INTO dbo.MovimientoHoras(Id,
												IdMarcaAsistencia)
				VALUES(@IdMovimiento,
					   @InIdMarcaAsistencia)
				UPDATE
					dbo.PlanillaSemanalXEmpleado
				SET
					SalarioNeto=SalarioNeto+(@Monto*@HorasLaboradas*2)
				WHERE
					PlanillaSemanalXEmpleado.Id=@IdSemanaXEmpleado;
			END
		END
		--Monto*Horas
		SELECT @IdMes=PM.Id
		FROM
			dbo.PlanillaMensual PM, 
			dbo.PlanillaSemanal PS, 
			dbo.PlanillaSemanalXEmpleado PSX
		WHERE
			PM.Id=PS.IdMes AND PS.Id=PSX.IdSemana AND PSX.Id=@IdSemanaXEmpleado;
		SELECT
			@Monto=PSX.SalarioNeto FROM PlanillaSemanalXEmpleado PSX
		WHERE
			PSX.Id=@IdSemanaXEmpleado;
		SELECT
			@IdE=E.Id
		FROM
			dbo.Empleado E
		WHERE
			E.ValorDocumentoIdentificacion=@InValorDocumentoIdentificacion;
		UPDATE
			dbo.PlanillaMensualXEmpleado
		SET SalarioTotal=SalarioTotal+@Monto
		WHERE
			PlanillaMensualXEmpleado.IdMes=@IdMes AND
			PlanillaMensualXEmpleado.IdEmpleado=@IdE;


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

CREATE PROCEDURE dbo.CrearMovimientoDebito
	@InFechaActual DATE,
	@InIdSemanaXEmpleado INT,
	@InIdDeduccionXEmpleado INT,
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SET @OutResultCode=0;
		DECLARE @Monto INT,
			    @IdMovimiento INT,
				@TipoMovD INT,
				@EsPorcentual INT,
				@TipoMov INT,
				@IdMes INT,
				@IdE INT;

		SELECT
			@Monto=PSX.SalarioNeto
		FROM
			dbo.PlanillaSemanalXEmpleado PSX
		WHERE
			PSX.Id=@InIdSemanaXEmpleado;

		SELECT
			@TipoMovD=DXE.IdTipoDeduccion
		FROM
			dbo.DeduccionXEmpleado DXE
		WHERE
			DXE.Id=@InIdDeduccionXEmpleado;

		SELECT
			@TipoMov=TMD.IdMovimiento
		FROM
			dbo.TipoMovimientoDeduccion TMD
		WHERE
			TMD.IdDeduccion=@TipoMovD;

		SELECT
			@EsPorcentual=TP.Porcentual
		FROM
			dbo.DeduccionXEmpleado DXE,
			dbo.TipoDeduccion TP
		WHERE
			DXE.Id=@InIdDeduccionXEmpleado AND TP.Id=DXE.IdTipoDeduccion;
		BEGIN TRANSACTION Debitar
		IF(@EsPorcentual=1)
		BEGIN
			DECLARE @ValorP DECIMAL(3,3);
			SELECT @ValorP=TD.Valor
			FROM
				dbo.TipoDeduccion TD
			WHERE
				TD.Id=@TipoMovD;
			INSERT INTO dbo.MovimientoPlanilla(Fecha,
											   Monto,
											   IdSemana,
											   TipoMovimiento)
			VALUES (@InFechaActual,
					@Monto*@ValorP,
					@InIdSemanaXEmpleado,
					@TipoMov)
			UPDATE
				dbo.PlanillaSemanalXEmpleado
			SET
				SalarioNeto=SalarioNeto-@Monto*@ValorP
			WHERE
				PlanillaSemanalXEmpleado.Id=@InIdSemanaXEmpleado;
			---
			SELECT
				@IdMes=PM.Id
			FROM
				dbo.PlanillaMensual PM,
				dbo.PlanillaSemanal PS,
				dbo.PlanillaSemanalXEmpleado PSX
			WHERE
				PM.Id=PS.IdMes AND PS.Id=PSX.IdSemana AND
				PSX.Id=@InIdSemanaXEmpleado;
			SELECT
				@IdE=DXE.IdEmpleado FROM DeduccionXEmpleado DXE
			WHERE
				DXE.Id=@InIdDeduccionXEmpleado;

			INSERT INTO dbo.DeduccionXEmpleadoXMes(IdPlanillaMensualXEmpleado,
													TotalDeducciones,
													IdTipoDeduccion)
			SELECT
				PME.Id,
				@Monto*@ValorP,
				@TipoMovD
			FROM
				dbo.PlanillaMensualXEmpleado PME
			WHERE
				PME.IdMes=@IdMes AND
				PME.IdEmpleado=@IdE;
			---
		END
		ELSE
		BEGIN
			DECLARE
				@ValorF INT,
				@CantJueves INT;
			SELECT
				@ValorF=FNO.Monto
			FROM
				dbo.FijaNoObligatoria FNO
			WHERE
				@InIdDeduccionXEmpleado=FNO.IdDeduccionXEmpleado;
			SELECT
				/*@CantJueves=((DATEDIFF(day,PM.FechaInicio,PM.FechaFinal)+IIF(DATEPART(dw,PM.FechaInicio)>5,
				DATEPART(dw,PM.FechaInicio)-5-7,DATEPART(dw,PM.FechaInicio)-5))/7)+1*/--ANDRES
				@CantJueves=((DATEDIFF(day,PM.FechaInicio,PM.FechaFinal)+IIF(DATEPART(dw,PM.FechaInicio)>4,
				DATEPART(dw,PM.FechaInicio)-4-7,DATEPART(dw,PM.FechaInicio)-4))/7)+1 --KEYLOR
			FROM
				dbo.PlanillaMensual PM,
				dbo.PlanillaSemanal PS,
				dbo.PlanillaSemanalXEmpleado PSX
			WHERE
				PM.Id=PS.IdMes AND
				PS.Id=PSX.IdSemana AND
				PSX.Id=@InIdSemanaXEmpleado;

			INSERT INTO dbo.MovimientoPlanilla(Fecha,
											   Monto,
											   IdSemana,
											   TipoMovimiento)
			VALUES (@InFechaActual,
					@ValorF/@CantJueves,
					@InIdSemanaXEmpleado,
					@TipoMov)
			UPDATE
				dbo.PlanillaSemanalXEmpleado
			SET
				SalarioNeto=SalarioNeto-@ValorF/@CantJueves
			WHERE
				PlanillaSemanalXEmpleado.Id=@InIdSemanaXEmpleado;

			---
			SELECT
				@IdMes=PM.Id
			FROM
				dbo.PlanillaMensual PM,
				dbo.PlanillaSemanal PS,
				dbo.PlanillaSemanalXEmpleado PSX
			WHERE
				PM.Id=PS.IdMes AND
				PS.Id=PSX.IdSemana AND
				PSX.Id=@InIdSemanaXEmpleado;
			SELECT
				@IdE=DXE.IdEmpleado
			FROM
				dbo.DeduccionXEmpleado DXE
			WHERE
				DXE.Id=@InIdDeduccionXEmpleado;

			INSERT INTO dbo.DeduccionXEmpleadoXMes(IdPlanillaMensualXEmpleado,
												   TotalDeducciones,
												   IdTipoDeduccion)
			SELECT
				PME.Id,
				(@ValorF/@CantJueves),
				@TipoMovD
			FROM
				dbo.PlanillaMensualXEmpleado PME
			WHERE
				PME.IdMes=@IdMes AND
				PME.IdEmpleado=@IdE;
			---
		END

		SELECT TOP 1
			@IdMovimiento=MP.Id
		FROM
			dbo.MovimientoPlanilla MP
		ORDER BY
			MP.Id DESC;
		INSERT INTO dbo.MovimientoDeduccion(Id,
											IdDeduccionXEmpleado)
		VALUES(@IdMovimiento,
			   @InIdDeduccionXEmpleado)
		SELECT
			@IdMes=PM.Id
		FROM
			dbo.PlanillaMensual PM,
			dbo.PlanillaSemanal PS,
			dbo.PlanillaSemanalXEmpleado PSX
		WHERE
			PM.Id=PS.IdMes AND
			PS.Id=PSX.IdSemana AND
			PSX.Id=@InIdSemanaXEmpleado;
		SELECT
			@Monto=PSX.SalarioNeto
		FROM
			dbo.PlanillaSemanalXEmpleado PSX
		WHERE
			PSX.Id=@InIdSemanaXEmpleado;
		SELECT
			@IdE=DXE.IdEmpleado
		FROM
			dbo.DeduccionXEmpleado DXE
		WHERE
			DXE.Id=@InIdDeduccionXEmpleado;
		UPDATE dbo.PlanillaMensualXEmpleado
		SET SalarioNeto=SalarioNeto+@Monto
		WHERE
			PlanillaMensualXEmpleado.IdMes=@IdMes AND
			PlanillaMensualXEmpleado.IdEmpleado=@IdE;


		COMMIT TRANSACTION Debitar;

		END TRY
		BEGIN CATCH
			IF @@Trancount>0 
				ROLLBACK TRANSACTION Debitar;
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