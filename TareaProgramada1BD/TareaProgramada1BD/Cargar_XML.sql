Use TareaProgramada;
Go

Create procedure insertarCatalogos as

Insert into Puesto

Select 

A.CatalogoXML.value('@Id','int') as Id,
A.CatalogoXML.value('@Nombre','varchar(40)') as Nombre,
A.CatalogoXML.value('@SalarioXHora','int') as SalarioXHora,
'1' as Activo

From
(
Select cast(CatalogoXML as xml) from
Openrowset(Bulk 'C:\Datos_Tarea2.xml', Single_Blob) T(CatalogoXML)
) as S(CatalogoXML)

Cross apply CatalogoXML.nodes('Datos/Catalogos/Puestos/Puesto') as A(CatalogoXML)

Insert into TipoDocuIdentidad

Select 

A.CatalogoXML.value('@Id','int') as Id,
A.CatalogoXML.value('@Nombre','varchar(40)') as Nombre
From
(
Select cast(CatalogoXML as xml) from
Openrowset(Bulk 'C:\Datos_Tarea2.xml', Single_Blob) T(CatalogoXML)
) as S(CatalogoXML)

Cross apply CatalogoXML.nodes('Datos/Catalogos/Tipos_de_Documento_de_Identificacion/TipoIdDoc') as A(CatalogoXML)

Insert into Departamento

Select 

A.CatalogoXML.value('@Id','int') as Id,
A.CatalogoXML.value('@Nombre','varchar(40)') as Nombre
From
(
Select cast(CatalogoXML as xml) from
Openrowset(Bulk 'C:\Datos_Tarea2.xml', Single_Blob) T(CatalogoXML)
) as S(CatalogoXML)

Cross apply CatalogoXML.nodes('Datos/Catalogos/Departamentos/Departamento') as A(CatalogoXML)

Insert into TiposDeJornada

Select 

A.CatalogoXML.value('@Id','int') as Id,
A.CatalogoXML.value('@Nombre','varchar(50)') as Nombre,
A.CatalogoXML.value('@HoraEntrada','time') as HoraEntrada,
A.CatalogoXML.value('@HoraSalida','time') as HoraSalida
From
(
Select cast(CatalogoXML as xml) from
Openrowset(Bulk 'C:\Datos_Tarea2.xml', Single_Blob) T(CatalogoXML)
) as S(CatalogoXML)

Cross apply CatalogoXML.nodes('Datos/Catalogos/TiposDeJornada/TipoDeJornada') as A(CatalogoXML)

Insert into TipoMovimiento

Select 

A.CatalogoXML.value('@Id','int') as Id,
A.CatalogoXML.value('@Nombre','varchar(50)') as Nombre
From
(
Select cast(CatalogoXML as xml) from
Openrowset(Bulk 'C:\Datos_Tarea2.xml', Single_Blob) T(CatalogoXML)
) as S(CatalogoXML)

Cross apply CatalogoXML.nodes('Datos/Catalogos/TiposDeMovimiento/TipoDeMovimiento') as A(CatalogoXML)

Insert into Feriados

Select 

A.CatalogoXML.value('@Fecha','date') as Fecha,
A.CatalogoXML.value('@Nombre','varchar(50)') as Nombre
From
(
Select cast(CatalogoXML as xml) from
Openrowset(Bulk 'C:\Datos_Tarea2.xml', Single_Blob) T(CatalogoXML)
) as S(CatalogoXML)

Cross apply CatalogoXML.nodes('Datos/Catalogos/Feriados/Feriado') as A(CatalogoXML)

Insert into TipoDeduccion

Select 

A.CatalogoXML.value('@Id','int') as Id,
A.CatalogoXML.value('@Nombre','varchar(50)') as Nombre,
case A.CatalogoXML.value('@Obligatorio','varchar(10)') WHEN  'Si' THEN 1 ELSE 0 END as Obligatorio,
case A.CatalogoXML.value('@Porcentual' ,'varchar(10)') WHEN  'Si' THEN 1 ELSE 0 END as Porcentual,
A.CatalogoXML.value('@Valor','decimal(3,3)') as Valor
From
(
Select cast(CatalogoXML as xml) from
Openrowset(Bulk 'C:\Datos_Tarea2.xml', Single_Blob) T(CatalogoXML)
) as S(CatalogoXML)

Cross apply CatalogoXML.nodes('Datos/Catalogos/Deducciones/TipoDeDeduccion') as A(CatalogoXML)

INSERT INTO PorcentualSiObligatoria SELECT TD.Id, TD.Valor
FROM TipoDeduccion TD WHERE TD.Obligatorio=1;
GO

/*Create procedure insertarEmpleado as

Insert into Empleado

Select 

A.EmpleadoXML.value('@Nombre','varchar(30)') as Nombre,
A.EmpleadoXML.value('@idTipoDocumentacionIdentidad','int') as IdTipoIdentificacion,
A.EmpleadoXML.value('@ValorDocumentoIdentidad','int') as ValorDocumentoIdentifacion,
A.EmpleadoXML.value('@IdDepartamento','int') as IdDepartamento,
A.EmpleadoXML.value('@idPuesto','int') as IdPuesto,
A.EmpleadoXML.value('@FechaNacimiento','date') as FechaNacimiento,
'1' as Activo
From
(
Select cast(EmpleadosXML as xml) from
Openrowset(Bulk 'C:\Datos_Tarea2.xml', Single_Blob) T(EmpleadosXML)
) as S(EmpleadosXML)

Cross apply EmpleadosXML.nodes('Datos/Empleados/Empleado') as A(EmpleadoXML)

GO*/

Create procedure insertarUsuario as

Insert into Usuario

Select 

A.UsuarioXML.value('@username','varchar(30)') as Username,
A.UsuarioXML.value('@pwd','varchar(30)') as Pwd,
A.UsuarioXML.value('@tipo','int') as Tipo

From
(
Select cast(UsuariosXML as xml) from
Openrowset(Bulk 'C:\Datos_Tarea2.xml', Single_Blob) T(UsuariosXML)
) as S(UsuariosXML)

Cross apply UsuariosXML.nodes('Datos/Usuarios/Usuario') as A(UsuarioXML)

GO

Execute insertarCatalogos
--Execute insertarEmpleado
Execute insertarUsuario