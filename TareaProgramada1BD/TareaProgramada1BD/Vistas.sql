USE TareaProgramada
GO

CREATE VIEW
	Vista
AS SELECT
	PM.Id AS Mes,
	D.Nombre AS Departamento,
	SUM(PSE.SalarioNeto) AS TotalSalario,
	SUM(DEM.TotalDeducciones) AS TotalDeducciones,
	E.Nombre AS SalarioMasAlto
FROM
	dbo.PlanillaMensual PM,
	dbo.Departamento D,
	dbo.PlanillaMensualXEmpleado PSE,
	dbo.Empleado E,
	dbo.DeduccionXEmpleadoXMes DEM
WHERE
	PM.Id>=1 AND PM.Id<=7 AND
	PSE.IdEmpleado=E.Id AND
	E.IdDepartamento=D.Id AND
	DEM.IdPlanillaMensualXEmpleado=PSE.Id AND
	E.Nombre=(SELECT TOP 1
				E2.Nombre
			FROM
				dbo.Empleado E2,
				dbo.PlanillaMensualXEmpleado PME,
				dbo.Departamento D2
			WHERE
				PME.IdEmpleado=E2.Id AND
				D2.Id=D.Id AND
				PME.Id=PSE.Id 
			ORDER BY
				PME.SalarioTotal)
GROUP BY
	PM.Id, D.Nombre, E.Nombre;
GO

SELECT V.Mes,
	   V.Departamento,
	   V.TotalSalario,
	   V.TotalDeducciones,
	   V.SalarioMasAlto
FROM
	   Vista V
ORDER BY 
	   V.Mes;
GO