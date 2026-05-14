const db = require('./config/db');

const data = {
    'Electronics': [
        { n: 'MacBook Pro M2', p: 450000, i: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=500' },
        { n: 'iPhone 15 Pro', p: 380000, i: 'https://images.unsplash.com/photo-1696446701796-da61225697cc?w=500' },
        { n: 'Sony WH-1000XM5', p: 95000, i: 'https://images.unsplash.com/photo-1618366712010-8c0e2477d010?w=500' },
        { n: 'iPad Pro M2', p: 220000, i: 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=500' },
        { n: 'Samsung S23 Ultra', p: 310000, i: 'https://images.unsplash.com/photo-1678911820864-e2c567c655d7?w=500' },
        { n: 'AirPods Pro 2', p: 65000, i: 'https://images.unsplash.com/photo-1588423770574-01b944230172?w=500' },
        { n: 'PlayStation 5', p: 165000, i: 'https://images.unsplash.com/photo-1606813907291-d86efa9b94db?w=500' },
        { n: 'Dell XPS 13', p: 295000, i: 'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?w=500' },
        { n: 'Canon EOS R5', p: 850000, i: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=500' },
        { n: 'Gaming Keyboard', p: 15000, i: 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=500' }
    ],
    'Clothing': [
        { n: 'Leather Jacket', p: 15000, i: 'https://images.unsplash.com/photo-1551028711-031c50728753?w=500' },
        { n: 'Denim Jacket', p: 7500, i: 'https://images.unsplash.com/photo-1576872381149-7847515ce5d8?w=500' },
        { n: 'Street Hoodie', p: 4500, i: 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=500' },
        { n: 'Slim Chinos', p: 3200, i: 'https://images.unsplash.com/photo-1473966968600-fa804b86d30b?w=500' },
        { n: 'Polo Shirt', p: 8500, i: 'https://images.unsplash.com/photo-1581655353564-df123a1eb820?w=500' },
        { n: 'Summer Dress', p: 6500, i: 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=500' },
        { n: 'Graphic Tee', p: 1800, i: 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=500' },
        { n: 'Trench Coat', p: 18000, i: 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=500' },
        { n: 'Workout Shorts', p: 2200, i: 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=500' },
        { n: 'Wool Sweater', p: 5500, i: 'https://images.unsplash.com/photo-1551488831-00ddcb6c6bd3?w=500' }
    ],
    'Shoes': [
        { n: 'Nike Air Max', p: 42000, i: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500' },
        { n: 'Adidas Boost', p: 38000, i: 'https://images.unsplash.com/photo-1587563871167-1ee9c731aefb?w=500' },
        { n: 'Converse All Star', p: 9500, i: 'https://images.unsplash.com/photo-1491553895911-0055eca6402d?w=500' },
        { n: 'Vans Old Skool', p: 8500, i: 'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?w=500' },
        { n: 'Timberland Boot', p: 35000, i: 'https://images.unsplash.com/photo-1551107696-a4b0c5a0d9a2?w=500' },
        { n: 'Chelsea Boots', p: 16000, i: 'https://images.unsplash.com/photo-1638247025967-b4e38f787b76?w=500' },
        { n: 'Jordan 1 Retro', p: 125000, i: 'https://images.unsplash.com/photo-1552346154-21d32810aba3?w=500' },
        { n: 'Yeezy Boost 350', p: 95000, i: 'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=500' },
        { n: 'Suede Loafers', p: 12000, i: 'https://images.unsplash.com/photo-1614252235316-8c857d38b5f4?w=500' },
        { n: 'Running Shoes', p: 14500, i: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500' }
    ],
    'Watches': [
        { n: 'Rolex Submariner', p: 1550000, i: 'https://images.unsplash.com/photo-1523170335258-f5ed11844a49?w=500' },
        { n: 'Apple Watch Ultra', p: 215000, i: 'https://images.unsplash.com/photo-1434494878577-86c23bcb06b9?w=500' },
        { n: 'Seiko 5 Auto', p: 38000, i: 'https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=500' },
        { n: 'Fossil Gen 6', p: 42000, i: 'https://images.unsplash.com/photo-1508685096489-7aaac462136a?w=500' },
        { n: 'G-Shock Mudmaster', p: 55000, i: 'https://images.unsplash.com/photo-1622434641406-a15812345ad1?w=500' },
        { n: 'Daniel Wellington', p: 22000, i: 'https://images.unsplash.com/photo-152327533bc6b-626ad1d8ff51?w=500' },
        { n: 'Omega Speedmaster', p: 950000, i: 'https://images.unsplash.com/photo-1614164185128-e4ec99c436d7?w=500' },
        { n: 'Citizen Eco-Drive', p: 35000, i: 'https://images.unsplash.com/photo-1542496658-e33a6d0d50f6?w=500' },
        { n: 'Tissot Gentleman', p: 85000, i: 'https://images.unsplash.com/photo-1612817159949-195b6eb9e31a?w=500' },
        { n: 'Galaxy Watch', p: 58000, i: 'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?w=500' }
    ],
    'Furniture': [
        { n: 'Velvet Sofa', p: 145000, i: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=500' },
        { n: 'Desk Chair', p: 28000, i: 'https://images.unsplash.com/photo-1505843490701-515a00718600?w=500' },
        { n: 'Oak Dining Table', p: 95000, i: 'https://images.unsplash.com/photo-1530018607912-eff2df114f11?w=500' },
        { n: 'Bed Frame', p: 65000, i: 'https://images.unsplash.com/photo-1505693419166-4102c9a272b2?w=500' },
        { n: 'Coffee Table', p: 22000, i: 'https://images.unsplash.com/photo-1533090161767-e6ffed986c88?w=500' },
        { n: 'Bookshelf', p: 35000, i: 'https://images.unsplash.com/photo-1594620302200-9a762244a156?w=500' },
        { n: 'Lounge Chair', p: 42000, i: 'https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?w=500' },
        { n: 'Wardrobe', p: 85000, i: 'https://images.unsplash.com/photo-1595428774223-ef52624120d2?w=500' },
        { n: 'Buffet Table', p: 48000, i: 'https://images.unsplash.com/photo-1592078615290-033ee584e267?w=500' },
        { n: 'Patio Set', p: 125000, i: 'https://images.unsplash.com/photo-1533158307587-828f0a76ef46?w=500' }
    ],
    'Accessories': [
        { n: 'Aviator Sunglasses', p: 15000, i: 'https://images.unsplash.com/photo-1511499767390-91f197f70017?w=500' },
        { n: 'Leather Belt', p: 3500, i: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=500' },
        { n: 'Silk Tie', p: 2500, i: 'https://images.unsplash.com/photo-1589756823851-910723997357?w=500' },
        { n: 'Wool Scarf', p: 4500, i: 'https://images.unsplash.com/photo-1520903920243-00d872a2d1c9?w=500' },
        { n: 'Leather Wallet', p: 5500, i: 'https://images.unsplash.com/photo-1627123424574-724758594e93?w=500' },
        { n: 'Fedora Hat', p: 6500, i: 'https://images.unsplash.com/photo-1514327605112-b887c0e61c0a?w=500' },
        { n: 'Gold Necklace', p: 85000, i: 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=500' },
        { n: 'Beanie Cap', p: 1200, i: 'https://images.unsplash.com/photo-1576871337632-b9aef4c17ab9?w=500' },
        { n: 'Cufflinks Set', p: 8500, i: 'https://images.unsplash.com/photo-1605051900898-028ec1172f3e?w=500' },
        { n: 'Backpack Canvas', p: 12000, i: 'https://images.unsplash.com/photo-1553062407-ac672224095c?w=500' }
    ],
    'Beauty': [
        { n: 'Chanel No 5', p: 35000, i: 'https://images.unsplash.com/photo-1541643600914-78b084683601?w=500' },
        { n: 'Face Serum', p: 4500, i: 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?w=500' },
        { n: 'Lipstick Matte', p: 2500, i: 'https://images.unsplash.com/photo-1586776977607-310e9c725c37?w=500' },
        { n: 'Hair Oil', p: 1200, i: 'https://images.unsplash.com/photo-1608248597279-f99d160bfcbc?w=500' },
        { n: 'Eyeshadow Palette', p: 6500, i: 'https://images.unsplash.com/photo-1583241475880-083f84372725?w=500' },
        { n: 'Moisturizer', p: 3200, i: 'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=500' },
        { n: 'Sunscreen SPF 50', p: 2800, i: 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=500' },
        { n: 'Luxury Soap', p: 850, i: 'https://images.unsplash.com/photo-1600857062241-98e5dba7f214?w=500' },
        { n: 'Face Mask', p: 1500, i: 'https://images.unsplash.com/photo-1596755389378-7d0d2211cdb1?w=500' },
        { n: 'Perfume Men', p: 12000, i: 'https://images.unsplash.com/photo-1594035910387-fea47794261f?w=500' }
    ],
    'Sports': [
        { n: 'Yoga Mat', p: 2500, i: 'https://images.unsplash.com/photo-1592432678016-e910b452f9a2?w=500' },
        { n: 'Dumbbells Set', p: 12000, i: 'https://images.unsplash.com/photo-1583454110551-21f2fa2ec617?w=500' },
        { n: 'Cricket Bat', p: 25000, i: 'https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=500' },
        { n: 'Football Pro', p: 5500, i: 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=500' },
        { n: 'Tennis Racket', p: 18000, i: 'https://images.unsplash.com/photo-1617083281297-af33e63ae892?w=500' },
        { n: 'Basketball', p: 4500, i: 'https://images.unsplash.com/photo-1519861531473-9200262188bf?w=500' },
        { n: 'Boxing Gloves', p: 6500, i: 'https://images.unsplash.com/photo-1552072805-2a9039d00e57?w=500' },
        { n: 'Cycling Helmet', p: 8500, i: 'https://images.unsplash.com/photo-1557053503-0c252e5c82bf?w=500' },
        { n: 'Protein Shaker', p: 1200, i: 'https://images.unsplash.com/photo-1593095199911-2092c488667c?w=500' },
        { n: 'Badminton Set', p: 3500, i: 'https://images.unsplash.com/photo-1626225967045-2c390255979d?w=500' }
    ],
    'Groceries': [
        { n: 'Fresh Apples', p: 450, i: 'https://images.unsplash.com/photo-1560806887-1e4cd0b6bcd6?w=500' },
        { n: 'Organic Milk', p: 280, i: 'https://images.unsplash.com/photo-1563636619-e910f2f819cf?w=500' },
        { n: 'Brown Bread', p: 180, i: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500' },
        { n: 'Greek Yogurt', p: 350, i: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=500' },
        { n: 'Cooking Oil', p: 1200, i: 'https://images.unsplash.com/photo-1474979266404-7eaacabc88c5?w=500' },
        { n: 'Pasta Penne', p: 450, i: 'https://images.unsplash.com/photo-1551462147-37885abb3e4a?w=500' },
        { n: 'Green Tea', p: 650, i: 'https://images.unsplash.com/photo-1564890369478-c89fe6d9c339?w=500' },
        { n: 'Honey Pure', p: 850, i: 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=500' },
        { n: 'Mixed Nuts', p: 1500, i: 'https://images.unsplash.com/photo-1514944288352-fffbb99f0bdf?w=500' },
        { n: 'Orange Juice', p: 450, i: 'https://images.unsplash.com/photo-1613478223719-2ab802602423?w=500' }
    ],
    'Toys': [
        { n: 'Teddy Bear', p: 2500, i: 'https://images.unsplash.com/photo-1559440666-3d89304918e9?w=500' },
        { n: 'Lego City Set', p: 12000, i: 'https://images.unsplash.com/photo-1560155016-bd4879ae8f21?w=500' },
        { n: 'RC Race Car', p: 8500, i: 'https://images.unsplash.com/photo-1594736797933-d0501ba2fe65?w=500' },
        { n: 'Barbie Doll', p: 4500, i: 'https://images.unsplash.com/photo-1558444455-24962bc02a43?w=500' },
        { n: 'Puzzle 1000 Pcs', p: 2200, i: 'https://images.unsplash.com/photo-1585338927000-1c787b17eb5e?w=500' },
        { n: 'Action Figure', p: 3500, i: 'https://images.unsplash.com/photo-1566576721346-d4a3b4eaad5b?w=500' },
        { n: 'Kids Bicycle', p: 18000, i: 'https://images.unsplash.com/photo-1532124957303-34e2c9035e5d?w=500' },
        { n: 'Building Blocks', p: 1500, i: 'https://images.unsplash.com/photo-1587654780291-39c9404d746b?w=500' },
        { n: 'Dinosaur Toy', p: 1200, i: 'https://images.unsplash.com/photo-1516981879613-9f5da904015f?w=500' },
        { n: 'Art Kit Kids', p: 3500, i: 'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=500' }
    ]
};

async function bulkInsert() {
    console.log('--- Starting Ultra Mega Mixed Insertion (100 Products) ---');
    
    // Flatten and mix products
    let allProducts = [];
    for (const cat in data) {
        data[cat].forEach(p => {
            allProducts.push({ ...p, cat });
        });
    }

    // Shuffle Algorithm (Fisher-Yates)
    for (let i = allProducts.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [allProducts[i], allProducts[j]] = [allProducts[j], allProducts[i]];
    }

    let count = 0;
    for (const p of allProducts) {
        try {
            const sql = "INSERT INTO products (name, description, price, category, image_url, discount_percent) VALUES (?, ?, ?, ?, ?, ?)";
            const discount = [0, 0, 10, 20, 30, 50][Math.floor(Math.random() * 6)];
            const desc = `Premium quality ${p.n} from our ${p.cat} collection. Experience the best with ShopNow.`;
            await db.query(sql, [p.n, desc, p.p, p.cat, p.i, discount]);
            count++;
            console.log(`[${count}/100] Added Mixed: ${p.n} (${p.cat})`);
        } catch (err) {
            console.error(`Error adding ${p.n}:`, err.message);
        }
    }
    
    console.log(`--- Finished! Successfully added ${count} products mixed! ---`);
    process.exit(0);
}

bulkInsert();
