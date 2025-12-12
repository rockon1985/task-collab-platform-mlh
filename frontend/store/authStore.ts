import { create } from 'zustand';
import { User, AuthResponse } from '@/types';
import apiClient from '@/lib/api';

interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  login: (email: string, password: string) => Promise<void>;
  register: (data: RegisterData) => Promise<void>;
  logout: () => void;
  setUser: (user: User) => void;
}

interface RegisterData {
  email: string;
  password: string;
  password_confirmation: string;
  first_name: string;
  last_name: string;
}

// Initialize state from localStorage
const getInitialState = () => {
  if (typeof window !== 'undefined') {
    const token = localStorage.getItem('auth_token');
    const userStr = localStorage.getItem('auth_user');

    if (token && userStr) {
      try {
        const user = JSON.parse(userStr);
        return { user, token, isAuthenticated: true };
      } catch (e) {
        console.error('Failed to parse stored user:', e);
        localStorage.removeItem('auth_token');
        localStorage.removeItem('auth_user');
      }
    }
  }

  return { user: null, token: null, isAuthenticated: false };
};

export const useAuthStore = create<AuthState>()((set) => ({
  ...getInitialState(),

  login: async (email: string, password: string) => {
    console.log('[AuthStore] Attempting login for:', email);
    console.log('[AuthStore] API Base URL:', apiClient.defaults.baseURL);

    try {
      const response = await apiClient.post<AuthResponse>('/auth/login', {
        auth: {
          email,
          password,
        },
      });

      console.log('[AuthStore] Login successful:', response.data);
      const { user, token } = response.data;
      if (typeof window !== 'undefined') {
        localStorage.setItem('auth_token', token);
        localStorage.setItem('auth_user', JSON.stringify(user));
      }

      set({ user, token, isAuthenticated: true });
    } catch (error: any) {
      console.error('[AuthStore] Login failed:', {
        status: error.response?.status,
        data: error.response?.data,
        headers: error.response?.headers,
        config: {
          url: error.config?.url,
          baseURL: error.config?.baseURL,
          method: error.config?.method,
        }
      });
      throw error;
    }
  },

  register: async (data: RegisterData) => {
    const response = await apiClient.post<AuthResponse>('/auth/register', {
      user: data,
    });

    const { user, token } = response.data;
    if (typeof window !== 'undefined') {
      localStorage.setItem('auth_token', token);
      localStorage.setItem('auth_user', JSON.stringify(user));
    }

    set({ user, token, isAuthenticated: true });
  },

  logout: () => {
    if (typeof window !== 'undefined') {
      localStorage.removeItem('auth_token');
      localStorage.removeItem('auth_user');
    }
    set({ user: null, token: null, isAuthenticated: false });
  },

  setUser: (user: User) => {
    if (typeof window !== 'undefined') {
      localStorage.setItem('auth_user', JSON.stringify(user));
    }
    set({ user });
  },
}));
