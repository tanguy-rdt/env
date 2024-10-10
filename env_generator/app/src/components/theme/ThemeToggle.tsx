import React from 'react';
import { getCurrentTheme } from '../../context/Theme'; // On utilise le hook pour accéder au contexte
import styles from './ThemeToggle.module.css';

const ThemeToggle: React.FC = () => {
  const { theme, toggleTheme } = getCurrentTheme(); // Récupère le thème et la fonction pour le changer

  return (
    <button 
    onClick={toggleTheme} 
    className={`${styles.button} ${theme === 'dark' ? styles.dark : styles.light}`} >
      {theme === 'light' ? '🌙' : '☀️'}
    </button>
  );
};

export default ThemeToggle;