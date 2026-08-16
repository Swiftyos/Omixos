# Text Extraction & Dictation

### Text Extraction

Hit `Super + Ctrl + PrtScr` to select a region on the screen for text extraction. The tesseract open source OCR model will then quickly convert that selection into text and place it on the clipboard. Then you just hit `Super + V` to paste.

This is very helpful for grabbing addresses out of image footers or phone numbers embedded in website headlines.

 ![text-extraction](images/text-extraction.webp)

### Dictation

Omarchy offers AI dictation via [Voxtype](https://voxtype.io/), but it is not
part of the Pi 4 core profile and is not installed through an Arch-style menu
transaction on OmixOS. Add a compatible package/service declaratively before
using `voxtype setup model`; physical/optional application support remains
unverified.

Once installed, you dictate by holding down `F9` or by toggling with `Super + Ctrl + X`, and the dictated text will appear in the focused input area.
