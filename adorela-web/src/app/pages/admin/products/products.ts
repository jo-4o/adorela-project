import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ProductService } from '../../../services/product.service';
import { Product } from '../../../models/product.model';
import { CategoryService, Category } from '../../../services/category.service';

@Component({
  selector: 'app-admin-products',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './products.html',
  styleUrls: ['./products.scss']
})
export class AdminProductsComponent implements OnInit {
  products: Product[] = [];
  categories: Category[] = [];
  editingProduct: Product | null = null;
  isLoading = true;

  constructor(
    private productService: ProductService,
    private categoryService: CategoryService
  ) {}

  ngOnInit(): void {
    this.loadProducts();
    this.loadCategories();
  }

  loadProducts(): void {
    this.isLoading = true;
    this.productService.getProducts().subscribe({
      next: (data) => {
        this.products = data;
        this.isLoading = false;
      },
      error: (err) => {
        console.error('Erro ao carregar produtos:', err);
        this.isLoading = false;
      }
    });
  }

  loadCategories(): void {
    this.categoryService.getCategories().subscribe({
      next: (data) => this.categories = data,
      error: (err) => console.error('Erro ao carregar categorias:', err)
    });
  }

  startAddProduct(): void {
    this.editingProduct = {
      id: null,
      name: '',
      description: '',
      price: 0 as any,
      imageUrl: '',
      isFeatured: false,
      stockQuantity: 0,
      unitType: 'UN',
      active: true,
      category: null,
      createdAt: null,
      updatedAt: null
    } as Product;
  }

  startEditProduct(p: Product): void {
    this.editingProduct = { ...p };
  }

  saveProduct(): void {
    if (!this.editingProduct) return;
    if (this.editingProduct.category && typeof this.editingProduct.category === 'object') {
      this.editingProduct.category = { id: this.editingProduct.category.id };
    }
    if (this.editingProduct.id) {
      this.productService.updateProduct(this.editingProduct.id as any, this.editingProduct)
        .subscribe(() => { this.editingProduct = null; this.loadProducts(); });
    } else {
      this.productService.createProduct(this.editingProduct)
        .subscribe(() => { this.editingProduct = null; this.loadProducts(); });
    }
  }

  cancelProduct(): void {
    this.editingProduct = null;
  }

  removeProduct(id: number): void {
    if (!confirm('Remover produto?')) return;
    this.productService.deleteProduct(id).subscribe(() => this.loadProducts());
  }

  onCategoryChange(event: Event): void {
    const select = event.target as HTMLSelectElement;
    const catId = Number(select.value);
    if (this.editingProduct) {
      this.editingProduct.category = catId ? { id: catId } : null;
    }
  }

  getSelectedCategoryId(): number | null {
    return this.editingProduct?.category?.id ?? null;
  }

  getFeaturedCount(): number {
    return this.products.filter(p => p.isFeatured).length;
  }

  getActiveCount(): number {
    return this.products.filter(p => p.active).length;
  }
}
