CREATE DATABASE TareaProgramada
GO

USE TareaProgramada
GO

CREATE TABLE Puesto ( Id INT PRIMARY KEY,
					  Nombre VARCHAR(40),
					  SalarioXHora INT,
					  Activo BIT)
GO

CREATE TABLE Departamento ( Id INT PRIMARY KEY,
							Nombre VARCHAR(40))
GO

CREATE TABLE TipoDocuIdentidad ( Id INT PRIMARY KEY,
								 Nombre VARCHAR(40))
GO

CREATE TABLE Empleado ( Id INT IDENTITY(1,1) PRIMARY KEY,
					    Nombre VARCHAR(50),
					    IdTipoIdentificacion INT,
						ValorDocumentoIdentificacion INT, 
						IdDepartamento INT, IdPuesto INT,
						FechaNacimiento DATE, Username VARCHAR(30),
						Pwd VARCHAR(30), Activo BIT,
						FOREIGN KEY (IdTipoIdentificacion) REFERENCES TipoDocuIdentidad (Id),
						FOREIGN KEY (IdPuesto) REFERENCES Puesto (Id),
						FOREIGN KEY (IdDepartamento) REFERENCES Departamento (Id))
GO

CREATE TABLE Usuario ( Username VARCHAR(30) PRIMARY KEY,
					   Pwd VARCHAR(30),
					   Tipo INT)

GO

CREATE TABLE DBErrores
         (ErrorID        INT IDENTITY(1, 1),
          UserName       VARCHAR(100),
          ErrorNumber    INT,
          ErrorState     INT,
          ErrorSeverity  INT,
          ErrorLine      INT,
          ErrorProcedure VARCHAR(MAX),
          ErrorMessage   VARCHAR(MAX),
          ErrorDateTime  DATETIME)
GO

CREATE TABLE TipoDeduccion ( Id INT PRIMARY KEY,
					    Nombre VARCHAR(50),
					    Obligatorio BIT,
						Porcentual BIT,
						Valor DECIMAL(3,3))
GO

CREATE TABLE TipoMovimiento ( Id INT PRIMARY KEY,
					    Nombre VARCHAR(50))
GO

CREATE TABLE TipoMovimientoDeduccion ( IdMovimiento INT, IdDeduccion INT,
						FOREIGN KEY (IdMovimiento) REFERENCES TipoMovimiento (Id),
						FOREIGN KEY (IdDeduccion) REFERENCES TipoDeduccion (Id))
GO

CREATE TABLE Feriados ( Fecha DATE,
					    Nombre VARCHAR(50))
GO

CREATE TABLE TiposDeJornada ( Id INT PRIMARY KEY,
						Nombre VARCHAR(50),
						HoraEntrada TIME,
						HoraSalida TIME)
GO

CREATE TABLE PlanillaMensual ( Id INT IDENTITY(1,1) PRIMARY KEY,
						FechaInicio DATE,
						FechaFinal DATE)
GO

CREATE TABLE PlanillaSemanal ( Id INT IDENTITY(1,1) PRIMARY KEY, IdMes INT,
						FechaInicio DATE, FechaFinal DATE,
						FOREIGN KEY (IdMes) REFERENCES PlanillaMensual (Id))
GO

CREATE TABLE Jornada ( Id INT IDENTITY(1,1) PRIMARY KEY,
						IdEmpleado INT, TipoJornada INT, IdSemana INT,
						FOREIGN KEY (IdEmpleado) REFERENCES Empleado (Id),
						FOREIGN KEY (TipoJornada) REFERENCES TiposDeJornada (Id),
						FOREIGN KEY (IdSemana) REFERENCES PlanillaSemanal (Id))
GO

CREATE TABLE PlanillaSemanalXEmpleado ( Id INT IDENTITY(1,1) PRIMARY KEY,
						IdSemana INT, IdEmpleado INT, SalarioNeto INT,
						FOREIGN KEY (IdSemana) REFERENCES PlanillaSemanal (Id),
						FOREIGN KEY (IdEmpleado) REFERENCES Empleado (Id),)
GO



