/*
  Morse code for Arduino.
  Based on details at: http://en.wikipedia.org/wiki/Morse_code
  
  Copyright 2011 Matthew Lowden.
  
  Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
 
static const unsigned short ditDuration = 300;
static const unsigned short dahDuration = ditDuration * 3;
static const unsigned short symbolSpaceDuration = ditDuration;

/* 
   Total duration between letters is 3 * dit duration.
   The letter space duration defined below will be added to the symbol space duration.
*/
static const unsigned short letterSpaceDuration = ditDuration * 2;

/* 
   Similarly;
   Total duration between words is 7 * dit duration.
   The word space duration defined below will be added to the letter and symbol space duration.
*/
static const unsigned short wordSpaceDuration = ditDuration * 4;

static const byte morseCodeLetters[26] = {
  // 0b0001cccc - 4 symbol code
  // 0b00001ccc - 3 symbol code
  // 0b000001cc - 2 symbol code
  // 0b0000001c - 1 symbol code
  // c - code symbol (1 = dit, 0 = dah)
  
  0b00000110, // A - ._
  0b00010111, // B - _...
  0b00010101, // C - _._.
  0b00001011, // D - _..
  0b00000011, // E - .
  0b00011101, // F - .._.
  0b00001001, // G - __.
  0b00011111, // H - ....
  0b00000111, // I - ..
  0b00011000, // J - .___
  0b00001010, // K - _._
  0b00011011, // L - ._..
  0b00000100, // M - __
  0b00000101, // N - _.
  0b00001000, // O - ___
  0b00011001, // P - .__.
  0b00010010, // Q - __._
  0b00001101, // R - ._.
  0b00001111, // S - ...
  0b00000010, // T - _
  0b00001110, // U - .._
  0b00011110, // V - ..._
  0b00001100, // W - .__
  0b00010110, // X - _.._
  0b00010100, // Y - _.__
  0b00010011  // Z - __..
};

static const byte morseCodeDigits[10] = {
  // All digits are 5 symbol codes 0b001ccccc
  // c - code symbol (1 = dit, 0 = dah)
  0b00100000, // 0 - _____
  0b00110000, // 1 - .____
  0b00111000, // 2 - ..___
  0b00111100, // 3 - ...__
  0b00111110, // 4 - ...._
  0b00111111, // 5 - .....
  0b00101111, // 6 - _....
  0b00100111, // 7 - __...
  0b00100011, // 8 - ___..
  0b00100001, // 9 - ____.
};

static const byte morseCodePunctuation[18] = {
  // 0b1ccccccc - 7 symbol code
  // 0b01cccccc - 6 symbol code
  // 0b001ccccc - 5 symbol code
  // c - code symbol (1 = dit, 0 = dah)
  0b01101010, // '.' - ._._._
  0b01001100, // ',' - __..__
  0b01110011, // '?' - ..__..
  0b01100001, // ''' - .____.
  0b01010100, // '!' - _._.__
  0b00101101, // '/' - _.._.
  0b00101001, // '(' - _.__.
  0b01010010, // ')' - _.__._
  0b00110111, // '&' - ._...
  0b01000111, // ':' - ___...
  0b01010101, // ';' - _._._.
  0b00101110, // '=' - _..._
  0b00110101, // '+' - ._._.
  0b01011110, // '-' - _...._
  0b01110010, // '_' - ..__._
  0b01101101, // '"' - ._.._.
  0b11110110, // '$' - ..._.._
  0b01100101  // '@' - .__._.
};

void sendMorseCodeLetter(char c)
{
  byte letter = morseCodeLetters[c - 'A'];

  sendMorseCodeCharacter(letter);
}

void sendMorseCodeDigit(char c)
{
  byte digit = morseCodeDigits[c - '0'];
  
  sendMorseCodeCharacter(digit);
}

void sendMorseCodePunctuation(char c)
{
  byte characterDescription;
  switch (c)
  {
    case '.':
      characterDescription = morseCodePunctuation[0];
      break;
    case ',':
      characterDescription = morseCodePunctuation[1];
      break;
    case '?':
      characterDescription = morseCodePunctuation[2];
      break;
    case '\'':
      characterDescription = morseCodePunctuation[3];
      break;
    case '!':
      characterDescription = morseCodePunctuation[4];
      break;
    case '/':
      characterDescription = morseCodePunctuation[5];
      break;
    case '(':
      characterDescription = morseCodePunctuation[6];
      break;
    case ')':
      characterDescription = morseCodePunctuation[7];
      break;
    case '&':
      characterDescription = morseCodePunctuation[8];
      break;
    case ':':
      characterDescription = morseCodePunctuation[9];
      break;
    case ';':
      characterDescription = morseCodePunctuation[10];
      break;
    case '=':
      characterDescription = morseCodePunctuation[11];
      break;
    case '+':
      characterDescription = morseCodePunctuation[12];
      break;
    case '-':
      characterDescription = morseCodePunctuation[13];
      break;
    case '_':
      characterDescription = morseCodePunctuation[14];
      break;
    case '"':
      characterDescription = morseCodePunctuation[15];
      break;
    case '$':
      characterDescription = morseCodePunctuation[16];
      break;
    case '@':
      characterDescription = morseCodePunctuation[17];
      break;
    default:
      // Unsupported character (skip)
      return;    
  }
  
  sendMorseCodeCharacter(characterDescription);

}

void sendMorseCodeCharacter(byte c)
{
  short codeSize;
  if (c & 0b10000000)
  {
    codeSize = 7;
  }
  else if (c & 0b01000000)
  {
    codeSize = 6;
  }
  else if (c & 0b00100000)
  {
    codeSize = 5;
  }
  else if (c & 0b00010000)
  {
    codeSize = 4;
  }
  else if (c & 0b00001000)
  {
    codeSize = 3;
  }
  else if (c & 0b00000100)
  {
    codeSize = 2;
  }
  else
  {
    codeSize = 1;
  }

  
  while (0 < codeSize)
  {
    if (c & (1 << (codeSize -1)))
    {
      dit();
    }
    else
    {
      dah();
    }
    codeSize --;

    delay(symbolSpaceDuration);
  }
  delay(letterSpaceDuration);
}

void sendMorseCodeCharacter(char c)
{
  if (' ' == c) {
    delay(wordSpaceDuration);
  }
  else if ('A' <= c && 'Z' >= c) {
    sendMorseCodeLetter(c);
  }
  else if ('a' <= c && 'z' >= c) {
    sendMorseCodeLetter(c - 'a' + 'A');
  }
  else if ('0' <=c && '9' >= c) {
    sendMorseCodeDigit(c);
  }
  else {
    sendMorseCodePunctuation(c);
  }
}

void sendMorseCodeString(char *message)
{
  int i=0;
  while (message[i] != 0)
  {
    sendMorseCodeCharacter(message[i]);
    i++;
  }
}

void dit() {
  digitalWrite(13, HIGH);   // set the LED on
  delay(ditDuration);       // wait for dit duration
  digitalWrite(13, LOW);    // set the LED off
}

void dah() {
  digitalWrite(13, HIGH);   // set the LED on
  delay(dahDuration);       // wait for dah duration
  digitalWrite(13, LOW);    // set the LED off
}
  


