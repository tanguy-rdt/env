#ifndef CONFIG_H
#define CONFIG_H

#include <string>
#include <vector>
#include <iostream>

struct Job {
    std::string uiName;
    std::string jobName;
    std::string runCmd;
    std::string checkCmd;
    int expectedResult;
    bool enable;
};

struct Category {
    std::string uiName;
    std::vector<Job> jobs;
    int nbJob = 0;
    std::vector<Category> subCategory;
    int nbSubCategory = 0;

    Category(const std::string& n) : uiName(n) {}

    void addJob(const Job& job) {
        jobs.push_back(job);
        nbJob += 1;
    }

    void addSubCategory(const Category& cat) {
        subCategory.push_back(cat);
        nbSubCategory += 1;
    }

    void display(int level = 0) const {
        std::string indent(level * 2, ' ');

        std::cout << indent << "-- " << uiName << std::endl;
        std::cout << std::endl;
        
        for (const auto& job : jobs) {
            std::cout << indent << "   * Job: " << job.jobName << std::endl;
            std::cout << indent << "      UI Name: " << job.uiName << std::endl;
            std::cout << indent << "      Run command: " << job.runCmd << std::endl;
            std::cout << indent << "      Check command: " << job.checkCmd << std::endl;
            std::cout << indent << "      Expected result: " << job.expectedResult << std::endl;
            std::cout << indent << "      Enable: " << job.enable << std::endl;
            std::cout << std::endl;
        }

        for (const auto& subCat : subCategory) {
            subCat.display(level + 1);
        }
    }
};

using Config = std::vector<Category>;

#endif // CONFIG_H