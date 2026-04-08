# CookingShare 

A full-stack application for sharing and discovering cooking recipes with features like user authentication, recipe management, ratings, and comments.

## Project Overview

CookingShare is a modern, scalable application built with **Flutter** for the frontend and **Node.js** for the backend. Users can create, share, and rate cooking recipes with images and videos.

## Tech Stack

### Frontend
- **Framework:** Flutter 3.1.5+
- **State Management:** Provider
- **HTTP Client:** HTTP
- **Storage:** SharedPreferences, Flutter Secure Storage
- **Media:** Image Picker, Video Player, Chewie
- **UI:** Google Fonts, Font Awesome Flutter, Shimmer

### Backend
- **Runtime:** Node.js
- **Framework:** Express.js 5.1.0
- **Database:** MongoDB with Mongoose
- **Authentication:** JWT (JSON Web Tokens)
- **File Upload:** Multer
- **Security:** Bcrypt, CORS
- **Environment:** Dotenv

## Features

### Core Features
- User Authentication (Signup/Login/Logout)
- JWT-based Authorization
- Create, Read, Update, Delete Recipes
- Recipe Search & Filter
- Image & Video Upload
- Rating System
- Comments & Reactions
- User Profiles

## Getting Started

### Prerequisites

- **Backend:** Node.js >= 14, MongoDB
- **Frontend:** Flutter SDK >= 3.1.5

### Installation

#### Backend Setup
```bash
cd cookingsharebe
npm install
```

Create `.env` file:
```env
MONGO_URI=mongodb://localhost:27017/cookingshare
JWT_SECRET=your_jwt_secret_key
REFRESH_TOKEN_SECRET=your_refresh_token_secret
PORT=5000
```

Run backend:
```bash
npm run dev
```

#### Frontend Setup
```bash
cd cookingsharefe
flutter pub get
```

Run frontend:
```bash
flutter run
```

## Project Structure

```
CookingShare/
├── cookingsharebe/          # Backend API
│   ├── app.js              # Express app setup
│   ├── package.json        # Dependencies
│   ├── config/             # Database configuration
│   ├── controllers/        # Business logic
│   ├── models/             # Database schemas
│   ├── routes/             # API endpoints
│   ├── middleware/         # Authentication, file upload
│   └── assets/             # Images & videos
│
└── cookingsharefe/         # Flutter app
    ├── lib/
    │   ├── main.dart       # App entry point
    │   ├── config/         # App configuration
    │   ├── core/           # Core utilities
    │   └── features/       # Feature modules
    ├── assets/             # Images & icons
    └── pubspec.yaml        # Dependencies
```

## Documentation

- **Backend Documentation:** [cookingsharebe/README.md](./cookingsharebe/README.md)
- **Frontend Documentation:** [cookingsharefe/README.md](./cookingsharefe/README.md)

## Author

**Phùng Thế Vinh**
- Student ID: 4451051043

## License

This project is licensed under the ISC License.

## Acknowledgments

- Flutter documentation and community
- Express.js documentation
- MongoDB documentation
