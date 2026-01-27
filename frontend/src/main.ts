import { Component } from '@angular/core';
import { AppComponent } from './app.component';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [AppComponent],
  template: '<app-root></app-root>',
})
export class RootComponent {}
