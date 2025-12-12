'use client';

import { useState, useEffect } from 'react';
import apiClient from '@/lib/api';
import { Project } from '@/types';

interface ProjectEditModalProps {
  isOpen: boolean;
  onClose: () => void;
  project: Project | null;
  onProjectUpdated: () => void;
}

export default function ProjectEditModal({ isOpen, onClose, project, onProjectUpdated }: ProjectEditModalProps) {
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    status: 'active',
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    if (project) {
      setFormData({
        name: project.name,
        description: project.description || '',
        status: project.status,
      });
    }
  }, [project]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      const response = await apiClient.put(`/projects/${project?.id}`, {
        project: formData,
      });
      console.log('Project updated successfully:', response.data);
      onProjectUpdated();
      onClose();
    } catch (err: any) {
      console.error('Project update error:', err);
      const errorMessage = err.response?.data?.errors?.join(', ') ||
                          err.response?.data?.error ||
                          'Failed to update project';
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async () => {
    if (!confirm('Are you sure you want to delete this project? This action cannot be undone.')) {
      return;
    }

    setError('');
    setLoading(true);

    try {
      await apiClient.delete(`/projects/${project?.id}`);
      console.log('Project deleted successfully');
      onProjectUpdated();
      onClose();
    } catch (err: any) {
      console.error('Project deletion error:', err);
      const errorMessage = err.response?.data?.error || 'Failed to delete project';
      setError(errorMessage);
      setLoading(false);
    }
  };

  if (!isOpen || !project) return null;

  return (
    <div className="fixed inset-0 z-50 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
      <div className="flex items-center justify-center min-h-screen px-4 pt-4 pb-20 text-center sm:block sm:p-0">
        <div className="fixed inset-0 bg-gray-900 bg-opacity-75 backdrop-blur-sm transition-opacity" onClick={onClose} aria-hidden="true"></div>

        <span className="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">&#8203;</span>

        <div className="inline-block align-bottom bg-white rounded-2xl text-left overflow-hidden shadow-2xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full relative z-10">
          <div className="bg-gradient-to-r from-purple-600 via-blue-600 to-indigo-600 px-6 py-5">
            <div className="flex items-center justify-between">
              <h3 className="text-xl font-bold text-white flex items-center">
                <svg className="w-7 h-7 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                </svg>
                Edit Project
              </h3>
              <button onClick={onClose} className="text-white hover:text-gray-200 transition-colors">
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
          </div>

          <form onSubmit={handleSubmit} className="bg-white px-6 py-6">
            {error && (
              <div className="mb-4 bg-red-50 border-l-4 border-red-500 text-red-700 px-4 py-3 rounded">
                <p className="text-sm">{error}</p>
              </div>
            )}

            <div className="space-y-5">
              <div>
                <label htmlFor="name" className="block text-sm font-semibold text-gray-700 mb-2">
                  Project Name *
                </label>
                <input
                  type="text"
                  id="name"
                  required
                  value={formData.name}
                  onChange={(e) => setFormData({...formData, name: e.target.value})}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                  placeholder="Enter project name"
                />
              </div>

              <div>
                <label htmlFor="description" className="block text-sm font-semibold text-gray-700 mb-2">
                  Description
                </label>
                <textarea
                  id="description"
                  rows={4}
                  value={formData.description}
                  onChange={(e) => setFormData({...formData, description: e.target.value})}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent transition resize-none"
                  placeholder="Describe your project..."
                />
              </div>

              <div>
                <label htmlFor="status" className="block text-sm font-semibold text-gray-700 mb-2">
                  Status
                </label>
                <select
                  id="status"
                  value={formData.status}
                  onChange={(e) => setFormData({...formData, status: e.target.value})}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                >
                  <option value="active">Active</option>
                  <option value="archived">Archived</option>
                  <option value="completed">Completed</option>
                </select>
              </div>
            </div>

            <div className="mt-8 flex items-center justify-between gap-3">
              <button
                type="button"
                onClick={handleDelete}
                disabled={loading}
                className="px-5 py-2.5 bg-red-50 text-red-600 rounded-lg hover:bg-red-100 transition-colors font-semibold disabled:opacity-50 disabled:cursor-not-allowed flex items-center space-x-2"
              >
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                </svg>
                <span>Delete</span>
              </button>

              <div className="flex gap-3">
                <button
                  type="button"
                  onClick={onClose}
                  className="px-5 py-2.5 border-2 border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors font-semibold"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={loading}
                  className="px-5 py-2.5 bg-gradient-to-r from-purple-600 to-blue-600 text-white rounded-lg hover:from-purple-700 hover:to-blue-700 transition-all shadow-lg disabled:opacity-50 disabled:cursor-not-allowed font-semibold flex items-center space-x-2"
                >
                  {loading ? (
                    <>
                      <svg className="animate-spin h-5 w-5" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                        <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                        <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                      </svg>
                      <span>Updating...</span>
                    </>
                  ) : (
                    <>
                      <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                      </svg>
                      <span>Update Project</span>
                    </>
                  )}
                </button>
              </div>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}
