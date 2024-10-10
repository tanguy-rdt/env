import React from 'react';

import { getCurrentTheme } from '../../context/Theme'; 
import styles from './ThemeToggle.module.css';

import icon_dark from '../../assets/icons/night_light_mode-dark.png';
import icon_light from '../../assets/icons/night_light_mode-light.png';

const ThemeToggle: React.FC = () => {
  const { theme, toggleTheme } = getCurrentTheme();

  return (
    <button 
    onClick={toggleTheme} 
    className={`${styles.button} ${theme === 'dark' ? styles.dark : styles.light}`} >
      <img 
      src={theme === 'dark' ? icon_dark : icon_light}
      alt="Button Icon" 
      className={`${styles.icon} ${theme === 'dark' ? styles.dark : styles.light}`} 
      />
    </button>
  );
};

export default ThemeToggle;