-- Create sample tables
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Insert sample data
INSERT INTO users (username, email) VALUES
('john_doe', 'john@example.com'),
('jane_smith', 'jane@example.com'),
('bob_johnson', 'bob@example.com')
ON CONFLICT (username) DO NOTHING;

INSERT INTO products (name, price, stock_quantity) VALUES
('Laptop', 999.99, 50),
('Smartphone', 699.99, 100),
('Headphones', 149.99, 200)
ON CONFLICT (name) DO NOTHING;

-- Create some functions to generate metrics
CREATE OR REPLACE FUNCTION generate_sample_data() RETURNS VOID AS $$
DECLARE
    user_rec RECORD;
    product_rec RECORD;
    i INTEGER;
BEGIN
    FOR i IN 1..100 LOOP
        -- Randomly select a user
        SELECT * INTO user_rec FROM users ORDER BY RANDOM() LIMIT 1;
        
        -- Randomly select a product
        SELECT * INTO product_rec FROM products ORDER BY RANDOM() LIMIT 1;
        
        -- Insert an order
        INSERT INTO orders (user_id, product_id, quantity, total_price)
        VALUES (
            user_rec.id,
            product_rec.id,
            (RANDOM() * 5 + 1)::INTEGER,
            product_rec.price * (RANDOM() * 5 + 1)::INTEGER
        );
        
        -- Randomly update product stock
        UPDATE products 
        SET stock_quantity = stock_quantity - (RANDOM() * 3)::INTEGER,
            updated_at = NOW()
        WHERE id = product_rec.id;
        
        -- Randomly update user
        UPDATE users
        SET updated_at = NOW()
        WHERE id = user_rec.id;
        
        -- Add some delay to spread out the operations
        PERFORM pg_sleep(RANDOM() * 0.1);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Create a view for monitoring
CREATE OR REPLACE VIEW database_stats AS
SELECT 
    (SELECT COUNT(*) FROM users) as user_count,
    (SELECT COUNT(*) FROM products) as product_count,
    (SELECT COUNT(*) FROM orders) as order_count,
    (SELECT SUM(total_price) FROM orders) as total_sales,
    (SELECT AVG(total_price) FROM orders) as avg_order_value;