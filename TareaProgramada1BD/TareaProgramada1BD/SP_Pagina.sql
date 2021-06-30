USE TareaProgramada
GO

CREATE PROCEDURE dbo.ListarUsuarios2

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SELECT E.Id, E.Username, E.Pwd FROM Empleado E WHERE E.Activo=1
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

CREATE PROCEDURE dbo.ListarEmpleados

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SELECT
				E.Id, E.Nombre, E.IdTipoIdentificacion, E.ValorDocumentoIdentificacion,
				D.Nombre AS Departamento , P.Nombre AS Puesto , E.FechaNacimiento
			FROM
				Empleado E, Departamento D, Puesto P
			WHERE
				E.Activo=1 AND E.IdPuesto=P.Id AND E.IdDepartamento=D.Id
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


CREATE PROCEDURE dbo.ListarUsuarios

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SELECT
				U.Username, U.Pwd
			FROM
				Usuario U
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

--EXECUTE ListarEmpleados
--ListarUsuarios
--EXECUTE ListarSemana 10

CREATE PROCEDURE dbo.ListarSemana
	@InIdEmpleado INT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY

		--DECLARE @InIdEmpleado INT;
		--SET @InIdEmpleado=10

			CREATE TABLE #Temp (Id INT IDENTITY(1,1) PRIMARY KEY, IdSemana INT,
				    TotalDeducciones INT, TotalHorasNormales INT,
					TotalHorasExtraNormales INT, TotalHorasExtraDobles INT)
			INSERT INTO #Temp SELECT TOP 15 PS.Id AS IdSemana, 0, 0, 0, 0
			FROM
				PlanillaSemanal PS
			ORDER BY
				PS.Id DESC;
			DECLARE
				@Cont INT, @LargoTabla INT;
			SELECT TOP 1  @Cont=T.Id FROM #Temp T ORDER BY T.Id DESC;
			SELECT @LargoTabla=COUNT(*) FROM #Temp
			SELECT @Cont=1;
			WHILE(@Cont<=@LargoTabla)
			BEGIN
				DECLARE @TotalDeducciones INT, @TotalHorasNormales INT,
				@TotalHorasExtraNormales INT, @TotalHorasExtraDobles INT;
				SELECT
					@TotalDeducciones=SUM(MP.Monto)
				FROM
					MovimientoPlanilla MP, PlanillaSemanalXEmpleado PSXE
				WHERE
					MP.IdSemana=PSXE.Id AND PSXE.IdEmpleado=@InIdEmpleado AND
					(MP.TipoMovimiento=4 OR MP.TipoMovimiento=5) AND PSXE.IdSemana=@Cont;
				IF(@TotalDeducciones IS NULL)
				BEGIN
					 SET @TotalDeducciones=0;
				END

				SELECT
					@TotalHorasNormales=SUM(MP.Monto)
				FROM
					MovimientoPlanilla MP, PlanillaSemanalXEmpleado PSXE
				WHERE
					MP.IdSemana=PSXE.Id AND PSXE.IdEmpleado=@InIdEmpleado AND
					MP.TipoMovimiento=1 AND PSXE.IdSemana=@Cont;
				IF(@TotalHorasNormales IS NULL)
				BEGIN
					 SET @TotalHorasNormales=0;
				END

				SELECT
					@TotalHorasExtraNormales=SUM(MP.Monto)
				FROM
					MovimientoPlanilla MP, PlanillaSemanalXEmpleado PSXE
				WHERE
					MP.IdSemana=PSXE.Id AND PSXE.IdEmpleado=@InIdEmpleado AND
					MP.TipoMovimiento=2 AND PSXE.IdSemana=@Cont;
				IF(@TotalHorasExtraNormales IS NULL)
				BEGIN
					 SET @TotalHorasExtraNormales=0;
				END

				SELECT
					@TotalHorasExtraDobles=SUM(MP.Monto)
				FROM
					MovimientoPlanilla MP, PlanillaSemanalXEmpleado PSXE
				WHERE
					MP.IdSemana=PSXE.Id AND PSXE.IdEmpleado=@InIdEmpleado AND
					MP.TipoMovimiento=3 AND PSXE.IdSemana=@Cont;

					
				IF(@TotalHorasExtraDobles IS NULL)
				BEGIN
					SET @TotalHorasExtraDobles=0;
				END

				--SELECT @TotalDeducciones, @TotalHorasNormales, @TotalHorasExtraNormales, @TotalHorasExtraDobles;
				--SELECT @Cont, @LargoTabla;
				UPDATE #Temp SET TotalDeducciones=@TotalDeducciones, TotalHorasNormales=@TotalHorasNormales,
				TotalHorasExtraNormales=@TotalHorasExtraNormales, TotalHorasExtraDobles=@TotalHorasExtraDobles
				WHERE #Temp.Id=@Cont;
				--SELECT T.TotalDeducciones, FROM #Temp T
				SET @Cont=@Cont+1;
			END
			

			SELECT TOP 15 PSM.Id, PSM.IdSemana, PSM.SalarioNeto,
			T.TotalDeducciones AS Deducciones, T.TotalHorasNormales AS HorasNormales,
			T.TotalHorasExtraNormales AS HorasExtraNormales, T.TotalHorasExtraDobles AS HorasExtraDobles,
			(T.TotalHorasNormales+T.TotalHorasExtraNormales+T.TotalHorasExtraDobles) AS SalarioBruto
			FROM
				PlanillaSemanalXEmpleado PSM, #Temp T
			WHERE
				PSM.IdEmpleado=@InIdEmpleado AND PSM.IdSemana=T.IdSemana
			DROP TABLE #Temp
			
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
GO

