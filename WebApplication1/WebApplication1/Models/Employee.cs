using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace WebApplication1.Models
{
    public class Employee
    {

        public int EmployeeId { get; set; }

        public string EmployeeName { get; set; }

        public int IdentificationDocTypeId { get; set; }

        public int IdentificationDocValue { get; set; }

        public int DepartmentId { get; set; }

        public int PositionName { get; set; }

        public string DateOfBirth { get; set; }

    }
}
