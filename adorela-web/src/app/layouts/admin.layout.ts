import { Component } from '@angular/core';
import { RouterOutlet, Router, RouterLink, RouterLinkActive } from '@angular/router';
import { CommonModule } from '@angular/common';
import { authService } from '../services/auth.service';

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
    authService.logout();
  }
}
