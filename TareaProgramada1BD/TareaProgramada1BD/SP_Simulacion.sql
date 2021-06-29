--SELECT EOMONTH( @mydate, -1 ) Último del mes anterior
--SELECT EOMONTH( '2021-02-04') Último del mes
--SELECT EOMONTH( @mydate, 1 ) Último del mes siguiente
--SELECT DATEADD(d,1,EOMONTH(getdate(),-1)) Primero del mes actual
--SELECT DATEDIFF(day, '2036-03-01', '2036-02-28') Diferencia de dos fechas en días

USE TareaProgramada
GO

CREATE PROCEDURE dbo.InsertarMes
	@InFechaInicio DATE,
	@InFechaFinal DATE,
	@OutIdMes INT OUTPUT,
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SELECT
				@OutResultCode=0;
			
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
				--@FechaFinal=DATEADD(DAY,7,'2021-02-04'), @FechaTemporal=EOMONTH(@FechaFinal), @Bandera='0';
			--PRINT(@InFechaFinal)
			INSERT INTO dbo.PlanillaSemanal(IdMes,
										FechaInicio,
										FechaFinal)
			VALUES (@InIdMes,
					@InFechaInicio,
					DATEADD(DAY,7,@InFechaInicio));
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
			DECLARE
				@IdJornada INT;
			SELECT
				@IdJornada=J.Id
			FROM
				dbo.Empleado E, dbo.Jornada J
			WHERE
				E.ValorDocumentoIdentificacion=@InValorDocumentoIdentidad AND
				E.Id=J.IdEmpleado;
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
	@InFecha DATE,
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SET @OutResultCode=0;
			DECLARE @IdDeduccionXEmpleado INT;
			BEGIN TRANSACTION AsociarDeduccion
			INSERT INTO dbo.DeduccionXEmpleado(IdEmpleado,
											   IdTipoDeduccion,
											   Activo,
											   FechaInicio)
			SELECT
				E.Id AS IdEmpleado,
				TD.Id AS IdTipoDeduccion,
				'1' AS Activo,
				@InFecha AS FechaInicio
			FROM
				dbo.Empleado E,
				dbo.TipoDeduccion TD
			WHERE
				TD.Id=@InIdDeduccion AND
				E.ValorDocumentoIdentificacion=@InValorDocumentoIdentificacion;
			SELECT @IdDeduccionXEmpleado=SCOPE_IDENTITY();
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
	@InFecha DATE,
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
											   IdTipoDeduccion,
											   Activo,
											   FechaInicio)
			SELECT
				E.Id AS IdEmpleado,
				TD.Id AS IdTipoDeduccion,
				'1' AS Activo,
				@InFecha AS FechaInicio
			FROM
				dbo.Empleado E,
				dbo.TipoDeduccion TD
			WHERE
				TD.Id=@InIdDeduccion AND
				E.ValorDocumentoIdentificacion=@InValorDocumentoIdentificacion;
			SELECT @IdDeduccionXEmpleado=SCOPE_IDENTITY();
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
	@InFecha DATE,
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
					E.ValorDocumentoIdentificacion=@InValorDocumentoIdentificacion AND
					DXE.Activo='1';
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
					E.ValorDocumentoIdentificacion=@InValorDocumentoIdentificacion AND
					DXE.Activo='1';
				DELETE FROM
					dbo.FijaNoObligatoria
				WHERE
					FijaNoObligatoria.IdDeduccionXEmpleado=@IdDeduccionXEmpleado;
			END
			UPDATE
				dbo.DeduccionXEmpleado
			SET Activo='0',
				FechaFin=@InFecha
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
			UPDATE
				Empleado
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

CREATE PROCEDURE dbo.CrearMovimientoHorasNormales
	@InFechaActual DATE,
	@InIdSemana INT,
	@InFechaEntrada DATETIME,
	@InFechaSalida DATETIME,
	@InValorDocumentoIdentificacion INT,
	@InIdMarcaAsistencia INT,
	@InIdSemanaXEmpleado INT,
	@InMonto INT,
	@InHorasEsperadas INT,
	@InIdMovimiento INT,
	@InIdE INT,
	@InIdMes INT,
	--@OutAux INT OUTPUT,
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SET @OutResultCode=0;
		BEGIN TRANSACTION Movimiento;
		INSERT INTO dbo.MovimientoPlanilla(Fecha,
										   Monto,
										   IdSemana,
										   TipoMovimiento)
		VALUES(@InFechaActual,
			  (@InMonto*@InHorasEsperadas),
			  @InIdSemanaXEmpleado,
			  1);
		SELECT @InIdMovimiento=SCOPE_IDENTITY();
		INSERT INTO dbo.MovimientoHoras(Id,
										IdMarcaAsistencia)
		VALUES(@InIdMovimiento,
			   @InIdMarcaAsistencia);
		UPDATE
			dbo.PlanillaSemanalXEmpleado
		SET
			SalarioNeto=SalarioNeto+(@InMonto*@InHorasEsperadas)
		FROM
			dbo.PlanillaSemanalXEmpleado PSE, dbo.Empleado E
		WHERE
			PSE.Id=@InIdSemanaXEmpleado AND
			PSE.IdEmpleado=E.Id AND
			E.Activo='1';
		COMMIT TRANSACTION Movimiento;

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

