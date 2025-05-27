const { z } = require("zod");

const userSchema = z.object({
  phone: z.string().min(10),
  name: z.string().min(1),
  email: z.string().email(),
  password: z.string().min(6),
  role: z.string(),
});

module.exports = userSchema;
