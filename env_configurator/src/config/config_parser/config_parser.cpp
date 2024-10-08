
#include <fstream>  

#include "config_parser.h"

ConfigParser::ConfigParser(const std::string configFile) {
    _tomlConfig = toml::parse_file(configFile);
    parseTable(_tomlConfig, "");

}

ConfigParser::~ConfigParser() {
    
}

void ConfigParser::parseTable(const toml::table& table, const std::string indent) {
    for (const auto& [key, value] : table) {
        if (value.is_table()) {
            std::string uiName = (*value.as_table())["ui_name"].value_or("Unknow");
            std::string type = (*value.as_table())["type"].value_or("Unknow");

            if (type == "category") {
                Category category(uiName);
                parseCategory(*value.as_table(), &category, indent + "  ");
                _config.push_back(category);
            }
        }
    }
}

void ConfigParser::parseCategory(const toml::table& table, Category* category, const std::string indent) {
    for (const auto& [key, value] : table) {
        if (value.is_table()) {
            std::string uiName = (*value.as_table())["ui_name"].value_or("Unknow");
            std::string type = (*value.as_table())["type"].value_or("Unknow");

            if (type == "sub_category") {
                Category subCategory(uiName);
                parseCategory(*value.as_table(), &subCategory, indent + "  ");
                category->addSubCategory(subCategory);
            } else if (type == "job") {
                Job job = parseJob(*value.as_table(), indent + "   ");
                category->addJob(job);
            } 
        }
    }
}

Job ConfigParser::parseJob(const toml::table& table, const std::string indent) {
    std::string uiName = table["ui_name"].value_or("Unknow");
    std::string jobName = table["job_name"].value_or("Unknow");
    std::string runCmd = table["run_command"].value_or("Unknow");
    std::string checkCmd = table["check_command"].value_or("Unknow");
    int expectedResult = table["expected_result"].value_or(0);
    bool enable = table["enable"].value_or(false);

    Job job = { uiName, jobName, runCmd, checkCmd, expectedResult, enable };

    return job;
}

Config ConfigParser::getConfig() {
    return _config;
}