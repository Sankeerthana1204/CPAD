# ER Model - E-Commerce App (Scoped)

## 1. ER Modeling Scope

The ER model is strictly limited to the approved assignment scope:
- Customer login
- Product listing with search
- Product detail viewing

Out-of-scope concepts are intentionally excluded:
- cart, order, payment, shipping, returns

## 2. Entities and Attributes

### 2.1 Customer

- `customer_id` (PK)
- `full_name`
- `email` (Unique)
- `password_hash`
- `status` (ACTIVE/INACTIVE)
- `created_at`
- `last_login_at`

Constraints:
- `email` must be unique and not null
- `password_hash` must be not null

### 2.2 Product

- `product_id` (PK)
- `name`
- `description`
- `price`
- `image_url`
- `stock_qty`
- `is_active`
- `created_at`
- `updated_at`

Constraints:
- `name` not null
- `price` >= 0
- `stock_qty` >= 0

### 2.3 LoginSession

- `session_id` (PK)
- `customer_id` (FK -> Customer.customer_id)
- `issued_at`
- `expires_at`
- `is_revoked`

Purpose:
- Tracks login sessions for authenticated users

## 3. Relationships and Cardinalities

1. Customer to LoginSession
- Relationship: `Customer` creates `LoginSession`
- Cardinality: 1 to many
- Meaning: One customer can have zero or many sessions over time; each session belongs to exactly one customer.

2. Product is standalone for current scope
- No mandatory relationship to customer in current feature set because purchasing workflow is out of scope.

## 4. Integrity Rules

- Every `LoginSession.customer_id` must reference an existing `Customer.customer_id`
- Delete behavior recommendation: soft-delete customers or restrict deletion when sessions exist
- Only products with `is_active = true` should be shown in dashboard and detail view

## 5. Mapping to Assignment Screens

- Login Screen -> `Customer`, `LoginSession`
- Dashboard (list + search) -> `Product`
- Detail Page -> `Product`
