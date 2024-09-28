
#include <fstream>  

#include "config_parser.h"

ConfigParser::ConfigParser(const char* configFile) {
    parse(configFile);
}

ConfigParser::~ConfigParser() {
    
}

void ConfigParser::parse(const char* configFile) {
    std::ifstream f(configFile);
    if (!f.is_open()) {
        
    }

    _data = json::parse(f);

    for (auto& [key, value] : _data.items()) {
        Category category(key);

        parseCategory(&category, value);
        _config.push_back(category);
    }

    // for (const auto& conf : _config) {
    //    conf.display();
    // }
}

void ConfigParser::parseCategory(Category* category, const json& data) {
    if (data.is_object()) {
        for (auto& [subKey, subValue] : data.items()) {
            if (subValue.is_array()) {
                Category subCategory(subKey);
                parsePackage(&subCategory, subValue); 
                category->addSubCategory(subCategory); 
            } 
            else if (subValue.is_object()) {
                Category subCategory(subKey);
                parseCategory(&subCategory, subValue);
                category->addSubCategory(subCategory); 
            }
        }
    }
}

void ConfigParser::parsePackage(Category* parentCategory, const json& data) {
    for (const auto& pkg : data) {
        Package package;
        package.name = pkg.value("name", ""); 
        package.installCmd = pkg.value("install_command", "");
        parentCategory->addPackage(package);
    }
}

Config ConfigParser::getConfig() {
    return _config;
}


