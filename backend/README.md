# SwiftRide Backend — Django REST API

## Stack
- Python 3.11+
- Django 4.2 + Django REST Framework
- PostgreSQL 15+
- Redis (caching + WebSockets via Django Channels)
- JWT Authentication (SimpleJWT)

## Quick Start

### 1. Clone & install
```bash
cd swiftride_backend
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Environment
```bash
cp .env.example .env
# Edit .env with your DB credentials
```

### 3. PostgreSQL setup
```sql
CREATE DATABASE swiftride_db;
CREATE USER swiftride_user WITH PASSWORD 'your-password';
GRANT ALL PRIVILEGES ON DATABASE swiftride_db TO swiftride_user;
```

### 4. Migrate & run
```bash
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver
```

### 5. API Docs
Visit: http://localhost:8000/api/docs/

---

## API Endpoints

### Auth
| Method | URL | Description |
|--------|-----|-------------|
| POST | /api/auth/register/ | Register new user |
| POST | /api/auth/login/ | Login → returns JWT tokens |
| POST | /api/auth/logout/ | Blacklist refresh token |
| POST | /api/auth/token/refresh/ | Refresh access token |
| GET/PUT | /api/auth/profile/ | View/update own profile |
| POST | /api/auth/change-password/ | Change password |

### Cars
| Method | URL | Description |
|--------|-----|-------------|
| GET | /api/cars/ | List available cars (public) |
| GET | /api/cars/?category=SUV&min_price=30&max_price=100 | Filter cars |
| GET | /api/cars/{id}/ | Car detail |
| GET/POST | /api/cars/fleet/ | Company fleet management |
| GET/PUT/DELETE | /api/cars/fleet/{id}/ | Manage specific car |
| POST | /api/cars/{id}/favorite/ | Toggle favorite |

### Bookings
| Method | URL | Description |
|--------|-----|-------------|
| POST | /api/bookings/ | Create booking |
| GET | /api/bookings/mine/ | My bookings |
| GET | /api/bookings/{id}/ | Booking detail |
| POST | /api/bookings/{id}/cancel/ | Cancel booking |
| GET | /api/bookings/company/ | Company bookings |
| POST | /api/bookings/company/{id}/status/ | Update booking status |

### Chat
| Method | URL | Description |
|--------|-----|-------------|
| GET/POST | /api/chat/ | List/start conversations |
| GET/POST | /api/chat/{id}/messages/ | Messages in conversation |
| WS | ws://localhost:8000/ws/chat/{convo_id}/ | Real-time chat |

### Wallet
| Method | URL | Description |
|--------|-----|-------------|
| GET | /api/wallet/ | My wallet balance |
| GET | /api/wallet/transactions/ | Transaction history |
| POST | /api/wallet/transfer/ | Transfer to another wallet |
| POST | /api/wallet/withdraw/ | Withdraw funds |

---

## User Roles
| Role | Permissions |
|------|-------------|
| customer | Browse cars, create bookings, chat, wallet, reviews |
| company_staff | View company bookings, update status, manage fleet |
| company_admin | Full company management + staff management |
| super_admin | Full platform access, approve/suspend companies |

## DB Relationships
- User → Company (FK, staff/admin belong to a company)
- Company → Car (FK, one-to-many)
- Car → Booking (FK, one-to-many)
- Booking → User (customer FK)
- Booking → Review (OneToOne)
- Conversation → User + Company (FK)
- Wallet → User OR Company (OneToOne each, constrained)
- AuditLog → User (actor FK)
