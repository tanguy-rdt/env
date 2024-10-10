import React from 'react';
import styles from './menu.module.css';

import Button from '../button/Button'; 

interface MenuProps {
  title: string; 
  items: { label: string; onClick: () => void }[]; 
}

const Menu = ({ title, items }: MenuProps) => {
  return (
    <nav className={styles.menu}> 
      <h2>{title}</h2> 
      {items.map((item, index) => (
        <Button key={index} label={item.label} onClick={item.onClick} />
      ))}
    </nav>
  );
};

export default Menu;
