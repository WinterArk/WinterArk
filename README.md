WinterArk App Testing Guide

Thank you for helping test the WinterArk app! This guide will walk you through setting up your environment, running the app, and testing its core features.

Prerequisites
Before you begin, ensure that you have the following installed on your system:

Git – for cloning the repository.
Flutter SDK – for building and running the app.
Android Studio – for managing Android emulators.
Make – to use the provided Makefile commands (usually available on macOS/Linux; Windows users can use an alternative terminal or run the commands manually).

1. Clone the Repository
    Clone the WinterArk repository to your local machine and navigate into the project directory:
    git clone <repository-url>
    cd <repository-directory>

2. Install Flutter Dependencies
    In your terminal, run:
    flutter pub get


3. Setting Up Flutter (If Not Already Installed)
    If you have not yet installed Flutter, follow these steps:
    1. Download Flutter:
        Visit the Flutter installation page and download the appropriate version for your operating system.

    2. Extract and Configure:
        Extract the downloaded archive.
        Add the flutter/bin directory to your system’s PATH.
        For example, on macOS or Linux, you can add the following line to your .bashrc or .zshrc:

    3. Run Flutter Doctor:
        Execute the following command in your terminal:
        flutter doctor
        Follow any recommendations to install missing dependencies (such as additional Android licenses or tools).

4. Install and Set Up Android Studio
    1. Download and Install Android Studio:
        Get it from the Android Studio website.

    2. Set Up an Emulator:
        Open Android Studio.
        Go to AVD Manager (accessible from the toolbar or via Tools > AVD Manager).
        Create and launch a new virtual device (emulator) that meets your testing requirements.

5. Running the App
    With your emulator running, execute the following command in your terminal:
    make run DEVICE=emulator-(#OFYOUREMULATOR)
    Replace (#OFYOUREMULATOR) with the appropriate identifier or number corresponding to your running emulator.
    The app should compile and launch on the emulator shortly.

    Tip: If you prefer, you can run the app using Flutter’s standard command:
    flutter run
    However, the provided Makefile command may include additional configuration specific to WinterArk.

6. Testing the App
    Account Creation
    1. Sign Up:
        When the app starts, tap the Sign Up button.
        Enter your Name, Email, and Password to create a new account.
        Upon successful sign-up, your account for WinterArk is created.
    2. Login:
        After account creation, if you wish to test logging in:
        Tap the back arrow in the top left to return to the previous screen.
        Use the same credentials (Email and Password) you just registered to log in.

    This verifies that both account creation and login functionalities are working as expected.

Additional Notes
    Emulator Management:
    Ensure your chosen emulator is running and properly configured before executing the make run command.

    Troubleshooting:
    If you encounter issues, run:
    flutter doctor
    to check for any configuration problems or missing dependencies.

    Further Customizations:
    Feel free to adjust any commands or instructions based on your local development setup or additional testing requirements.

    Happy testing, and thank you for contributing to the WinterArk project!
