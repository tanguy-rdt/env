#include <stdio.h>
#include <stdlib.h>
#include <cstring>

#include "config_parser.h"

int main(int argc, char* argv[]) {
    if (argc != 2 ) exit(1);
        
    char* configPath = argv[1];
    const char* configFile = strcat(configPath, "/config.json");
    ConfigParser configParser(configFile);
    Config config = configParser.getConfig();


    return 0;
}