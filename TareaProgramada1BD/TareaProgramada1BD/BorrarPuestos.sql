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
--EXECUTE BorrarPuestos 'Id', @ResultCode
--SELECT @ResultCode