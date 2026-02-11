import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { MainShellComponent } from './main-shell.component';
import { PrivacyComponent } from './privacy.component';
import { TermsComponent } from './terms.component';

const routes: Routes = [
  { path: '', component: MainShellComponent },
  { path: 'privacy', component: PrivacyComponent },
  { path: 'terms', component: TermsComponent },
  { path: '**', redirectTo: '' }
];

@NgModule({
  imports: [RouterModule.forRoot(routes, { scrollPositionRestoration: 'enabled' })],
  exports: [RouterModule]
})
export class AppRoutingModule {}
