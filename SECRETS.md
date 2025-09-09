# 🔐 Secret Management

This template uses **GitHub Actions → Cloud Run** for secret management - the simplest and most cost-effective approach.

## How it Works

1. **Store secrets** in GitHub Repository Settings → Secrets and variables → Actions
2. **Deploy with secrets** - GitHub Actions injects them as environment variables during Cloud Run job deployment
3. **dlt picks them up** automatically using its native configuration system

## Setup Instructions

### 1. Add Secrets to GitHub

Go to your repository → Settings → Secrets and variables → Actions:

**Repository Secrets:**
- `WEATHER_API_KEY` - Your weather API key
- `GCP_SERVICE_ACCOUNT_KEY_DEV` - Service account JSON for dev environment  
- `GCP_SERVICE_ACCOUNT_KEY_PRD` - Service account JSON for prod environment

**Repository Variables:**
- `GCP_PROJECT_ID` - Base project ID (without -dev/-prd suffix)
- `CLIENT_SLUG` - Your client identifier
- `GCP_REGION` - GCP region (e.g., us-central1)

### 2. Secret Naming Convention

The template uses dlt's standard naming convention:

```bash
# Weather API
SOURCES__WEATHER_API__API_KEY=your-weather-api-key

# Google Sheets  
SOURCES__GOOGLE_SHEETS__CREDENTIALS_PATH=/tmp/google-sheets-creds.json
```

### 3. Local Development

For local development, create `.dlt/secrets.toml`:

```toml
[sources.weather_api]
api_key = "your-local-weather-api-key"

[sources.google_sheets]  
credentials_path = "/path/to/local/credentials.json"

[destination.bigquery]
project_id = "your-dev-project-id"
```

## Benefits

✅ **Free** - No additional GCP costs (part of GitHub)  
✅ **Simple** - No extra infrastructure to manage  
✅ **Secure** - Secrets encrypted at rest in GitHub  
✅ **dlt Native** - Works seamlessly with dlt's config system  

## Limitations

❌ **Redeploy required** - Secret rotation requires redeployment  
❌ **GitHub dependent** - Secrets only live in GitHub Actions context

## Adding New Secrets

1. Add to GitHub Actions secrets
2. Update the deployment step in `.github/workflows/deploy-cloud-run-jobs.yml`:

```yaml
--set-env-vars="SOURCES__YOUR_SOURCE__SECRET_NAME=${{ secrets.YOUR_SECRET }}" \
```

That's it! dlt will automatically pick up the secret using its naming convention.