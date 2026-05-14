const express = require('express');
const router = express.Router();
const db = require('../config/db');

// Place a new order
router.post('/', async (req, res) => {
    const { firebase_uid, total_amount, payment_method, items, name, email, phone, address } = req.body;
    
    console.log("Incoming Order Request:", req.body);

    try {
        // 1. Check if user exists, if not create user
        let [users] = await db.query('SELECT id FROM users WHERE firebase_uid = ?', [firebase_uid]);
        let userId;

        if (users.length === 0) {
            console.log("Creating new user...");
            const [newUser] = await db.query(
                'INSERT INTO users (firebase_uid, name, email, phone, address) VALUES (?, ?, ?, ?, ?)',
                [firebase_uid, name, email, phone, address]
            );
            userId = newUser.insertId;
        } else {
            userId = users[0].id;
            console.log("Existing user found, ID:", userId);
        }

        // 2. Create Order
        console.log("Inserting order for user:", userId);
        const [orderResult] = await db.query(
            'INSERT INTO orders (user_id, total_amount, payment_method) VALUES (?, ?, ?)',
            [userId, total_amount, payment_method]
        );
        const orderId = orderResult.insertId;

        // 3. Insert Order Items
        console.log("Inserting", items.length, "items for order ID:", orderId);
        for (let item of items) {
            await db.query(
                'INSERT INTO order_items (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)',
                [orderId, item.product_id, item.quantity, item.price]
            );
        }

        console.log("✅ Order placed successfully! ID:", orderId);
        res.status(201).json({ message: 'Order placed successfully!', orderId });
    } catch (error) {
        console.error("❌ SQL ERROR:", error.message);
        res.status(500).json({ 
            error: 'Failed to place order', 
            details: error.message 
        });
    }
});

// Get all orders (For Admin)
router.get('/', async (req, res) => {
    try {
        const [orders] = await db.execute(`
            SELECT o.id, o.total_amount, o.status, o.payment_method, o.created_at, u.name as customer_name, u.phone 
            FROM orders o 
            JOIN users u ON o.user_id = u.id 
            ORDER BY o.created_at DESC
        `);
        res.json(orders);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch orders' });
    }
});

// Get orders for a specific user
router.get('/user/:uid', async (req, res) => {
    const { uid } = req.params;
    try {
        const [orders] = await db.execute(`
            SELECT o.id, o.total_amount, o.status, o.payment_method, o.created_at, u.name as customer_name, u.phone 
            FROM orders o 
            JOIN users u ON o.user_id = u.id 
            WHERE u.firebase_uid = ?
            ORDER BY o.created_at DESC
        `, [uid]);
        res.json(orders);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Failed to fetch user orders' });
    }
});

module.exports = router;
