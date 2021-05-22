--SELECT EOMONTH( @mydate, -1 )
--SELECT EOMONTH( '2021-02-04')
--SELECT EOMONTH( @mydate, 1 )
USE TareaProgramada
GO

CREATE PROCEDURE InsertarMes
	@InFechaInicio DATE,
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
			SELECT
				@InFechaFinal=DATEADD(DAY,7,@InFechaInicio),  @InFechaTemporal=EOMONTH(@InFechaFinal), @Bandera='0';
				--@FechaFinal=DATEADD(DAY,7,'2021-02-04'), @FechaTemporal=EOMONTH(@FechaFinal), @Bandera='0';
			--PRINT(@InFechaFinal)
			INSERT INTO PlanillaSemanal VALUES (@InIdMes, @InFechaInicio, @InFechaFinal);
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
	END*/