--EXECUTE ListarSalarioSemana '10'

CREATE PROCEDURE dbo.ListarSalarioSemana
	@InIdPlanillaXEmpleado INT
	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			/*DECLARE @InIdPlanillaXEmpleado INT;
			SET @InIdPlanillaXEmpleado=8;*/
			SELECT
				DATEPART(dw, CONVERT(DATE, MA.FechaEntrada)) 'DiaDeLaSemana',
				CONVERT(TIME, MA.FechaEntrada) 'FechaDeEntrada',
				CONVERT(TIME, MA.FechaSalida) 'FechaDeSalida',
				DATEDIFF(hh,TJ.HoraEntrada, TJ.HoraSalida) 'HorasOrdinarias',
				DATEDIFF(hh,MA.FechaEntrada, MA.FechaSalida)-DATEDIFF(hh,TJ.HoraEntrada, TJ.HoraSalida) 'HorasExtra',
				/*SUM(MP.Monto)*/ MP.Monto 'TotalGanado', CASE TM.Id WHEN 3 THEN 1 ELSE 0 END 'EsDoble' 
			FROM
				PlanillaSemanalXEmpleado PSE, Jornada J, TiposDeJornada TJ, MarcaAsistencia MA,
				MovimientoHoras MH, MovimientoPlanilla MP, TipoMovimiento TM
			WHERE
				PSE.Id=@InIdPlanillaXEmpleado AND J.IdSemana=PSE.IdSemana
				AND J.IdEmpleado=PSE.IdEmpleado AND/**/ J.TipoJornada=TJ.Id AND MA.IdJornada=J.Id
				AND MH.IdMarcaAsistencia=MA.Id AND MH.Id=MP.Id AND TM.Id=MP.TipoMovimiento --AND
				--(TM.Id=2 OR TM.Id=3)
			/*GROUP BY
				DATEPART(dw, CONVERT(DATE, MA.FechaEntrada)), CONVERT(TIME, MA.FechaEntrada),
				CONVERT(TIME, MA.FechaSalida),
				DATEDIFF(hh,TJ.HoraEntrada, TJ.HoraSalida),
				DATEDIFF(hh,MA.FechaEntrada, MA.FechaSalida)-DATEDIFF(hh,TJ.HoraEntrada, TJ.HoraSalida),
				TM.Id*/
			
			
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
GO

--EXECUTE ListarSemana '10'

---Recibe el Id del empleado, y devuelve los campos solicitados además del ID de
--PlanillaMensualXEmpleado, este no se muestra, solo se necesita para consultar en ListarDeduccionesMes
CREATE PROCEDURE dbo.ListarMes
	@InIdEmpleado INT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			/*DECLARE @InIdEmpleado INT;
			SET @InIdEmpleado=8*/

			SELECT TOP 12
				PMXE.Id, PMXE.IdMes, PMXE.SalarioNeto+SUM(DEM.TotalDeducciones) 'SalarioTotal', PMXE.SalarioNeto, SUM(DEM.TotalDeducciones) AS TotalDeducciones
			FROM
				PlanillaMensualXEmpleado PMXE,
				Empleado E, DeduccionXEmpleadoXMes DEM
			WHERE
				PMXE.IdEmpleado=@InIdEmpleado AND E.Id=@InIdEmpleado AND E.Activo=1 AND
				DEM.IdPlanillaMensualXEmpleado=PMXE.Id
			GROUP BY
				PMXE.Id, PMXE.IdMes, PMXE.SalarioNeto;
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
GO

--EXEC ListarMes'10'
--EXEC ListarDeduccionesSemana '10'

