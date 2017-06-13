-----------------------------------------------------------
--                                                       --
-- PROCESSOR                                             --
--                                                       --
-- Copyright (c) 2017, John Leimon                       --
--                                                       --
-- Permission to use, copy, modify, and/or distribute    --
-- this software for any purpose with or without fee is  --
-- hereby granted, provided that the above copyright     --
-- notice and this permission notice appear in all       --
-- copies.                                               --
--                                                       --
-- THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR       --
-- DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE --
-- INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY   --
-- AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE   --
-- FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL   --
-- DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM      --
-- LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION    --
-- OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,     --
-- ARISING OUT OF OR IN CONNECTION WITH THE USE OR       --
-- PERFORMANCE OF THIS SOFTWARE.                         --
--                                                       --
-----------------------------------------------------------
WITH ADA.COMMAND_LINE;      USE ADA.COMMAND_LINE;
WITH ADA.DIRECTORIES;       USE ADA.DIRECTORIES;
WITH ADA.TEXT_IO;           USE ADA.TEXT_IO;
WITH ADA.STRINGS.FIXED;     USE ADA.STRINGS.FIXED;
WITH ADA.STRINGS.UNBOUNDED; USE ADA.STRINGS.UNBOUNDED;
WITH INTERFACES.C;          USE INTERFACES.C;

PROCEDURE PROCESSOR IS
   PATH    : UNBOUNDED_STRING := TO_UNBOUNDED_STRING ("");  
   TOKEN   : UNBOUNDED_STRING;
   COMMAND : UNBOUNDED_STRING;
   
   PROCEDURE SYSTEM (ARGUMENTS : CHAR_ARRAY);
   PRAGMA IMPORT (C, SYSTEM, "system");

   --------------
   -- GET FILE --
   --------------

   FUNCTION GET_FILE 
      RETURN STRING
   IS
      SEARCH    : SEARCH_TYPE;
      DIR_ENTRY : DIRECTORY_ENTRY_TYPE;
   BEGIN
      START_SEARCH (SEARCH, TO_STRING (PATH), "*");
      LOOP
         IF MORE_ENTRIES (SEARCH) THEN
            GET_NEXT_ENTRY (SEARCH, DIR_ENTRY);
            IF SIMPLE_NAME (DIR_ENTRY) /= "." AND
               SIMPLE_NAME (DIR_ENTRY) /= ".."
            THEN
               RETURN (SIMPLE_NAME (DIR_ENTRY));
            END IF;
         ELSE
            RETURN "";
         END IF;
      END LOOP;
   END GET_FILE;

   -------------
   -- REPLACE --
   -------------

   PROCEDURE REPLACE
      (TEXT  : IN OUT UNBOUNDED_STRING;
       KEY   : IN     STRING;
       VALUE : IN     STRING)
   IS
      CURSOR : NATURAL := 1;
   BEGIN
      LOOP
         CURSOR := INDEX (TO_STRING (TEXT), KEY);
         EXIT WHEN CURSOR = 0;
         REPLACE_SLICE (TEXT,
                        CURSOR,
                        CURSOR + KEY'LENGTH - 1,
                        VALUE);
         CURSOR := CURSOR + VALUE'LENGTH - 1;
      END LOOP;
   END REPLACE;

   -------------------
   -- BUILD_COMMAND --
   -------------------

   FUNCTION BUILD_COMMAND 
      (FILE_PATH : STRING)
       RETURN STRING
   IS
      OUTPUT : UNBOUNDED_STRING := COMMAND;
   BEGIN
      REPLACE (OUTPUT,
               TO_STRING (TOKEN),
               FILE_PATH);
      RETURN TO_STRING (OUTPUT);
   END BUILD_COMMAND;

BEGIN

   BEGIN
      IF ARGUMENT_COUNT = 1 AND
         ARGUMENT (1) = "-h"
      THEN
         PUT_LINE ("Copyright (c) 2017 John Leimon");
         PUT_LINE ("Usage: processor [path] [token] [command]");
         NEW_LINE;
         PUT_LINE ("This program searches a 'path' for non-directory");
         PUT_LINE ("files non-recursively. If a file is found, then");
         PUT_LINE ("all instances of 'token' inside 'command' are");
         PUT_LINE ("replaced by the full path to the file that was found.");
         PUT_LINE ("The command string that has had all 'token' strings");
         PUT_LINE ("replaced by the file name is then executed.");
         PUT_LINE ("After command execution, the file is deleted.");
         PUT_LINE ("This process of searching for files within the 'path'");
         PUT_LINE ("continues until all files have been deleted.");
         NEW_LINE;
         PUT_LINE ("Examples:");
         NEW_LINE;
         PUT_LINE ("Copy a file from /src to /dst");
         PUT_LINE ("  processor /src [FILE] ""cp [FILE] /dst""");
         NEW_LINE;
         PUT_LINE ("Display the contents of files in /src one time");
         PUT_LINE ("  processor /src [FILE] ""cat [FILE]""");
         RETURN;
      END IF;
   EXCEPTION
      WHEN CONSTRAINT_ERROR =>
         NULL;
   END;

   IF ARGUMENT_COUNT /= 3 THEN
      PUT_LINE ("usage: processor [path] [token] [command]");
      RETURN;
   END IF;

   PATH    := TO_UNBOUNDED_STRING (ARGUMENT (1)); 
   TOKEN   := TO_UNBOUNDED_STRING (ARGUMENT (2));
   COMMAND := TO_UNBOUNDED_STRING (ARGUMENT (3));

   LOOP
      DECLARE
         FILE    : STRING := GET_FILE;
         COMMAND : STRING := BUILD_COMMAND (FILE);
      BEGIN
         IF FILE /= "" THEN
            SYSTEM (TO_C (COMMAND)); 
            DELETE_FILE (FILE);
         ELSE
            DELAY 0.05;
         END IF;
      END;
   END LOOP;

END PROCESSOR;
