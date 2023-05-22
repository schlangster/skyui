#include <windows.h>
#include <stdio.h>
#include <fcntl.h>
#include <io.h>
#include <iostream>
#include <fstream>

// maximum mumber of lines the output console should have
static const WORD MAX_CONSOLE_LINES = 500;

bool RedirectIOToConsole()
{
   CONSOLE_SCREEN_BUFFER_INFO coninfo;

   // allocate a console for this app
   AllocConsole();

   // set the screen buffer to be big enough to let us scroll text
   GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &coninfo);
   coninfo.dwSize.Y = MAX_CONSOLE_LINES;
   SetConsoleScreenBufferSize(GetStdHandle(STD_OUTPUT_HANDLE), coninfo.dwSize);

   bool result = true;
   FILE* fp;

   // Redirect STDIN if the console has an input handle
   if (GetStdHandle(STD_INPUT_HANDLE) != INVALID_HANDLE_VALUE)
      if (freopen_s(&fp, "CONIN$", "r", stdin) != 0)
         result = false;
      else
         setvbuf(stdin, NULL, _IONBF, 0);

   // Redirect STDOUT if the console has an output handle
   if (GetStdHandle(STD_OUTPUT_HANDLE) != INVALID_HANDLE_VALUE)
      if (freopen_s(&fp, "CONOUT$", "w", stdout) != 0)
         result = false;
      else
         setvbuf(stdout, NULL, _IONBF, 0);

   // Redirect STDERR if the console has an error handle
   if (GetStdHandle(STD_ERROR_HANDLE) != INVALID_HANDLE_VALUE)
      if (freopen_s(&fp, "CONOUT$", "w", stderr) != 0)
         result = false;
      else
         setvbuf(stderr, NULL, _IONBF, 0);

   // Make C++ standard streams point to console as well.
   std::ios::sync_with_stdio(true);

   // Clear the error state for each of the C++ standard streams.
   std::wcout.clear();
   std::cout.clear();
   std::wcerr.clear();
   std::cerr.clear();
   std::wcin.clear();
   std::cin.clear();

   return result;
}