CREATE PROCEDURE dbo.ListarDeduccionesSemana
	@InIdPlanillaXEmpleado INT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			/*DECLARE @InIdPlanillaXEmpleado INT;
			SET @InIdPlanillaXEmpleado=14;*/
			SELECT
				TD.Nombre, TD.Valor, TD.Porcentual, MP.Monto
			FROM
				TipoDeduccion TD, MovimientoPlanilla MP, MovimientoDeduccion MD, DeduccionXEmpleado DXE,
				TipoMovimiento TM, TipoMovimientoDeduccion TMD
			WHERE
				MP.IdSemana=@InIdPlanillaXEmpleado AND MD.Id=MP.Id AND MD.IdDeduccionXEmpleado=DXE.Id
				AND MP.TipoMovimiento=TM.Id AND TM.Id=TMD.IdMovimiento AND TMD.IdDeduccion=TD.Id

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
GO

--EXECUTE ListarMes '7'

---Recibe el Id de la PlanillaMensualXEmpleado, y devuelve el nombre de la deduccion, el valor(Si no
--es porcentual será 0), si es porcentual y el monto que dedujo
CREATE PROCEDURE dbo.ListarDeduccionesMes
	@InIdPlanillaMensualXEmpleado INT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SELECT
				TD.Nombre, TD.Valor, TD.Porcentual, DEM.TotalDeducciones
			FROM
				TipoDeduccion TD, DeduccionXEmpleadoXMes DEM
			WHERE
				DEM.IdTipoDeduccion=TD.Id AND DEM.IdPlanillaMensualXEmpleado=@InIdPlanillaMensualXEmpleado
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
GO
--ListarDeducciones
--Drop Procedure ListarDeducciones

CREATE PROCEDURE ListarDeducciones

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SELECT TD.Id, TD.Nombre FROM TipoDeduccion TD WHERE TD.Obligatorio=0
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
GO

CREATE PROCEDURE ListarFINAL

	AS
	BEGIN
			SELECT * FROM HistorialPagina;
		
	END
GO

--Drop Procedure InsertarDeducciones
--EXECUTE InsertarDeducciones 10, 'Ahorro de Vivienda'
CREATE PROCEDURE InsertarDeducciones
	@InIdEmpleado INT,
	@InTipoDeduccionName VARCHAR(50)

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
		INSERT INTO HistorialPagina(Texto, Fecha)
			VALUES ('Anadida deduccion para el empleado: '+convert(varchar, @InIdEmpleado)+
			' esta consiste en: '+@InTipoDeduccionName,
			GETDATE())

		DECLARE @InTipoDeduccion INT;
		SELECT @InTipoDeduccion=TD.Id FROM TipoDeduccion TD WHERE TD.Nombre=@InTipoDeduccionName;
			INSERT INTO DeduccionXEmpleado(IdEmpleado, IdTipoDeduccion, Activo)
			VALUES(@InIdEmpleado, @InTipoDeduccion, '1')
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
GO
--Drop Procedure ListarDeducciones2
--EXECUTE ListarDeducciones2
CREATE PROCEDURE ListarDeducciones2
	--@InIdEmpleado INT

	AS
	BEGIN
	DECLARE @InIdEmpleado INT;
	SET @InIdEmpleado=60;
		SET NOCOUNT ON;
		SELECT DXE.Id, DXE.IdEmpleado, TD.Nombre FROM DeduccionXEmpleado DXE, TipoDeduccion TD
		WHERE DXE.IdEmpleado=@InIdEmpleado AND 
		DXE.Activo=1 AND TD.Id=DXE.IdTipoDeduccion
		AND TD.Obligatorio=0
	END
GO

--Drop Procedure EliminarDeducciones
--EXECUTE EliminarDeducciones '9', 'Ahorro Navidenno'
--SELECT * FROM DeduccionXEmpleado DXE WHERE DXE.IdEmpleado=60;
/*Update DeduccionXEmpleado SET Activo=1 WHERE DeduccionXEmpleado.IdEmpleado=60 AND
	DeduccionXEmpleado.IdTipoDeduccion=7;*/
CREATE PROCEDURE EliminarDeducciones
	@InIdEmpleado2 INT,
	@Nombre VARCHAR(50)

	AS
	BEGIN
	INSERT INTO HistorialPagina(Texto, Fecha)
			VALUES ('Eliminada deduccion para el empleado: '+convert(varchar, @InIdEmpleado2)+
			' esta consistia en: '+@Nombre,
			GETDATE())

	DECLARE @NameTP INT, @InIdEmpleado INT;
	SELECT @NameTP=TD.Id FROM TipoDeduccion TD WHERE TD.Nombre=@Nombre;
	SET @InIdEmpleado=60;
	Update DeduccionXEmpleado SET Activo=0 WHERE DeduccionXEmpleado.IdEmpleado=@InIdEmpleado AND
	DeduccionXEmpleado.IdTipoDeduccion=@NameTP;
	END
GO
--DROP PRocedure ListarDeduccionesMes

--EXECUTE ListarDeduccionesMes '20'

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

