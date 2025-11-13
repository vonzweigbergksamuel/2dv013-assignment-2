import { RedisStore } from "connect-redis";
import { createClient } from "redis";

const redisClient = createClient({
	url: process.env.REDIS_URL || "redis://localhost:6379",
});
await redisClient.connect();

// Options object for the session middleware.
export const sessionOptions = {
	store: new RedisStore({ client: redisClient }),
	name: process.env.SESSION_NAME, // Don't use default session cookie name.
	secret: process.env.SESSION_SECRET, // Change it!!! The secret is used to hash the session with HMAC.
	resave: false, // Resave even if a request is not changing the session.
	saveUninitialized: false, // Don't save a created but not modified session.
	cookie: {
		maxAge: 1000 * 60 * 60 * 24, // 1 day
		sameSite: "strict",
	},
};

// if (process.env.NODE_ENV === "production") {
// 	sessionOptions.cookie.secure = true; // serve secure cookies
// }
