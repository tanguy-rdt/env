import { useState } from "react";
import reactLogo from "./assets/react.svg";
import { invoke } from "@tauri-apps/api/core";
import "./App.css";

import Menu from './components/menu/Menu';

function App() {
  const menuItems = [
    { label: 'Accueil', onClick: () => alert('Accueil') },
    { label: 'À propos', onClick: () => alert('À propos') },
    { label: 'Contact', onClick: () => alert('Contact') }
  ];

  return (
    <div className="container">
      <Menu title="Mon Menu Principal" items={menuItems} />
    </div>
  );
}

export default App;