CREATE PROCEDURE dbo.CrearMovimientoHorasExtra
	@InFechaActual DATE,
	@InIdSemana INT,
	@InFechaEntrada DATETIME,
	@InFechaSalida DATETIME,
	@InValorDocumentoIdentificacion INT,
	@InIdMarcaAsistencia INT,
	@InIdSemanaXEmpleado INT,
	@InMonto INT,
	@InHorasLaboradas INT,
	@InIdMovimiento INT,
	@InIdE INT,
	@InIdMes INT,
	--@OutAux INT OUTPUT,
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SET @OutResultCode=0;
			BEGIN TRANSACTION Movimiento;
		
			INSERT INTO dbo.MovimientoPlanilla(Fecha,
											   Monto,
											   IdSemana,
											   TipoMovimiento)
			VALUES(@InFechaActual,
				  (@InMonto*@InHorasLaboradas*(1.5)),
				   @InIdSemanaXEmpleado,
				   2);
			SELECT
				@InIdMovimiento=SCOPE_IDENTITY();
			INSERT INTO dbo.MovimientoHoras(Id,
											IdMarcaAsistencia)
			VALUES(@InIdMovimiento,
				   @InIdMarcaAsistencia)
			UPDATE
				dbo.PlanillaSemanalXEmpleado
			SET
				SalarioNeto=SalarioNeto+(@InMonto*@InHorasLaboradas*(1.5))
			FROM
				dbo.PlanillaSemanalXEmpleado PSE, dbo.Empleado E
			WHERE
				PSE.Id=@InIdSemanaXEmpleado AND
				PSE.IdEmpleado=E.Id AND
				E.Activo='1';

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

CREATE PROCEDURE dbo.CrearMovimientoHorasExtraDobles
	@InFechaActual DATE,
	@InIdSemana INT,
	@InFechaEntrada DATETIME,
	@InFechaSalida DATETIME,
	@InValorDocumentoIdentificacion INT,
	@InIdMarcaAsistencia INT,
	@InIdSemanaXEmpleado INT,
	@InMonto INT,
	@InHorasLaboradas INT,
	@InIdMovimiento INT,
	@InIdE INT,
	@InIdMes INT,
	--@OutAux INT OUTPUT,
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SET @OutResultCode=0;
			BEGIN TRANSACTION Movimiento;
		
			INSERT INTO dbo.MovimientoPlanilla(Fecha,
											   Monto,
											   IdSemana,
											   TipoMovimiento)
			VALUES(@InFechaActual,
				  (@InMonto*@InHorasLaboradas*(2)),
				   @InIdSemanaXEmpleado,
				   3);
			SELECT
				@InIdMovimiento=SCOPE_IDENTITY();
			INSERT INTO dbo.MovimientoHoras(Id,
											IdMarcaAsistencia)
			VALUES(@InIdMovimiento,
				   @InIdMarcaAsistencia)
			UPDATE
				dbo.PlanillaSemanalXEmpleado
			SET
				SalarioNeto=SalarioNeto+(@InMonto*@InHorasLaboradas*(2))
			FROM
				dbo.PlanillaSemanalXEmpleado PSE, dbo.Empleado E
			WHERE
				PSE.Id=@InIdSemanaXEmpleado AND
				PSE.IdEmpleado=E.Id AND
				E.Activo='1';

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

CREATE PROCEDURE dbo.ActualizarSalarioEmpleado
	@InMonto INT,
	@InIdE INT,
	@InIdMes INT,
	--@OutAux INT OUTPUT,
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SET @OutResultCode=0;
			UPDATE
				dbo.PlanillaMensualXEmpleado
			SET SalarioTotal=SalarioTotal+@InMonto
			FROM
				dbo.PlanillaMensualXEmpleado PME,
				dbo.Empleado E
			WHERE
				PME.IdMes=@InIdMes AND
				PME.IdEmpleado=@InIdE AND
				@InIdE=E.Id AND
				E.Activo='1';
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


