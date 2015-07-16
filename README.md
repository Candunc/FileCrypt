## FileCrypt

FileCrypt is a program to index a location, generating a tree of the folders, and hashes of the files inside. This allows you to restore your files in a situation where filenames and/or folder names, folder locations, and folder structures, are lost. An example use of this is when there is a hard drive failure, and a tool like [PhotoRec](http://www.cgsecurity.org/wiki/PhotoRec) recovers some files, however the names and folders they resided in were lost. Filecrypt then scans this directory, creates the folder tree, and moves the files back to how they originally were, on a new drive or location.

**CAUTION:** This repository is currently in development. **USE AT YOUR OWN RISK.** We are not responsible for the loss of your files, nor are we responsible for any other problems you may have while using this program. We do not guarentee the program will run on your operating system, however you may submit any issues you have.

### Installation

#### Debian & Derivatives (Ubuntu, elementary OS)

> sudo git clone https://github.com/candunc/FileCrypt.git /opt/filecrypt
> 
> cd /opt/FileCrypt
> 
> sudo /opt/FileCrypt/install_debian.sh


#### Manual Installation (*nix)

Install the following dependancies:

* lz4
* shasum / sha256sum
* lua (5.1, 5.2, or 5.3)
* luajson
* luafilesystem

*cd* to your desired location, for example /opt/. Depending on where you are, you may have to use *sudo* to write, modify, or execute the files.

> git clone https://github.com/candunc/FileCrypt.git
> 
> mv FileCrypt/filecrypt /usr/local/bin/
> 
> chmod 555 /usr/local/bin/filecrypt

### Usage

*todo*

### Todo

* Add some sort of collision to try and detect when an index is performed on an incompatible database. 
* Convert from json to SQLite (and add luasql.sqlite to dependancies; install script)
* Add install script for Windows