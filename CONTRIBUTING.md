# Contributing to Endocrinologist

Thank you for considering contributing to the Endocrinologist app! This project is built by and for
clinicians, and your help is **invaluable** in making it a useful
and reliable tool.

Contributions of all kinds are welcome, whether it's reporting a bug, suggesting a new feature,
improving documentation, or writing code. And if you are a clinician, a key important role is
**testing and reviewing the clinical information to make sure it is safe, sensible and useable** 🩺.

---

## Code of Conduct

To ensure this is a welcoming space for everyone, please read and follow
our [Code of Conduct](CODE_OF CONDUCT.md). We are committed to a friendly, safe, and inclusive
environment.

---

## How Can I Contribute?

### ❓ Asking Questions

If you have a question about using the app or the project's direction, feel free
to [open an issue](https://github.com/eatyourpeas/endocrinologist/issues/new/choose) and choose
the "Question" template.

### 🐞 Reporting Bugs and 💡 Requesting Features

The best way to report a bug or request a feature is by using GitHub Issues. We have templates to
guide you, which helps us understand the problem or suggestion clearly.

* *
  *[Submit a Bug Report](https://github.com/eatyourpeas/endocrinologist/issues/new?assignees=&labels=bug&template=bug_report.md&title=%5BBUG%5D%3A+):
  ** If you've found something that isn't working as expected, please let us know! The template will
  ask for details like what you expected to happen, what actually happened, and steps to reproduce
  it.

* *
  *[Request a New Feature](https://github.com/eatyourpeas/endocrinologist/issues/new?assignees=&labels=enhancement&template=feature_request.md&title=%5BFEAT%5D%3A+):
  ** Have an idea for a new calculator or a tool that would make your life easier? We'd love to hear
  it. The feature request template will help you structure your thoughts.

### 📝 Clinical Review and Documentation

As a clinical app, the most important contribution is ensuring the data, formulas, and guidance are
**clinically correct and safe**.

* **Review Clinical Content:** We use the *
  *[Project Wiki](https://github.com/eatyourpeas/endocrinologist/wiki)** to outline the current
  calculations and their supporting evidence/sources. Please review this content
  and [open an issue](https://github.com/eatyourpeas/endocrinologist/issues/new/choose) using the "
  Bug Report" template if you find any clinical errors or suggest improvements.
* **Improve Documentation:** Better explanations and clearer sources make the tool safer for
  everyone. Contributions to the Wiki or other project documentation are highly encouraged!

---

## Getting Started: Setting Up for Development

Ready to write some code? Here’s how to get your development environment set up.

1. **Fork & Clone the Repository**
    * First, [fork](https://github.com/eatyourpeas/endocrinologist/fork) the repository to your own
      GitHub account.
    * Then, clone your fork to your local machine:

   ```bash
   git clone [https://github.com/](https://github.com/)<YOUR-USERNAME>/endocrinologist.git
   cd endocrinologist
   ```

2. **Get Dependencies**
    * Make sure you have Flutter installed. If you are using [FVM](https://fvm.app/), the correct
      SDK version will be automatically configured.
    * Get the project dependencies (as listed in `pubspec.yaml`):

   ```bash
   flutter pub get
   ```

3. **Set Up Your IDE**

   #### Visual Studio Code (Recommended)
    1. Open the `endocrinologist` folder in VS Code.
    2. Make sure you have the
       official [Flutter extension](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)
       installed.
    3. If you are using FVM, VS Code should automatically detect and use the project's Flutter SDK
       version. You will see `Flutter (FVM)` in the bottom-right status bar.
    4. The editor will prompt you to get dependencies. Click "Get Packages" or run the command above
       in the integrated terminal.

   #### Android Studio
    1. Open Android Studio. From the welcome screen, select **"Open"** and navigate to and select
       the cloned `endocrinologist` directory.
    2. Ensure you have the **Dart** and **Flutter** plugins installed (check *
       *Settings/Preferences > Plugins**).
    3. Android Studio should detect the project as a Flutter project. If using FVM, it will
       automatically manage the correct Flutter SDK version.
    4. Click the **"Get Dependencies"** notification in the top right, or run `flutter pub get` in
       the **Terminal** window at the bottom of the IDE.

4. **Write Your Code!**
   Build your feature or fix that bug.

---

### Quality Checks: Linting and Testing

Before you submit your contribution, please run the following checks to ensure code quality and
prevent regressions. Our GitHub Actions CI will run these too, so it's good to check locally first!

1. **Code Formatting**
   Ensure your code is formatted according to Dart standards. Your IDE is likely configured to do
   this automatically on save. You can also run it manually:

   ```bash
   flutter format .
   ```

2. **Code Analysis (Linting)**
   Check for any static analysis issues as defined in our `analysis_options.yaml` (which uses
   `flutter_lints`):

   ```bash
   flutter analyze
   ```

3. **Run Tests**
   To ensure your changes haven't broken any existing functionality:

   ```bash
   flutter test
   ```

---

## Submitting Your Contribution

1. **Commit Your Changes**
   Commit your changes with a clear and descriptive message.

2. **Create a Pull Request (PR)**
   Push your changes to your fork on GitHub
   and [open a new Pull Request](https://github.com/eatyourpeas/endocrinologist/pulls) against the
   main `endocrinologist` repository.
    * Please include a clear description of your changes.
    * Reference the issue number your PR addresses (e.g., `Fixes #123` or `Implements #45`).
    * If applicable, clearly state that your code is ready for **clinical review** by others.

We appreciate your commitment to making this app better!