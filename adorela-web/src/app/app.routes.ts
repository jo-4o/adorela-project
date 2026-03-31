import { Routes } from '@angular/router';
import { HomeComponent } from './pages/public/home/home';
import { MenuComponent } from './pages/public/menu/menu';
import { AdminDashboardComponent } from './pages/admin/dashboard/dashboard';
import { AdminProductsComponent } from './pages/admin/products/products';
import { AdminCategoriesComponent } from './pages/admin/categories/categories';
import { adminGuard } from './auth.guard';
import { LoginComponent } from './pages/public/login/login';
import { AdminLayoutComponent } from './layouts/admin.layout';

export const routes: Routes = [
  { path: '', component: HomeComponent },
  { path: 'cardapio', component: MenuComponent },
  { path: 'login', component: LoginComponent },
  {
    path: 'admin',
    component: AdminLayoutComponent,
    canActivate: [adminGuard],
    children: [
      { path: '', component: AdminDashboardComponent },
      { path: 'produtos', component: AdminProductsComponent },
      { path: 'categorias', component: AdminCategoriesComponent }
    ]
  }
];