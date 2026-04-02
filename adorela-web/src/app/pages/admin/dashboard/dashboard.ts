import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { ProductService } from '../../../services/product.service';
import { Product } from '../../../models/product.model';
import { CategoryService, Category } from '../../../services/category.service';

@Component({
  selector: 'app-admin-dashboard',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './dashboard.html',
  styleUrls: ['./dashboard.scss']
})
export class AdminDashboardComponent implements OnInit {
  products: Product[] = [];
  categories: Category[] = [];
  isLoading = true;

  constructor(
    private productService: ProductService,
    private categoryService: CategoryService
  ) {}

  ngOnInit(): void {
    this.loadData();
  }

  loadData(): void {
    this.isLoading = true;
    this.productService.getProducts().subscribe({
      next: (data) => {
        this.products = data;
        this.isLoading = false;
      },
      error: () => this.isLoading = false
    });
    this.categoryService.getCategories().subscribe({
      next: (data) => this.categories = data
    });
  }

  getFeaturedCount(): number {
    return this.products.filter(p => p.isFeatured).length;
  }

  getActiveProductsCount(): number {
    return this.products.filter(p => p.active).length;
  }

  getTotalStock(): number {
    return this.products.reduce((sum, p) => sum + (p.stockQuantity || 0), 0);
  }

  getRecentProducts(): Product[] {
    return this.products.slice(0, 5);
  }
}
