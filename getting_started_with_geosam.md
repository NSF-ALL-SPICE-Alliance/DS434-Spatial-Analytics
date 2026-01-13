# Getting Started with geosam

A step-by-step guide for setting up and using the `geosam` package for object detection in satellite imagery using Meta's SAM3 model.

**Official Documentation**: [walker-data.com/geosam](https://walker-data.com/geosam/)  
**Getting Started Vignette**: [Getting started with geosam](https://walker-data.com/geosam/articles/getting-started.html)

---

## Overview

The `geosam` package brings Meta's Segment Anything Model 3 (SAM3) to R for detecting objects in satellite imagery and photos. You can describe what you're looking for in plain text—no training data or model fine-tuning required.

**Estimated setup time**: 30-45 minutes

---

## Step 1: Install the R Package

Install the development version from GitHub:
```r
# Install remotes if you don't have it
install.packages("remotes")

# Install geosam
remotes::install_github("walkerke/geosam")
```

Or using `pak`:
```r
pak::pak("walkerke/geosam")
```

---

## Step 2: Create a HuggingFace Account

1. Go to [huggingface.co](https://huggingface.co/)
2. Click "Sign Up" and create a free account
3. Verify your email address

---

## Step 3: Request Access to SAM3 Model

1. Visit the [SAM3 model page](https://huggingface.co/facebook/sam3)
2. Click "**Request access**" button
3. Access is typically granted within a few minutes to a few hours

---

## Step 4: Create a HuggingFace Access Token

1. Log into your HuggingFace account
2. Go to **Settings** > **Access Tokens**
3. Click "**New token**"
4. Name it (e.g., "geosam")
5. Select "**Read**" permissions (sufficient for downloading models)
6. Click "**Generate token**"
7. **Copy the token** (starts with `hf_...`)

### Add your token to .Renviron
```r
# Open your .Renviron file
usethis::edit_r_environ()

# Add this line (replace with your actual token):
HF_TOKEN=hf_xxxxxxxxxxxxxxxxxxxxx

# Save, close, and restart R
```

---

## Step 5: Set Up Python Environment

Load the package and install the Python environment:
```r
library(geosam)
geosam_install()
```

### Troubleshooting Python Installation

If `geosam_install()` fails, try these alternatives:

**If you get "uv is not installed":**
```r
# Use virtualenv instead
geosam_install(method = "virtualenv")
```

**If using conda and you have Python 3.11+ available:**
```r
# Use conda's Python for virtualenv
geosam_install(
  method = "virtualenv",
  python_version = "/opt/anaconda3/bin/python3"
)
```

**If conda fails with architecture errors (Mac M1/M2/M3):**
```r
# Force ARM64 architecture
Sys.setenv(CONDA_SUBDIR = "osx-arm64")
geosam_install(method = "conda")
```

---

## Step 6: Fix Spatial Libraries (Critical Step!)

This is the most common issue. The `sf` and `terra` packages need to be properly configured to work with PROJ/GDAL.

### 6a. Reinstall sf and terra from source

This ensures they're compiled against your current PROJ installation:
```r
install.packages(c("sf", "terra"), type = "source")
```

**Note**: This may take 5-10 minutes as it compiles from source.

### 6b. Find your PROJ database location

**On macOS:**

First, check if the generic path exists (recommended, as it's version-agnostic):
```r
# Check for generic path
system("ls -la /opt/homebrew/share/proj/proj.db")
```

If that file exists, you'll use `/opt/homebrew/share/proj` in the next step.

If the generic path doesn't exist, find the version-specific path:
```r
# Find version-specific path
system("find /opt/homebrew -name proj.db 2>/dev/null")
# Or for Intel Macs:
system("find /usr/local -name proj.db 2>/dev/null")
```

You'll get output like:
```
/opt/homebrew/Cellar/proj/9.4.1/share/proj/proj.db
```

### 6c. Set PROJ_LIB environment variable
```r
# Open .Renviron
usethis::edit_r_environ()

# Add ONE of these lines based on what you found in step 6b:

# Option 1: If generic path exists (recommended):
PROJ_LIB=/opt/homebrew/share/proj

# Option 2: If only version-specific path exists:
PROJ_LIB=/opt/homebrew/Cellar/proj/9.4.1/share/proj

# Save, close, and RESTART R completely
```

**Note**: After reinstalling sf/terra from source, you may not need the PROJ_LIB variable at all. Test your setup in Step 7 first, and only add PROJ_LIB if you still get PROJ errors.

---

## Step 7: Verify Your Setup

After restarting R, verify everything is working:
```r
library(geosam)

# Check geosam status
geosam_status()
```

You should see all green checkmarks:
```
── geosam Status ───────────────────────────────────────────
✔ Environment: virtualenv at ~/.../geosam
✔ Python: 3.11
✔ PyTorch 2.9.1: MPS (Apple Silicon) or CPU
✔ transformers: available (SAM3 via HuggingFace)
✔ HuggingFace token: configured
```

---

## Step 8: Set Up Imagery API Keys (Optional)

For satellite imagery, you can use Mapbox for high-quality imagery or Esri for free access.

### Mapbox (High Quality)

1. Create account at [mapbox.com](https://www.mapbox.com/)
2. Get your public token from your account dashboard
3. Add to .Renviron:
```r
# Open your .Renviron file
usethis::edit_r_environ()

# Add this line (replace with your actual token):
MAPBOX_PUBLIC_TOKEN=pk.xxxxxxxxxxxxxxxxxxxxx

# Save, close, and restart R
```

### Esri (Free, No Account Needed)

No setup required! Just use `source = "esri"` in your detection calls.

---

## Your First Detection

### Example: Detect football fields
```r
library(geosam)

# Detect football fields at TCU campus
field <- sam_detect(
  bbox = c(-97.372, 32.707, -97.366, 32.712),
  text = "football field",
  source = "esri",  # Free, no API key needed
  zoom = 17
)

# View results
plot(field)
```



---

## Common Issues & Solutions

### "cannot transform sfc object with missing crs"

**Solution**: Add PROJ_LIB to your .Renviron file (Step 6c) and restart R. Make sure you've also reinstalled sf/terra from source (Step 6a).

### "Could not find a version that satisfies the requirement torch>=2.7"

**Solution**: You need Python 3.9 or newer. Use Anaconda's Python:
```r
geosam_install(
  method = "virtualenv",
  python_version = "/opt/anaconda3/bin/python3"
)
```

### "PROJ: proj_create_from_database: Cannot find proj.db"

**Solution**: PROJ_LIB path is incorrect or not set. Follow Steps 6b and 6c to find the correct path and add it to your .Renviron file.

### Version mismatch (e.g., sf wants 9.5.1 but you have 9.4.1)

**Solution**: Update PROJ via Homebrew:
```bash
# In terminal
brew upgrade proj
```

Then restart R and reinstall sf/terra from source (Step 6a).

---

## Tips for Success

1. **Always use .Renviron** for environment variables (HF_TOKEN, MAPBOX_PUBLIC_TOKEN, PROJ_LIB)
2. **Restart R completely** after editing .Renviron
3. **Start with small bounding boxes** (~0.005° × 0.005°) to test
4. **Use zoom 18-19 for small objects** like solar panels, cars
5. **Use zoom 15-17 for large objects** like buildings, fields
6. **Try different text prompts** if detection quality is poor
7. **Use Esri source** for quick tests (no API key needed)

---

## Additional Resources

- **Official Documentation**: [walker-data.com/geosam](https://walker-data.com/geosam/)
- **Getting Started Vignette**: [Detailed walkthrough](https://walker-data.com/geosam/articles/getting-started.html)
- **Satellite Imagery Detection**: [Advanced techniques](https://walker-data.com/geosam/articles/satellite-imagery.html)
- **GitHub Issues**: [Report problems](https://github.com/walkerke/geosam/issues)

---

**Questions or issues?** File an issue on [GitHub](https://github.com/walkerke/geosam/issues) or contact Kyle Walker.
