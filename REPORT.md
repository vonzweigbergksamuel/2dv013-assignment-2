# Assignment Report

## 1. Architectural Patterns and Development

### 1.1 Architectural Patterns in Your Solution

**1. Infrastructure as Code (IaC) Pattern**

I used Terraform to define my infrastructure as code. My Terraform files in `infra/terraform/gke/` define the GKE cluster, network, and node pools. This lets me version control infrastructure changes and deploy the same setup to different environments.

```1:36:infra/terraform/gke/cluster.tf
resource "google_container_cluster" "gke" {
  name     = "gke-${lower(var.project_name)}-${var.environment}"
  location = var.zone
  network  = google_compute_network.network.id
  subnetwork = google_compute_subnetwork.subnet.id
  // ... cluster configuration ...
}
```

**2. Event-Driven Architecture Pattern**

Events are published to RabbitMQ when tasks are created, completed, or deleted, decoupling the Taskit service from analytics processing. The controller publishes messages without waiting for consumers, enabling asynchronous processing.

```163:170:src/controllers/TaskController.js
				if (wasDoneModified) {
					const eventType = req.doc.done
						? "task_completed"
						: "task_uncompleted";
					await publishMessage({
						event_type: eventType,
						task_id: req.doc.id,
					});
				}
```

Events are sent to a durable quorum queue configured in `src/config/rabbitMq.js`, enabling the analytics service to process events asynchronously without blocking the main application.

**3. Stateless Application Pattern**

Session state is externalized to Redis instead of pod memory, enabling horizontal scalability. This allows the HorizontalPodAutoscaler to scale pods without session affinity, as any pod can handle any request since session data is centralized in Redis.

```1:20:src/config/sessionOptions.js
import { RedisStore } from "connect-redis";
import { createClient } from "redis";

const redisClient = createClient({
	url: process.env.REDIS_URL || "redis://localhost:6379",
});
await redisClient.connect();

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
```

### 1.2 Debugging in a Cloud-Native Environment

When I scaled the app to multiple pods in Kubernetes, I ran into a problem. My sessions kept getting lost when requests went to different pods.

I checked pod logs with `kubectl logs` and found sessions were stored in each pod's memory. The load balancer was sending requests to different pods, and each pod had its own separate session storage. My app was using Express's default in-memory session store, so when a request went to Pod A, the session was only in Pod A. If the next request went to Pod B, it had no idea about that session.

I fixed it by moving sessions to Redis. I set up `connect-redis` in `src/config/sessionOptions.js` so all pods share the same Redis instance for sessions:

```1:20:src/config/sessionOptions.js
import { RedisStore } from "connect-redis";
import { createClient } from "redis";

const redisClient = createClient({
	url: process.env.REDIS_URL || "redis://localhost:6379",
});
await redisClient.connect();

export const sessionOptions = {
	store: new RedisStore({ client: redisClient }),
	// ... session configuration ...
};
```

What I learned: In Kubernetes, each pod is separate. If I store sessions in a pod's memory, they disappear when requests go to different pods. I need to put any shared data in external storage like Redis, databases, or message queues.

## 2. JTI Implementation and Reflection

### 2.1 The Problem of State

When I first scaled to multiple pods, I immediately hit the session problem. I could create a task, but when I refreshed the page or made another request, my session was gone. Success messages disappeared, and sometimes it looked like I was logged out.

I moved sessions to Redis, which all pods share. Now any pod can read or write sessions to the same Redis instance. With Redis, sessions survive pod restarts and work across all pods. Now my HPA can scale from 1 to 4 pods without breaking sessions.

### 2.2 The Asynchronous Data Flow

When I mark a task as complete, the controller updates the task in MongoDB and publishes an event to RabbitMQ with `event_type: "task_completed"` and the task ID. RabbitMQ stores it in a durable queue. Telegraf consumes the message from RabbitMQ and forwards the event data to InfluxDB with timestamp and metadata. Grafana queries InfluxDB and displays it in the dashboard.

The asynchronous message queue provides a clear benefit at the publishing step. The controller publishes the message and immediately responds without waiting for analytics processing. This decouples the web service from the analytics pipeline.

Without the message queue, my app would need to synchronously write to both MongoDB and InfluxDB in the same request, wait for InfluxDB to finish before responding, and handle InfluxDB failures that could break the app. This would mean slower responses, reduced reliability, and tight coupling between the web service and analytics storage. The message queue allows the web service to remain fast and responsive while analytics processing happens asynchronously in the background.

### 2.3 The Development Environment Trade-off

Using GKE made things a bit easier since Kubernetes was already set up. I just had to get my app deployed to the cluster. But it was really hard to deploy it with GKE when I have never really used Google Cloud before. How it all connected together was really difficult to comprehend - understanding how Terraform, GKE, Cloud Build, container registry, and all the services connected was overwhelming at first.

Working in Kubernetes meant my dev environment was close to production. I caught issues like the session problem early. With HPA, I could test real scaling behavior. I saw how the app handled multiple pods, which quickly revealed the session issue. This wouldn't have been possible with a simple local setup.

Cloud Build worked as my CI/CD pipeline to deploy to the cluster. This helped a lot since I didn't have to manually SSH in and figure out how to deploy everything to the cluster myself.

The frustrating part was debugging. When Telegraf wasn't working, finding the problem took forever. I had to check Telegraf logs, verify RabbitMQ connections, check InfluxDB settings, and validate environment variables. A simple typo in `telegraf.conf` took a long time to find because the error wasn't obvious. Also, every small code change meant rebuilding the Docker image, pushing it, updating the deployment, and waiting for pods to restart. What takes seconds locally took minutes in Kubernetes.

In the end, using GKE and Kubernetes was valuable. I got to learn Google Cloud Platform and how everything works together. The slower development was worth it for this assignment, but in real work I'd use a mix: develop locally with docker-compose, then test in Kubernetes.

