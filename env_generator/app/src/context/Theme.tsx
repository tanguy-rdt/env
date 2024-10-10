import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';

const ThemeContext = createContext<any>(null);

export const getCurrentTheme = () => useContext(ThemeContext);

export const Theme = ({ children }: { children: ReactNode }) => {
  const [theme, setTheme] = useState<'light' | 'dark'>('light');

  const toggleTheme = () => {
    setTheme((prevTheme) => (prevTheme === 'light' ? 'dark' : 'light'));
  };

  useEffect(() => {
    const root = document.documentElement; 
    if (theme === 'dark') {
      root.style.setProperty('--background-color', '#2f2f2f');
      root.style.setProperty('--text-color', '#f6f6f6');
    } else {
      root.style.setProperty('--background-color', '#f6f6f6');
      root.style.setProperty('--text-color', '#2f2f2f');
    }
  }, [theme]);

  return (
    <ThemeContext.Provider value={{ theme, toggleTheme }}>
      {children}
    </ThemeContext.Provider>
  );
};