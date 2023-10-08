# Flutter Task Manager App

This is a simple Flutter task manager app that allows you to manage your tasks by marking them as pending or completed. You can add tasks with titles, descriptions, and due dates. It uses the Provider package for state management and follows the Material Design guidelines.

### Prerequisites

Before you begin, ensure you have Flutter and Dart installed on your development machine. You can install them by following the [official Flutter installation guide](https://flutter.dev/docs/get-started/install).

### Installation

1. Clone this repository or download the project files to your local machine.

   ```bash
   git clone <repository-url>
   ```

2. Navigate to the project directory.

   ```bash
   cd ~/path/to/directory
   ```

3. Run the app on an emulator or a physical device.

   ```bash
   export PATH="$PATH:`pwd`/flutter/bin"
   ```

   ```bash
   flutter run
   ```

### Features

 - Task Management: Add, complete, and mark tasks as incomplete.
 - Task Categories: View pending and completed tasks separately.
 - Due Dates: Assign due dates to tasks for better organization.

### How to Use

When you launch the app, you'll see a navigation rail with two categories: "Pending Tasks" and "Completed."

To add a new task, click the floating action button (add icon) when viewing "Pending Tasks." You can enter the task title, description, and due date.

To select a due date for a task, click the "Select Due Date" button when adding a task. Choose a date from the date picker.

Click "Add" to add the task to your pending tasks list.

Click on "Pending Tasks" to view your pending tasks. You can mark a task as completed by checking the checkbox. This will make it appear in the "Completed" page.

Click on "Completed" to view your completed tasks. You can mark a task as incomplete by clicking the close icon. This will cause it to go back to "Pending Tasks" page.


### Dependencies (included in pubspec.yaml)

 - flutter
 - provider
 - intl


### Contributors
Carlo Pastor Montrucchio