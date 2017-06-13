## Synopsis

Processor monitors a directory for files. When a 
file is discovered, processor runs a command using the
file name and deletes the file.

## Dependencies

### Compilation

* GNATMAKE

## Operational Description

This program searches a 'path' for non-directory
files non-recursively. If a file is found, then
all instances of 'token' inside 'command' are
replaced by the full path to the file that was found.
The command string that has had all 'token' strings
replaced by the file name is then executed.
After command execution, the file is deleted.
This process of searching for files within the 'path'
continues until all files have been deleted.

## Usage

`processor [path] [token] command]`

# Examples

Copy files in /src to /dst continuously

`processor /src [FILE] "cp [FILE] /dst"`

Display the contents of files in /src one time

`processor /src [FILE] "cat [FILE]"`

# Installation

1. Build processor using gnatmake `gnatmake processor`

# License

Internet Systems Consortium (ISC)
