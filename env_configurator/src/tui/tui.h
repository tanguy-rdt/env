#ifndef TUI_H
#define TUI_H

#include <string>
#include <memory>

#include "config.h"
#include "termUi.h"

class Tui {
    public:
        Tui(Config* config);
        ~Tui();

        void init();
        int run();

    private:
        void populateCategory(Page* page, Category* cat);
        void cancelBtn();
        void enterBtn();

        Config* _config;
        TermUi* _termUi;
        Page* page;
};
#endif // TUI_H