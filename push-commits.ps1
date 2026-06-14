# TalentIQ — staged multi-commit push script
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

function Commit-Files {
    param([string]$Message, [string[]]$Paths)
    if ($Paths.Count -eq 0) { return }
    git add -- $Paths
    $staged = git diff --cached --name-only
    if ($staged) {
        git commit -m $Message
        Write-Host "OK: $Message"
    } else {
        Write-Host "SKIP (no files): $Message"
    }
}

$commits = @(
    @{ M = "chore: add project license and gitignore"; P = @(".gitignore", "LICENSE") },
    @{ M = "chore: add workspace root configuration"; P = @("package.json", "package-lock.json") },
    @{ M = "docs: add project README"; P = @("README.md") },
    @{ M = "docs: add deployment guide"; P = @("DEPLOY.md") },
    @{ M = "chore: add docker-compose development configuration"; P = @("docker-compose.yml") },
    @{ M = "chore: add docker-compose production overrides"; P = @("docker-compose.prod.yml") },
    @{ M = "chore: add development helper scripts"; P = @("dev.ps1", "init.ps1") },
    @{ M = "docs: add platform screenshots"; P = @("screenshots") },
    @{ M = "ci: add mobile CI workflow"; P = @(".github") },

    @{ M = "chore(backend): add Python dependencies and Docker setup"; P = @("backend/requirements.txt", "backend/Dockerfile", "backend/run_server.py", "backend/start.sh") },
    @{ M = "chore(backend): add environment variables template"; P = @("backend/.env.example") },
    @{ M = "feat(backend): add core database and redis configuration"; P = @("backend/src/core/db.py", "backend/src/core/redis.py") },
    @{ M = "feat(backend): add Clerk authentication module"; P = @("backend/src/core/auth.py") },
    @{ M = "feat(backend): add OpenRouter LLM client and feature flags"; P = @("backend/src/core/openrouter_client.py", "backend/src/core/feature_flags.py") },
    @{ M = "feat(backend): add SQLAlchemy user and profile models"; P = @("backend/src/models/user.py", "backend/src/models/__init__.py") },
    @{ M = "feat(backend): add resume and job database models"; P = @("backend/src/models/resume.py", "backend/src/models/job.py") },
    @{ M = "feat(backend): add interview and live room database models"; P = @("backend/src/models/interview.py", "backend/src/models/live_room.py") },
    @{ M = "feat(backend): add group chat and embeddings models"; P = @("backend/src/models/group_chat.py", "backend/src/models/embeddings.py") },
    @{ M = "feat(backend): add Pydantic schemas for API validation"; P = @("backend/src/schemas") },
    @{ M = "feat(backend): add static interview and roadmap fallback data"; P = @("backend/src/data") },
    @{ M = "feat(backend): add resume parsing and scoring services"; P = @("backend/src/services/resume_service.py", "backend/src/services/scoring_service.py") },
    @{ M = "feat(backend): add job matching and mock interview services"; P = @("backend/src/services/job_service.py", "backend/src/services/mock_interview_service.py") },
    @{ M = "feat(backend): add AI copilot, Stream, and code execution services"; P = @("backend/src/services/ai_copilot_service.py", "backend/src/services/stream_service.py", "backend/src/services/code_execution_service.py") },
    @{ M = "feat(backend): add authentication API routes"; P = @("backend/src/api/auth_router.py") },
    @{ M = "feat(backend): add resume API routes"; P = @("backend/src/api/resume_router.py") },
    @{ M = "feat(backend): add job and matching API routes"; P = @("backend/src/api/job_router.py") },
    @{ M = "feat(backend): add AI copilot API routes"; P = @("backend/src/api/ai_router.py") },
    @{ M = "feat(backend): add mock interview API routes"; P = @("backend/src/api/interview_router.py") },
    @{ M = "feat(backend): add live interview room API routes"; P = @("backend/src/api/live_room_router.py") },
    @{ M = "feat(backend): add application tracker API routes"; P = @("backend/src/api/tracker_router.py") },
    @{ M = "feat(backend): add analytics API routes"; P = @("backend/src/api/analytics_router.py") },
    @{ M = "feat(backend): add collaborative groups API routes"; P = @("backend/src/api/group_router.py") },
    @{ M = "feat(backend): add FastAPI application entry point"; P = @("backend/src/main.py") },
    @{ M = "feat(backend): add Celery worker and background tasks"; P = @("backend/src/workers") },
    @{ M = "chore(backend): add Alembic migrations setup"; P = @("backend/alembic.ini", "backend/alembic") },
    @{ M = "chore(backend): add utility scripts and API contract tests"; P = @("backend/scripts", "backend/tests") },

    @{ M = "chore(frontend): add Next.js configuration and dependencies"; P = @("frontend/package.json", "frontend/next.config.ts", "frontend/tsconfig.json", "frontend/eslint.config.mjs", "frontend/postcss.config.mjs", "frontend/next-env.d.ts", "frontend/Dockerfile") },
    @{ M = "docs(frontend): add design system documentation"; P = @("frontend/README.md", "frontend/AGENTS.md", "frontend/CLAUDE.md", "frontend/design-showcase.html") },
    @{ M = "style(frontend): add global styles and theme provider"; P = @("frontend/src/app/globals.css", "frontend/src/lib/ThemeProvider.tsx", "frontend/retheme.js", "frontend/tailwind-retheme.js") },
    @{ M = "feat(frontend): add API client and shared utilities"; P = @("frontend/src/lib/api.ts", "frontend/src/lib/featureFlags.ts", "frontend/src/lib/utils.ts", "frontend/src/middleware.ts") },
    @{ M = "feat(frontend): add glassmorphism UI component library"; P = @("frontend/src/components/ui", "frontend/src/components/ui-custom.tsx") },
    @{ M = "feat(frontend): add Three.js 3D visualization components"; P = @("frontend/src/components/3d") },
    @{ M = "feat(frontend): add layout components"; P = @("frontend/src/components/Navbar.tsx", "frontend/src/components/Footer.tsx", "frontend/src/components/DashboardLayout.tsx", "frontend/src/app/layout.tsx", "frontend/src/app/favicon.ico") },
    @{ M = "feat(frontend): add landing page"; P = @("frontend/src/app/page.tsx") },
    @{ M = "feat(frontend): add authentication routes"; P = @("frontend/src/app/(auth)") },
    @{ M = "feat(frontend): add career dashboard"; P = @("frontend/src/app/dashboard") },
    @{ M = "feat(frontend): add AI resume analyzer page"; P = @("frontend/src/app/resume") },
    @{ M = "feat(frontend): add job analysis and matching page"; P = @("frontend/src/app/job-analysis") },
    @{ M = "feat(frontend): add AI career copilot page"; P = @("frontend/src/app/copilot") },
    @{ M = "feat(frontend): add mock interview suite"; P = @("frontend/src/app/mock-interview") },
    @{ M = "feat(frontend): add live interview room page"; P = @("frontend/src/app/live-interview") },
    @{ M = "feat(frontend): add interview replay page"; P = @("frontend/src/app/interview-replay") },
    @{ M = "feat(frontend): add application tracker page"; P = @("frontend/src/app/tracker") },
    @{ M = "feat(frontend): add skill-gap roadmap page"; P = @("frontend/src/app/roadmap") },
    @{ M = "feat(frontend): add career analytics page"; P = @("frontend/src/app/analytics") },
    @{ M = "feat(frontend): add talent groups collaboration page"; P = @("frontend/src/app/groups") },
    @{ M = "feat(frontend): add StudyNotion integration page"; P = @("frontend/src/app/studynotion") },
    @{ M = "chore(frontend): add public assets"; P = @("frontend/public") },

    @{ M = "chore(mobile): add Flutter project configuration"; P = @("mobile/pubspec.yaml", "mobile/pubspec.lock", "mobile/analysis_options.yaml", "mobile/.metadata", "mobile/web") },
    @{ M = "docs(mobile): add mobile app documentation"; P = @("mobile/README.md") },
    @{ M = "feat(mobile): add app entry point and core configuration"; P = @("mobile/lib/main.dart", "mobile/lib/app") },
    @{ M = "feat(mobile): add network layer and storage utilities"; P = @("mobile/lib/core") },
    @{ M = "feat(mobile): add shared widgets and theme"; P = @("mobile/lib/shared") },
    @{ M = "feat(mobile): add authentication feature module"; P = @("mobile/lib/features/auth") },
    @{ M = "feat(mobile): add dashboard feature module"; P = @("mobile/lib/features/dashboard") },
    @{ M = "feat(mobile): add resume feature module"; P = @("mobile/lib/features/resume") },
    @{ M = "feat(mobile): add job analysis feature module"; P = @("mobile/lib/features/job_analysis") },
    @{ M = "feat(mobile): add interview feature module"; P = @("mobile/lib/features/interview") },
    @{ M = "feat(mobile): add copilot feature module"; P = @("mobile/lib/features/copilot") },
    @{ M = "feat(mobile): add roadmap feature module"; P = @("mobile/lib/features/roadmap") },
    @{ M = "feat(mobile): add application tracker feature module"; P = @("mobile/lib/features/tracker") },
    @{ M = "feat(mobile): add groups feature module"; P = @("mobile/lib/features/groups") },
    @{ M = "feat(mobile): add analytics feature module"; P = @("mobile/lib/features/analytics") },
    @{ M = "test(mobile): add mobile app tests"; P = @("mobile/test") }
)

foreach ($c in $commits) { Commit-Files -Message $c.M -Paths $c.P }

# Catch any remaining tracked files
git add -A
$remaining = git diff --cached --name-only
if ($remaining) {
    git commit -m "chore: add remaining project files"
    Write-Host "OK: chore: add remaining project files"
}

Write-Host ""
Write-Host "Total commits: $(git rev-list --count HEAD)"
