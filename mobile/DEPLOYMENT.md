# Flutter Web Deployment to DigitalOcean App Platform

## 🚀 Deployment Options

### Option 1: Static Site (Recommended)

Use the `.do/app-static.yaml` configuration for a static site deployment.

### Option 2: Service Deployment

Use the `.do/app.yaml` configuration for a full service deployment.

## 📋 Prerequisites

1. **GitHub Repository**: Your Flutter app must be in a GitHub repository
2. **DigitalOcean Account**: Connected to your GitHub account
3. **Flutter Web**: Your app must support web platform

## 🔧 Setup Steps

### Step 1: Update Configuration Files

1. **Update `.do/app-static.yaml`** (or `.do/app.yaml`):

   ```yaml
   github:
     repo: YOUR-GITHUB-USERNAME/YOUR-REPO-NAME
     branch: main
   ```

2. **Replace `YOUR-GITHUB-USERNAME/YOUR-REPO-NAME`** with your actual repository path.

### Step 2: Commit and Push

```bash
git add .
git commit -m "Add DigitalOcean deployment configuration"
git push origin main
```

### Step 3: Deploy on DigitalOcean

1. **Go to DigitalOcean App Platform**
2. **Click "Create App"**
3. **Select "GitHub"** as source
4. **Choose your repository**
5. **Select branch** (usually `main`)
6. **Choose deployment method**:
   - **Static Site**: Use `.do/app-static.yaml`
   - **Service**: Use `.do/app.yaml`

### Step 4: Configure Build Settings

**For Static Site:**

- **Source Directory**: `/mobile`
- **Build Command**: `cd mobile && flutter pub get && flutter build web --release`
- **Output Directory**: `/mobile/build/web`

**For Service:**

- **Source Directory**: `/mobile`
- **Build Command**: `cd mobile && flutter pub get && flutter build web --release`
- **Run Command**: `cd mobile/build/web && python3 -m http.server 8080`
- **HTTP Port**: `8080`

## 🛠️ Manual Configuration (If Auto-Detection Fails)

If DigitalOcean still shows "no component detected":

1. **Select "Static Site"** or **"Service"** manually
2. **Configure manually**:
   - **Source Directory**: `/mobile`
   - **Build Command**: `cd mobile && flutter pub get && flutter build web --release`
   - **Output Directory**: `/mobile/build/web` (for static sites)
   - **Run Command**: `cd mobile/build/web && python3 -m http.server 8080` (for services)

## 🔍 Troubleshooting

### Common Issues:

1. **"No component detected"**

   - Use manual configuration
   - Ensure source directory is `/mobile`

2. **Build fails**

   - Check Flutter version compatibility
   - Ensure all dependencies are in `pubspec.yaml`

3. **App doesn't load**
   - Check if `flutter build web` completed successfully
   - Verify output directory is correct

### Debug Commands:

```bash
# Test build locally
cd mobile
flutter pub get
flutter build web --release

# Check build output
ls -la mobile/build/web/
```

## 📝 Environment Variables

If you need environment variables:

```yaml
envs:
  - key: FLUTTER_WEB_AUTO_DETECT
    value: "true"
  - key: NODE_ENV
    value: "production"
```

## 🌐 Custom Domain

After deployment:

1. **Go to your app settings**
2. **Add custom domain**
3. **Update DNS records** as instructed

## 💰 Cost Optimization

- **Static Site**: Cheaper, good for simple Flutter web apps
- **Service**: More expensive, needed for server-side features

## 📚 Additional Resources

- [DigitalOcean App Platform Docs](https://docs.digitalocean.com/products/app-platform/)
- [Flutter Web Deployment](https://docs.flutter.dev/platform-integration/web)
- [DigitalOcean Static Sites](https://docs.digitalocean.com/products/app-platform/how-to/static-sites/)
