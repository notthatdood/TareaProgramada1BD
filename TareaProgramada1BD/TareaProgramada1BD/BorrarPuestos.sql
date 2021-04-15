Create procedure BorrarPuestos
	@Nombre varchar(40)

	as

	Update Puesto
	Set Activo='0'
	Where Nombre=@Nombre

GO