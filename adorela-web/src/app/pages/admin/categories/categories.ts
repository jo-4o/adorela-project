import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { CategoryService, Category } from '../../../services/category.service';

@Component({
  selector: 'app-admin-categories',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './categories.html',
  styleUrls: ['./categories.scss']
})
export class AdminCategoriesComponent implements OnInit {
  categories: Category[] = [];
  editingCategory: Category | null = null;
  isLoading = true;

  constructor(private categoryService: CategoryService) {}

  ngOnInit(): void {
    this.loadCategories();
  }

  loadCategories(): void {
    this.isLoading = true;
    this.categoryService.getCategories().subscribe({
      next: (data) => {
        this.categories = data;
        this.isLoading = false;
      },
      error: (err) => {
        console.error('Erro ao carregar categorias:', err);
        this.isLoading = false;
      }
    });
  }

  startAddCategory(): void {
    this.editingCategory = { name: '', description: '', active: true };
  }

  startEditCategory(c: Category): void {
    this.editingCategory = { ...c };
  }

  saveCategory(): void {
    if (!this.editingCategory) return;
    if (this.editingCategory.id) {
      this.categoryService.updateCategory(this.editingCategory.id, this.editingCategory)
        .subscribe(() => { this.editingCategory = null; this.loadCategories(); });
    } else {
      this.categoryService.createCategory(this.editingCategory)
        .subscribe(() => { this.editingCategory = null; this.loadCategories(); });
    }
  }

  cancelCategory(): void {
    this.editingCategory = null;
  }

  removeCategory(id: number): void {
    if (!confirm('Remover categoria?')) return;
    this.categoryService.deleteCategory(id).subscribe(() => this.loadCategories());
  }

  getActiveCount(): number {
    return this.categories.filter(c => c.active).length;
  }
}
