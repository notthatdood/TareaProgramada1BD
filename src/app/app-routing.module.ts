import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

import {EmployeeComponent} from './employee/employee.component';
import {PositionComponent} from './position/position.component';

const routes: Routes = [
  {path :'employee',component:EmployeeComponent},
  {path :'position',component:PositionComponent}
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
