'use client';

import { useState } from 'react';
import ProjectModal from '@/components/ProjectModal';
import TaskModal from '@/components/TaskModal';

export default function TestModalsPage() {
  const [isProjectModalOpen, setIsProjectModalOpen] = useState(false);
  const [isTaskModalOpen, setIsTaskModalOpen] = useState(false);

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 to-pink-50 p-8">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-4xl font-bold mb-8 bg-gradient-to-r from-purple-600 to-pink-600 bg-clip-text text-transparent">
          Modal Testing Page
        </h1>

        <div className="bg-white rounded-2xl shadow-xl p-8 space-y-6">
          <div>
            <h2 className="text-2xl font-bold mb-4 text-gray-900">Project Modal Test</h2>
            <button
              onClick={() => {
                console.log('Project button clicked!');
                setIsProjectModalOpen(true);
              }}
              className="px-6 py-3 bg-gradient-to-r from-purple-600 to-blue-600 text-white rounded-lg font-semibold hover:from-purple-700 hover:to-blue-700 transition-all shadow-lg"
            >
              Open Project Modal
            </button>
            <p className="mt-2 text-sm text-gray-600">
              Modal State: {isProjectModalOpen ? 'OPEN' : 'CLOSED'}
            </p>
          </div>

          <div className="border-t pt-6">
            <h2 className="text-2xl font-bold mb-4 text-gray-900">Task Modal Test</h2>
            <button
              onClick={() => {
                console.log('Task button clicked!');
                setIsTaskModalOpen(true);
              }}
              className="px-6 py-3 bg-gradient-to-r from-blue-600 to-indigo-600 text-white rounded-lg font-semibold hover:from-blue-700 hover:to-indigo-700 transition-all shadow-lg"
            >
              Open Task Modal
            </button>
            <p className="mt-2 text-sm text-gray-600">
              Modal State: {isTaskModalOpen ? 'OPEN' : 'CLOSED'}
            </p>
          </div>

          <div className="border-t pt-6">
            <h3 className="text-lg font-bold mb-2 text-gray-900">Instructions:</h3>
            <ol className="list-decimal list-inside space-y-2 text-gray-700">
              <li>Click the button above to open the modal</li>
              <li>Check if the modal appears</li>
              <li>Try to submit the form (it will fail but should show errors)</li>
              <li>Click the backdrop or X button to close</li>
              <li>Open browser console (F12) to see debug messages</li>
            </ol>
          </div>
        </div>
      </div>

      <ProjectModal
        isOpen={isProjectModalOpen}
        onClose={() => {
          console.log('Closing project modal');
          setIsProjectModalOpen(false);
        }}
        onProjectCreated={() => {
          console.log('Project created callback');
          alert('Project created successfully!');
        }}
      />

      <TaskModal
        isOpen={isTaskModalOpen}
        onClose={() => {
          console.log('Closing task modal');
          setIsTaskModalOpen(false);
        }}
        projectId="1"
        onTaskCreated={() => {
          console.log('Task created callback');
          alert('Task created successfully!');
        }}
      />
    </div>
  );
}
