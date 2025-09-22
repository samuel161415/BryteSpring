# Digital Ocean Deployment Guide for Flutter Mobile App

## 🎯 Quick Answer to Your Question

**What is `WORKDIR /app`?**
- `WORKDIR /app` sets the working directory inside the Docker container to `/app`
- When Flutter builds your web app, it creates files in `/app/build/web`
- **For Digital Ocean Output Directory, use: `/app/build/web`**

## 📋 Digital Ocean Configuration

### Step 1: Update Configuration File

1. Edit `/mobile/.do/app-static.yaml`
2. Replace `YOUR-GITHUB-USERNAME/YOUR-REPO-NAME` with your actual GitHub repository path

### Step 2: Digital Ocean App Platform Settings

When creating your app in Digital Ocean:

1. **App Type**: Static Site
2. **Source Directory**: `/mobile`
3. **Build Strategy**: Dockerfile
4. **Output Directory**: `/app/build/web` ← **This is the key setting!**

### Step 3: Manual Configuration (If Auto-Detection Fails)

If Digital Ocean doesn't auto-detect your configuration:

1. **Select "Static Site"** manually
2. **Configure these settings**:
   - **Source Directory**: `/mobile`
   - **Build Command**: `flutter pub get && flutter build web --release`
   - **Output Directory**: `/app/build/web`
   - **Dockerfile Path**: `mobile/Dockerfile`

## 🔧 Understanding Your Dockerfile

```dockerfile
WORKDIR /app                    # Sets working directory to /app
COPY pubspec.yaml pubspec.lock ./ # Copies dependency files
RUN flutter pub get             # Installs dependencies
COPY . ./                      # Copies your Flutter code
RUN flutter build web --release # Builds web app → creates /app/build/web/
```

**The built files end up in `/app/build/web/`** - this is what Digital Ocean needs!

## 🚀 Deployment Steps

### 1. Prepare Your Repository

```bash
# Make sure you're in your project root
cd /path/to/your/bnw/project

# Add and commit the Digital Ocean config
git add mobile/.do/
git commit -m "Add Digital Ocean deployment configuration"
git push origin main
```

### 2. Deploy on Digital Ocean

1. **Go to DigitalOcean App Platform**
2. **Click "Create App"**
3. **Select "GitHub"** as source
4. **Choose your repository** (the one with both mobile and backend folders)
5. **Select branch** (usually `main`)
6. **Choose "Static Site"**
7. **Configure manually**:
   - **Source Directory**: `/mobile`
   - **Build Strategy**: Dockerfile
   - **Output Directory**: `/app/build/web`

### 3. Alternative: Use Configuration File

If you prefer using the configuration file:

1. **Upload `.do/app-static.yaml`** to your repository root
2. **Digital Ocean will auto-detect** the configuration
3. **Update the GitHub repository path** in the config file

## 🔍 Troubleshooting

### Common Issues:

1. **"Output directory is required"**
   - ✅ **Solution**: Use `/app/build/web` as the output directory

2. **"No component detected"**
   - ✅ **Solution**: Manually select "Static Site" and configure

3. **Build fails**
   - ✅ **Check**: Flutter version compatibility
   - ✅ **Check**: All dependencies in `pubspec.yaml`

4. **App doesn't load**
   - ✅ **Check**: Build completed successfully
   - ✅ **Check**: Output directory is correct (`/app/build/web`)

### Debug Commands:

```bash
# Test build locally
cd mobile
flutter pub get
flutter build web --release

# Check if build output exists
ls -la build/web/
```

## 📁 File Structure After Build

```
mobile/
├── Dockerfile
├── .do/
│   └── app-static.yaml
├── build/
│   └── web/          ← Digital Ocean serves files from here
│       ├── index.html
│       ├── main.dart.js
│       └── assets/
└── ... (other Flutter files)
```

## 💡 Key Points

1. **`WORKDIR /app`** creates the `/app` directory inside the container
2. **`flutter build web --release`** creates `/app/build/web/` with your static files
3. **Digital Ocean needs `/app/build/web`** as the output directory
4. **Source directory should be `/mobile`** since your Dockerfile is in the mobile folder

## 🌐 After Deployment

1. **Your app will be available** at the Digital Ocean provided URL
2. **Add custom domain** in app settings if needed
3. **Update DNS records** as instructed by Digital Ocean

## 💰 Cost Optimization

- **Static Site**: Cheaper option, perfect for Flutter web apps
- **Service**: More expensive, only needed for server-side features

---

**Remember**: The key setting is **Output Directory: `/app/build/web`** - this tells Digital Ocean where to find your built Flutter web files!
