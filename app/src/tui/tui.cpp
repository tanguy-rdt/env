#include <iostream>
#include "tui.h"
#include "page.h"

#include <cstring>
#include <ncurses.h>


Tui::Tui(Config* config): _config(config) {

}

Tui::~Tui(){

}

void Tui::init(){
    _termUi = new TermUi();
    page = _termUi->addPage();

    AbstractMenu* menu = page->addMenu();
    menu->addBtn("Cancel", [this]() {
        cancelBtn();
    });
    menu->addBtn("Enter", [this]() {
        enterBtn();
    });

    for (auto& cat: *_config) {
        populateCategory(page, &cat);
    }
}

int Tui::run(){
    if (_termUi != nullptr) {
        _termUi->showPage(page);
        int ret = _termUi->run();
        delete _termUi;
        return ret;
    }
}

void Tui::populateCategory(Page* page, Category* cat){
    page->addTitle(cat->name);

    for (auto& pkg: cat->packages) {
        page->addSelectableLine(pkg.name, pkg.enable, [this, &pkg](bool enable) {
            pkg.enable = enable;
        });
    }

    for (auto& subCat: cat->subCategory) {
        Page* subPage = _termUi->addPage();
        
        AbstractMenu* menu = subPage->addMenu();
        menu->addBtn("Cancel", [this]() {
            cancelBtn();
        });
        menu->addBtn("Previous", [this]() {
            _termUi->showPreviousPage(); 
        });
        menu->addBtn("Enter", [this]() {
            enterBtn();
        });

        populateCategory(subPage, &subCat);
        page->addEmbeddedPageLine(subCat.name, subPage);
    }
}

void Tui::cancelBtn(){
    _termUi->quit(1);
}

void Tui::enterBtn(){
    _termUi->quit(0);
}