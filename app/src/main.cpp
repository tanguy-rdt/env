#include <stdio.h>
#include <stdlib.h>
#include <cstring>

#include "config_parser.h"
#include "config_generator.h"
#include "tui.h"

int main(int argc, char* argv[]) {
    if (argc != 2 ) exit(1);
        
    std::string configPath = argv[1]; 

    const std::string configFile = configPath + "/config.toml";
    ConfigParser configParser(configFile);
    Config config = configParser.getConfig();

    Tui tui(&config);
    tui.init();
    int ret = tui.run();

    if (ret == 0) {
        const std::string generatedFile = configPath + "/config_generated.toml";
        ConfigGenerator configGenerator(&config, generatedFile);
        ret = configGenerator.generate();
    }

    return ret;
}