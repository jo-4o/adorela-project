import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { authService } from '../../../services/auth.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './login.html',
  styleUrls: ['./login.scss']
})
export class LoginComponent implements OnInit {
  
  ngOnInit(): void {
    // Se a pessoa já estiver logada e cair na página de login, pode ser redirecionada para o admin
    if (authService.isLoggedIn()) {
      window.location.href = '/admin';
    }
  }

  onLogin(): void {
    authService.login();
  }
}
