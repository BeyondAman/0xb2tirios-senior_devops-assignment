# BestCity

**BestCity** is a real estate investment platform with React frontend and Node/Express backend, used here for the Senior DevOps assignment (containerization, Compose, CI).

---

## Assignment Summary & Deliverables

### Task 1 — Containerize the Application

**Done:** A production Dockerfile builds the React frontend and runs the Node backend in one image.

- **Build stage:** `npm ci --ignore-scripts`, then `npm run build` (React).
- **Runtime stage:** Node 20 Alpine, production deps only, non-root user `appuser`, Express serves the built frontend via `express.static` from `frontend/build`.
- **Build and run:**
  ```bash
  docker build -t bestcity .
  docker run -p 3099:3099 bestcity
  ```
- **Verify:** Open http://localhost:3099 — app should load and respond.

---

### Task 2 — Local Development with Docker Compose

**Done:** One-command stack: app + MongoDB, env vars via compose (and optional `.env`).

- **Files:** `docker-compose.yml` (app + MongoDB), optional `docker-compose.override.yml.example` for dev overrides.
- **Env:** `MONGO_URI`, `PORT` set in compose; default `MONGO_URI=mongodb://mongodb:27017/bestcity`. Copy `.env.docker.example` to `.env` to override.
- **Start:** `docker compose up` (or `docker compose up --build` to rebuild)  
- **Stop:** `docker compose down`  
- Backend connects to MongoDB when both services are up (app `depends_on` mongodb).

---

### Task 3 — CI Pipeline for Build and Test

**Done:** GitHub Actions workflow in `.github/workflows/ci.yml`.

- **Triggers:** Push to `main`, and pull requests targeting `main`.
- **Node:** 20 (aligned with project).
- **Steps:** Checkout → `npm ci --ignore-scripts` → `npm run lint` → `npm run test:ci` → `npm run build`. Job fails if any step fails.
- **Scripts:** `lint` and `test:ci` added in `package.json`; `test:ci` runs Jest with `--watchAll=false --passWithNoTests`.
- **Security audit:** `npm audit --audit-level=high` runs as a CI step. Currently non-blocking (`|| true`) due to upstream dependency vulnerabilities; can be made blocking once dependencies are upgraded.
- **Run the same locally:**
  ```bash
  npm ci --ignore-scripts
  npm run lint
  npm run test:ci
  npm audit --audit-level=high
  npm run build
  ```

#### How I'd Add Deployment Steps

Add a `deploy` job that runs **after** `build-and-test` succeeds. Example flow:

1. **Build and push Docker image** — After the build job passes, build the Docker image in CI and push it to a container registry (e.g. GitHub Container Registry, ECR, Docker Hub).
2. **Deploy to staging** — Use a deployment action or SSH/kubectl step to pull the new image and deploy to staging. Gate this on merge to `main`.
3. **Deploy to production** — Trigger on release tags (`v*`) or via `workflow_dispatch` with manual approval using GitHub Environments protection rules.

```yaml
# Example deploy job (would be added to ci.yml)
deploy:
  needs: build-and-test
  if: github.ref == 'refs/heads/main'
  runs-on: ubuntu-latest
  environment: staging          # GitHub Environment with protection rules
  steps:
    - name: Login to registry
      uses: docker/login-action@v3
      with:
        registry: ghcr.io
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    - name: Build and push image
      run: |
        docker build -t ghcr.io/${{ github.repository }}:${{ github.sha }} .
        docker push ghcr.io/${{ github.repository }}:${{ github.sha }}
    - name: Deploy to staging
      run: echo "Deploy image to staging cluster/server here"
```

#### How I'd Add Security Checks

| Check | Tool | Where |
|---|---|---|
| Dependency vulnerabilities | `npm audit --audit-level=high` | Already in CI (step 5) |
| Static analysis (SAST) | GitHub CodeQL | Add as a separate workflow or job |
| Secret scanning | GitHub Secret Scanning | Enable in repo settings (free for public repos) |
| Container image scanning | Trivy or Docker Scout | Add after Docker image build step |
| Dependency updates | Dependabot | Add `.github/dependabot.yml` |

```yaml
# Example: CodeQL (separate workflow or added as a job)
security:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - uses: github/codeql-action/init@v3
      with:
        languages: javascript
    - uses: github/codeql-action/analyze@v3
```

These checks would block PRs from merging if critical/high issues are found, keeping `main` clean.

---

## Improvements (Recommended Next Steps)

