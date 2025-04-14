const Cart = require('../models/cart');
const { MAX_CART_ITEMS } = require('../../config/app_config');

const getCart = async (req, res) => {
  try {
    const cart = await Cart.findOne({ userId: req.user._id });
    res.status(200).json(cart?.items || []);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch cart' });
  }
};

const addItem = async (req, res) => {
  try {
    const items = req.body;
    let cart = await Cart.findOne({ userId: req.user._id });
    if (!cart) {
      cart = new Cart({ userId: req.user._id, items: [] });
    }

    if (cart.items.length + items.length > MAX_CART_ITEMS) {
      return res.status(400).json({ error: `Cart cannot exceed ${MAX_CART_ITEMS} items` });
    }

    items.forEach((newItem) => {
      const existingIndex = cart.items.findIndex((item) => item.id === newItem.id);
      if (existingIndex !== -1) {
        cart.items[existingIndex].quantity += newItem.quantity || 1;
      } else {
        cart.items.push(newItem);
      }
    });

    cart.updatedAt = new Date();
    await cart.save();
    res.status(200).json(cart.items);
  } catch (error) {
    res.status(500).json({ error: 'Failed to add item to cart' });
  }
};

const updateCart = async (req, res) => {
  try {
    const items = req.body;
    if (items.length > MAX_CART_ITEMS) {
      return res.status(400).json({ error: `Cart cannot exceed ${MAX_CART_ITEMS} items` });
    }

    let cart = await Cart.findOne({ userId: req.user._id });
    if (!cart) {
      cart = new Cart({ userId: req.user._id, items });
    } else {
      cart.items = items;
    }

    cart.updatedAt = new Date();
    await cart.save();
    res.status(200).json(cart.items);
  } catch (error) {
    res.status(500).json({ error: 'Failed to update cart' });
  }
};

module.exports = { getCart, addItem, updateCart };