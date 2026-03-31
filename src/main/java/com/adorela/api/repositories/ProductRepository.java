package com.adorela.api.repositories;

import com.adorela.api.models.Product;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    List<Product> findByActiveTrue();
    List<Product> findByIsFeaturedTrueAndActiveTrue();
    List<Product> findByCategoryIdAndActiveTrue(Long categoryId);

    // Paginação com busca por nome/descrição
    @Query("SELECT p FROM Product p WHERE p.active = true " +
           "AND (:q IS NULL OR LOWER(p.name) LIKE LOWER(CONCAT('%', :q, '%')) " +
           "     OR LOWER(p.description) LIKE LOWER(CONCAT('%', :q, '%')))")
    Page<Product> searchActive(@Param("q") String q, Pageable pageable);

    // Paginação por categoria
    Page<Product> findByCategoryIdAndActiveTrue(Long categoryId, Pageable pageable);
}