- **CI lifecycle alerts**  
  Notify on success/failure (e.g. Slack, email, GitHub commit status). Use a step at the end of the workflow to call a webhook or Slack Incoming Webhook when the job fails (or on success for deploy jobs). Reduces time to notice broken main.

- **Multi-environment CI (dev, staging, prod)**  
  - **Dev:** Run full CI (lint, test, build) on every push to feature branches and on PRs; optionally deploy to a dev environment on merge to `develop` or on PR label.  
  - **Staging:** On merge to `main`, run the same CI, then deploy the built artifact to staging (e.g. push image to registry, deploy to staging cluster).  
  - **Prod:** On tag (e.g. `v*`) or manual approval, run CI (or reuse staging build), then promote to production with approval gates and rollback plan.

- **Automated promotion model**  
  - Feature/tag branches → CI on every push/PR; optional deploy to **dev** when branch is pushed or when PR is merged to a “dev” branch.  
  - Merge to **main** → CI must pass, then auto-deploy to **staging**.  
  - **Production** → Triggered by release tag (e.g. `v1.0.0`) or by manual workflow_dispatch with approval; deploy only after staging validation.

- **Security and quality**  
  Add a job or step for: `npm audit` (or `npm audit --audit-level=high`), SAST (e.g. CodeQL), and optionally dependency scanning (e.g. Dependabot). Block merge or deploy on critical/high findings.

- **Build artifacts and caching**  
  Cache `node_modules` (or use `actions/cache` with `npm ci`). For deployment, build the Docker image in CI, push to a container registry (e.g. GHCR), and use that image for dev/staging/prod so every env runs the same artifact.

- **Environment and secrets**  
  Use GitHub Environments (e.g. `staging`, `production`) with protection rules and secrets per env. Never log secrets; use short-lived tokens where possible.

---

## How to Run the Project

### 1. Clone or Download the Project locally.

You can clone a Bitbucket project (repository) to your computer using Git.
 
- Click the Clone button (usually near the top-right) on Bitbucket
- Copy the URL shown using HTTPS (simplest)
- Open a command prompt (CMD) in the selected folder (press F4 on your keyboard on folder and type cmd).
- Enter the copied URL in the CMD.
- Open the cloned Project.

If you don't have Git installed, you can download the project as a ZIP file.

- Open the repository on Bitbucket
- Click the ••• (three dots) or Download button (top right)
- Select Download repository
- A ZIP file will be downloaded
- Extract (unzip) it on your computer
- Open the downloaded Project.

### 2. Installing the Runnig Environment

- Install NodeJS ( version 20 or 22 ) : https://nodejs.org/en/download/archive/v20.19.5
- Install VS Code : https://code.visualstudio.com/download

### 3. Run the Project

Open the project in VS Code :

- Open VS Code
- Click File → Open Folder…
- Select the project folder you downloaded or cloned
- Click Open

Run the Project on Terminal :

- Click the top menu Terminal and Select New Terminal
- Install the node module : Enter the **npm install** in the Terminal
- Build the Project : Enter the **npm start** in the Terminal

## Learn More

- You can learn more in the [Create React App documentation](https://facebook.github.io/create-react-app/docs/getting-started).
- To learn React, check out the [React documentation](https://reactjs.org/).

## Core Components

### 1. **Home Page** - Hero Section with value proposition

- Featured Properties Grid (3 properties)
- "Why Choose Us" highlighting crypto benefits
- Investment Guide with step-by-step process
- Blog Preview with latest 3 posts
- Discord Community Section

### 2. **Properties Page**

- Filterable property grid
- Advanced search functionality
- Detailed property cards
- Three.js 3D visualization

### 3. **About Us Page**

- Company vision and mission
- Team profiles
- Platform statistics

### 4. **Blog Section**

- Category filtering
- Search functionality
- Author profiles
- Social sharing buttons

## Development Guidelines

### 1. **Component Creation**

- Follow atomic design principles
- Use TypeScript for type safety
- Implement responsive designs using Tailwind breakpoints
- Add proper comments and documentation

### 2. **State Management**

- Use React Context for global state
- Implement Redux for complex state management
- Keep component state minimal

### 3. **Security Considerations**

- Implement proper input validation
- Secure wallet connections
- Follow best practices for crypto transactions
- Regular security audits

## Contributing

Contributions are welcome! Please:

- Create a feature branch
- Write comprehensive tests
- Document new features
- Ensure code style consistency
- Submit pull requests with clear descriptions

## Acknowledgments

Special thanks to the BestCity team for inspiration and the React/Tailwind CSS communities for their continued support and resources.
