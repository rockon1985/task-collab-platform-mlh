export interface User {
  id: number;
  email: string;
  first_name: string;
  last_name: string;
  full_name: string;
  role: 'admin' | 'member' | 'viewer';
  avatar_url?: string;
  last_login_at?: string;
  created_at: string;
}

export interface Project {
  id: number;
  name: string;
  description?: string;
  status: 'active' | 'archived' | 'completed';
  owner: User;
  member_count: number;
  task_count: number;
  completed_tasks_count: number;
  progress_percentage: number;
  created_at: string;
  updated_at: string;
  members?: User[];
  tasks?: Task[];
  overdue_tasks_count?: number;
  archived_at?: string;
}

export interface Task {
  id: number;
  title: string;
  description?: string;
  status: 'todo' | 'in_progress' | 'review' | 'done';
  priority: 'low' | 'medium' | 'high' | 'critical';
  due_date?: string;
  position: number;
  overdue: boolean;
  assignee?: User;
  creator: User;
  created_at: string;
  updated_at: string;
  completed_at?: string;
  project?: {
    id: number;
    name: string;
  };
  comments_count?: number;
  time_to_completion?: number;
}

export interface Comment {
  id: number;
  content: string;
  user: User;
  created_at: string;
  updated_at: string;
}

export interface AuthResponse {
  user: User;
  token: string;
}

export interface ProjectAnalytics {
  total_tasks: number;
  completed_tasks: number;
  in_progress_tasks: number;
  overdue_tasks: number;
  completion_rate: number;
  average_completion_time?: number;
  tasks_by_priority: {
    critical: number;
    high: number;
    medium: number;
    low: number;
  };
  tasks_by_status: {
    todo: number;
    in_progress: number;
    review: number;
    done: number;
  };
  member_count: number;
  recent_activity: Array<{
    action: string;
    user?: string;
    created_at: string;
    metadata: Record<string, unknown>;
  }>;
}
