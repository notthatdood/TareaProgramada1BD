using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace WebApplication1.Models
{
    public class Position
    {
        public int PositionId { get; set; }

        public string PositionName { get; set; }

        public int HourlyWage { get; set; }

        public int Active { get; set; }
    }
}
