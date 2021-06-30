using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Pagina_Bases_de_Datos.Modelos
{
    public class Empleados
    {
        public int Id { get; set; }
        public string Nombre { get; set; }
        public int IdTipoIdentificacion { get; set; }
        public int ValorDocumentoIdentificacion { get; set; }
        public int IdDepartamento { get; set; }
        public int IdPuesto { get; set; }
    }
}
