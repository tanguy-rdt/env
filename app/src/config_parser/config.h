#ifndef CONFIG_H
#define CONFIG_H

struct Package {
    std::string name;
    std::string installCmd;
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

        std::cout << indent << "Category: " << name << " (SubCategory: " << nbSubCategory << ", Package " << nbPackage << " )" << std::endl;

        for (const auto& pkg : packages) {
            std::cout << indent << indent << "Package: " << pkg.name << ", Install Command: " << pkg.installCmd << std::endl;
        }

        for (const auto& subCat : subCategory) {
            subCat.display(level + 1);
        }
    }
};

using Config = std::vector<Category>;

#endif // CONFIG_H