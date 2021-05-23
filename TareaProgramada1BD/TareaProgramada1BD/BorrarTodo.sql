--Drop database TareaProgramada;
Use TareaProgramada;
DECLARE @i int;
SET @i=0;
WHILE(@i<5)
BEGIN
	Drop table DBErrores;
	Drop table DeduccionXEmpleado;
	Drop table DeduccionXEmpleadoXMes;
	Drop table Departamento;
	Drop table Empleado;
	Drop table Feriados;
	Drop table MarcaAsistencia;
	Drop table MovimientoDeduccion;
	Drop table MovimientoHoras;
	Drop table MovimientoPlanilla;
	Drop table PlanillaMensual;
	Drop table PlanillaMensualXEmpleado;
	Drop table PlanillaSemanal;
	Drop table PlanillaSemanalXEmpleado;
	Drop table Puesto;
	Drop table TipoDeduccion;
	Drop table TipoDocuIdentidad;
	Drop table TipoMovimiento;
	Drop table TipoMovimientoDeduccion;
	Drop table TiposDeJornada;
	Drop table Usuario;
	Drop table PorcentualNoObligatoria;
	Drop table PorcentualSiObligatoria;
	Drop table FijaNoObligatoria;
	Drop table Jornada;
	SET @i=@i+1;
END