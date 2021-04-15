Create procedure EditarPuestos
	@Nombre varchar(40),
	@SalarioXHora int

	as

	Update Puesto
	Set Nombre=@Nombre, SalarioXHora=@SalarioXHora
	Where Nombre=@Nombre and Activo='1'

GO