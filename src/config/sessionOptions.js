import { RedisStore } from "connect-redis";
import { createClient } from "redis";

const redisClient = createClient({
	url: process.env.REDIS_URL || "redis://localhost:6379",
});
await redisClient.connect();

// Options object for the session middleware.
export const sessionOptions = {
	store: new RedisStore({ client: redisClient }),
	name: process.env.SESSION_NAME,
	secret: process.env.SESSION_SECRET,
	resave: false,
	saveUninitialized: false,
	cookie: {
		maxAge: 1000 * 60 * 60 * 24, // 1 day
		sameSite: "lax",
	},
};