CREATE PROCEDURE dbo.CrearMovimientoDebitoPorcentual
	@InFechaActual DATE,
	@InIdSemanaXEmpleado INT,
	@InMonto INT,
	@InIdMovimiento INT,
	@InTipoMovD INT,
	@InTipoMov INT,
	@InValorP DECIMAL(3,3),
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SET @OutResultCode=0;
			INSERT INTO dbo.MovimientoPlanilla(Fecha,
											   Monto,
											   IdSemana,
											   TipoMovimiento)
			VALUES (@InFechaActual,
					@InMonto*@InValorP,
					@InIdSemanaXEmpleado,
					@InTipoMov)

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

CREATE PROCEDURE dbo.ActualizarPlanillaSemanalPorcentual
	@InIdSemanaXEmpleado INT,
	@InMonto INT,
	@InValorP DECIMAL(3,3),
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SET @OutResultCode=0;
		UPDATE
			dbo.PlanillaSemanalXEmpleado
		SET
			SalarioNeto=SalarioNeto-@InMonto*@InValorP
		FROM
			dbo.PlanillaSemanalXEmpleado PSE,
			dbo.Empleado E
		WHERE
			PSE.Id=@InIdSemanaXEmpleado AND
			PSE.IdEmpleado=E.Id AND
			E.Activo='1';
		---

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

CREATE PROCEDURE dbo.CrearMovimientoDebitoFijo
	@InFechaActual DATE,
	@InIdSemanaXEmpleado INT,
	@InMonto INT,
	@InIdMovimiento INT,
	@InTipoMov INT,
	@InValorF INT,
	@InCantJueves INT,
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SET @OutResultCode=0;
			INSERT INTO dbo.MovimientoPlanilla(Fecha,
											   Monto,
											   IdSemana,
											   TipoMovimiento)
			VALUES (@InFechaActual,
					@InValorF/@InCantJueves,
					@InIdSemanaXEmpleado,
					@InTipoMov)

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

CREATE PROCEDURE dbo.ActualizarPlanillaSemanalFijo
	@InIdSemanaXEmpleado INT,
	@InMonto INT,
	@InValorF INT,
	@InCantJueves INT,
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SET @OutResultCode=0;
		UPDATE
			dbo.PlanillaSemanalXEmpleado
		SET
			SalarioNeto=SalarioNeto-@InValorF/@InCantJueves
		FROM
			dbo.PlanillaSemanalXEmpleado PSE,
			dbo.Empleado E
		WHERE
			PSE.Id=@InIdSemanaXEmpleado AND
			PSE.IdEmpleado=E.Id AND
			E.Activo='1';

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
			
CREATE PROCEDURE dbo.ActualizarDeduccionXEmpleadoXMes
	@InTipoMovD INT,
	@InMonto INT,
	@InIdMes INT,
	@InIdE INT,
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SET @OutResultCode=0;
		INSERT INTO dbo.DeduccionXEmpleadoXMes(IdPlanillaMensualXEmpleado,
													TotalDeducciones,
													IdTipoDeduccion)
		SELECT
			PME.Id,
			@InMonto,
			@InTipoMovD
		FROM
			dbo.PlanillaMensualXEmpleado PME
		WHERE
			PME.IdMes=@InIdMes AND
			PME.IdEmpleado=@InIdE;

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
	
CREATE PROCEDURE dbo.InsertarMovDeduccion
	@InIdMovimiento INT,
	@InIdDeduccionXEmpleado INT,
	@InIdSemanaXEmpleado INT,
	@InIdMes INT,
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SET @OutResultCode=0;
		INSERT INTO dbo.MovimientoDeduccion(Id,
											IdDeduccionXEmpleado)
		VALUES(@InIdMovimiento,
			   @InIdDeduccionXEmpleado)
		SELECT
			@InIdMes=PM.Id
		FROM
			dbo.PlanillaMensual PM,
			dbo.PlanillaSemanal PS,
			dbo.PlanillaSemanalXEmpleado PSX
		WHERE
			PM.Id=PS.IdMes AND
			PS.Id=PSX.IdSemana AND
			PSX.Id=@InIdSemanaXEmpleado;

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
	
CREATE PROCEDURE dbo.ActualizarPlanillaMensualXEmpleado
	@InMonto INT,
	@InIdE INT,
	@InIdMes INT,
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SET @OutResultCode=0;
		UPDATE
			dbo.PlanillaMensualXEmpleado
		SET
			SalarioNeto=SalarioNeto+@InMonto
		FROM
			dbo.PlanillaMensualXEmpleado PME,
			dbo.Empleado E
		WHERE
			PME.IdMes=@InIdMes AND
			PME.IdEmpleado=@InIdE AND
			E.Id=@InIdE AND
			E.Activo='1';

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