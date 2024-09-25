# MouseGestureMedicalImaging

An AutoHotkey script for efficient navigation and annotation in medical imaging software using mouse gestures and extra mouse buttons.

## Overview

This script enhances the workflow for medical imaging professionals by providing intuitive mouse gestures and button mappings for common actions. It's particularly useful for radiologists and other medical professionals who frequently interact with imaging software.

## Features

- Mouse gesture recognition for quick actions
- Extra mouse button mappings for common tasks
- Approximate gesture matching for more natural interactions
- GUI for gesture reminders and event logging
- Customizable gestures and actions

## Mouse Gestures

The script recognizes various mouse gestures, which are generally designed to resemble the first letter of their intended action. Gesturing is activated with a middle mouse click and mouse manipulation. For example:

- "u" (up) for "Previous Protocol"
- "d" (down) for "Next Protocol"
- "l" (left) for "Previous Series"
- "r" (right) for "Next Series"

The liver window gesture is an exception, using a "V"-like motion ("udu") instead.

### ROI Gestures

Region of Interest (ROI) gestures are designed to be intuitive and quick to perform:

- "rdld" for ROI: This gesture forms a rough square shape, mimicking the act of drawing an ROI
- "udr" for Lung Window: Resembles an "L" shape
- "urdlrdl" for Bone Window: Forms a "B" shape
- "uldrdl" for Soft Tissue Window: Approximates an "S" shape
- "udu" for Liver Window: Forms a "V" shape (exception to the first-letter rule)

## Use Cases

1. Rapid navigation between protocols and series
2. Quick access to different window settings (lung, bone, soft tissue, liver)
3. Efficient annotation and measurement tools
4. Easy erasure of measurements and annotations
5. Fast toggling of scroll mode

## Hardware Compatibility

This script has been tested and optimized for use with a Corsair M55 mouse. While it may work with other mice, your mileage may vary. The script utilizes the following mouse inputs:

- Left click
- Right click
- Middle click (for gestures)
- XButton1 and XButton2 (side buttons)
- Wheel up/down

## Installation

1. Install AutoHotkey (v1.1 or later) from [https://www.autohotkey.com/](https://www.autohotkey.com/)
2. Download the script file (`MouseGestureMedicalImaging.ahk`) from this repository
3. Double-click the script file to run it, or add it to your startup folder for automatic execution

## Customization

You can customize the gestures and their associated actions by modifying the `gestures` array at the beginning of the script. Each gesture is defined with the following properties:

- `gesture`: The string representation of the mouse movement
- `hotkey`: The action to perform (can be a single key or an array of keys)
- `humanName`: A descriptive name for the action

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Disclaimer

This software is provided as-is, without any guarantees or warranty. The authors are not responsible for any damage or data loss that may occur from the use of this script. Always ensure you have proper backups and test the script in a safe environment before using it with critical systems or data.
