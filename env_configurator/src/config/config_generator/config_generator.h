#ifndef CONFIG_GENERATOR_H
#define CONFIG_GENERATOR_H

#include <string>

#include "toml++/toml.hpp"
#include "config.h"

class ConfigGenerator {
    public:
        ConfigGenerator(Config* config, const std::string fileGeneratedPath);
        ~ConfigGenerator();

        int generate();

    private:
        void goThroughCategory(const Category* category);
        void addJob(const Job* job);

        Config* _config;
        const std::string _fileGeneratedPath;
        toml::array _jobs;
};
#endif // CONFIG_GENERATOR_H