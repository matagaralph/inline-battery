# Inline Battery

Battery indicator for the Plasma 6 panel, a slim pill icon with the percentage inline, plus a popup with power management, brightness sliders and battery details.

Originally derived from Kelvin Zhang's Mac OSX Inline Battery and the mcOS BS fork by F.Korpsvrat, ported to Plasma 6.8.

## Install

```
kpackagetool6 -t Plasma/Applet --install /path/to/inline-battery
```

Then right click the panel, choose "Add Widgets" and search for "Inline Battery".

## Update

```
kpackagetool6 -t Plasma/Applet --upgrade /path/to/inline-battery
```

## Uninstall

```
kpackagetool6 -t Plasma/Applet --remove org.ralph.inlinebattery
```
