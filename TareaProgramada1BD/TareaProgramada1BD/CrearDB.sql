Create database TareaProgramada
GO

Use TareaProgramada
GO

Create table Puesto ( Id int PRIMARY KEY,
					  Nombre varchar(40),
					  SalarioXHora int,
					  Activo bit)
GO

Create table Departamento ( Id int PRIMARY KEY,
							Nombre varchar(40))
GO

Create table TipoDocuIdentidad ( Id int PRIMARY KEY,
								 Nombre varchar(40))
GO

Create table Empleado ( Id int IDENTITY(1,1) PRIMARY KEY,
					    Nombre varchar(50),
					    IdTipoIdentificacion int,
						ValorDocumentoIdentificacion int, 
						IdDepartamento int, IdPuesto int,
						FechaNacimiento date, Username varchar(30),
						Pwd varchar(30), Activo bit,
						FOREIGN KEY (IdTipoIdentificacion) REFERENCES TipoDocuIdentidad (Id),
						FOREIGN KEY (IdPuesto) REFERENCES Puesto (Id),
						FOREIGN KEY (IdDepartamento) REFERENCES Departamento (Id))
GO

Create table Usuario ( Username varchar(30) PRIMARY KEY,
					   Pwd varchar(30),
					   Tipo int)

GO

Create table DBErrores
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

Create table TipoDeduccion ( Id int PRIMARY KEY,
					    Nombre varchar(50),
					    Obligatorio bit,
						Porcentual bit,
						Valor decimal(2,2))
GO

Create table TipoMovimiento ( Id int PRIMARY KEY,
					    Nombre varchar(50))
GO

Create table TipoMovimientoDeduccion ( IdMovimiento int,
					    IdDeduccion int,
						FOREIGN KEY (IdMovimiento) REFERENCES TipoMovimiento (Id),
						FOREIGN KEY (IdDeduccion) REFERENCES TipoDeduccion (Id))
GO

Create table Feriados ( Fecha date,
					    Nombre varchar(50))
GO

Create table TiposDeJornada ( Id int PRIMARY KEY,
						Nombre varchar(50),
						HoraEntrada time,
						HoraSalida time)
GO

Create table PlanillaMensual ( Id int IDENTITY(1,1) PRIMARY KEY,
						FechaInicio date,
						FechaFinal date)
GO

Create table PlanillaSemanal ( Id int IDENTITY(1,1) PRIMARY KEY,
						IdMes int,
						FechaInicio date,
						FechaFinal date,
						FOREIGN KEY (IdMes) REFERENCES PlanillaMensual (Id))
GO

Create table PlanillaSemanalXEmpleado ( IdSemana int,
						IdEmpleado int,
						SalarioNeto int,
						TipoJornada int,
						FOREIGN KEY (IdSemana) REFERENCES PlanillaSemanal (Id),
						FOREIGN KEY (IdEmpleado) REFERENCES Empleado (Id),
						FOREIGN KEY (TipoJornada) REFERENCES TiposDeJornada (Id))
GO

Create table PlanillaMensualXEmpleado ( IdMes int,
						IdEmpleado int,
						SalarioNeto int,
						SalarioTotal int,
						FOREIGN KEY (IdMes) REFERENCES PlanillaMensual (Id),
						FOREIGN KEY (IdEmpleado) REFERENCES Empleado (Id))
GO

Create table MovimientoPlanilla ( Id int IDENTITY(1,1) PRIMARY KEY,
						Fecha date,
						Monto int,
						IdSemana int,
						FOREIGN KEY (IdSemana) REFERENCES PlanillaSemanal (Id))
GO

Create table MovimientoHoras ( Id int primary key,
						FOREIGN KEY (Id) REFERENCES MovimientoPlanilla (Id))
GO

Create table MovimientoDeduccion ( Id int primary key,
						FOREIGN KEY (Id) REFERENCES MovimientoPlanilla (Id))
GO

Create table MarcaAsistencia ( IdMovimiento int primary key,
						IdEmpleado int,
						ValorDocIdentidad int,
						FechaEntrada datetime,
						FechaSalida datetime,
						FOREIGN KEY (IdEmpleado) REFERENCES Empleado (Id),
						FOREIGN KEY (IdMovimiento) REFERENCES MovimientoHoras (Id))
GO

Create table DeduccionXEmpleado ( IdMovimiento int primary key,
						IdEmpleado int,
						ValorDocIdentidad int,
						Nombre varchar(50),
					    Obligatorio bit,
						Porcentual bit,
						Valor decimal(2,2)
						FOREIGN KEY (IdEmpleado) REFERENCES Empleado (Id),
						FOREIGN KEY (IdMovimiento) REFERENCES MovimientoDeduccion (Id))
GO

Create table DeduccionXEmpleadoXMes ( Id int primary key,
						IdEmpleado int,
						TotalDeducciones int,
						FOREIGN KEY (IdEmpleado) REFERENCES Empleado (Id),
						FOREIGN KEY (Id) REFERENCES PlanillaMensual (Id))
GO