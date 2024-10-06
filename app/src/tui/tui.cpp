#include <iostream>
#include "tui.h"
#include "page.h"

#include <cstring>
#include <ncurses.h>


Tui::Tui(Config config){
    _config = config;
    init();
}

Tui::~Tui(){

}

void Tui::init(){
    page = _termUi.addPage();


    AbstractMenu* menu = page->addMenu();
    menu->addBtn("Cancel", nullptr);
    menu->addBtn("Enter", nullptr);

    _termUi.showPage(page);
    _termUi.run();
}