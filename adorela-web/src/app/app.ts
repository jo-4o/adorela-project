import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterOutlet, Router } from '@angular/router';
import { NavComponent } from './components/public/nav/nav';
import { FooterComponent } from './components/public/footer/footer';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule, RouterOutlet, NavComponent, FooterComponent],
  template: `
    <ng-container *ngIf="!isAdminRoute()">
      <app-nav></app-nav>
    </ng-container>

    <router-outlet></router-outlet>

    <ng-container *ngIf="!isAdminRoute()">
      <app-footer></app-footer>
    </ng-container>
  `
})
export class AppComponent {
  constructor(private router: Router) {}

  isAdminRoute(): boolean {
    return this.router.url.startsWith('/admin') || this.router.url.startsWith('/login');
  }
}