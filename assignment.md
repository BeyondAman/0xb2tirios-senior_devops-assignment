Senior DevOps Engineer Tasks
Test Project : 
https://bitbucket.org/0xb2tirios/bestcity-mvp/src/main/
Task 1 — Containerize the Application : 10 ~ 12 min
Goal : Run the app in Docker.
First, run this project in your local environment to ensure it works properly (don't use Docker).
Requirements :
Add a Dockerfile that:
Builds the React frontend (npm run build).
Runs the Node backend (Express server).
Serves the built frontend in production (e.g. express.static).
Use a multi-stage build if appropriate (build stage + runtime stage).
Use a non-root user in the final image.
Document how to build and run (e.g. docker build -t bestcity . and docker run -p 3099:3099 bestcity).
Ensure the app starts and responds (e.g. at http://localhost:3099).
Deliverable : Working Dockerfile and brief run instructions. In the video: build the image, run the container, and show the app responding.
Task 2 — Local Development with Docker Compose : 8 ~ 10 min
Goal : Provide a one-command local dev environment.
Requirements :
Add a docker-compose.yml that:
Runs the BestCity app (from the Dockerfile or a dev override).
Runs MongoDB (or another DB used by the app) as a service.
Sets env vars (e.g. MONGODB_URI, PORT) via .env or environment in compose.
Optionally add a docker-compose.override.yml for dev (e.g. hot reload, different ports).
Document how to start (docker-compose up) and stop the stack.
Ensure the backend can connect to the database when started with docker-compose up.
Deliverable : Working docker-compose.yml (and override if used). In the video: run docker-compose up, show services starting, and briefly explain the setup.
Task 3 — CI Pipeline for Build and Test : 10 ~ 12 min
Goal : Automate build, lint, and test in CI.
Requirements :
Add a CI workflow (e.g. GitHub Actions in .github/workflows/ci.yml):
Trigger on push to main and on pull requests.
Use Node.js (version aligned with the project).
Steps:
Checkout code.
Install dependencies (npm ci).
Run lint (npm run lint if present, or npx eslint .).
Run tests (npm test).
Build the app (npm run build).
Fail the job if any step fails.
If lint or test scripts are missing, add minimal ones or document what would be run.
Document how to run the same steps locally.
Deliverable : Working CI workflow. In the video: trigger a run (push or PR), show a green run, and explain how you’d add deployment or security checks.