Create procedure EditarEmpleados
	@Id int,
	@Nombre varchar(50),
	@IdTipoIdentificacion int,
	@ValorDocumentoIdentificacion int,
	@FechaNacimiento date,
	@Puesto varchar(40),
	@IdDepartamento int

	as

	Update Empleado
	Set Nombre=@Nombre, IdTipoIdentificacion=@IdTipoIdentificacion,
	ValorDocumentoIdentificacion=@ValorDocumentoIdentificacion, FechaNacimiento=@FechaNacimiento,
	Puesto=@Puesto, IdDepartamento=@IdDepartamento

	Where Id=@Id and Activo='1'

GO