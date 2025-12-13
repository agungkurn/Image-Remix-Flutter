# redraw

Your image. Redrawn.

## Getting Started

- Connect to your Firebase Project with FlutterFire first.
- Run this command on the root project directory to generate freezed code:

```shell

dart run build_runner build --delete-conflicting-outputs
```

## Architecture

This project is using BLoC+Repository with GetIt as dependency injection.

## Security Approach

- Exclude files with API keys or credentials from Git repository