package com.adorela.api.controllers;

import com.adorela.api.models.Category;
import com.adorela.api.repositories.CategoryRepository;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * CategoryController — Endpoints de categorias.
 *
 * Autorização por perfil (4 perfis funcionais):
 *  - admin (dono/gerente/revisao): leitura + escrita + exclusão
 *  - limitado:    SEM acesso a categorias (bloqueado em todos os endpoints)
 *  - exclusivo1:  apenas leitura
 *  - exclusivo2:  apenas leitura
 *
 * GETs também são acessíveis a usuários anônimos (catálogo público),
 * mas usuários autenticados com role 'limitado' são explicitamente bloqueados.
 */
@RestController
@RequestMapping("/api/categories")
@RequiredArgsConstructor
public class CategoryController {

    private final CategoryRepository categoryRepository;

    @GetMapping
    @PreAuthorize("!hasRole('limitado')")
    public ResponseEntity<List<Category>> getAllCategories() {
        return ResponseEntity.ok(categoryRepository.findByActiveTrue());
    }

    @GetMapping("/{id}")
    @PreAuthorize("!hasRole('limitado')")
    public ResponseEntity<Category> getCategoryById(@PathVariable Long id) {
        return categoryRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('dono', 'gerente')")
    public ResponseEntity<Category> createCategory(@Valid @RequestBody Category category) {
        Category saved = categoryRepository.save(category);
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('dono', 'gerente')")
    public ResponseEntity<Category> updateCategory(@PathVariable Long id, @Valid @RequestBody Category category) {
        return categoryRepository.findById(id)
                .map(existing -> {
                    existing.setName(category.getName());
                    existing.setDescription(category.getDescription());
                    existing.setActive(category.getActive());
                    Category updated = categoryRepository.save(existing);
                    return ResponseEntity.ok(updated);
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('dono')")
    public ResponseEntity<Void> deleteCategory(@PathVariable Long id) {
        if (!categoryRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        categoryRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
