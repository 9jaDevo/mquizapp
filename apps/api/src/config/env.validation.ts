import * as Joi from 'joi';

export const envValidationSchema = Joi.object({
  NODE_ENV: Joi.string().valid('development', 'production', 'test').default('development'),
  PORT: Joi.number().default(3000),
  APP_URL: Joi.string().uri().required(),
  ADMIN_URL: Joi.string().uri().required(),
  MOBILE_APP_BUNDLE: Joi.string().required(),

  DATABASE_URL: Joi.string().required(),

  FIREBASE_PROJECT_ID: Joi.string().required(),
  FIREBASE_CLIENT_EMAIL: Joi.string().email().required(),
  FIREBASE_PRIVATE_KEY: Joi.string().required(),

  REDIS_URL: Joi.string().required(),

  OPENAI_API_KEY: Joi.string().allow('').optional(),
  OPENAI_MODEL: Joi.string().default('gpt-4o'),
  OPENAI_MINI_MODEL: Joi.string().default('gpt-4o-mini'),

  // Paystack: optional at boot so dev can run without it; PaymentsService validates at use-time.
  PAYSTACK_SECRET_KEY: Joi.string().allow('').optional(),
  PAYSTACK_PUBLIC_KEY: Joi.string().allow('').optional(),
  PAYSTACK_WEBHOOK_SECRET: Joi.string().allow('').optional(),

  CLOUDINARY_CLOUD_NAME: Joi.string().allow('').optional(),
  CLOUDINARY_API_KEY: Joi.string().allow('').optional(),
  CLOUDINARY_API_SECRET: Joi.string().allow('').optional(),
});
