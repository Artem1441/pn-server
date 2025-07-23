1) DOCX -> PDF

We use the libreoffice-convert library to turn .docx files into PDF. But this works only if LibreOffice is installed on the 
computer. It does not work through Node.js. So you need to install LibreOffice first

Ubuntu:
sudo apt update
sudo apt install libreoffice

MacOS:
brew install --cask libreoffice
