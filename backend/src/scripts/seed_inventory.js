const mongoose = require('mongoose');
const connectDB = require('../config/database'); // Adjust path if needed
const Inventory = require('../models/inventory'); // Adjust path if needed

const seedInventory = async () => {
  try {
    await connectDB();

    const sampleItems = [
      {
        barcode: '12345',
        name: 'Sample Item',
        price: 100.0,
        stock: 50,
        discount: 0.1,
        imageUrl: 'https://example.com/item.jpg',
      },
      {
        barcode: '67890',
        name: 'Another Item',
        price: 200.0,
        stock: 30,
        discount: 0.0,
        imageUrl: 'https://example.com/another.jpg',
      },
    ];

    await Inventory.deleteMany({});
    await Inventory.insertMany(sampleItems);

    console.log('✅ Inventory seeded successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Seeding failed:', error);
    process.exit(1);
  }
};

seedInventory();
