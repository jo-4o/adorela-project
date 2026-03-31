import { Component } from '@angular/core';
import { RouterOutlet, Router, RouterLink, RouterLinkActive } from '@angular/router';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-admin-layout',
  standalone: true,
  imports: [RouterOutlet, RouterLink, RouterLinkActive, CommonModule],
  templateUrl: './admin.layout.html',
  styleUrls: ['./admin.layout.scss']
})
export class AdminLayoutComponent {
  constructor(private router: Router) {}

  logout(): void {
    localStorage.removeItem('keycloak_token');
    localStorage.removeItem('keycloak_refresh_token');
    localStorage.removeItem('keycloak_user');
    this.router.navigate(['/login']);
  }
}
