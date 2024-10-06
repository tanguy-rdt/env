#ifndef CONFIG_H
#define CONFIG_H

#include <string>
#include <vector>
#include <iostream>

struct Package {
    std::string name;
    std::string packageName;
    std::string installCmd;
    bool enable;
};

struct Category {
    std::string name;
    std::vector<Package> packages;
    int nbPackage = 0;
    std::vector<Category> subCategory;
    int nbSubCategory = 0;

    Category(const std::string& n) : name(n) {}

    void addPackage(const Package& pkg) {
        packages.push_back(pkg);
        nbPackage += 1;
    }

    void addSubCategory(const Category& cat) {
        subCategory.push_back(cat);
        nbSubCategory += 1;
    }

    void display(int level = 0) const {
        std::string indent(level * 2, ' ');

        std::cout << indent << "-- " << name << std::endl;
        std::cout << std::endl;
        
        for (const auto& pkg : packages) {
            std::cout << indent << "   * Package: " << pkg.name << std::endl;
            std::cout << indent << "      Name: " << pkg.packageName << std::endl;
            std::cout << indent << "      Install command: " << pkg.installCmd << std::endl;
            std::cout << indent << "      Enable: " << pkg.enable << std::endl;
            std::cout << std::endl;
        }

        for (const auto& subCat : subCategory) {
            subCat.display(level + 1);
        }
    }
};

using Config = std::vector<Category>;

#endif // CONFIG_H