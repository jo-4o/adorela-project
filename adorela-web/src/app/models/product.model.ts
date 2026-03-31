export interface Product {
  id?: number | null;
  name: string;
  description?: string | null;
  price: number;
  imageUrl?: string | null;
  isFeatured?: boolean;
  stockQuantity?: number;
  unitType?: string;
  active?: boolean;
  category?: any;
  createdAt?: any;
  updatedAt?: any;
}