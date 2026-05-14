const express = require('express');
const router = express.Router();
const db = require('../config/db');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        if (!fs.existsSync('uploads')) fs.mkdirSync('uploads');
        cb(null, 'uploads/');
    },
    filename: function (req, file, cb) {
        cb(null, Date.now() + path.extname(file.originalname));
    }
});
const upload = multer({ storage });

// GET all products
router.get('/', async (req, res) => {
    try {
        const [rows] = await db.execute('SELECT * FROM products ORDER BY created_at DESC');
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: 'Database error' });
    }
});

// GET products by category
router.get('/category/:cat', async (req, res) => {
    try {
        const [rows] = await db.execute(
            'SELECT * FROM products WHERE category = ? ORDER BY created_at DESC',
            [req.params.cat]
        );
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: 'Database error' });
    }
});

// ADD new product
router.post('/', upload.single('image'), async (req, res) => {
    try {
        const { name, description, price, category } = req.body;
        const discount_val = req.body.discount_percent || req.body.discountPercent || 0;
        const discount_percent = Number(discount_val);
        
        const imageUrl = req.file ? `/uploads/${req.file.filename}` : null;
        const sql = "INSERT INTO products (name, description, price, category, image_url, discount_percent) VALUES (?, ?, ?, ?, ?, ?)";
        const values = [name, description, price, category, imageUrl, discount_percent];
        const [result] = await db.query(sql, values);
        
        res.status(201).json({ message: 'Product added', id: result.insertId });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Database error' });
    }
});

// EDIT product
router.put('/:id', upload.single('image'), async (req, res) => {
    try {
        console.log('--- Received Update Body ---');
        console.log(req.body);
        const { name, description, price, category } = req.body;
        const discount_val = req.body.discount_percent || req.body.discountPercent || 0;
        const discount_percent = parseInt(discount_val) || 0;
        
        console.log(`Parsed Discount Value: ${discount_percent}% from received: ${discount_val}`);
        const productId = req.params.id;
        let imageUrl = null;

        if (req.file) {
            imageUrl = `/uploads/${req.file.filename}`;
            await db.execute(
                'UPDATE products SET name=?, description=?, price=?, category=?, image_url=?, discount_percent=? WHERE id=?',
                [name, description, price, category, imageUrl, discount_percent, productId]
            );
        } else {
            await db.execute(
                'UPDATE products SET name=?, description=?, price=?, category=?, discount_percent=? WHERE id=?',
                [name, description, price, category, discount_percent, productId]
            );
        }
        res.json({ message: 'Product updated' });
    } catch (error) {
        res.status(500).json({ error: 'Database error' });
    }
});

// DELETE product
router.delete('/:id', async (req, res) => {
    try {
        await db.execute('DELETE FROM products WHERE id = ?', [req.params.id]);
        res.json({ message: 'Product deleted' });
    } catch (error) {
        res.status(500).json({ error: 'Database error' });
    }
});

// BULK DELETE products
router.post('/bulk-delete', async (req, res) => {
    try {
        const { ids } = req.body;
        if (!ids || !Array.isArray(ids) || ids.length === 0) {
            return res.status(400).json({ error: 'No IDs provided' });
        }
        
        // Use placeholders for each ID in the array
        const placeholders = ids.map(() => '?').join(',');
        const sql = `DELETE FROM products WHERE id IN (${placeholders})`;
        await db.query(sql, ids);
        
        res.json({ message: `${ids.length} products deleted successfully` });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Database error' });
    }
});

module.exports = router;
