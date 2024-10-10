import { useState } from "react";
import reactLogo from "./assets/react.svg";
import { invoke } from "@tauri-apps/api/core";
import "./App.css";

import { Theme } from './context/Theme';
import ThemeToggle from './components/theme_toggle/ThemeToggle';
import Menu from './components/menu/Menu';

function App() {
  const menuItems = [
    { label: 'Accueil', onClick: () => alert('Accueil') },
    { label: 'À propos', onClick: () => alert('À propos') },
    { label: 'Contact', onClick: () => alert('Contact') }
  ];

  return (
    <Theme>
      <ThemeToggle />
      <Menu title="Mon Menu Principal" items={menuItems} />
    </Theme>
  );
}

export default App;
