import React from 'react';

import { getCurrentTheme } from '../../context/Theme'; 
import styles from './menu.module.css';

import Button from '../button/Button'; 

interface MenuProps {
  title: string; 
  items: { label: string; onClick: () => void }[]; 
}

const Menu = ({ title, items }: MenuProps) => {
  const { theme } = getCurrentTheme(); 

  return (
    <nav className={`${styles.menu} ${theme === 'dark' ? styles.dark : styles.light}`}> 
      <h2>{title}</h2> 
      {items.map((item, index) => (
        <Button key={index} label={item.label} onClick={item.onClick} />
      ))}
    </nav>
  );
};

export default Menu;
