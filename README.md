# 🤖 AI Tool Recommender

> **Personalized AI Tool Discovery** — A full-stack recommendation system that helps users find the best AI tools using semantic search, LLM-powered deep search, and personalized hybrid ranking.

![Python](https://img.shields.io/badge/Python-3.10+-3776AB?logo=python&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-0.115-009688?logo=fastapi&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-8.0+-4479A1?logo=mysql&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)

---

## ✨ Features

- **🔍 Semantic Search** — Uses sentence-transformers + FAISS for fast vector similarity search across 500+ AI tools
- **🧠 Deep Search** — LLM-enhanced ranking with Ollama (Qwen / Mistral) for nuanced, context-aware results
- **👤 Personalized Recommendations** — Hybrid scoring combining user preferences, collaborative filtering, and engagement signals
- **⭐ Feedback System** — Like/dislike, 5-star ratings, comments, and bookmarks
- **🔐 JWT Authentication** — Secure user signup/login with token-based auth
- **🎨 Modern UI** — Dark-themed, responsive single-page frontend

---

## 🏗️ Architecture

```
Ai_Tools_Recommenderr/
├── backend/
│   ├── main.py                  # FastAPI application entry point
│   ├── api/
│   │   ├── routes.py            # Core API endpoints (recommend, deep_search, feedback)
│   │   └── auth_routes.py       # Authentication endpoints (signup, login)
│   ├── services/
│   │   ├── recommender.py       # Semantic search + LLM deep search logic
│   │   └── hybrid_recommend.py  # Personalized hybrid scoring engine
│   ├── utils/
│   │   ├── db.py                # MySQL connection pool + data operations
│   │   ├── auth.py              # JWT token creation & validation
│   │   ├── vectorizer.py        # FAISS index + sentence-transformer embeddings
│   │   └── simple_parse.py      # Query parsing utilities
│   └── scripts/
│       └── build_faiss.py       # Rebuild FAISS index from dataset
├── frontend/
│   ├── index.html               # Single-page application
│   └── styles.css               # Dark-themed responsive styles
├── data/
│   ├── raw/                     # Original source dataset
│   └── processed/               # Cleaned CSV datasets
├── models/
│   ├── embeddings.npy           # Precomputed sentence embeddings
│   └── vector_store.faiss       # FAISS vector index
├── requirements.txt             # Python dependencies
└── .env                         # Environment variables (not tracked)
```

---

## 🚀 Getting Started

### Prerequisites

- **Python 3.10+**
- **MySQL 8.0+**
- **Ollama** (for LLM-powered deep search)

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/Ai_Tools_Recommenderr.git
cd Ai_Tools_Recommenderr
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Set Up the Database

Create a MySQL database:

```sql
CREATE DATABASE ai_recommender;
```

Tables (`users`, `user_data`, `feedback`) are auto-created on first run.

### 4. Configure Environment Variables

Create a `.env` file in the project root:

```env
# Database
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=ai_recommender
DB_POOL_SIZE=5

# JWT
JWT_SECRET=your-secret-key-change-in-prod

# Ollama Models
OLLAMA_MODEL=qwen2.5:3b
QUICK_MODEL=mistral:7b-instruct
OLLAMA_TIMEOUT=120
```

### 5. Set Up Ollama (for Deep Search)

```bash
# Install Ollama: https://ollama.com
ollama pull qwen2.5:3b
ollama pull mistral:7b-instruct
```

### 6. Run the Server

```bash
USE_TF=0 USE_TORCH=1 python -m uvicorn backend.main:app --reload --port 8000
```

Open **http://localhost:8000** in your browser.

---

## 📡 API Endpoints

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| `POST` | `/api/recommend` | Semantic + hybrid personalized search | Optional |
| `POST` | `/api/deep_search` | LLM-enhanced deep search | Optional |
| `POST` | `/api/feedback` | Submit like/dislike/rating/bookmark | Required |
| `POST` | `/api/log_event` | Log user interaction events | Required |
| `GET` | `/api/bookmarks` | Get user's bookmarked tools | Required |
| `POST` | `/api/auth/signup` | Register new user | — |
| `POST` | `/api/auth/login` | Login and get JWT token | — |
| `GET` | `/api/health` | Health check | — |

### Example Request

```bash
curl -X POST http://localhost:8000/api/recommend \
  -H "Content-Type: application/json" \
  -d '{"query": "image generator for posters", "top_k": 5}'
```

---

## 🔧 Rebuild FAISS Index

If you update the dataset, rebuild the vector index:

```bash
python -m backend.scripts.build_faiss
```

---

## 🧪 Tech Stack

| Component | Technology |
|-----------|-----------|
| Backend | FastAPI + Uvicorn |
| Database | MySQL (connection pooling) |
| Vector Search | FAISS + sentence-transformers |
| LLM | Ollama (Qwen 2.5, Mistral 7B) |
| Auth | JWT (PyJWT) |
| Frontend | Vanilla HTML/CSS/JS |
| Data Processing | Pandas, NumPy, scikit-learn |

---

## 📄 License

This project is licensed under the MIT License.