CREATE TABLE PlanillaMensualXEmpleado ( Id INT IDENTITY(1,1) PRIMARY KEY,
						IdMes INT, IdEmpleado INT,
						SalarioNeto INT, SalarioTotal INT,
						FOREIGN KEY (IdMes) REFERENCES PlanillaMensual (Id),
						FOREIGN KEY (IdEmpleado) REFERENCES Empleado (Id))
GO

CREATE TABLE MovimientoPlanilla ( Id INT IDENTITY(1,1) PRIMARY KEY,
						Fecha DATE, Monto INT, IdSemana INT, TipoMovimiento INT,
						FOREIGN KEY (IdSemana) REFERENCES PlanillaSemanalXEmpleado (Id),
						FOREIGN KEY (TipoMovimiento) REFERENCES TipoMovimiento (Id))
GO

CREATE TABLE MarcaAsistencia ( Id INT IDENTITY(1,1) PRIMARY KEY,
						IdJornada INT, FechaEntrada DATETIME, FechaSalida DATETIME,
						FOREIGN KEY (IdJornada) REFERENCES Jornada (Id))
GO

CREATE TABLE MovimientoHoras ( Id INT PRIMARY KEY, IdMarcaAsistencia INT,
						FOREIGN KEY (Id) REFERENCES MovimientoPlanilla (Id),
						FOREIGN KEY (IdMarcaAsistencia) REFERENCES MarcaAsistencia (Id))
GO

CREATE TABLE DeduccionXEmpleado ( Id INT IDENTITY(1,1) PRIMARY KEY,
						IdEmpleado INT, IdTipoDeduccion INT, Activo BIT,
						FOREIGN KEY (IdEmpleado) REFERENCES Empleado (Id),
						FOREIGN KEY (IdTipoDeduccion) REFERENCES TipoDeduccion (Id))
GO

CREATE TABLE MovimientoDeduccion ( Id INT PRIMARY KEY,
						IdDeduccionXEmpleado INT,
						FOREIGN KEY (Id) REFERENCES MovimientoPlanilla (Id),
						FOREIGN KEY (IdDeduccionXEmpleado) REFERENCES DeduccionXEmpleado (Id))
GO

CREATE TABLE FijaNoObligatoria ( IdDeduccionXEmpleado INT, Monto INT,
						FOREIGN KEY (IdDeduccionXEmpleado) REFERENCES DeduccionXEmpleado (Id))
GO

CREATE TABLE PorcentualNoObligatoria ( IdDeduccionXEmpleado INT, Porcentaje DECIMAL(3,3),
						FOREIGN KEY (IdDeduccionXEmpleado) REFERENCES DeduccionXEmpleado (Id))
GO

CREATE TABLE PorcentualSiObligatoria ( IdTipoDeduccion INT, Porcentaje DECIMAL(3,3),
						FOREIGN KEY (IdTipoDeduccion) REFERENCES TipoDeduccion (Id))
GO

CREATE TABLE DeduccionXEmpleadoXMes ( Id INT IDENTITY(1,1) PRIMARY KEY,
						IdPlanillaMensualXEmpleado INT,
						TotalDeducciones INT, IdTipoDeduccion INT,
						FOREIGN KEY (IdTipoDeduccion) REFERENCES TipoDeduccion (Id),
						FOREIGN KEY (IdPlanillaMensualXEmpleado) REFERENCES PlanillaMensualXEmpleado (Id))
GO

CREATE TABLE Corrida ( Id INT IDENTITY(1,1) PRIMARY KEY
					,FechaOperacion DATE
					,TipoRegistro INT
					,PostTime DATETIME
					)
GO

CREATE TABLE TipoOperacion (Id INT IDENTITY (1,1) PRIMARY KEY
							,Nombre VARCHAR(30)) 
GO

CREATE TABLE DetalleCorrida (Id INT IDENTITY (1,1) PRIMARY KEY
							,IdCorrida INT
							,TipoOperacionXML INT
							,RefID INT
							,FOREIGN KEY (IdCorrida) REFERENCES Corrida (Id)
							,FOREIGN KEY (TipoOperacionXML) REFERENCES TipoOperacion (Id)) 
GO

CREATE TABLE Bitacora (Id INT IDENTITY (1,1) PRIMARY KEY,
						IdTipoOperacion INT,
						Texto VARCHAR(100),
						Fecha DATE,
						FOREIGN KEY (IdTipoOperacion) REFERENCES TipoOperacion (Id))