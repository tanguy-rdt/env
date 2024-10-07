#include "config_generator.h"
#include <fstream>

ConfigGenerator::ConfigGenerator(Config* config, const std::string fileGeneratedPath) :
    _config(config), _fileGeneratedPath(fileGeneratedPath) {
        
}

ConfigGenerator::~ConfigGenerator() {
    
}


int ConfigGenerator::generate() {
    for (const auto& cat: *_config) {
        goThroughCategory(&cat);
    }

    toml::table packages;
    packages.insert_or_assign("package", _packages);

    std::ofstream file(_fileGeneratedPath);

    if (file.is_open()) {
        file << packages;
        file.close();
        return 0;
    } else {
        return 2;
    }
}

void ConfigGenerator::goThroughCategory(const Category* category) {
    for (auto& pkg: category->packages) {
        addPackage(&pkg);
    }

    for (auto& subCat: category->subCategory) {
        goThroughCategory(&subCat);
    }
}

void ConfigGenerator::addPackage(const Package* package) {
    if (package->enable) {
        toml::table pkg;
        pkg.insert_or_assign("name", toml::value<std::string>(package->name));
        pkg.insert_or_assign("package_name", toml::value<std::string>(package->packageName));
        pkg.insert_or_assign("install_command", toml::value<std::string>(package->installCmd));
        _packages.push_back(pkg);
    }
}