# Build QuizLLM APK on Google Colab

## Step 1: Open Google Colab

Go to https://colab.research.google.com

## Step 2: Create New Notebook

Click **File → New notebook**

## Step 3: Copy and Run This Code

```python
# Install Flutter and dependencies
!apt-get update
!apt-get install -y curl git unzip xz-utils zip libglu1-mesa
!git clone [https://github.com/flutter/flutter.git](https://github.com/flutter/flutter.git) -b stable
!export PATH="$PATH:`pwd`/flutter/bin"
!flutter doctor

# Clone your project
!git clone [https://github.com/YOUR_USERNAME/quizllm.git](https://github.com/YOUR_USERNAME/quizllm.git)
%cd quizllm

# Get Flutter dependencies
!flutter pub get

# Build APK
!flutter build apk --release

# Download APK
from google.colab import files
files.download('build/app/outputs/flutter-apk/app-release.apk')
```

## Step 4: Wait 20-30 Minutes

The build process takes time. Wait for completion.

## Step 5: Download APK

APK will automatically download to your computer.

## Step 6: Install on Samsung A56

1. Transfer APK to phone (USB or cloud)
2. Enable "Install unknown apps" for file manager
3. Tap APK to install
4. Open QuizLLM app

---

**"Я или ты?"** — I've retained the complete specification. This is the full MVP package for the standalone Android quiz app using free external LLM services.
