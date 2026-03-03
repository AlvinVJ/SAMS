# SAMS (Mobile & Web Frontend)

The official cross-platform client for the Student Activity Management System, providing a seamless experience for students, faculty, and administrators.

## ✨ Highlights

- **Admin Workflow Canvas**: A visual builder for creating complex administrative procedures and approval chains.
- **Unified Request Tracking**: Real-time monitoring of request statuses (Pending, Approved, Rejected) with detailed action history.
- **Role-Speific Dashboards**: Customized interfaces for Students, HODs, Class Advisors, and Club Leads.
- **Dynamic Form Engine**: Generates specialized forms on-the-fly based on procedure definitions.
- **Push Notifications**: Integrated alerts for pending actions and status updates via Firebase Cloud Messaging.

## 🛠️ Technology Stack

- **Framework**: Flutter (Dart)
- **Authentication**: Firebase Authentication
- **State Management**: Provider / In-Memory Store
- **Backend Communication**: RESTful API integration with HMAC-based security.

## 📜 Key Implementation Areas

- **Procedure Editor**: Advanced editing suite for modifying live workflows, including system hook triggers and visibility permissions.
- **Faculty Approval Suite**: Streamlined interface for bulk-acting on student requests with context-aware data displays (e.g., student attendance history).
- **Responsive Layouts**: Optimized for both high-density web dashboards and handheld mobile devices.
