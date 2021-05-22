USE TareaProgramada;
GO

CREATE TRIGGER AsociarConDeduccion ON Empleado
AFTER INSERT
	AS
	DECLARE @IdEmpleado INT=(SELECT Id FROM inserted)
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			INSERT INTO DeduccionXEmpleado SELECT E.Id, TD.Id
			FROM Empleado E, TipoDeduccion TD WHERE TD.Obligatorio='1' AND E.Id=@IdEmpleado;
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
	
/*DECLARE @ResultCode INT
EXECUTE InsertarEmpleados 'Mario Ferrer Calvo', '2', '92500121', '1998-02-24', '10',
'4', 'MFerrer', '6512', @ResultCode OUTPUT
SELECT @ResultCode*/