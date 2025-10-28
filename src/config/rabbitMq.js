import amqplib from "amqplib";

let channel = null;

export const connectToRabbitMq = async () => {
	const connection = await amqplib.connect(process.env.RABBITMQ_URL);
	channel = await connection.createChannel();
	await channel.assertQueue(process.env.RABBITMQ_QUEUE, {
		durable: true,
		arguments: {
			"x-queue-type": "quorum",
		},
	});

	return { connection, channel };
};

export const publishMessage = async (message) => {
	if (!channel) {
		throw new Error("Channel not initialized");
	}

	const messageObject = {
		event_type: message.event_type,
		task_id: message.task_id,
		timestamp: new Date().toISOString(),
		count: 1,
	};

	await channel.sendToQueue(
		process.env.RABBITMQ_QUEUE,
		Buffer.from(JSON.stringify(messageObject)),
		{
			persistent: true,
		},
	);
};
