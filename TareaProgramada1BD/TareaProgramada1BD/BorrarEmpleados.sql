CREATE PROCEDURE BorrarEmpleados
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
					Set @OutResultCode=50001; --El empleado no existe
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
--EXECUTE BorrarEmpleados 'Id', @ResultCode
--SELECT @ResultCode