USE TareaProgramada;
GO

CREATE TRIGGER dbo.AsociarConDeduccion ON Empleado
AFTER INSERT
	AS
	DECLARE @IdEmpleado INT=(SELECT Id FROM inserted)
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
		BEGIN TRANSACTION TriggerEmpleado;
			INSERT INTO DeduccionXEmpleado(IdEmpleado,
										   IdTipoDeduccion,
										   Activo)
			SELECT
				E.Id AS IdEmpleado,
				TD.Id AS IdTipoDeduccion,
				'1' AS Activo
			FROM
				Empleado E,
				TipoDeduccion TD
			WHERE
				TD.Obligatorio='1' AND
				E.Id=@IdEmpleado;

			INSERT INTO dbo.PlanillaMensualXEmpleado(IdMes,
												    IdEmpleado,
												    SalarioNeto,
												    SalarioTotal)
			SELECT
				PM.Id AS IdMes,
				@IdEmpleado AS IdEmpleado,
				0 AS SalarioNeto,
				0 AS SalarioTotal
			FROM
				dbo.PlanillaMensual PM;

			INSERT INTO dbo.PlanillaSemanalXEmpleado(IdSemana,
													 IdEmpleado,
													 SalarioNeto)
			SELECT
				PS.Id AS IdSemana,
				@IdEmpleado AS IdEmpleado,
				0 AS SalarioNeto
			FROM
				dbo.PlanillaSemanal PS;
		COMMIT TRANSACTION TriggerEmpleado;
		END TRY
		BEGIN CATCH
			IF @@Trancount>0 
				ROLLBACK TRANSACTION TriggerEmpleado;
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