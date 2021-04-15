Create procedure BorrarEmpleados
	@Id int

	as

	Update Empleado
	Set Activo='0'
	Where Id=@Id

GO