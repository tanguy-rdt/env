#ifndef CONFIG_PARSER_H
#define CONFIG_PARSER_H

#include <string>

#include "toml++/toml.hpp"
#include "config.h"

class ConfigParser {
    public:
        ConfigParser(const char* configFile);
        ~ConfigParser();

        Config getConfig();

    private:
        void parseTable(const toml::table& table, const std::string indent);
        void parseCategory(const toml::table& table, Category* category, const std::string indent);
        Package parsePackage(const toml::table& table, const std::string indent);

        toml::table _tomlConfig;
        Config _config;
};
#endif // CONFIG_PARSER_H