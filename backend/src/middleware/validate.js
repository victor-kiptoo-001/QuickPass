const Joi = require('joi');

const validate = (schema) => (req, res, next) => {
  const { error } = schema.validate(req.body);
  if (error) {
    return res.status(400).json({ error: error.details[0].message });
  }
  next();
};

// Schemas
const authSchema = Joi.object({
  phone: Joi.string().pattern(/^\d{10}$/).required(),
});

const verifyOtpSchema = Joi.object({
  phone: Joi.string().pattern(/^\d{10}$/).required(),
  otp: Joi.string().length(6).required(),
  deviceId: Joi.string().required(),
});

const cartItemSchema = Joi.object({
  id: Joi.string().required(),
  name: Joi.string().required(),
  price: Joi.number().positive().required(),
  quantity: Joi.number().integer().min(1).default(1),
  discount: Joi.number().min(0).max(1).optional(),
  imageUrl: Joi.string().uri().optional(),
});

const paymentSchema = Joi.object({
  phone: Joi.string().pattern(/^\d{10}$/).optional(),
  amount: Joi.number().positive().required(),
  cartItems: Joi.array().items(cartItemSchema).required(),
  paymentId: Joi.string().required(),
});

const redeemPointsSchema = Joi.object({
  userId: Joi.string().required(),
  points: Joi.number().integer().positive().required(),
  paymentId: Joi.string().required(),
});

module.exports = {
  validate,
  authSchema,
  verifyOtpSchema,
  cartItemSchema,
  paymentSchema,
  redeemPointsSchema,
};