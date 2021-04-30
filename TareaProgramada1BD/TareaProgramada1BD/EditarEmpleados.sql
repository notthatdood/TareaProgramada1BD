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
					Set @OutResultCode=50001; --El empleado no existe
					RETURN
				END;
			UPDATE Empleado
			SET Nombre=@InEmpleadoNombre, IdTipoIdentificacion=@InEmpleadoIdTipoIdentificacion,
			ValorDocumentoIdentificacion=@InEmpleadoValorDocumentoIdentificacion,
			FechaNacimiento=@InEmpleadoIdDepartamento,
			IdPuesto=@InEmpleadoIdPuesto, IdDepartamento=@InEmpleadoIdDepartamento
			WHERE Id=@InEmpleadoId and Activo='1'
		END TRY
		BEGIN CATCH
			INSERT INTO DBErrores values (
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
--'ValorDocIdentificacion', 'FechaNacimiento', 'IdPuesto', 'IdDepartamento', @ResultCode
--SELECT @ResultCode
