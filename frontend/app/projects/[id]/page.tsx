'use client';

import { use, useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import apiClient from '@/lib/api';
import PrivateRoute from '@/components/PrivateRoute';
import TaskModal from '@/components/TaskModal';
import TaskEditModal from '@/components/TaskEditModal';
import ProjectEditModal from '@/components/ProjectEditModal';
import { useAuthStore } from '@/store/authStore';
import { Project, Task } from '@/types';

export default function ProjectDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const router = useRouter();
  const { user, logout } = useAuthStore();
  const [isTaskModalOpen, setIsTaskModalOpen] = useState(false);
  const [isEditModalOpen, setIsEditModalOpen] = useState(false);
  const [isProjectEditModalOpen, setIsProjectEditModalOpen] = useState(false);
  const [selectedTask, setSelectedTask] = useState<Task | null>(null);
  const [currentPage, setCurrentPage] = useState(1);
  const tasksPerPage = 10;

  const { data: project, isLoading, refetch } = useQuery<Project>({
    queryKey: ['project', id],
    queryFn: async () => {
      const response = await apiClient.get(`/projects/${id}`);
      return response.data;
    },
  });

  // Pagination logic for tasks
  const totalTasksCount = project?.tasks?.length || 0;
  const totalPages = Math.ceil(totalTasksCount / tasksPerPage);
  const startIndex = (currentPage - 1) * tasksPerPage;
  const endIndex = startIndex + tasksPerPage;
  const paginatedTasks = project?.tasks?.slice(startIndex, endIndex) || [];

  const handleLogout = () => {
    logout();
    router.push('/');
  };

  const handleTaskClick = (task: Task) => {
    setSelectedTask(task);
    setIsEditModalOpen(true);
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'todo': return 'bg-gray-100 text-gray-800 border-gray-300';
      case 'in_progress': return 'bg-blue-100 text-blue-800 border-blue-300';
      case 'done': return 'bg-green-100 text-green-800 border-green-300';
      default: return 'bg-gray-100 text-gray-800 border-gray-300';
    }
  };

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'low': return 'bg-green-50 text-green-700 border-green-200';
      case 'medium': return 'bg-yellow-50 text-yellow-700 border-yellow-200';
      case 'high': return 'bg-orange-50 text-orange-700 border-orange-200';
      case 'urgent': return 'bg-red-50 text-red-700 border-red-200';
      default: return 'bg-gray-50 text-gray-700 border-gray-200';
    }
  };

  const tasksStats = {
    todo: project?.tasks?.filter(t => t.status === 'todo').length || 0,
    in_progress: project?.tasks?.filter(t => t.status === 'in_progress').length || 0,
    done: project?.tasks?.filter(t => t.status === 'done').length || 0,
  };

  const totalTasks = tasksStats.todo + tasksStats.in_progress + tasksStats.done;
  const completionRate = totalTasks > 0 ? Math.round((tasksStats.done / totalTasks) * 100) : 0;

  return (
    <PrivateRoute>
      <div className="min-h-screen bg-gradient-to-br from-purple-50 via-pink-50 to-blue-50">
        {/* Navigation */}
        <nav className="bg-white/80 border-b border-purple-100 sticky top-0 z-50 backdrop-blur-xl shadow-sm">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex justify-between items-center h-16">
              <div className="flex items-center space-x-4">
                <Link href="/projects" className="text-purple-600 hover:text-purple-900 flex items-center group font-semibold">
                  <svg className="w-5 h-5 mr-1 transform group-hover:-translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                  </svg>
                  Back to Projects
                </Link>
                <div className="flex items-center space-x-2">
                  <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-purple-600 via-pink-600 to-blue-600 flex items-center justify-center shadow-md">
                    <svg className="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                  </div>
                  <span className="text-lg font-bold bg-gradient-to-r from-purple-600 to-pink-600 bg-clip-text text-transparent">TaskCollab Pro</span>
                </div>
              </div>
              <div className="flex items-center space-x-4">
                <div className="hidden sm:flex items-center space-x-2 px-3 py-2 rounded-xl bg-gradient-to-br from-purple-100 to-pink-100">
                  <div className="w-8 h-8 rounded-full bg-gradient-to-br from-purple-600 via-pink-600 to-blue-600 flex items-center justify-center text-white font-semibold text-sm shadow-md">
                    {user?.first_name?.[0]}{user?.last_name?.[0]}
                  </div>
                  <div className="text-sm">
                    <div className="font-medium text-gray-900">{user?.full_name}</div>
                    <div className="text-purple-600 text-xs font-medium">{user?.role}</div>
                  </div>
                </div>
                <button onClick={handleLogout} className="px-4 py-2 text-sm font-medium text-gray-700 hover:text-gray-900 hover:bg-purple-50 rounded-lg transition-colors">
                  Logout
                </button>
              </div>
            </div>
          </div>
        </nav>

        <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          {isLoading ? (
            <div className="flex items-center justify-center py-20">
              <div className="relative">
                <div className="animate-spin rounded-full h-16 w-16 border-b-4 border-purple-600"></div>
                <div className="absolute top-0 left-0 animate-spin rounded-full h-16 w-16 border-t-4 border-pink-600 animate-pulse"></div>
              </div>
            </div>
          ) : project ? (
            <>
              {/* Project Header */}
              <div className="bg-white/70 backdrop-blur-lg rounded-2xl shadow-xl border border-purple-100 p-8 mb-6">
                <div className="flex items-start justify-between mb-4">
                  <div className="flex-1">
                    <h1 className="text-4xl font-bold bg-gradient-to-r from-purple-600 via-pink-600 to-blue-600 bg-clip-text text-transparent mb-3">{project.name}</h1>
                    <p className="text-gray-700 text-lg">{project.description}</p>
                  </div>
                  <div className="ml-4 flex items-center space-x-3">
                    <button
                      onClick={() => setIsProjectEditModalOpen(true)}
                      className="px-4 py-2 bg-white border-2 border-purple-300 text-purple-600 rounded-lg hover:bg-purple-50 transition-all shadow-sm hover:shadow-md font-semibold flex items-center space-x-2"
                    >
                      <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                      </svg>
                      <span>Edit</span>
                    </button>
                    <span className={`inline-flex items-center px-5 py-2 rounded-full text-sm font-bold border-2 ${
                    project.status === 'active'
                      ? 'bg-green-50 text-green-700 border-green-300 shadow-lg shadow-green-500/30'
                      : 'bg-gray-50 text-gray-700 border-gray-300'
                  }`}>
                    <span className={`w-2.5 h-2.5 mr-2 rounded-full ${
                      project.status === 'active' ? 'bg-green-600 animate-pulse' : 'bg-gray-600'
                    }`}></span>
                    {project.status}
                  </span>
                  </div>
                </div>
                <div className="flex items-center text-sm text-gray-600 space-x-4">
                  <div className="flex items-center bg-purple-100 px-3 py-1.5 rounded-lg">
                    <svg className="w-4 h-4 mr-1.5 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                    </svg>
                    <span className="font-semibold text-purple-900">
                      Created {new Date(project.created_at).toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' })}
                    </span>
                  </div>
                </div>
              </div>

              {/* Stats Grid */}
              <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-6">
                <div className="bg-white/70 backdrop-blur-lg rounded-2xl shadow-lg border border-purple-100 p-6 hover:shadow-xl transition-all hover:-translate-y-1">
                  <div className="flex items-center justify-between mb-4">
                    <h3 className="text-sm font-bold text-purple-600 uppercase">Total Tasks</h3>
                    <div className="w-12 h-12 bg-gradient-to-br from-purple-500 to-pink-600 rounded-xl flex items-center justify-center shadow-lg shadow-purple-500/50">
                      <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                      </svg>
                    </div>
                  </div>
                  <p className="text-3xl font-bold text-gray-900">{totalTasks}</p>
                </div>

                <div className="bg-white/70 backdrop-blur-lg rounded-2xl shadow-lg border border-gray-100 p-6 hover:shadow-xl transition-all hover:-translate-y-1">
                  <div className="flex items-center justify-between mb-4">
                    <h3 className="text-sm font-bold text-gray-600 uppercase">To Do</h3>
                    <div className="w-12 h-12 bg-gray-100 rounded-xl flex items-center justify-center">
                      <span className="text-xl font-bold text-gray-700">{tasksStats.todo}</span>
                    </div>
                  </div>
                  <div className="w-full bg-gray-200 rounded-full h-3">
                    <div className="bg-gray-600 h-3 rounded-full transition-all duration-500" style={{width: `${totalTasks > 0 ? (tasksStats.todo/totalTasks)*100 : 0}%`}}></div>
                  </div>
                </div>

                <div className="bg-white/70 backdrop-blur-lg rounded-2xl shadow-lg border border-blue-100 p-6 hover:shadow-xl transition-all hover:-translate-y-1">
                  <div className="flex items-center justify-between mb-4">
                    <h3 className="text-sm font-bold text-blue-600 uppercase">In Progress</h3>
                    <div className="w-12 h-12 bg-blue-100 rounded-xl flex items-center justify-center">
                      <span className="text-xl font-bold text-blue-700">{tasksStats.in_progress}</span>
                    </div>
                  </div>
                  <div className="w-full bg-gray-200 rounded-full h-3">
                    <div className="bg-gradient-to-r from-blue-500 to-blue-600 h-3 rounded-full transition-all duration-500" style={{width: `${totalTasks > 0 ? (tasksStats.in_progress/totalTasks)*100 : 0}%`}}></div>
                  </div>
                </div>

                <div className="bg-white/70 backdrop-blur-lg rounded-2xl shadow-lg border border-green-100 p-6 hover:shadow-xl transition-all hover:-translate-y-1">
                  <div className="flex items-center justify-between mb-4">
                    <h3 className="text-sm font-bold text-green-600 uppercase">Completed</h3>
                    <div className="w-12 h-12 bg-green-100 rounded-xl flex items-center justify-center">
                      <span className="text-xl font-bold text-green-700">{tasksStats.done}</span>
                    </div>
                  </div>
                  <div className="w-full bg-gray-200 rounded-full h-3">
                    <div className="bg-gradient-to-r from-green-500 to-emerald-600 h-3 rounded-full transition-all duration-500" style={{width: `${completionRate}%`}}></div>
                  </div>
                </div>
              </div>

              {/* Tasks Table */}
              <div className="bg-white/70 backdrop-blur-lg rounded-2xl shadow-xl border border-purple-100 overflow-hidden">
                <div className="px-6 py-5 border-b border-purple-100 flex items-center justify-between bg-gradient-to-r from-purple-50/50 to-pink-50/50">
                  <div>
                    <h2 className="text-2xl font-bold bg-gradient-to-r from-purple-600 to-pink-600 bg-clip-text text-transparent">Tasks</h2>
                    <p className="mt-1 text-sm text-gray-600">Manage project tasks and track progress</p>
                  </div>
                  <button
                    onClick={() => setIsTaskModalOpen(true)}
                    className="px-5 py-2.5 bg-gradient-to-r from-purple-600 via-pink-600 to-blue-600 text-white rounded-xl hover:from-purple-700 hover:via-pink-700 hover:to-blue-700 transition-all shadow-lg shadow-purple-500/50 font-semibold flex items-center space-x-2 hover:shadow-xl hover:-translate-y-0.5 duration-300"
                  >
                    <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
                    </svg>
                    <span>Add Task</span>
                  </button>
                </div>

                <div className="overflow-x-auto">
                  {project.tasks && project.tasks.length > 0 ? (
                    <>
                      <table className="min-w-full divide-y divide-purple-100">
                        <thead className="bg-gradient-to-r from-purple-50 to-pink-50">
                          <tr>
                            <th className="px-6 py-4 text-left text-xs font-bold text-purple-600 uppercase tracking-wider">Task</th>
                            <th className="px-6 py-4 text-left text-xs font-bold text-purple-600 uppercase tracking-wider">Status</th>
                            <th className="px-6 py-4 text-left text-xs font-bold text-purple-600 uppercase tracking-wider">Priority</th>
                            <th className="px-6 py-4 text-left text-xs font-bold text-purple-600 uppercase tracking-wider">Assignee</th>
                            <th className="px-6 py-4 text-left text-xs font-bold text-purple-600 uppercase tracking-wider">Due Date</th>
                          </tr>
                        </thead>
                        <tbody className="bg-white/50 divide-y divide-purple-100">
                          {paginatedTasks.map((task: Task) => (
                            <tr
                              key={task.id}
                              onClick={() => handleTaskClick(task)}
                              className="hover:bg-purple-50/50 transition-colors cursor-pointer"
                            >
                              <td className="px-6 py-4">
                                <div className="flex items-start">
                                  <input type="checkbox" checked={task.status === 'done'} readOnly className="mt-1 w-5 h-5 text-purple-600 border-gray-300 rounded focus:ring-purple-500" />
                                  <div className="ml-3">
                                    <div className={`text-sm font-bold ${task.status === 'done' ? 'text-gray-500 line-through' : 'text-gray-900'}`}>
                                      {task.title}
                                    </div>
                                    <div className="text-sm text-gray-600 mt-1">{task.description}</div>
                                  </div>
                                </div>
                              </td>
                              <td className="px-6 py-4 whitespace-nowrap">
                                <span className={`inline-flex items-center px-3 py-1 rounded-full text-xs font-bold border ${getStatusColor(task.status)}`}>
                                  {task.status.replace('_', ' ')}
                                </span>
                              </td>
                              <td className="px-6 py-4 whitespace-nowrap">
                                <span className={`inline-flex items-center px-3 py-1 rounded-full text-xs font-bold border ${getPriorityColor(task.priority)}`}>
                                  {task.priority}
                                </span>
                              </td>
                              <td className="px-6 py-4 whitespace-nowrap">
                                <div className="flex items-center">
                                  <div className="flex-shrink-0 h-9 w-9 rounded-full bg-gradient-to-br from-purple-600 via-pink-600 to-blue-600 flex items-center justify-center text-white text-xs font-bold shadow-md">
                                    {task.assignee?.first_name?.[0]}{task.assignee?.last_name?.[0]}
                                  </div>
                                  <div className="ml-3">
                                    <div className="text-sm font-semibold text-gray-900">{task.assignee?.full_name || 'Unassigned'}</div>
                                  </div>
                                </div>
                              </td>
                              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600 font-medium">
                                {task.due_date ? new Date(task.due_date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' }) : '-'}
                              </td>
                            </tr>
                          ))}
                        </tbody>
                      </table>

                      {/* Pagination Controls */}
                      {totalPages > 1 && (
                        <div className="px-6 py-4 border-t border-purple-100 flex items-center justify-between bg-gradient-to-r from-purple-50/30 to-pink-50/30">
                          <div className="text-sm text-gray-600">
                            Showing <span className="font-semibold text-purple-600">{startIndex + 1}</span> to <span className="font-semibold text-purple-600">{Math.min(endIndex, totalTasksCount)}</span> of <span className="font-semibold text-purple-600">{totalTasksCount}</span> tasks
                          </div>
                          <div className="flex items-center space-x-2">
                            <button
                              onClick={() => setCurrentPage(p => Math.max(1, p - 1))}
                              disabled={currentPage === 1}
                              className="px-3 py-2 text-sm font-medium rounded-lg border border-purple-200 text-purple-600 hover:bg-purple-50 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                            >
                              Previous
                            </button>
                            <div className="flex items-center space-x-1">
                              {Array.from({ length: totalPages }, (_, i) => i + 1).map(page => (
                                <button
                                  key={page}
                                  onClick={() => setCurrentPage(page)}
                                  className={`px-3 py-2 text-sm font-medium rounded-lg transition-colors ${
                                    currentPage === page
                                      ? 'bg-gradient-to-r from-purple-600 to-pink-600 text-white shadow-lg'
                                      : 'border border-purple-200 text-purple-600 hover:bg-purple-50'
                                  }`}
                                >
                                  {page}
                                </button>
                              ))}
                            </div>
                            <button
                              onClick={() => setCurrentPage(p => Math.min(totalPages, p + 1))}
                              disabled={currentPage === totalPages}
                              className="px-3 py-2 text-sm font-medium rounded-lg border border-purple-200 text-purple-600 hover:bg-purple-50 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                            >
                              Next
                            </button>
                          </div>
                        </div>
                      )}
                    </>
                  ) : (
                    <div className="text-center py-16 bg-gradient-to-br from-purple-50/30 to-pink-50/30">
                      <svg className="mx-auto h-16 w-16 text-purple-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                      </svg>
                      <p className="mt-4 text-lg font-semibold text-gray-600">No tasks yet</p>
                      <p className="mt-2 text-sm text-gray-500">Create your first task to get started!</p>
                      <button
                        onClick={() => setIsTaskModalOpen(true)}
                        className="mt-4 px-6 py-3 bg-gradient-to-r from-purple-600 to-pink-600 text-white rounded-xl hover:from-purple-700 hover:to-pink-700 transition-all shadow-lg font-semibold"
                      >
                        Create First Task
                      </button>
                    </div>
                  )}
                </div>
              </div>
            </>
          ) : (
            <div className="text-center py-20">
              <p className="text-gray-500 text-lg">Project not found</p>
            </div>
          )}
        </main>
      </div>

      <TaskModal
        isOpen={isTaskModalOpen}
        onClose={() => setIsTaskModalOpen(false)}
        projectId={id}
        projectMembers={project?.members || []}
        onTaskCreated={() => {
          refetch();
        }}
      />

      <TaskEditModal
        isOpen={isEditModalOpen}
        onClose={() => {
          setIsEditModalOpen(false);
          setSelectedTask(null);
        }}
        task={selectedTask}
        projectId={id}
        projectMembers={project?.members || []}
        onTaskUpdated={() => {
          refetch();
        }}
      />

      <ProjectEditModal
        isOpen={isProjectEditModalOpen}
        onClose={() => setIsProjectEditModalOpen(false)}
        project={project || null}
        onProjectUpdated={() => {
          refetch();
        }}
      />
    </PrivateRoute>
  );
}
