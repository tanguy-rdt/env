import React from 'react';

import { getCurrentTheme } from '../../context/Theme'; 
import styles from './button.module.css';

interface ButtonProps {
    label: string;
    onClick: () => void;
}

const Button = ({ label, onClick }: ButtonProps) => {
    const { theme } = getCurrentTheme(); // On récupère le thème actuel

    return (
    <button
        className={`${styles.button} ${theme === 'dark' ? styles.dark : styles.light}`}
        onClick={onClick}>
        {label}
    </button>
    );
};
  

export default Button;