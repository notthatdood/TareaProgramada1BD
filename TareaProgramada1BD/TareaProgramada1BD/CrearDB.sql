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
						FechaNacimiento date, Activo bit,
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