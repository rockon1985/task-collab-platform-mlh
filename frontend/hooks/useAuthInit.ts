'use client';

import { useEffect } from 'react';
import { useAuthStore } from '@/store/authStore';

export const useAuthInit = () => {
  useEffect(() => {
    if (typeof window !== 'undefined') {
      const token = localStorage.getItem('auth_token');
      const userStr = localStorage.getItem('auth_user');

      if (token && userStr) {
        try {
          const user = JSON.parse(userStr);
          useAuthStore.setState({
            user,
            token,
            isAuthenticated: true
          });
        } catch (error) {
          // Clear invalid data
          localStorage.removeItem('auth_token');
          localStorage.removeItem('auth_user');
        }
      }
    }
  }, []);
};
