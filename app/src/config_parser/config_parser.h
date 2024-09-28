#ifndef CONFIG_PARSER_H
#define CONFIG_PARSER_H

#include <string>
#include <iostream>

#include "nlohmann/json.hpp"

#include "config.h"

using json = nlohmann::json;

class ConfigParser {
    public:
        ConfigParser(const char* configFile);
        ~ConfigParser();



        void parse(const char* configFile);
        
        Config getConfig();



    private:
        json _data;
        Config _config;

        void parseCategory(Category* category, const json& value);
        void parsePackage(Category* parentCategory, const json& data);
};
#endif // CONFIG_PARSER_H