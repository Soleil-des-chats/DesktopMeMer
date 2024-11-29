# DesktopMeMer

**DesktopMeMer** is a Windows desktop application that allows you to open and view **Wacky WebM** files in scalable, resizable windows. It offers unique features such as **directional audio**, where the sound changes based on the window's position on your screen, and configurable options for playback and window behavior. You can easily configure the app with a `config.json` file, or use **.zip** and **.dsmm** files that bundle both WebM content and specific settings.

## Features

- **Open WebM files by dragging and dropping** them onto the app's executable.
- **Directional sound**: Audio is dynamically adjusted based on where the window is located on your screen.
- **Customizable configuration**: Adjust settings such as window size, volume, and audio behavior via a `config.json` file.
- **Support for .zip and .dsmm files**: Package WebM videos with their associated configuration into a single file.

## Building

To build **DesktopMeMer** from source, follow the steps below:

### Prerequisites

- Windows environment (requires `.bat` scripts).
- Development environment with git installed.

### Steps to Build

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Soleil-des-chats/DesktopMeMer.git
   cd DesktopMeMer
   ```

2. **Run the Setup Project**:
   This script will set up dependencies and prepare your build environment.
   ```bash
   SetupProject.bat
   ```

3. **Build the project**:
   After setting up, build the application using:
   ```bash
   BuildProject.bat
   ```

   > **Note:** The `config.json` file is bundled inside the app during the build process, so it cannot be easily modified post-build. If you need to make changes, modify the `config.json` before building.

## Usage

To launch **DesktopMeMer**, simply **drag and drop** a WebM file onto the app's executable (`DskMeM.exe`). The app will open the WebM in a window. 

### Controls

- **Resize the window**: You can drag the corners of the window to scale the WebM display.
- **Directional Sound**: If enabled in the configuration, the sound will adjust dynamically depending on the window's position on your screen.
- **Volume**: Adjust the volume based on your system settings or modify the `config.json` to set it by default.

## Configuration

The app uses a `config.json` file to configure settings such as the window size, volume, and audio behavior. Here's an example configuration:

### Example `config.json`

```json
{
  "directionalSound": false,
  "volume": 1,
  "sizeRatio": 0.75
}
```

### Configuration Options:

- **`directionalSound`**: A boolean that enables or disables directional audio. When enabled, the sound adjusts based on where the window is positioned on your screen, creating a spatial audio effect.
- **`volume`**: The volume of the WebM playback. The value can range from `0` (muted) to `1` (maximum volume).
- **`sizeRatio`**: The default size ratio of the WebM window relative to the screen. For example, `0.75` would make the window 75% of the screen's width and height.

### Config in `.dsmm` and `.zip` Files

- **.dsmm** and **.zip** files can contain their own `config.json` file, which allows you to override the default settings for specific WebM files.
- When you drop a `.dsmm` or `.zip` file on the app, the configuration within that file will be applied automatically.

## Contributing

We welcome contributions! To contribute to **DesktopMeMer**, follow these steps:

1. Fork the repository.
2. Create a branch for your changes.
3. Submit a pull request with a description of your changes.

Ensure that your contributions are well-documented and include unit tests where appropriate.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Thanks to the WebM developers for their high-quality video compression format.
- Thanks to everyone who has contributed to making **DesktopMeMer** better!

---

If you have any questions or feedback, feel free to open an issue in the repository or contact me directly.
