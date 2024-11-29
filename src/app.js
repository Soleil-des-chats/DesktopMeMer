const fs = require('fs');
const gui = require('nw.gui');
const win = gui.Window.get();
const video = document.getElementById('video-player');
const path = require('path');
const os = require('os');
const AdmZip = require('adm-zip');
const configFilePath = 'config.json';

// Load configuration (default values if config file doesn't exist)
let config = {
  sizeRatio: 1.5,         // Default size ratio
  volume: 1,              // Default volume (1 = 100%)
  directionalSound: false // Default: directional sound off
};

// Load the config.json file if it exists
if (fs.existsSync(configFilePath)) {
  config = JSON.parse(fs.readFileSync(configFilePath, 'utf-8'));
}

// Function to center the window on the screen
function centerWindow() {
  const screen = gui.Screen.screens[0]; // Get the primary screen
  const screenWidth = screen.bounds.width;
  const screenHeight = screen.bounds.height;

  const windowWidth = win.width;
  const windowHeight = win.height;

  const x = Math.floor((screenWidth - windowWidth) / 2);
  const y = Math.floor((screenHeight - windowHeight) / 2);

  win.moveTo(x, y); // Move the window to the calculated center position
}

// Function to exit the app if no video is found
function closeApp() {
  win.close();
}

// Function to play video
function playVideo(videoPath) {
  if (!fs.existsSync(videoPath)) {
    console.error('File does not exist:', videoPath);
    closeApp();  // Close the app if the video file doesn't exist
    return;
  }

  const validExtensions = ['.mp4', '.webm', '.ogg'];
  const fileExtension = videoPath.substring(videoPath.lastIndexOf('.')).toLowerCase();

  if (!validExtensions.includes(fileExtension)) {
    console.error('Invalid file format:', fileExtension);
    closeApp();  // Close the app if the video format is invalid
    return;
  }

  // Set the video source to the selected file
  video.src = `file://${videoPath}`;
  video.load();

  video.onloadedmetadata = () => {
    const videoWidth = video.videoWidth;
    const videoHeight = video.videoHeight;

    if (videoWidth && videoHeight) {
      const windowWidth = Math.floor(videoWidth * config.sizeRatio);
      const windowHeight = Math.floor(videoHeight * config.sizeRatio);

      win.setResizable(true);
      win.resizeTo(windowWidth, windowHeight);
      win.setResizable(false);

      centerWindow(); // Center the window after resizing

      let isResizing = false;

      const checkAndResize = () => {
        if (!isResizing) {
          const currentVideoWidth = video.videoWidth;
          const currentVideoHeight = video.videoHeight;

          if (currentVideoWidth && currentVideoHeight) {
            const newWindowWidth = Math.floor(currentVideoWidth * config.sizeRatio);
            const newWindowHeight = Math.floor(currentVideoHeight * config.sizeRatio);

            if (newWindowWidth !== win.width || newWindowHeight !== win.height) {
              win.setResizable(true);
              win.resizeTo(newWindowWidth, newWindowHeight, () => {
                win.setResizable(false);
              });
            }
          }
        }

        requestAnimationFrame(checkAndResize);
      };

      requestAnimationFrame(checkAndResize);

      if (config.directionalSound) {
        setupDirectionalSound(video);
      }
    } else {
      console.error('Unable to retrieve video dimensions.');
      closeApp();
    }

    video.volume = config.volume;
  };
}

// Function to setup directional sound
function setupDirectionalSound(video) {
  const audioContext = new (window.AudioContext || window.webkitAudioContext)();
  const source = audioContext.createMediaElementSource(video);
  const panner = audioContext.createStereoPanner();

  source.connect(panner).connect(audioContext.destination);

  const updatePan = () => {
    const winX = win.x;
    const screens = gui.Screen.screens;
    let currentScreen = screens[0];

    screens.forEach(screen => {
      const { bounds } = screen;
      if (winX >= bounds.x && winX <= (bounds.x + bounds.width)) {
        currentScreen = screen;
      }
    });

    const relativePosition = (winX - currentScreen.bounds.x) / currentScreen.bounds.width;
    const panValue = (relativePosition - 0.5) * 2;
    panner.pan.setValueAtTime(panValue, audioContext.currentTime);

    requestAnimationFrame(updatePan);
  };

  requestAnimationFrame(updatePan);
}

// Function to handle zip and dsmm file extraction and video playback
function handleCompressedFile(filePath) {
  const tempDir = path.join(os.tmpdir(), 'video-player-temp');
  if (!fs.existsSync(tempDir)) {
    fs.mkdirSync(tempDir);
  }

  const zip = new AdmZip(filePath);
  const zipEntries = zip.getEntries();

  let videoFilePath = null;
  let configFilePathInZip = null;

  zipEntries.forEach(entry => {
    const extractedPath = path.join(tempDir, entry.entryName);
    zip.extractEntryTo(entry, tempDir, false, true);

    if (entry.entryName.endsWith('.json')) {
      configFilePathInZip = extractedPath;
    } else if (['.mp4', '.webm', '.ogg'].some(ext => entry.entryName.endsWith(ext))) {
      videoFilePath = extractedPath;
    }
  });

  if (videoFilePath) {
    if (configFilePathInZip) {
      config = JSON.parse(fs.readFileSync(configFilePathInZip, 'utf-8'));
    }
    playVideo(videoFilePath);
  } else {
    console.error('No valid video file found in the compressed file.');
    closeApp();
  }
}

// Check for command-line arguments (file path when dragging onto the exe)
const args = gui.App.argv;
if (args.length > 0) {
  const filePath = args[0];

  if (filePath.endsWith('.zip') || filePath.endsWith('.dsmm')) {
    handleCompressedFile(filePath); // Handle .zip and .dsmm
  } else {
    playVideo(filePath); // Handle regular video files
  }
} else {
  console.error('No file provided. Closing the application.');
  closeApp();  // Close the app if no arguments were provided
}

// Close the window when the ESC key is pressed
document.addEventListener('keydown', function (event) {
  if (event.key === 'Escape') {
    win.close();
  }
});
