USE TareaProgramada
GO

CREATE PROCEDURE ListarUsuarios

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			SELECT Id,Username,Pwd FROM Empleado WHERE Empleado.Activo=1
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


CREATE PROCEDURE ListarSemana
	@InIdEmpleado INT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY

		--DECLARE @InIdEmpleado INT;
		--SET @InIdEmpleado=7

			CREATE TABLE #Temp (Id INT PRIMARY KEY,
				    TotalDeducciones INT, TotalHorasNormales INT,
					TotalHorasExtraNormales INT, TotalHorasExtraDobles INT,)
			INSERT INTO #Temp SELECT TOP 15 PS.Id AS Id, 0, 0, 0, 0
			FROM
				PlanillaSemanal PS
			ORDER BY
				PS.Id DESC;
			DECLARE
				@Cont INT, @LargoTabla INT;
			SELECT TOP 1  @Cont=T.Id FROM #Temp T ORDER BY T.Id ASC;
			SELECT @LargoTabla=COUNT(*) FROM #Temp
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
				--SELECT @Cont, @InIdEmpleado;
				UPDATE #Temp SET TotalDeducciones=@TotalDeducciones, TotalHorasNormales=@TotalHorasNormales,
				TotalHorasExtraNormales=@TotalHorasExtraNormales, TotalHorasExtraDobles=@TotalHorasExtraDobles
				WHERE #Temp.Id=@Cont;
				SET @Cont=@Cont+1;
			END

			SELECT TOP 15 PSM.Id, PSM.IdSemana, PSM.SalarioNeto,
			T.TotalDeducciones AS Deducciones, T.TotalHorasNormales AS HorasNormales,
			T.TotalHorasExtraNormales AS HorasExtraNormales, T.TotalHorasExtraDobles AS HorasExtraDobles,
			(T.TotalHorasNormales+T.TotalHorasExtraNormales+T.TotalHorasExtraDobles) AS SalarioBruto
			FROM
				PlanillaSemanalXEmpleado PSM, #Temp T
			WHERE
				PSM.IdEmpleado=@InIdEmpleado AND PSM.IdSemana=T.Id
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

--ListarSalarioSemana '8'

CREATE PROCEDURE ListarSalarioSemana
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

--EXECUTE ListarSemana '6'

---Recibe el Id del empleado, y devuelve los campos solicitados además del ID de
--PlanillaMensualXEmpleado, este no se muestra, solo se necesita para consultar en ListarDeduccionesMes
CREATE PROCEDURE ListarMes
	@InIdEmpleado INT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			DECLARE @TotalDeducciones INT;
			SELECT
				@TotalDeducciones=SUM(DEM.TotalDeducciones)
			FROM
				DeduccionXEmpleadoXMes DEM, PlanillaMensualXEmpleado PMXE
			WHERE
				DEM.IdPlanillaMensualXEmpleado=PMXE.Id AND PMXE.IdEmpleado=@InIdEmpleado;
			

			SELECT TOP 12
				PMXE.Id, PMXE.IdMes, PMXE.SalarioTotal, PMXE.SalarioNeto, @TotalDeducciones AS TotalDeducciones
			FROM
				PlanillaMensualXEmpleado PMXE, Empleado E
			WHERE
				PMXE.IdEmpleado=@InIdEmpleado AND E.Id=@InIdEmpleado AND E.Activo=1;
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

CREATE PROCEDURE ListarDeduccionesSemana
	@InIdPlanillaXEmpleado INT

	AS
	BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			DECLARE @InIdPlanillaXEmpleado INT;
			SET @InIdPlanillaXEmpleado=20;
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
CREATE PROCEDURE ListarDeduccionesMes
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

--EXECUTE ListarDeduccionesMes '17'

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