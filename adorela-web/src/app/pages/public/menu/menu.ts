import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ProductService } from '../../../services/product.service';
import { Product } from '../../../models/product.model';

@Component({
  selector: 'app-menu',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './menu.html',
  styleUrls: ['./menu.scss']
})
export class MenuComponent implements OnInit {
  products: Product[] = [];
  filtered: Product[] = [];
  categories: string[] = [];
  activeCategory: string | null = null;

  constructor(private productService: ProductService) {}

  ngOnInit(): void {
    this.productService.getProducts().subscribe({
      next: (data) => {
        this.products = data;
        this.categories = Array.from(new Set(data.map(p => p.category?.name || 'Outros')));
        this.filtered = this.products;
      }
    });
  }

  filterBy(category: string | null) {
    this.activeCategory = category;
    if (!category) {
      this.filtered = this.products;
      return;
    }
    this.filtered = this.products.filter(p => (p.category?.name || 'Outros') === category);
  }
}
