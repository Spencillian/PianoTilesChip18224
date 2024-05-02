# PianoTiles18224

Spencer Li
18-224 Spring 2024 Final Tapeout Project

## Overview
Piano Tiles implementation for a small battery powered chip design. This is meant to be a toy similar to early handheld gaming devices. 

## How it Works
The design interfaces with a small SSD1306 SPI OLED display and 4 buttons for inputs. In order to drive these, the chip has a small SPI driver implemented on board that outputs the data from the game. Data is taken from the game hardware thread and used to drive the spi display driver hardware thread after it has initialized the screen. The game loads into a nice flashing play screen where you can press any button to start. 
![Flashing Play Screen](image1.gif)
Once a button is pressed you enter the game. Tiles will drop from the top and you need to press buttons when they reach the button in order to clear them. Tiles are generated using a 24 bit Linear Feedback Shift Register (LFSR) of the polynomial x^24 + x^23 + x^22 + x^17 + 1 which was the one with the longest period on wikipedia. 
![Tiles Dropping During Gameplay](image2.gif)
If you lose, you get sent to a Game Over animation.
![Flashing Game Over Screen](image3.gif)
After a short duration you are sent back to the play screen to play again.

## Inputs/Outputs
### Inputs: 
- 5 Left Most Button
- 3 Left Center Button
- 1 Right Center Button
- 0 Right Most Button
- 2 General Start Button
- 4 General Start Button
### Outputs:
- 11 SPI clock for OLED SSD1306 Screen (clk)
- 10 SPI Master In Slave Out (mosi)
- 9 SPI Data/Command Selector (dc)
- 8 SPI Display Reset Low (res_n)
- 7 SPI Chip Select Low (cs_n)

## Hardware Peripherals
This design needs at least 4 buttons to work (2 and 4 need to pulled low if not in use) and a SSD1306 OLED Display

## Design Testing / Bringup
In order to check that outputs are correct you will need a Digital Logic Analyzer. The most important parts to check are the spi initialization bytes. If this doesn't work than the screen will not turn on. As long as this is correct, the rest of the game should just work.
From here you need to attach the screen and the buttons to the screen. The screen needs a seperate 3.3V power supply, but the logic of the SPI Driver should be enough to drive the OLED part of the display. This should hopefully bring up the nice screen with the flashing PLAY text and you should be able to play.

## Media
I have a lot of media in the form of videos which are a bit too hefty to upload to github. A full devlog will be made once I get a website.

## Bring Up and Final Touches
Once the chip comes back from the foundry, it will be tested to see if it works. If it does then a 3d printed chassis will be made for it that holds the screen, battery and buttons. This finalizes the product allowing it to be brought anywhere to satisfy my boredom.

