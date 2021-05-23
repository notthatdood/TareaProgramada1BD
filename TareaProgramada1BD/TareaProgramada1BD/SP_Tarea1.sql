Use TareaProgramada;
GO

/*CREATE PROCEDURE BorrarEmpleados
	@InEmpleadoId INT,
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SELECT
				@OutResultCode=0;
			IF NOT EXISTS(SELECT 1 FROM Empleado C WHERE C.Id=@InEmpleadoId)
			OR EXISTS(SELECT 1 FROM Empleado C WHERE C.Id=@InEmpleadoId AND Activo='0')
				BEGIN
					SET @OutResultCode=50001; --El empleado no existe
					RETURN
				END;
			UPDATE Empleado
			SET Activo='0'
			WHERE Id=@InEmpleadoId
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

--DECLARE @ResultCode INT
--EXECUTE BorrarEmpleados 'Id', @ResultCode OUTPUT
--SELECT @ResultCode
GO*/

CREATE PROCEDURE BorrarPuestos
	@InPuestoId INT,
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SELECT
				@OutResultCode=0;
			IF NOT EXISTS(SELECT 1 FROM Puesto C WHERE C.Id=@InPuestoId)
			OR EXISTS(SELECT 1 FROM Puesto C WHERE C.Id=@InPuestoId AND Activo='0')
				BEGIN
					Set @OutResultCode=50001; --El puesto no existe
					RETURN
				END;
			UPDATE Puesto
			SET Activo='0'
			WHERE Id=@InPuestoId
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

--DECLARE @ResultCode INT
--EXECUTE BorrarPuestos 'Id', @ResultCode OUTPUT
--SELECT @ResultCode
GO

CREATE PROCEDURE EditarEmpleados
	@InEmpleadoId INT,
	@InEmpleadoNombre VARCHAR(50),
	@InEmpleadoIdTipoIdentificacion INT,
	@InEmpleadoValorDocumentoIdentificacion INT,
	@InEmpleadoFechaNacimiento DATE,
	@InEmpleadoIdPuesto INT,
	@InEmpleadoIdDepartamento INT,
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SELECT
				@OutResultCode=0;
			IF NOT EXISTS(SELECT 1 FROM Empleado C WHERE C.Id=@InEmpleadoId)
			OR EXISTS(SELECT 1 FROM Empleado C WHERE C.Id=@InEmpleadoId AND Activo='0')
				BEGIN
					SET @OutResultCode=50001; --El empleado no existe
					RETURN
				END;
			UPDATE Empleado
			SET Nombre=@InEmpleadoNombre, IdTipoIdentificacion=@InEmpleadoIdTipoIdentificacion,
			ValorDocumentoIdentificacion=@InEmpleadoValorDocumentoIdentificacion,
			FechaNacimiento=@InEmpleadoFechaNacimiento,
			IdPuesto=@InEmpleadoIdPuesto, IdDepartamento=@InEmpleadoIdDepartamento
			WHERE Id=@InEmpleadoId and Activo='1'
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

--DECLARE @ResultCode INT
--EXECUTE EditarEmpleados 'Id', 'Nombre', 'TipoIdentificacion',
--'ValorDocIdentificacion', 'FechaNacimiento', 'IdPuesto', 'IdDepartamento', @ResultCode OUTPUT
--SELECT @ResultCode
GO

CREATE PROCEDURE EditarPuestos
	@InPuestoId INT,
	@InPuestoNombre varchar(40),
	@InPuestoSalarioXHora INT,
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SELECT
				@OutResultCode=0;
			IF NOT EXISTS(SELECT 1 FROM Puesto C WHERE C.Id=@InPuestoId)
			OR EXISTS(SELECT 1 FROM Puesto C WHERE C.Id=@InPuestoId AND Activo='0')
				BEGIN
					Set @OutResultCode=50001; --El puesto no existe
					RETURN
				END;
			UPDATE Puesto
			SET Nombre=@InPuestoNombre, SalarioXHora=@InPuestoSalarioXHora
			WHERE Id=@InPuestoId and Activo='1'
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

--DECLARE @ResultCode INT
--EXECUTE EditarPuestos 'Id', 'Nombre', 'SalarioXHora', @ResultCode OUTPUT
--SELECT @ResultCode
GO

CREATE PROCEDURE InsertarPuestos
	@InPuestoId INT,
	@InPuestoNombre varchar(40),
	@InPuestoSalarioXHora INT,
	@OutResultCode INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SET @OutResultCode=0;
			INSERT INTO Puesto
			VALUES(@InPuestoId, @InPuestoNombre, @InPuestoSalarioXHora,'1')
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

--DECLARE @ResultCode INT
--EXECUTE InsertarPuestos 'Id', 'Nombre', 'SalarioXHora', @ResultCode OUTPUT
--SELECT @ResultCode
GO

CREATE PROCEDURE ListarDepartamento

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SELECT * FROM Departamento ORDER BY Id
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
		END CATCH
		SET NOCOUNT OFF;
	END

--EXECUTE ListarDepartamento
GO

CREATE PROCEDURE ListarEmpleados

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SELECT Nombre,IdPuesto FROM Empleado WHERE Activo=1 ORDER BY Nombre
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
		END CATCH
		SET NOCOUNT OFF;
	END

--EXECUTE ListarEmpleados
GO

CREATE PROCEDURE ListarPuestos

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SELECT * FROM Puesto WHERE Activo=1 ORDER BY Id
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
		END CATCH
		SET NOCOUNT OFF;
	END

--EXECUTE ListarPuestos
GO

CREATE PROCEDURE ListarTarjetas

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SELECT * FROM TipoDocuIdentidad ORDER BY Id
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
		END CATCH
		SET NOCOUNT OFF;
	END

--EXECUTE ListarTarjetas
GO