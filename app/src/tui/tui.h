#ifndef TUI_H
#define TUI_H

#include <string>
#include <memory>

#include "config.h"
#include "termUi.h"

class Tui {
    public:
        Tui(Config config);
        ~Tui();

    private:
        void init();

        Config _config;
        TermUi _termUi;
        Page* page;
};
#endif // TUI_H