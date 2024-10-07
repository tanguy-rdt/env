
#include <fstream>  

#include "config_parser.h"

ConfigParser::ConfigParser(const char* configFile) {
    _tomlConfig = toml::parse_file(configFile);
    parseTable(_tomlConfig, "");
    
    // for (const auto& category: _config) {
    //     category.display();
    // }
}

ConfigParser::~ConfigParser() {
    
}

void ConfigParser::parseTable(const toml::table& table, const std::string indent) {
    for (const auto& [key, value] : table) {
        if (value.is_table()) {
            std::string name = (*value.as_table())["name"].value_or("Unknow");
            std::string type = (*value.as_table())["type"].value_or("Unknow");

            if (type == "category") {
                Category category(name);
                parseCategory(*value.as_table(), &category, indent + "  ");
                _config.push_back(category);
            }
        }
    }
}

void ConfigParser::parseCategory(const toml::table& table, Category* category, const std::string indent) {
    for (const auto& [key, value] : table) {
        if (value.is_table()) {
            std::string name = (*value.as_table())["name"].value_or("Unknow");
            std::string type = (*value.as_table())["type"].value_or("Unknow");

            if (type == "sub_category") {
                Category subCategory(name);
                parseCategory(*value.as_table(), &subCategory, indent + "  ");
                category->addSubCategory(subCategory);
            } else if (type == "package") {
                Package package = parsePackage(*value.as_table(), indent + "   ");
                category->addPackage(package);
            } 
        }
    }
}

Package ConfigParser::parsePackage(const toml::table& table, const std::string indent) {
    std::string name = table["name"].value_or("Unknow");
    std::string packageName = table["package_name"].value_or("Unknow");
    std::string installCmd = table["install_cmd"].value_or("Unknow");
    bool enable = table["enable"].value_or(false);

    Package package = { name, packageName, installCmd, enable };

    return package;
}

Config ConfigParser::getConfig() {
    return _config;
}