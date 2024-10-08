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


    toml::table jobs;
    jobs.insert_or_assign("job", _jobs);

    std::ofstream file(_fileGeneratedPath);
    
    if (file.is_open() && !_jobs.empty()) {
        file << jobs;
        file.close();
        return 0;
    } else {
        file.close();
        return 2;
    }
}

void ConfigGenerator::goThroughCategory(const Category* category) {
    for (auto& job: category->jobs) {
        addJob(&job);
    }

    for (auto& subCat: category->subCategory) {
        goThroughCategory(&subCat);
    }
}

void ConfigGenerator::addJob(const Job* job) {
    if (job->enable) {
        toml::table tomlJob;
        tomlJob.insert_or_assign("job_name", toml::value<std::string>(job->jobName));
        tomlJob.insert_or_assign("run_command", toml::value<std::string>(job->runCmd));
        tomlJob.insert_or_assign("check_command", toml::value<std::string>(job->checkCmd));
        tomlJob.insert_or_assign("expected_result", job->expectedResult);
        _jobs.push_back(tomlJob);
    }
}