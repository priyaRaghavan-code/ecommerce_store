# E-Commerce Store (Rails + Redis)

A simple e-commerce application built using **Ruby on Rails** with **Redis as an in-memory store**.

This project focuses on cart handling, checkout flow, automatic discounts on every *Nth* order, and a small admin dashboard — without using a database.

---

## Features

### User Features
- View products on the home page
- Add and remove items from the cart
- View cart subtotal
- Checkout and place an order
- **Every Nth order gets a 10% discount**
- Discount is applied automatically on the **same order**
- Order success page displays:
  - Order number
  - Discount applied
  - Final amount paid

### Admin Features
- Admin dashboard API showing:
  - Total items purchased
  - Total purchase amount
  - Total discount amount
  - List of generated discount codes

---

## Discount Logic

- Default rule: **Every 5th order**
- Discount percentage: **10%**
- On every Nth order:
  - A coupon code is generated
  - Discount is applied automatically during checkout
- No manual coupon entry is required

---

## Tech Stack

- Ruby on Rails
- Redis (in-memory store)
- ERB views
- RSpec (optional / can be added later)

---

## Running the Application

### Prerequisites
- Ruby
- Rails
- Redis

### Start Redis
```bash
redis-server
```

### Start Rails
```bash
bundle install
rails server
```

---

## Important Routes

```
GET  /                 → Products page
GET  /cart             → View cart
POST /checkout         → Place order
GET  /checkout/success → Order success page

GET  /admin/dashboard  → Admin dashboard (protected)
```

---

## Admin Access

Admin APIs require the following request header:

```
X-ADMIN-KEY: secret
```

Example request:

```
GET /admin/dashboard
```

```
POST /admin/coupons
```

---

## Data Storage

- No database is used
- All data is stored in Redis:
  - Cart data
  - Order count
  - Discount metrics
  - Admin dashboard aggregates