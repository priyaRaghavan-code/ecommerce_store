class ProductCatalog
  PRODUCTS = [
    { id: "p1", name: "iPhone", price: 70000 },
    { id: "p2", name: "AirPods", price: 15000 },
    { id: "p3", name: "MacBook", price: 120000 }
  ].freeze

  def self.all
    PRODUCTS
  end

  def self.find(product_id)
    PRODUCTS.find { |p| p[:id] == product_id }
  end
end
