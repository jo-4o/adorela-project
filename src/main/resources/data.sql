-- Seed de dados inicial para desenvolvimento

-- Categorias
INSERT INTO categories (id, name, description, active, created_at) VALUES
(1, 'Bolos', 'Bolos tradicionais e especiais para todas as ocasiões', true, NOW()),
(2, 'Doces', 'Doces finos, brigadeiros e outras delícias', true, NOW()),
(3, 'Salgados', 'Salgados assados e fritos para festas', true, NOW()),
(4, 'Tortas', 'Tortas doces e salgadas', true, NOW())
ON CONFLICT (id) DO NOTHING;

-- Atualiza sequence caso necessário
SELECT setval('categories_id_seq', (SELECT MAX(id) FROM categories));

-- Produtos
INSERT INTO products (id, category_id, name, description, price, image_url, is_featured, stock_quantity, unit_type, active, created_at, updated_at) VALUES
(1, 1, 'Bolo de Chocolate', 'Delicioso bolo de chocolate com cobertura cremosa', 65.00, NULL, true, 10, 'UN', true, NOW(), NOW()),
(2, 1, 'Bolo de Cenoura', 'Bolo de cenoura com cobertura de chocolate', 55.00, NULL, true, 8, 'UN', true, NOW(), NOW()),
(3, 1, 'Bolo Red Velvet', 'Bolo red velvet com cream cheese', 85.00, NULL, true, 5, 'UN', true, NOW(), NOW()),
(4, 2, 'Brigadeiro Tradicional', 'Brigadeiro de chocolate ao leite', 3.50, NULL, false, 100, 'UN', true, NOW(), NOW()),
(5, 2, 'Brigadeiro Gourmet', 'Brigadeiro belga com granulado especial', 5.00, NULL, true, 80, 'UN', true, NOW(), NOW()),
(6, 2, 'Beijinho', 'Beijinho de coco tradicional', 3.50, NULL, false, 100, 'UN', true, NOW(), NOW()),
(7, 3, 'Coxinha', 'Coxinha de frango cremosa', 6.00, NULL, false, 50, 'UN', true, NOW(), NOW()),
(8, 3, 'Empada de Frango', 'Empada artesanal de frango', 7.00, NULL, false, 40, 'UN', true, NOW(), NOW()),
(9, 3, 'Quibe Frito', 'Quibe de carne bovina', 5.50, NULL, false, 60, 'UN', true, NOW(), NOW()),
(10, 4, 'Torta de Limão', 'Torta de limão siciliano com merengue', 75.00, NULL, true, 6, 'UN', true, NOW(), NOW()),
(11, 4, 'Torta de Morango', 'Torta de morango com creme', 80.00, NULL, true, 4, 'UN', true, NOW(), NOW()),
(12, 4, 'Torta Salgada de Frango', 'Torta salgada recheada com frango desfiado', 45.00, NULL, false, 8, 'UN', true, NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Atualiza sequence caso necessário
SELECT setval('products_id_seq', (SELECT MAX(id) FROM products));
