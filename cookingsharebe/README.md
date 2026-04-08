# CookingShare Backend API 

RESTful API backend for the CookingShare application built with Express.js and MongoDB.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Running the Server](#running-the-server)
- [API Endpoints](#api-endpoints)
- [Project Structure](#project-structure)
- [Technologies Used](#technologies-used)

## Prerequisites

- Node.js >= 14.x
- MongoDB (local or Atlas)
- npm or yarn

## Installation

Clone and install dependencies:

```bash
cd cookingsharebe
npm install
```

## Configuration

Create a `.env` file in the root directory:

```env
# Database
MONGO_URI=mongodb://localhost:27017/cookingshare

# JWT Secrets
JWT_SECRET=your_jwt_secret_key_here
REFRESH_TOKEN_SECRET=your_refresh_token_secret_here

# Server
PORT=5000
NODE_ENV=development
```

## Running the Server

### Development Mode (with auto-restart)
```bash
npm run dev
```

### Production Mode
```bash
npm start
```

The server will run on `http://localhost:5000`

## API Endpoints

### Authentication Routes (`/api/auth`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/signup` | Register new user | No |
| POST | `/login` | User login | No |
| POST | `/logout` | User logout | Yes |

**Example Request - Signup:**
```bash
POST /api/auth/signup
Content-Type: application/json

{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "password123"
}
```

---

### Recipe Routes (`/api/recipes`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/` | Create new recipe | Yes |
| GET | `/` | Get all recipes | No |
| GET | `/search` | Search recipes | No |
| GET | `/:id` | Get recipe details | Yes |
| PUT | `/:id` | Update recipe | Yes |
| DELETE | `/:id` | Delete recipe | Yes |
| POST | `/:id/reaction` | Add reaction to recipe | Yes |
| POST | `/:id/comment` | Add comment to recipe | Yes |

**Example Request - Create Recipe:**
```bash
POST /api/recipes
Content-Type: multipart/form-data
Authorization: Bearer <token>

{
  "title": "Chocolate Cake",
  "description": "Delicious homemade chocolate cake",
  "ingredients": ["2 cups flour", "1 cup sugar", "1 cup butter"],
  "instructions": ["Mix ingredients", "Bake at 180°C"],
  "tag": ["dessert", "chocolate"],
  "prepTime": "15 mins",
  "cookTime": "30 mins",
  "difficulty": "Easy",
  "image": <file>,
  "video": <file>
}
```

---

### User Routes (`/api/users`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/profile` | Get user profile | Yes |
| PUT | `/profile` | Update user profile | Yes |
| GET | `/:id` | Get user by ID | No |

---

### Rating Routes (`/api/recipes/:id/rating`)

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/` | Add rating to recipe | Yes |
| GET | `/` | Get recipe ratings | No |

## Project Structure

```
cookingsharebe/
├── app.js                    # Express application setup
├── package.json              # Project dependencies
├── .env                      # Environment variables (not in repo)
├── .gitignore               # Git ignore file
│
├── config/
│   └── db.js                # MongoDB connection configuration
│
├── models/
│   ├── User.js              # User schema & model
│   ├── Recipe.js            # Recipe schema & model
│   └── rating.js            # Rating schema & model
│
├── controllers/
│   ├── authController.js    # Authentication logic
│   ├── recipeController.js  # Recipe CRUD operations
│   ├── userController.js    # User management logic
│   └── ratingController.js  # Rating logic
│
├── routes/
│   ├── authRoutes.js        # Auth endpoints
│   ├── recipeRoutes.js      # Recipe endpoints
│   ├── userRoutes.js        # User endpoints
│   └── ratingRoutes.js      # Rating endpoints
│
├── middleware/
│   ├── authMiddleware.js    # JWT verification
│   └── uploadMiddleware.js  # File upload with Multer
│
└── assets/
    ├── img/                 # Uploaded images
    └── video/               # Uploaded videos
```

## Technologies Used

| Technology | Version | Purpose |
|-----------|---------|---------|
| **express** | 5.1.0 | Web framework |
| **mongoose** | Latest | MongoDB ODM |
| **bcrypt** | 5.1.1 | Password hashing |
| **jsonwebtoken** | 9.0.2 | JWT authentication |
| **multer** | 1.4.5-lts.2 | File upload |
| **cors** | 2.8.5 | Cross-origin requests |
| **dotenv** | 16.5.0 | Environment variables |
| **nodemon** | 3.1.10 | Development auto-restart |

## Authentication

The API uses **JWT (JSON Web Tokens)** for authentication.

### How it works:
1. User signs up/logs in
2. Server returns `accessToken` and `refreshToken`
3. Client sends `accessToken` in Authorization header for protected routes
4. Token format: `Authorization: Bearer <token>`

### Protected Routes:
All endpoints marked with require a valid JWT token.

## Request/Response Format

### Success Response
```json
{
  "success": true,
  "message": "Operation successful",
  "data": {
    // Response data
  }
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error message",
  "error": "Error details"
}
```

## Error Handling

- `400` - Bad Request (invalid input)
- `401` - Unauthorized (missing/invalid token)
- `403` - Forbidden (permission denied)
- `404` - Not Found (resource not found)
- `500` - Server Error

## File Upload

Supported file types:
- **Images:** JPG, JPEG, PNG
- **Videos:** MP4

Max file size: 50MB per file

Files are stored in `assets/img/` and `assets/video/` directories.

## Testing APIs

Use tools like:
- **Postman** - GUI API client
- **cURL** - Command line
- **REST Client Extension** - VS Code

Example with cURL:
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123"}'
```

## Troubleshooting

### MongoDB Connection Error
- Ensure MongoDB is running
- Check `MONGO_URI` in `.env`
- Verify MongoDB credentials

### Port Already in Use
```bash
# Change PORT in .env or kill process using port 5000
```

### JWT Token Expired
- Client should use `refreshToken` to get new `accessToken`

## Support

For issues or questions, contact: phungthevinh@example.com

## 📄 License

ISC License
