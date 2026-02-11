import { Component } from '@angular/core';
import { SessionService } from './session.service';

@Component({
  selector: 'app-main-shell',
  templateUrl: './main-shell.component.html',
  styleUrls: ['./main-shell.component.css']
})
export class MainShellComponent {
  token$ = this.session.token$;

  constructor(private session: SessionService) {}
}
