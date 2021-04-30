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
Openrowset(Bulk 'C:\CatalogoFinal.xml', Single_Blob) T(CatalogoXML)
) as S(CatalogoXML)

Cross apply CatalogoXML.nodes('Datos/Catalogos/Puestos/Puesto') as A(CatalogoXML)

Insert into TipoDocuIdentidad

Select 

A.CatalogoXML.value('@Id','int') as Id,
A.CatalogoXML.value('@Nombre','varchar(40)') as Nombre
From
(
Select cast(CatalogoXML as xml) from
Openrowset(Bulk 'C:\CatalogoFinal.xml', Single_Blob) T(CatalogoXML)
) as S(CatalogoXML)

Cross apply CatalogoXML.nodes('Datos/Catalogos/Tipos_de_Documento_de_Identificacion/TipoIdDoc') as A(CatalogoXML)

Insert into Departamento

Select 

A.CatalogoXML.value('@Id','int') as Id,
A.CatalogoXML.value('@Nombre','varchar(40)') as Nombre
From
(
Select cast(CatalogoXML as xml) from
Openrowset(Bulk 'C:\CatalogoFinal.xml', Single_Blob) T(CatalogoXML)
) as S(CatalogoXML)

Cross apply CatalogoXML.nodes('Datos/Catalogos/Departamentos/Departamento') as A(CatalogoXML)
GO

Create procedure insertarEmpleado as

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
Openrowset(Bulk 'C:\CatalogoFinal.xml', Single_Blob) T(EmpleadosXML)
) as S(EmpleadosXML)

Cross apply EmpleadosXML.nodes('Datos/Empleados/Empleado') as A(EmpleadoXML)

GO

Create procedure insertarUsuario as

Insert into Usuario

Select 

A.UsuarioXML.value('@username','varchar(30)') as Username,
A.UsuarioXML.value('@pwd','varchar(30)') as Pwd,
A.UsuarioXML.value('@tipo','int') as Tipo

From
(
Select cast(UsuariosXML as xml) from
Openrowset(Bulk 'C:\CatalogoFinal.xml', Single_Blob) T(UsuariosXML)
) as S(UsuariosXML)

Cross apply UsuariosXML.nodes('Datos/Usuarios/Usuario') as A(UsuarioXML)

GO

Execute insertarCatalogos
Execute insertarEmpleado
Execute insertarUsuario